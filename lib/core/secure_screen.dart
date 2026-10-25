import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Obrazovka s citlivými údaji (Vault, doklady, SOS): nejde vyfotit snímkem obrazovky ani nahrát
/// a v přehledu spuštěných aplikací je místo náhledu prázdná plocha (Android FLAG_SECURE).
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled; // false = nechránit (např. jiná záložka)

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static const _ch = MethodChannel('tc/secure');
  static int _count = 0; // víc chráněných obrazovek nad sebou

  static void _set(bool on) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    _ch.invokeMethod('setSecure', on).catchError((_) {});
  }

  bool _on = false;

  void _apply(bool on) {
    if (on == _on) return;
    _on = on;
    if (on) {
      if (_count++ == 0) _set(true);
    } else {
      if (--_count == 0) _set(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _apply(widget.enabled);
  }

  @override
  void didUpdateWidget(SecureScreen old) {
    super.didUpdateWidget(old);
    _apply(widget.enabled);
  }

  @override
  void dispose() {
    _apply(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
