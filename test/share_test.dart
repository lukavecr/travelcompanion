import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/features/share/share_logic.dart';

void main() {
  test('pozvánka: kód, id a klíč cesty', () async {
    final code = newInviteCode(Random(1));
    expect(code.length, 12);
    expect(normalizeInviteCode(' ${formatInviteCode(code).toLowerCase()} '), code);
    expect(normalizeInviteCode('Kód je ${formatInviteCode(code)}, platí 7 dní'), code);
    expect(normalizeInviteCode('ahoj'), isNull);
    expect(normalizeInviteCode(formatInviteCode(code).replaceAll('-', ' ')), code);
    expect(await inviteId(code), hasLength(32));
    expect(await inviteId(code), isNot(await inviteId(newInviteCode(Random(2)))));

    final key = newTripKey();
    final wrapped = await wrapTripKey(code, key);
    expect(await unwrapTripKey(code, wrapped), key);
    await expectLater(unwrapTripKey(newInviteCode(Random(3)), wrapped), throwsA(anything));
  });

  test('dělení útrat a vyrovnání', () {
    const m = ['roman', 'jana', 'petr'];
    final b = balances(const [
      SplitExpense(amount: 900, paidBy: 'roman'), // všichni po 300
      SplitExpense(amount: 300, paidBy: 'jana', splitWith: ['roman', 'jana']), // po 150
    ], m);
    expect(b['roman'], closeTo(450, 0.01)); // 900 − 300 − 150
    expect(b['jana'], closeTo(-150, 0.01)); // 300 − 300 − 150
    expect(b['petr'], closeTo(-300, 0.01));
    final t = settle(b);
    expect(t.length, 2);
    expect(t.map((x) => x.toString()), containsAll(['petr→roman 300.00', 'jana→roman 150.00']));
    expect(settle({'a': 0, 'b': 0}), isEmpty);
  });
}
