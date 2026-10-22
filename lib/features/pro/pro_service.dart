import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/tr.dart';

/// Travel Companion Pro = roční předplatné v Google Play.
///
/// Free: 1 aktivní cesta, 10 dokladů, 30 výdajů, data jen v telefonu; Vault a SOS zdarma.
/// Pro: bez omezení + záloha a synchronizace do cloudu.
///
/// Stav předplatného se ověřuje u Google Play (obnovení nákupů) při každém spuštění.
/// Offline platí poslední známý stav ještě [_offlineGrace].
class ProService extends ChangeNotifier {
  ProService._();
  static final instance = ProService._();

  /// Id předplatného v Google Play Console (Monetizace → Předplatná).
  static const productId = 'pro_yearly';

  static const freeActiveTrips = 1;
  static const freeDocuments = 10;
  static const freeExpenses = 30;

  /// SHA-256 e-mailů majitele (Pro napořád, bez nákupu). E-mail sám v aplikaci není.
  static const _ownerHashes = {
    'f08b1b9d6587d1e90304264b292c5ccfaf07796b52dfd4096279b751bdd615a3', // Roman – přihlášení do aplikace (uživatelský účet)
    'b7b5618c1153d20c7ac84bf0274106ac281804d32ea4ea84bda973ee96c05d36', // lrtechcz – e-mail pro aplikaci
  };

  static const _offlineGrace = Duration(days: 7);
  static const _prefUntil = 'pro_cached_until';

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool _subscribed = false;
  bool _owner = false;
  bool _storeAvailable = false;
  ProductDetails? product;
  String? lastError;
  bool busy = false;

  bool get isPro => _owner || _subscribed;
  bool get isOwner => _owner;
  bool get storeAvailable => _storeAvailable;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_prefUntil);
    if (until != null && DateTime.now().millisecondsSinceEpoch < until) _subscribed = true;
    FirebaseAuth.instance.authStateChanges().listen((u) => _checkOwner(u?.email));
    notifyListeners();

    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) return;
      _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (Object e) {
        lastError = '$e';
        notifyListeners();
      });
      final r = await _iap.queryProductDetails({productId});
      product = r.productDetails.isEmpty ? null : r.productDetails.first;
      // Google Play vrátí jen aktivní předplatné → když nic nepřijde, Pro skončilo
      await _iap.restorePurchases();
      Future.delayed(const Duration(seconds: 8), _expireIfNotRestored);
    } catch (e) {
      lastError = '$e';
    }
    notifyListeners();
  }

  bool _restoredThisRun = false;

  Future<void> _expireIfNotRestored() async {
    if (_restoredThisRun || !_storeAvailable) return;
    // obchod odpověděl a předplatné v něm není → po uplynutí offline lhůty Pro vypnout
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_prefUntil) ?? 0;
    if (DateTime.now().millisecondsSinceEpoch >= until && _subscribed) {
      _subscribed = false;
      notifyListeners();
    }
  }

  Future<void> _checkOwner(String? email) async {
    var owner = false;
    if (email != null) {
      final h = await Sha256().hash(utf8.encode(email.trim().toLowerCase()));
      final hex = h.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
      owner = _ownerHashes.contains(hex);
    }
    if (owner != _owner) {
      _owner = owner;
      notifyListeners();
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID != productId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _restoredThisRun = true;
          await _setSubscribed(true);
        case PurchaseStatus.error:
          lastError = p.error?.message;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
    busy = false;
    notifyListeners();
  }

  Future<void> _setSubscribed(bool v) async {
    _subscribed = v;
    final prefs = await SharedPreferences.getInstance();
    if (v) {
      await prefs.setInt(
          _prefUntil, DateTime.now().add(_offlineGrace).millisecondsSinceEpoch);
    } else {
      await prefs.remove(_prefUntil);
    }
  }

  /// Spustí nákup v Google Play. Výsledek přijde přes [purchaseStream].
  Future<void> buy() async {
    final p = product;
    if (p == null) {
      lastError = tr('Předplatné teď nejde načíst z Google Play.');
      notifyListeners();
      return;
    }
    lastError = null;
    busy = true;
    notifyListeners();
    try {
      await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      busy = false;
      lastError = '$e';
      notifyListeners();
    }
  }

  Future<void> restore() async {
    lastError = null;
    busy = true;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      lastError = '$e';
    }
    Future.delayed(const Duration(seconds: 6), () {
      busy = false;
      notifyListeners();
    });
  }

  /// Správa / zrušení předplatného v Google Play.
  static Uri get manageUrl => Uri.parse(
      'https://play.google.com/store/account/subscriptions?sku=$productId&package=com.lukrom.travelcompanion');
}
