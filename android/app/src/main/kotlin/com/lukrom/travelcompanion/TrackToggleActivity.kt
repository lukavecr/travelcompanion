package com.lukrom.travelcompanion

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.net.Uri
import android.widget.Toast

/**
 * Neviditelná aktivita pro tlačítko Start/Stop na widgetu: zapne nebo vypne záznam trasy a hned se zavře,
 * aplikace se neotevře. (Službu s polohou smí Android spustit jen z viditelné aktivity, proto ne přímo z widgetu.)
 * Bez oprávnění k poloze otevře aplikaci, která o něj požádá.
 */
class TrackToggleActivity : Activity() {
    override fun onResume() {
        super.onResume()
        when {
            TrackService.isRecording(this) -> {
                TrackService.stop(this)
                toast(TrackService.label(this, "t_stopped", "Trasa uložena"))
            }
            !TrackService.hasLocationPermission(this) -> {
                startActivity(
                    Intent(this, MainActivity::class.java).setAction(Intent.ACTION_VIEW)
                        .setData(Uri.parse("travelcompanion://track"))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
            }
            !(getSystemService(Context.LOCATION_SERVICE) as LocationManager)
                .isProviderEnabled(LocationManager.GPS_PROVIDER) -> {
                toast(TrackService.label(this, "t_gps", "Zapni v telefonu polohu (GPS)."))
            }
            else -> {
                TrackService.start(this)
                toast(TrackService.label(this, "t_started", "Záznam trasy spuštěn"))
            }
        }
        finish()
        overridePendingTransition(0, 0)
    }

    private fun toast(text: String) = Toast.makeText(applicationContext, text, Toast.LENGTH_SHORT).show()
}
