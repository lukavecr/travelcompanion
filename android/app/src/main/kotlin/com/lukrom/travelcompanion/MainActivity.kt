package com.lukrom.travelcompanion

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // záznam trasy (TrackService) – aplikace je jen „ovladač“, body sbírá služba
        MethodChannel(messenger, "tc/tracker").setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    TrackService.start(this)
                    result.success(null)
                }
                "stop" -> {
                    TrackService.stop(this)
                    result.success(null)
                }
                "state" -> {
                    val p = TrackService.prefs(this)
                    result.success(
                        JSONObject()
                            .put("recording", p.getBoolean("recording", false))
                            .put("startedAt", p.getLong("startedAt", 0))
                            .put("distance", p.getFloat("distance", 0f).toDouble())
                            .put("points", p.getString("points", "[]"))
                            .toString(),
                    )
                }
                "takeFinished" -> {
                    val p = TrackService.prefs(this)
                    val f = p.getString("finished", "[]")
                    p.edit().putString("finished", "[]").apply()
                    result.success(f)
                }
                "setLabels" -> {
                    val e = TrackService.prefs(this).edit()
                    (call.arguments as? Map<*, *>)?.forEach { (k, v) -> e.putString(k.toString(), v.toString()) }
                    e.apply()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ochrana obrazovky: Vault a doklady se neukážou v přehledu aplikací ani na snímku obrazovky
        MethodChannel(messenger, "tc/secure").setMethodCallHandler { call, result ->
            if (call.method == "setSecure") {
                if (call.arguments == true) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
