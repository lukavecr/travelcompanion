import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../core/format.dart';
import '../../data/database.dart';
import '../onboarding/demo_trip.dart';
import '../../l10n/tr.dart';

/// Bod trasy: zeměpisná šířka, délka, sekundy od začátku záznamu.
typedef TrackPoint = (double lat, double lng, int t);

List<TrackPoint> decodePoints(String json) {
  try {
    return [
      for (final p in jsonDecode(json) as List)
        ((p[0] as num).toDouble(), (p[1] as num).toDouble(), (p[2] as num).toInt())
    ];
  } catch (_) {
    return const [];
  }
}

String encodePoints(List<TrackPoint> pts) => jsonEncode([
      for (final p in pts)
        [double.parse(p.$1.toStringAsFixed(5)), double.parse(p.$2.toStringAsFixed(5)), p.$3]
    ]);

/// Vzdálenost dvou bodů v metrech (haversine).
double distanceM(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1), dLng = rad(lng2 - lng1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

double trackLength(List<TrackPoint> pts) {
  var d = 0.0;
  for (var i = 1; i < pts.length; i++) {
    d += distanceM(pts[i - 1].$1, pts[i - 1].$2, pts[i].$1, pts[i].$2);
  }
  return d;
}

String fmtDistance(double m) =>
    m < 1000 ? '${m.round()} m' : '${fmtMoney(m / 1000, m < 10000 ? 2 : 1)} km';

String fmtDuration(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60;
  return h > 0 ? '$h h ${m.toString().padLeft(2, '0')} min' : '${d.inMinutes} min';
}

/// GPX soubor trasy (pro Mapy.cz, Strava, Google Earth…).
String buildGpx(Track t) {
  final pts = decodePoints(t.points);
  String esc(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
  final b = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln('<gpx version="1.1" creator="Travel Companion" xmlns="http://www.topografix.com/GPX/1/1">')
    ..writeln('<trk><name>${esc(t.name)}</name><trkseg>');
  for (final p in pts) {
    final time = t.startedAt.add(Duration(seconds: p.$3)).toUtc().toIso8601String();
    b.writeln('<trkpt lat="${p.$1}" lon="${p.$2}"><time>$time</time></trkpt>');
  }
  b.writeln('</trkseg></trk></gpx>');
  return b.toString();
}

/// Ruční záznam trasy (Start/Stop). Běží i se zhasnutým displejem přes službu
/// v popředí s oznámením „Zaznamenávám trasu“.
class TrackerService extends ChangeNotifier {
  TrackerService._();
  static final instance = TrackerService._();

  AppDatabase? _db;
  StreamSubscription<Position>? _sub;
  Timer? _flushTimer;
  String? trackId;
  DateTime? startedAt;
  final List<TrackPoint> points = [];
  double distance = 0;
  bool _dirty = false;

  bool get recording => trackId != null;

  /// Při startu aplikace: trasa, která zůstala otevřená (aplikace spadla / telefon ji ukončil), se uzavře.
  Future<void> init(AppDatabase db) async {
    _db = db;
    final open = await (db.select(db.tracks)..where((t) => t.endedAt.isNull() & t.deletedAt.isNull())).get();
    for (final t in open) {
      final pts = decodePoints(t.points);
      await (db.update(db.tracks)..where((x) => x.id.equals(t.id))).write(TracksCompanion(
        endedAt: Value(t.startedAt.add(Duration(seconds: pts.isEmpty ? 0 : pts.last.$3))),
        updatedAt: Value(DateTime.now()),
        syncState: const Value('pending'),
      ));
    }
  }

  /// Vrátí null, když se záznam spustil, jinak text chyby pro uživatele.
  Future<String?> start() async {
    final db = _db;
    if (db == null || recording) return null;
    if (!await Geolocator.isLocationServiceEnabled()) return tr('Zapni v telefonu polohu (GPS).');
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return tr('Aplikace nemá povolený přístup k poloze.');
    }

    final now = DateTime.now();
    // patří k probíhající cestě (když nějaká je)
    String? tripId;
    for (final t in await (db.select(db.trips)..where((t) => t.deletedAt.isNull())).get()) {
      if (t.notes == demoTripNote || t.startDate == null) continue;
      final s = dayOnly(t.startDate!), e = t.endDate == null ? null : dayOnly(t.endDate!);
      if (!s.isAfter(dayOnly(now)) && (e == null || !e.isBefore(dayOnly(now)))) tripId = t.id;
    }
    final id = const Uuid().v4();
    await db.into(db.tracks).insert(TracksCompanion.insert(
          id: id,
          tripId: Value(tripId),
          name: tr('Trasa {d}', {'d': '${fmtDate(now)} ${fmtTime(now.hour * 60 + now.minute)}'}),
          startedAt: now,
        ));
    trackId = id;
    startedAt = now;
    points.clear();
    distance = 0;
    notifyListeners();

    final settings = defaultTargetPlatform == TargetPlatform.android
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 8,
            intervalDuration: const Duration(seconds: 5),
            foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: tr('Zaznamenávám trasu'),
              notificationText: tr('Klepnutím otevřeš Travel Companion'),
              notificationChannelName: tr('Záznam trasy'),
              enableWakeLock: true,
              setOngoing: true,
            ),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 8,
            allowBackgroundLocationUpdates: true,
            showBackgroundLocationIndicator: true,
            pauseLocationUpdatesAutomatically: false,
            activityType: ActivityType.fitness,
          ) as LocationSettings;
    _sub = Geolocator.getPositionStream(locationSettings: settings).listen(_onPosition, onError: (_) {});
    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) => _flush());
    return null;
  }

  void _onPosition(Position p) {
    if (p.accuracy > 35) return; // nepřesné body (uvnitř budov) vynechat
    final t = DateTime.now().difference(startedAt!).inSeconds;
    if (points.isNotEmpty) {
      final last = points.last;
      final d = distanceM(last.$1, last.$2, p.latitude, p.longitude);
      final dt = math.max(1, t - last.$3);
      if (d / dt > 70) return; // skok polohy (> 250 km/h)
      if (d < math.max(5, p.accuracy * 0.5)) return; // stání na místě
      distance += d;
    }
    points.add((p.latitude, p.longitude, t));
    _dirty = true;
    notifyListeners();
  }

  Future<void> _flush() async {
    final db = _db, id = trackId;
    if (db == null || id == null || !_dirty) return;
    _dirty = false;
    await (db.update(db.tracks)..where((x) => x.id.equals(id))).write(TracksCompanion(
      points: Value(encodePoints(points)),
      distanceM: Value(distance),
      updatedAt: Value(DateTime.now()),
      syncState: const Value('pending'),
    ));
  }

  Future<void> stop() async {
    final db = _db, id = trackId;
    if (db == null || id == null) return;
    await _sub?.cancel();
    _sub = null;
    _flushTimer?.cancel();
    _dirty = true;
    await _flush();
    await (db.update(db.tracks)..where((x) => x.id.equals(id))).write(TracksCompanion(
      endedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      syncState: const Value('pending'),
    ));
    trackId = null;
    startedAt = null;
    points.clear();
    distance = 0;
    notifyListeners();
  }
}
