import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/app_settings.dart';
import '../vault/vault_crypto.dart';

/// Ověření otiskem / obličejem, případně PINem či gestem telefonu.
/// Vrací true i tehdy, když telefon zámek nemá (to hlásí [deviceHasLock]).
class DeviceAuth {
  static final _auth = LocalAuthentication();
  static bool _busy = false;

  /// Právě běží systémové okno ověření (aplikace kvůli němu jde do pozadí).
  static bool get busy => _busy;

  static Future<bool> deviceHasLock() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Telefon hlásí, že nemá nastavený PIN/gesto/heslo (pak nejde zamykat).
  static bool lastNoCredentials = false;

  static Future<bool> confirm(String reason) async {
    lastNoCredentials = false;
    if (_busy) return false;
    _busy = true;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        persistAcrossBackgrounding: true,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Travel Companion',
            signInHint: 'Otisk prstu, obličej nebo PIN telefonu',
            cancelButton: 'Zrušit',
          ),
        ],
      );
    } on PlatformException {
      return false;
    } on LocalAuthException catch (e) {
      lastNoCredentials = e.code == LocalAuthExceptionCode.noCredentialsSet;
      return false;
    } finally {
      // okno ověření vyvolá pauzu a návrat aplikace – chvíli to nepočítat jako odchod
      Future.delayed(const Duration(milliseconds: 800), () => _busy = false);
    }
  }
}

/// Zámek celé aplikace: po spuštění a po návratu z pozadí (doba podle Nastavení → Účet → Zámek).
class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _locked = AppSettings.instance.lockAfterSeconds >= 0;
  bool _noDeviceLock = false;
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_locked) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (DeviceAuth.busy) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _pausedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final away = _pausedAt == null ? Duration.zero : DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
      final after = AppSettings.instance.lockAfterSeconds;
      if (!_locked && after >= 0 && away >= Duration(seconds: after)) {
        VaultKeys.instance.lock();
        setState(() => _locked = true);
        _unlock();
      }
    }
  }

  Future<void> _unlock() async {
    if (!await DeviceAuth.deviceHasLock()) {
      if (mounted) setState(() => _noDeviceLock = true);
      return;
    }
    final ok = await DeviceAuth.confirm('Odemkni Travel Companion');
    if (!mounted) return;
    if (ok) {
      setState(() => _locked = false);
    } else if (DeviceAuth.lastNoCredentials) {
      setState(() => _noDeviceLock = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // pod zámkem se obsah nevykresluje, ale zůstává rozpracovaný (formuláře, otevřené obrazovky)
        Offstage(
          offstage: _locked,
          child: TickerMode(enabled: !_locked, child: widget.child),
        ),
        if (_locked)
          Positioned.fill(
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline,
                          size: 72, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      Text('Travel Companion je zamčená',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        _noDeviceLock
                            ? 'Telefon nemá nastavený zámek obrazovky. Pro ochranu dat si v Nastavení '
                                'telefonu nastav PIN a otisk prstu.'
                            : 'Odemkni otiskem prstu, obličejem nebo PINem telefonu.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_noDeviceLock)
                        OutlinedButton(
                          onPressed: () => setState(() => _locked = false),
                          child: const Text('Pokračovat bez zámku'),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _unlock,
                          icon: const Icon(Icons.fingerprint),
                          label: const Text('Odemknout'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
