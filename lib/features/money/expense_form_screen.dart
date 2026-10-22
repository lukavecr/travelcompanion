import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/country_info.dart';
import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../core/full_image_screen.dart';
import '../../data/database.dart';
import '../documents/scan_service.dart';
import '../trips/trip_repository.dart';
import 'categories.dart';
import 'expense_repository.dart';
import 'fx_service.dart';
import 'receipt_reader.dart';

class ExpenseFormArgs {
  const ExpenseFormArgs(this.tripId, [this.existing, this.defaultCountry]);
  final String tripId;
  final Expense? existing;
  final String? defaultCountry; // vybraná země z přehledu
}

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, required this.args});
  final ExpenseFormArgs args;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _amount = TextEditingController();
  final _cur = TextEditingController();
  final _country = TextEditingController();
  final _note = TextEditingController();
  final _rate = TextEditingController();

  String _category = 'food';
  DateTime _date = DateTime.now();
  String? _receipt; // cesta k obrázku
  bool _receiptIsNew = false;
  String? _rateMsg;
  bool _curInit = false;
  bool _busy = false;
  bool _saving = false;

  Expense? get _existing => widget.args.existing;

  String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    final e = _existing;
    if (e != null) {
      _amount.text = _num(e.amount);
      _cur.text = e.currency;
      _category = e.category;
      _date = e.spentAt;
      _country.text = e.country ?? '';
      _note.text = e.note ?? '';
      _rate.text = e.fxRate?.toString() ?? '';
      _receipt = (e.receiptPath == null || e.receiptPath!.isEmpty)
          ? null
          : e.receiptPath;
      _curInit = true;
    } else if (widget.args.defaultCountry != null) {
      _country.text = widget.args.defaultCountry!;
    }
  }

  @override
  void dispose() {
    for (final c in [_amount, _cur, _country, _note, _rate]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _mainCurrency() =>
      ref.read(tripProvider(widget.args.tripId)).value?.mainCurrency;

  Future<void> _updateRate() async {
    final main = _mainCurrency();
    final cur = _cur.text.trim().toUpperCase();
    if (main == null || cur.length != 3) return;
    if (cur == main) {
      setState(() {
        _rate.text = '1';
        _rateMsg = null;
      });
      return;
    }
    setState(() => _rateMsg = 'Načítám kurz…');
    final r = await fetchRate(from: cur, to: main, date: _date);
    if (!mounted || _cur.text.trim().toUpperCase() != cur) return;
    setState(() {
      if (r != null) {
        _rate.text = r.toString();
        _rateMsg = 'Kurz ECB: 1 $cur = ${r.toStringAsFixed(4)} $main';
      } else {
        _rate.text = '';
        _rateMsg = 'Kurz se nepodařilo načíst (offline nebo měna není v ECB). '
            'Zadej ho ručně, nebo nech prázdné a doplní se později.';
      }
    });
  }

  Future<void> _scanReceipt() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Vyfotit účtenku'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Vybrat fotku nebo screenshot'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source);
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    final g = await readReceipt(picked.path);
    if (!mounted) return;
    final planned = tripCountries(ref.read(tripProvider(widget.args.tripId)).value);
    final country = _country.text.trim().isNotEmpty
        ? _country.text.trim()
        : matchCountry(g.country, planned);
    final currency = g.currency ?? (country != null ? currencyForCountry(country) : null);
    setState(() {
      _busy = false;
      _receipt = picked.path;
      _receiptIsNew = true;
      if (g.amount != null) _amount.text = _num(g.amount!);
      if (currency != null) _cur.text = currency;
      if (g.date != null) _date = g.date!;
      if (g.category != null) _category = g.category!;
      if (g.merchant != null && _note.text.trim().isEmpty) _note.text = g.merchant!;
      if (country != null && _country.text.trim().isEmpty) _country.text = country;
    });
    if (!mounted) return;
    final found = [
      if (g.amount != null) 'částka ${_num(g.amount!)}',
      if (currency != null) 'měna $currency',
      if (g.date != null) 'datum ${fmtDate(g.date!)}',
      if (g.category != null) 'kategorie',
      if (g.merchant != null) 'název',
      if (country != null) 'země $country',
    ];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(found.isEmpty
          ? 'Z účtenky se nepodařilo nic přečíst, vyplň údaje ručně.'
          : 'Z účtenky přečteno: ${found.join(', ')}. Zkontroluj to.'),
    ));
    _updateRate();
  }

  Future<void> _save() async {
    final amount = parseAmount(_amount.text);
    final cur = _cur.text.trim().toUpperCase();
    final main = _mainCurrency();
    if (amount == null || amount <= 0) {
      _snack('Zadej částku.');
      return;
    }
    if (cur.length != 3 || main == null) {
      _snack('Zadej měnu jako třípísmenný kód, např. EUR.');
      return;
    }
    setState(() => _saving = true);

    double? rate = cur == main ? 1 : parseAmount(_rate.text);
    rate ??= await fetchRate(from: cur, to: main, date: _date);
    final amountMain = rate == null ? null : amount * rate;

    var receipt = _receipt;
    if (receipt != null && _receiptIsNew) receipt = await storeImage(receipt);

    String? clean(TextEditingController c) {
      final t = c.text.trim();
      return t.isEmpty ? null : t;
    }

    // stejná země se stejným pravopisem (Thajsko = thajsko)
    var country = clean(_country);
    if (country != null) {
      final existingList = ref.read(expensesProvider(widget.args.tripId)).value ??
          const <Expense>[];
      final known = <String>[
        ...tripCountries(ref.read(tripProvider(widget.args.tripId)).value),
        for (final x in existingList) (x.country ?? '').trim(),
      ];
      for (final c in known) {
        if (c.isNotEmpty && c.toLowerCase() == country!.toLowerCase()) {
          country = c;
          break;
        }
      }
    }

    final repo = ref.read(expenseRepositoryProvider);
    final e = _existing;
    if (e == null) {
      await repo.addExpense(
        tripId: widget.args.tripId,
        amount: amount,
        currency: cur,
        fxRate: rate,
        amountMain: amountMain,
        category: _category,
        spentAt: _date,
        country: country,
        note: clean(_note),
        receiptPath: receipt,
      );
    } else {
      await repo.updateExpense(
        e.id,
        amount: amount,
        currency: cur,
        fxRate: rate,
        amountMain: amountMain,
        category: _category,
        spentAt: _date,
        country: country,
        note: clean(_note),
        receiptPath: receipt,
      );
    }
    if (!mounted) return;
    context.go('/money');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripProvider(widget.args.tripId)).value;
    final expenses =
        ref.watch(expensesProvider(widget.args.tripId)).value ?? const <Expense>[];

    if (!_curInit && trip != null) {
      _curInit = true;
      // u předvybrané země nabídni měnu, kterou jsi tam použil naposledy
      String? last;
      final dc = widget.args.defaultCountry;
      if (dc != null) {
        for (final e in expenses) {
          if ((e.country ?? '').trim() == dc) {
            last = e.currency;
            break;
          }
        }
      }
      _cur.text = last ?? trip.mainCurrency;
      _rate.text = '1';
      if (last != null && last != trip.mainCurrency) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateRate();
        });
      }
    }
    final main = trip?.mainCurrency ?? 'CZK';
    final cur = _cur.text.trim().toUpperCase();

    final currencies = <String>[
      main,
      for (final c in ['EUR', 'USD', 'THB', 'JPY', 'NZD', 'MXN', 'IDR'])
        if (c != main) c,
    ];
    final countries = <String>[
      ...tripCountries(trip),
      for (final e in expenses)
        if (e.country != null && e.country!.isNotEmpty) e.country!,
    ].toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'Nový výdaj' : 'Upravit výdaj'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
        actions: [
          if (_existing != null)
            IconButton(
              tooltip: 'Smazat',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                if (await confirm(context, 'Smazat výdaj?')) {
                  await ref
                      .read(expenseRepositoryProvider)
                      .deleteExpense(_existing!.id);
                  if (context.mounted) context.go('/money');
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: Text(_receipt == null
                ? 'Naskenovat účtenku (vyplní částku a měnu)'
                : 'Nahradit účtenku'),
            onPressed: _busy ? null : _scanReceipt,
          ),
          if (_receipt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => openFullImage(context, 'Účtenka', _receipt!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_receipt!),
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('Klepnutím zobrazíš celou účtenku')),
                TextButton(
                  onPressed: () => setState(() {
                    _receipt = null;
                    _receiptIsNew = false;
                  }),
                  child: const Text('Odebrat účtenku'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Částka'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _cur,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 3,
                  decoration:
                      const InputDecoration(labelText: 'Měna', counterText: ''),
                  onChanged: (_) {
                    setState(() {});
                    if (_cur.text.trim().length == 3) _updateRate();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              for (final c in currencies)
                ChoiceChip(
                  label: Text(c),
                  selected: cur == c,
                  onSelected: (_) {
                    _cur.text = c;
                    setState(() {});
                    _updateRate();
                  },
                ),
            ],
          ),
          if (cur.length == 3 && cur != main) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Kurz (1 $cur = ? $main)',
                helperText: _rateMsg,
                helperMaxLines: 3,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Kategorie', style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: [
              for (final e in expenseCategories.entries)
                ChoiceChip(
                  avatar: Icon(categoryIcon(e.key), size: 18),
                  label: Text(e.value),
                  selected: _category == e.key,
                  onSelected: (_) => setState(() => _category = e.key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.event),
            label: Text(fmtDate(_date)),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2040),
              );
              if (d != null) {
                setState(() => _date = d);
                _updateRate();
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _country,
            decoration: const InputDecoration(labelText: 'Země (nepovinné)'),
          ),
          if (countries.isNotEmpty)
            Wrap(
              spacing: 6,
              children: [
                for (final c in countries)
                  ActionChip(
                    label: Text(c),
                    onPressed: () => setState(() => _country.text = c),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(labelText: 'Poznámka (nepovinné)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Uložit výdaj'),
          ),
        ],
      ),
    );
  }
}
