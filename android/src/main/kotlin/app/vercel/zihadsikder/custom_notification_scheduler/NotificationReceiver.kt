package app.vercel.zihadsikder.custom_notification_scheduler

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationReceiver : BroadcastReceiver() {
    companion object {
        private const val CHANNEL_ID = "default_channel"
        private const val CHANNEL_NAME = "Default Channel"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "Notification"
        val body = intent.getStringExtra("body") ?: ""
        val sound = intent.getStringExtra("sound")
        val payload = intent.getSerializableExtra("payload") as? Map<*, *>

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Sound URI
        val soundUri: Uri = sound?.let {
            Uri.parse("android.resource://${context.packageName}/raw/$it")
        } ?: Uri.parse("android.resource://${context.packageName}/raw/custom_sound")

        // Create channel if needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && notificationManager.getNotificationChannel(CHANNEL_ID) == null) {
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .build()

            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH).apply {
                enableVibration(true)
                setSound(soundUri, audioAttributes)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }

            notificationManager.createNotificationChannel(channel)
        }

        // Build notification
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setSound(soundUri)

        // Add PendingIntent if payload available
        if (payload != null) {
            val intentWithPayload = Intent(context, getMainActivityClass(context)).apply {
                putExtra("payload", payload as java.io.Serializable)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intentWithPayload,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.setContentIntent(pendingIntent)
        }

        // Show notification
        notificationManager.notify(0, builder.build())
    }

    private fun getMainActivityClass(context: Context): Class<*> {
        return try {
            Class.forName("${context.packageName}.MainActivity")
        } catch (e: ClassNotFoundException) {
            throw IllegalStateException("MainActivity not found in package ${context.packageName}", e)
        }
    }
}
