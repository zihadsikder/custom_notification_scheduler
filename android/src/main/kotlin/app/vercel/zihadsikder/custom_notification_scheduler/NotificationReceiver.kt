package app.vercel.zihadsikder.custom_notification_scheduler

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import android.app.PendingIntent // Added for PendingIntent

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: ""
        val body = intent.getStringExtra("body") ?: ""
        val sound = intent.getStringExtra("sound")
        val payload = intent.getSerializableExtra("payload") as? Map<*, *>

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "default_channel",
                "Default Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                enableVibration(true)
                setSound(sound?.let { android.net.Uri.parse("android.resource://package app.vercel.zihadsikder.custom_notification_scheduler/raw/$sound") }, null)
            }
            notificationManager.createNotificationChannel(channel)
        }

        val builder = NotificationCompat.Builder(context, "default_channel")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setSound(sound?.let { android.net.Uri.parse("android.resource://package app.vercel.zihadsikder.custom_notification_scheduler/raw/$sound") })

        // Remove or replace MainActivity with a valid activity from the example app
        // For now, remove the payload intent to avoid the unresolved reference
        // If you need payload handling, update with the correct activity (e.g., from example/android/app/src/main/java/.../MainActivity)
        /*
        if (payload != null) {
            builder.setContentIntent(
                PendingIntent.getActivity(
                    context,
                    0,
                    Intent(context, MainActivity::class.java).apply {
                        putExtra("payload", payload as java.io.Serializable)
                    },
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
        }
        */

        notificationManager.notify(0, builder.build())
    }
}