package app.vercel.zihadsikder.custom_notification_scheduler

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class CustomNotificationSchedulerPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "custom_notification_scheduler")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "scheduleNotification" -> {
        val title = call.argument<String>("title") ?: ""
        val body = call.argument<String>("body") ?: ""
        val scheduledTimeStr = call.argument<String>("scheduledTime") ?: ""
        val sound = call.argument<String>("sound")
        val payload = call.argument<Map<String, Any>?>("payload") ?: emptyMap()
        val repeatInterval = call.argument<String>("repeatInterval")

        val scheduledTime = try {
          Date.from(ZonedDateTime.parse(scheduledTimeStr).toInstant())
        } catch (e: Exception) {
          result.error("INVALID_TIME", "Invalid scheduled time", e)
          return
        }

        scheduleNotification(
          title = title,
          body = body,
          scheduledTime = scheduledTime,
          sound = sound,
          payload = payload,
          repeatInterval = repeatInterval,
          result = result
        )
      }
      "cancelAllNotifications" -> {
        cancelAllNotifications(result)
      }
      else -> result.notImplemented()
    }
  }

  private fun scheduleNotification(
    title: String,
    body: String,
    scheduledTime: Date,
    sound: String?,
    payload: Map<String, Any>,
    repeatInterval: String?,
    result: Result
  ) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val intent = Intent(context, NotificationReceiver::class.java).apply {
      putExtra("title", title)
      putExtra("body", body)
      putExtra("sound", sound)
      putExtra("payload", payload as java.io.Serializable)
    }
    val pendingIntent = PendingIntent.getBroadcast(
      context,
      0,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val triggerTime = scheduledTime.time
    when (repeatInterval) {
      "RepeatInterval.daily" -> {
        alarmManager.setRepeating(
          AlarmManager.RTC_WAKEUP,
          triggerTime,
          AlarmManager.INTERVAL_DAY,
          pendingIntent
        )
      }
      "RepeatInterval.weekly" -> {
        alarmManager.setRepeating(
          AlarmManager.RTC_WAKEUP,
          triggerTime,
          AlarmManager.INTERVAL_DAY * 7,
          pendingIntent
        )
      }
      else -> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerTime,
            pendingIntent
          )
        } else {
          alarmManager.setExact(
            AlarmManager.RTC_WAKEUP,
            triggerTime,
            pendingIntent
          )
        }
      }
    }
    result.success(null)
  }

  private fun cancelAllNotifications(result: Result) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    val intent = Intent(context, NotificationReceiver::class.java)
    val pendingIntent = PendingIntent.getBroadcast(
      context,
      0,
      intent,
      PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    alarmManager.cancel(pendingIntent)
    result.success(null)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}