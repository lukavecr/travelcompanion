import 'package:flutter_test/flutter_test.dart';
import 'package:travelcompanion/core/plus_code.dart';
import 'package:travelcompanion/features/vault/vault_types.dart';

void main() {
  test('texty upozornění na konec platnosti', () {
    expect(fmtDaysAhead(0), 'dnes');
    expect(fmtDaysAhead(1), 'zítra');
    expect(fmtDaysAhead(3), 'za 3 dny');
    expect(fmtDaysAhead(14), 'za 14 dní');
    expect(fmtDaysAhead(90), 'za 3 měsíce');
    expect(fmtDaysAhead(183), 'za 6 měsíců');
    expect(remindPlanText(vaultType('passport')),
        'Upozorním 6 měsíců, 3 měsíce, 30 dní předem a v den konce platnosti (v 9:00).');
    expect(remindPlanText(vaultType('visa')),
        'Upozorním 14 dní, 3 dny, 1 den předem a v den konce platnosti (v 9:00).');
  });

  test('Plus Code (testovací hodnoty Open Location Code)', () {
    final (lat, lng) = decodePlusCode('7FG49QCJ+2V');
    expect(lat, closeTo(20.3700625, 1e-9));
    expect(lng, closeTo(2.7821875, 1e-9));
    final (rlat, rlng) = recoverPlusCode('9QCJ+2V', 20.3, 2.7);
    expect(rlat, closeTo(20.3700625, 1e-9));
    expect(rlng, closeTo(2.7821875, 1e-9));
    expect(findPlusCode('JP9V JX2 Huong Pagoda')?.code, 'JP9V+JX2');
  });
}
