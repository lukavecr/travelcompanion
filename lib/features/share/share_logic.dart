import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Pozvánka do společné cesty: kód se pošle zprávou (12 znaků, ~59 bitů).
/// Do Firestore jde jen hash kódu (id pozvánky) a klíč cesty zamčený kódem –
/// Google ani nikdo bez kódu klíč nezíská.
const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
final _aes = AesGcm.with256bits();

String newInviteCode([Random? rnd]) {
  final r = rnd ?? Random.secure();
  return List.generate(12, (_) => _alphabet[r.nextInt(_alphabet.length)]).join();
}

/// „abcd efgh-jkmn“ → „ABCDEFGHJKMN“ (null, když to kód není).
String? normalizeInviteCode(String input) {
  final up = input.toUpperCase();
  const c = '[$_alphabet]{4}';
  final m = RegExp('(?<![A-Z0-9])($c)[\\s-]?($c)[\\s-]?($c)(?![A-Z0-9])').firstMatch(up);
  if (m != null) return '${m.group(1)}${m.group(2)}${m.group(3)}';
  final s = up.replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return RegExp('^[$_alphabet]{12}\$').hasMatch(s) ? s : null;
}

String formatInviteCode(String c) => '${c.substring(0, 4)}-${c.substring(4, 8)}-${c.substring(8)}';

Future<List<int>> _hash(String code, String purpose) async =>
    (await Sha256().hash(utf8.encode('travelcompanion|$purpose|$code'))).bytes;

/// Id dokumentu pozvánky (`invites/{id}`).
Future<String> inviteId(String code) async =>
    (await _hash(code, 'id')).take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

/// Klíč cesty zamčený kódem pozvánky.
Future<String> wrapTripKey(String code, List<int> tripKey) async {
  final box = await _aes.encrypt(tripKey, secretKey: SecretKey(await _hash(code, 'key')));
  return base64Encode(box.concatenation());
}

Future<List<int>> unwrapTripKey(String code, String wrapped) async => _aes.decrypt(
      SecretBox.fromConcatenation(base64Decode(wrapped),
          nonceLength: _aes.nonceLength, macLength: _aes.macAlgorithm.macLength),
      secretKey: SecretKey(await _hash(code, 'key')),
    );

List<int> newTripKey() => List<int>.generate(32, (_) => Random.secure().nextInt(256));

// ---------- dělení útrat ----------

class SplitExpense {
  const SplitExpense({required this.amount, required this.paidBy, this.splitWith});
  final double amount; // v hlavní měně cesty
  final String paidBy;
  final List<String>? splitWith; // null = všichni účastníci
}

class Transfer {
  const Transfer(this.from, this.to, this.amount);
  final String from, to;
  final double amount;
  @override
  String toString() => '$from→$to ${amount.toStringAsFixed(2)}';
}

/// Zůstatky: kladné = ostatní mu dluží, záporné = dluží on.
Map<String, double> balances(List<SplitExpense> expenses, List<String> members) {
  final b = {for (final m in members) m: 0.0};
  for (final e in expenses) {
    final who = (e.splitWith == null || e.splitWith!.isEmpty)
        ? members
        : e.splitWith!.where(members.contains).toList();
    if (who.isEmpty || !b.containsKey(e.paidBy)) continue;
    b[e.paidBy] = b[e.paidBy]! + e.amount;
    final share = e.amount / who.length;
    for (final m in who) {
      b[m] = b[m]! - share;
    }
  }
  return b;
}

/// Kdo komu kolik pošle, aby bylo vyrovnáno (co nejméně převodů).
List<Transfer> settle(Map<String, double> balances) {
  final debt = [
    for (final e in balances.entries)
      if (e.value < -0.005) [e.key, -e.value]
  ]..sort((a, b) => (b[1] as double).compareTo(a[1] as double));
  final cred = [
    for (final e in balances.entries)
      if (e.value > 0.005) [e.key, e.value]
  ]..sort((a, b) => (b[1] as double).compareTo(a[1] as double));
  final out = <Transfer>[];
  var i = 0, j = 0;
  while (i < debt.length && j < cred.length) {
    final d = debt[i][1] as double, c = cred[j][1] as double;
    final x = min(d, c);
    out.add(Transfer(debt[i][0] as String, cred[j][0] as String, x));
    debt[i][1] = d - x;
    cred[j][1] = c - x;
    if ((debt[i][1] as double) < 0.005) i++;
    if ((cred[j][1] as double) < 0.005) j++;
  }
  return out;
}
