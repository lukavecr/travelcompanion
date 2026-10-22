// ignore_for_file: avoid_print
// Kontrola šifrování Vaultu (stejné kroky jako lib/features/vault/vault_crypto.dart):
// dart run tool/vault_crypto_probe.dart
import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final aes = AesGcm.with256bits();
  final r = Random.secure();
  List<int> rnd(int n) => List.generate(n, (_) => r.nextInt(256));
  Future<SecretKey> derive(String pw, List<int> salt) =>
      Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 310000, bits: 256)
          .deriveKeyFromPassword(password: pw, nonce: salt);

  final master = rnd(32);
  final salt = rnd(16);
  final sw = Stopwatch()..start();
  final wrapKey = await derive('Heslo1234', salt);
  print('PBKDF2 310k: ${sw.elapsedMilliseconds} ms (čisté Dart, v telefonu nativně rychleji)');
  final wrapped = (await aes.encrypt(master, secretKey: wrapKey)).concatenation();

  SecretBox box(List<int> d) => SecretBox.fromConcatenation(d,
      nonceLength: aes.nonceLength, macLength: aes.macAlgorithm.macLength);

  final back = await aes.decrypt(box(wrapped), secretKey: await derive('Heslo1234', salt));
  print('obnova správným heslem: ${base64Encode(back) == base64Encode(master) ? "OK" : "CHYBA"}');
  try {
    await aes.decrypt(box(wrapped), secretKey: await derive('spatne', salt));
    print('špatné heslo: CHYBA – prošlo');
  } on SecretBoxAuthenticationError {
    print('špatné heslo: odmítnuto ✔');
  }

  final key = SecretKey(master);
  final item = {'fields': {'number': '45123456', 'name': 'Roman'}, 'photos': ['a']};
  final enc = (await aes.encrypt(utf8.encode(jsonEncode(item)), secretKey: key)).concatenation();
  print('zašifrovaná položka obsahuje číslo pasu: ${utf8.decode(enc, allowMalformed: true).contains('45123456')}');
  final dec = jsonDecode(utf8.decode(await aes.decrypt(box(enc), secretKey: key)));
  print('odšifrováno: ${dec['fields']['number']}');
}
