import 'dart:convert';

import 'package:http/http.dart' as http;

String _d(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Kolik [to] stojí 1 [from] v den [date] (referenční kurzy ECB přes
/// frankfurter.dev). Vrátí null, když není internet nebo měna v ECB není.
Future<double?> fetchRate({
  required String from,
  required String to,
  required DateTime date,
}) async {
  if (from == to) return 1;
  try {
    final now = DateTime.now();
    final day = date.isAfter(now) ? 'latest' : _d(date);
    final uri = Uri.parse(
        'https://api.frankfurter.dev/v1/$day?base=$from&symbols=$to');
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final rate = (json['rates'] as Map<String, dynamic>?)?[to];
    return (rate as num?)?.toDouble();
  } catch (_) {
    return null;
  }
}
