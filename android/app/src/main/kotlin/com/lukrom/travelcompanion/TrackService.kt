package com.lukrom.travelcompanion

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.Looper
import org.json.JSONArray
import org.json.JSONObject
import java.util.Locale
import java.util.UUID
import kotlin.math.max

/**
 * Záznam trasy jako služba v popředí (běží i se zavřenou aplikací a zhasnutým displejem).
 *
 * Spouští ji tlačítko na widgetu (přes [TrackToggleActivity]) i aplikace (kanál „tc/tracker“ v [MainActivity]).
 * Body se ukládají průběžně do SharedPreferences „tc_track“ (nic se neztratí, když systém službu ukončí);
 * po zastavení se trasa přesune do seznamu „finished“ a aplikace si ji při příštím otevření uloží do databáze.
 */
class TrackService : Service(), LocationListener {
    companion object {
        const val ACTION_START = "tc.track.START"
        const val ACTION_STOP = "tc.track.STOP"
        private const val CHANNEL = "track_recording"
        private const val NOTIF_ID = 4711

        @Volatile
        var running = false

        fun prefs(c: Context): SharedPreferences = c.getSharedPreferences("tc_track", Context.MODE_PRIVATE)
        fun isRecording(c: Context) = prefs(c).getBoolean("recording", false)

        fun hasLocationPermission(c: Context) =
            c.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED

        fun start(c: Context) {
            val i = Intent(c, TrackService::class.java).setAction(ACTION_START)
            if (Build.VERSION.SDK_INT >= 26) c.startForegroundService(i) else c.startService(i)
        }

        fun stop(c: Context) {
            if (running) {
                c.startService(Intent(c, TrackService::class.java).setAction(ACTION_STOP))
            } else {
                finish(c) // služba neběží (systém ji ukončil) → uložit, co je zaznamenané
            }
        }

        /** Ukončí záznam: aktuální trasu přesune do seznamu dokončených. */
        fun finish(c: Context) {
            val p = prefs(c)
            if (!p.getBoolean("recording", false)) return
            val points = JSONArray(p.getString("points", "[]"))
            val finished = JSONArray(p.getString("finished", "[]"))
            if (points.length() > 0) {
                val start = p.getLong("startedAt", System.currentTimeMillis())
                val lastT = points.getJSONArray(points.length() - 1).getLong(2)
                finished.put(
                    JSONObject()
                        .put("id", p.getString("id", UUID.randomUUID().toString()))
                        .put("startedAt", start)
                        // služba běžela až do teď → konec = teď; jinak (ukončil ji systém) = čas posledního bodu
                        .put("endedAt", if (running) System.currentTimeMillis() else start + lastT * 1000)
                        .put("distance", p.getFloat("distance", 0f).toDouble())
                        .put("points", points),
                )
            }
            p.edit().putBoolean("recording", false).putString("points", "[]").putFloat("distance", 0f)
                .putString("finished", finished.toString()).apply()
            updateWidget(c)
        }

        fun fmtDistance(m: Double): String =
            if (m < 1000) "${m.toInt()} m" else String.format(Locale.getDefault(), "%.1f km", m / 1000)

        /** Stav záznamu na widgetu (stejné klíče, jaké zapisuje aplikace). */
        fun updateWidget(c: Context) {
            val p = prefs(c)
            val rec = p.getBoolean("recording", false)
            c.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE).edit()
                .putString("w_rec", if (rec) "1" else "0")
                .putString("w_track_dist", if (rec) fmtDistance(p.getFloat("distance", 0f).toDouble()) else "")
                .apply()
            val mgr = AppWidgetManager.getInstance(c)
            val ids = mgr.getAppWidgetIds(ComponentName(c, PlanWidgetProvider::class.java))
            if (ids.isNotEmpty()) {
                c.sendBroadcast(
                    Intent(c, PlanWidgetProvider::class.java)
                        .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
                        .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids),
                )
            }
        }

        fun label(c: Context, key: String, def: String) = prefs(c).getString(key, def) ?: def
    }

    private var lm: LocationManager? = null
    private var lastNotify = 0L

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopTracking()
                return START_NOT_STICKY
            }
            ACTION_START -> {
                if (!isRecording(this)) {
                    prefs(this).edit()
                        .putBoolean("recording", true)
                        .putString("id", UUID.randomUUID().toString())
                        .putLong("startedAt", System.currentTimeMillis())
                        .putString("points", "[]")
                        .putFloat("distance", 0f)
                        .apply()
                }
            }
            // null = systém službu obnovil po ukončení → pokračovat, pokud záznam běžel
            else -> if (!isRecording(this)) {
                stopSelf()
                return START_NOT_STICKY
            }
        }
        startInForeground()
        listen()
        running = true
        updateWidget(this)
        return START_STICKY
    }

    private fun startInForeground() {
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26 && nm.getNotificationChannel(CHANNEL) == null) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL, label(this, "n_channel", "Záznam trasy"), NotificationManager.IMPORTANCE_LOW),
            )
        }
        val n = buildNotification()
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(NOTIF_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
        } else {
            startForeground(NOTIF_ID, n)
        }
    }

    private fun buildNotification(): Notification {
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val open = PendingIntent.getActivity(
            this, 1,
            Intent(this, MainActivity::class.java).setAction(Intent.ACTION_VIEW).setData(Uri.parse("travelcompanion://open")),
            flags,
        )
        val stop = PendingIntent.getService(this, 2, Intent(this, TrackService::class.java).setAction(ACTION_STOP), flags)
        val dist = fmtDistance(prefs(this).getFloat("distance", 0f).toDouble())
        val b = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(this, CHANNEL) else Notification.Builder(this)
        return b.setSmallIcon(R.drawable.ic_stat_track)
            .setContentTitle(label(this, "n_title", "Zaznamenávám trasu"))
            .setContentText(dist)
            .setOngoing(true)
            .setContentIntent(open)
            .addAction(Notification.Action.Builder(null, label(this, "n_stop", "Stop"), stop).build())
            .build()
    }

    private fun listen() {
        if (lm != null) return
        if (!hasLocationPermission(this)) {
            stopTracking()
            return
        }
        val m = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        lm = m
        try {
            m.requestLocationUpdates(LocationManager.GPS_PROVIDER, 4000L, 5f, this, Looper.getMainLooper())
        } catch (e: Exception) {
            stopTracking()
        }
    }

    override fun onLocationChanged(loc: Location) {
        if (loc.hasAccuracy() && loc.accuracy > 35) return // nepřesné body (uvnitř budov)
        val p = prefs(this)
        if (!p.getBoolean("recording", false)) return
        val start = p.getLong("startedAt", System.currentTimeMillis())
        val t = (System.currentTimeMillis() - start) / 1000
        val points = JSONArray(p.getString("points", "[]"))
        var distance = p.getFloat("distance", 0f).toDouble()
        if (points.length() > 0) {
            val last = points.getJSONArray(points.length() - 1)
            val prev = Location("").apply {
                latitude = last.getDouble(0)
                longitude = last.getDouble(1)
            }
            val d = prev.distanceTo(loc).toDouble()
            val dt = max(1L, t - last.getLong(2))
            if (d / dt > 70) return // skok polohy (> 250 km/h)
            if (d < max(5.0, (if (loc.hasAccuracy()) loc.accuracy else 10f) * 0.5)) return // stání na místě
            distance += d
        }
        points.put(JSONArray().put(round5(loc.latitude)).put(round5(loc.longitude)).put(t))
        p.edit().putString("points", points.toString()).putFloat("distance", distance.toFloat()).apply()
        val now = System.currentTimeMillis()
        if (now - lastNotify > 10_000) {
            lastNotify = now
            getSystemService(NotificationManager::class.java).notify(NOTIF_ID, buildNotification())
            updateWidget(this)
        }
    }

    private fun round5(v: Double) = Math.round(v * 100000.0) / 100000.0

    @Deprecated("Deprecated in Java")
    override fun onStatusChanged(provider: String?, status: Int, extras: android.os.Bundle?) {}
    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}

    private fun stopTracking() {
        lm?.removeUpdates(this)
        lm = null
        finish(this)
        running = false
        if (Build.VERSION.SDK_INT >= 24) stopForeground(STOP_FOREGROUND_REMOVE) else @Suppress("DEPRECATION") stopForeground(true)
        stopSelf()
    }

    override fun onDestroy() {
        lm?.removeUpdates(this)
        lm = null
        running = false
        super.onDestroy()
    }
}
