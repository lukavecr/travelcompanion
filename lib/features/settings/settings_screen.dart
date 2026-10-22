import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_settings.dart';
import '../../core/dialogs.dart';
import '../../core/format.dart';
import '../../data/database.dart';
import '../money/expense_repository.dart';
import '../reminders/reminder_service.dart';
import '../lock/app_lock.dart';
import '../pro/paywall.dart';
import '../pro/pro_service.dart';
import '../sync/sync_service.dart';
import 'export_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _wiping = false;

  Future<void> _wipe() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Smazat všechna data?'),
        content: const Text(
          'Smaže se v telefonu i v záloze:\n'
          '• cesty a plán\n• místa\n• doklady a jejich fotky\n• výdaje a účtenky\n\n'
          'Zůstane: Vault, tvůj účet a přihlášení.\n\n'
          'Vrátit to nepůjde.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pokračovat'),
          ),
        ],
      ),
    );
    if (first != true || !mounted) return;

    // druhé potvrzení: otisk prstu / obličej / PIN telefonu
    final hasLock = await DeviceAuth.deviceHasLock();
    if (!mounted) return;
    final second = hasLock
        ? await DeviceAuth.confirm('Potvrď smazání všech dat')
        : await confirm(context,
            'Telefon nemá zámek obrazovky, proto se smazání potvrzuje jen tady. Opravdu smazat vše?');
    if (second != true || !mounted) return;

    setState(() => _wiping = true);
    String? error;
    try {
      await ref.read(syncServiceProvider).wipeAllData();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _wiping = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error == null
          ? 'Všechna data jsou smazaná.'
          : 'Smazání se nepovedlo (jsi online?). V telefonu se nic nesmazalo.\n$error'),
    ));
    if (error == null) context.go('/trips');
  }

  Future<void> _deleteAccount() async {
    final err = Theme.of(context).colorScheme.error;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.person_remove),
        title: const Text('Smazat účet?'),
        content: const Text(
          'Smaže se úplně všechno – cesty, místa, doklady, výdaje i celý Vault – '
          'v telefonu i v záloze, a nakonec tvůj účet.\n\nVrátit to nepůjde.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Zrušit')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: err, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Pokračovat'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (await DeviceAuth.deviceHasLock() &&
        !await DeviceAuth.confirm('Potvrď smazání účtu')) {
      return;
    }
    if (!mounted) return;
    final password = await _askPassword();
    if (password == null || !mounted) return;

    setState(() => _wiping = true);
    final error = await ref.read(syncServiceProvider).deleteAccount(password);
    if (!mounted) return;
    setState(() => _wiping = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Účet i všechna data jsou smazané.'),
    ));
    // po smazání se aplikace sama vrátí na přihlášení
  }

  Future<String?> _askPassword() {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Heslo účtu'),
        content: TextField(
          controller: c,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Heslo, kterým se přihlašuješ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Zrušit')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('Smazat účet'),
          ),
        ],
      ),
    );
  }

  // ---------- pomocné ----------

  void _snack(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  /// Výběr jedné možnosti ze seznamu (spodní panel).
  Future<T?> _choose<T>(BuildContext ctx, String title, Map<T, String> options, T current,
      {String? note}) {
    return showModalBottomSheet<T>(
      context: ctx,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(title, style: Theme.of(c).textTheme.titleMedium),
            ),
            if (note != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(note, style: Theme.of(c).textTheme.bodySmall),
              ),
            for (final e in options.entries)
              ListTile(
                title: Text(e.value),
                trailing: e.key == current
                    ? Icon(Icons.check, color: Theme.of(c).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(c, e.key),
              ),
          ],
        ),
      ),
    );
  }

  void _open(String title, List<Widget> Function(BuildContext) children) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ListenableBuilder(
        listenable: Listenable.merge([AppSettings.instance, ProService.instance]),
        builder: (c, _) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: ListView(padding: const EdgeInsets.all(12), children: children(c)),
        ),
      ),
    ));
  }

  Widget _tile(IconData icon, String title, String? value, VoidCallback? onTap,
          {Color? color}) =>
      Card(
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(title, style: color == null ? null : TextStyle(color: color)),
          subtitle: value == null ? null : Text(value),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );

  Widget _header(BuildContext c, String text, {Color? color}) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
        child: Text(text, style: Theme.of(c).textTheme.titleSmall?.copyWith(color: color)),
      );

  // ---------- Účet ----------

  List<Widget> _account(BuildContext c) {
    final st = AppSettings.instance;
    final pro = ProService.instance.isPro;
    final danger = Theme.of(c).colorScheme.error;
    return [
      _tile(
          Icons.workspace_premium,
          pro ? 'Travel Companion Pro – aktivní' : 'Travel Companion Pro',
          pro
              ? 'Bez omezení, se zálohou do cloudu'
              : 'Zdarma: 1 aktivní cesta, 10 dokladů, 30 výdajů, bez zálohy',
          () => openPaywall(c),
          color: pro ? Colors.amber : null),
      _tile(Icons.cloud_outlined, 'Záloha a účet', 'Synchronizace, změna e-mailu, odhlášení',
          () => c.push('/sync')),
      _tile(Icons.lock_clock, 'Zámek aplikace', AppSettings.lockOptions[st.lockAfterSeconds],
          () async {
        final v = await _choose<int>(
            c, 'Kdy aplikaci zamknout po odchodu', AppSettings.lockOptions, st.lockAfterSeconds,
            note: 'Odemyká se otiskem prstu, obličejem nebo PINem telefonu.');
        if (v == null || !c.mounted) return;
        if (v == -1 &&
            !await confirm(c,
                'Bez zámku uvidí tvoje doklady každý, kdo vezme odemčený telefon. Opravdu?')) {
          return;
        }
        await st.setLockAfter(v);
      }),
      _header(c, 'Nebezpečná zóna', color: danger),
      _tile(Icons.person_remove, 'Smazat účet', 'Všechna data včetně Vaultu a účet samotný.',
          _wiping ? null : _deleteAccount,
          color: danger),
    ];
  }

  // ---------- Personalizace ----------

  List<Widget> _personal(BuildContext c) {
    final st = AppSettings.instance;
    const themes = {
      ThemeMode.system: 'Podle telefonu',
      ThemeMode.light: 'Světlý',
      ThemeMode.dark: 'Tmavý',
    };
    const weeks = {1: 'Pondělí', 0: 'Neděle', 6: 'Sobota'};
    return [
      _tile(Icons.language, 'Jazyk', AppSettings.languages[st.language], () async {
        final v = await _choose(c, 'Jazyk aplikace', AppSettings.languages, st.language,
            note: 'Překlad všech textů aplikace připravuji. '
                'Zatím se podle jazyka mění kalendáře a názvy na mapě.');
        if (v != null) await st.setLanguage(v);
      }),
      _tile(Icons.brightness_6, 'Barevný motiv', themes[st.themeMode], () async {
        final v = await _choose(c, 'Barevný motiv', themes, st.themeMode);
        if (v != null) await st.setThemeMode(v);
      }),
      _tile(Icons.payments_outlined, 'Výchozí měna', st.homeCurrency, () => _pickCurrency(c)),
      _tile(Icons.calendar_view_week, 'Začátek týdne', weeks[st.weekStart], () async {
        final v = await _choose(c, 'Týden začíná', weeks, st.weekStart);
        if (v != null) await st.setWeekStart(v);
      }),
      _tile(Icons.event, 'Formát data', AppSettings.dateFormats[st.dateFormat], () async {
        final v = await _choose(c, 'Formát data', AppSettings.dateFormats, st.dateFormat);
        if (v != null) await st.setDateFormat(v);
      }),
      _tile(Icons.schedule, 'Formát času', st.use24h ? '24 hodin (14:30)' : '12 hodin (2:30 PM)',
          () async {
        final v = await _choose(c, 'Formát času',
            const {true: '24 hodin (14:30)', false: '12 hodin (2:30 PM)'}, st.use24h);
        if (v != null) await st.setUse24h(v);
      }),
      _tile(Icons.home_outlined, 'Úvodní záložka', AppSettings.startTabs[st.startTab], () async {
        final v = await _choose(c, 'Na čem se aplikace otevře', AppSettings.startTabs, st.startTab,
            note: 'Projeví se při příštím spuštění.');
        if (v != null) await st.setStartTab(v);
      }),
      _tile(Icons.translate, 'Názvy na mapě',
          st.mapLocalNames ? 'Místní (東京, Hà Nội…)' : 'V jazyce aplikace', () async {
        final v = await _choose(
            c,
            'Názvy měst a míst na mapě',
            const {false: 'V jazyce aplikace (Tokyo, Hanoi…)', true: 'Místní (東京, Hà Nội…)'},
            st.mapLocalNames);
        if (v != null) await st.setMapLocalNames(v);
      }),
    ];
  }

  Future<void> _pickCurrency(BuildContext c) async {
    final st = AppSettings.instance;
    final v = await _choose(
        c, 'Výchozí měna', {for (final cur in AppSettings.currencies) cur: cur}, st.homeCurrency,
        note: 'V této měně uvidíš součty výdajů a rozpočty. Nové cesty ji dostanou automaticky.');
    if (v == null || v == st.homeCurrency || !c.mounted) return;
    final ok = await confirm(
        c, 'Přepočítat všechny cesty a výdaje na $v? Použijí se kurzy ECB ze dne každého výdaje.');
    if (!ok || !mounted) return;
    setState(() => _wiping = true);
    await st.setHomeCurrency(v);
    final missing = await ref.read(expenseRepositoryProvider).changeMainCurrency(v);
    if (!mounted) return;
    setState(() => _wiping = false);
    _snack(missing == 0
        ? 'Hotovo, vše je v $v.'
        : 'Hotovo. $missing výdajů zatím bez přepočtu (bez internetu nebo měna mimo ECB) '
            '– dopočítají se později.');
  }

  // ---------- Data ----------

  List<Widget> _data(BuildContext c) {
    final st = AppSettings.instance;
    final danger = Theme.of(c).colorScheme.error;
    final export = ExportService(ref.read(databaseProvider));
    return [
      Card(
        child: SwitchListTile(
          secondary: const Icon(Icons.notifications_active_outlined),
          title: const Text('Upozornění na konec platnosti'),
          subtitle: const Text('Pas, víza, pojištění… z Vaultu'),
          value: st.expiryReminders,
          onChanged: (v) async {
            await st.setExpiryReminders(v);
            await ReminderService.reschedule();
          },
        ),
      ),
      if (st.expiryReminders)
        _tile(Icons.alarm, 'Čas upozornění', fmtTime(st.expiryReminderMinutes), () async {
          final t = await showTimePicker(
            context: c,
            initialTime: TimeOfDay(
                hour: st.expiryReminderMinutes ~/ 60, minute: st.expiryReminderMinutes % 60),
          );
          if (t == null) return;
          await st.setExpiryReminderMinutes(t.hour * 60 + t.minute);
          await ReminderService.reschedule();
        }),
      _header(c, 'Export'),
      _tile(Icons.table_chart_outlined, 'Výdaje do tabulky (CSV)', 'Pro Excel nebo Tabulky Google',
          () => export.exportExpensesCsv()),
      _tile(Icons.data_object, 'Všechna data (JSON)',
          'Cesty, místa, plán, doklady, výdaje – bez Vaultu', () => export.exportAllJson()),
      _header(c, 'Nebezpečná zóna', color: danger),
      _tile(Icons.delete_forever, 'Smazat všechna data', 'Telefon i záloha. Vault a účet zůstanou.',
          _wiping ? null : _wipe,
          color: danger),
    ];
  }

  // ---------- O aplikaci ----------

  static const _web = 'https://travel-companion-ai-e300c.web.app';

  List<Widget> _about(BuildContext c) => [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (c, snap) => _tile(
              Icons.info_outline,
              'Travel Companion',
              snap.hasData ? 'Verze ${snap.data!.version} (${snap.data!.buildNumber})' : null,
              null),
        ),
        Card(
          child: ListTile(
            leading:
                ClipOval(child: Image.asset('assets/lr-tech-logo.png', width: 40, height: 40)),
            title: const Text('LR Tech CZ'),
            subtitle: const Text('Vývojář aplikace'),
          ),
        ),
        _tile(Icons.mail_outline, 'Kontakt a podpora', 'lrtechcz@gmail.com',
            () => launchUrl(Uri.parse('mailto:lrtechcz@gmail.com?subject=Travel%20Companion'))),
        _tile(Icons.privacy_tip_outlined, 'Zásady ochrany soukromí', null,
            () => launchUrl(Uri.parse('$_web/privacy'), mode: LaunchMode.externalApplication)),
        _tile(
            Icons.star_outline,
            'Ohodnotit v Google Play',
            null,
            () => launchUrl(
                Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.lukrom.travelcompanion'),
                mode: LaunchMode.externalApplication)),
        _tile(
            Icons.article_outlined,
            'Licence knihoven',
            null,
            () => showLicensePage(
                  context: c,
                  applicationName: 'Travel Companion',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                        child: Image.asset('assets/lr-tech-logo.png', width: 48, height: 48)),
                  ),
                  applicationLegalese: '© 2026 LR Tech CZ',
                )),
      ];

  @override
  Widget build(BuildContext context) {
    final st = AppSettings.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
        bottom: _wiping
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4), child: LinearProgressIndicator())
            : null,
      ),
      body: AbsorbPointer(
        absorbing: _wiping,
        child: ListenableBuilder(
          listenable: Listenable.merge([st, ProService.instance]),
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _tile(Icons.person_outline, 'Účet',
                  '${ProService.instance.isPro ? 'Pro' : 'Zdarma'} · záloha · zámek aplikace',
                  () => _open('Účet', _account)),
              _tile(Icons.tune, 'Personalizace',
                  '${AppSettings.languages[st.language]} · ${st.homeCurrency} · motiv · formáty',
                  () => _open('Personalizace', _personal)),
              _tile(Icons.storage_outlined, 'Data', 'Upozornění · export · smazání dat',
                  () => _open('Data', _data)),
              _tile(Icons.info_outline, 'O aplikaci', 'Verze · kontakt · zásady · licence',
                  () => _open('O aplikaci', _about)),
            ],
          ),
        ),
      ),
    );
  }
}
