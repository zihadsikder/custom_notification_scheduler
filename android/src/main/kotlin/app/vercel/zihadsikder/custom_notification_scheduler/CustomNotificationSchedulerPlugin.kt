package app.vercel.zihadsikder.custom_notification_scheduler

import android.content.Context
import androidx.annotation.NonNull
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.Date

class CustomNotificationSchedulerPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "app.vercel.zihadsikder.custom_notification_scheduler")
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
          val formatterWithZone = DateTimeFormatter.ISO_OFFSET_DATE_TIME.withLocale(java.util.Locale.getDefault())
          val zonedDateTime = ZonedDateTime.parse(scheduledTimeStr, formatterWithZone)
          Date.from(zonedDateTime.toInstant())
        } catch (e: Exception) {
          try {
            val formatterWithoutZone = DateTimeFormatter.ISO_LOCAL_DATE_TIME
            val localDateTime = LocalDateTime.parse(scheduledTimeStr, formatterWithoutZone)
            val zonedDateTime = localDateTime.atZone(ZoneId.systemDefault())
            Date.from(zonedDateTime.toInstant())
          } catch (e2: Exception) {
            result.error("INVALID_TIME", "Invalid scheduled time: ${e2.message}", e2)
            return
          }
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
      "getFcmToken" -> {
        FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
          if (task.isSuccessful) {
            result.success(task.result)
          } else {
            result.error("FCM_ERROR", "Failed to get FCM token", task.exception)
          }
        }
      }
      "setNotificationSound" -> {
        val soundPath = call.argument<String>("soundPath")
        if (soundPath != null) {
          // Notify Dart to update _currentSoundPath
          channel.invokeMethod("updateSound", mapOf("soundPath" to soundPath))
          result.success(true)
        } else {
          result.error("INVALID_SOUND", "Sound path is required", null)
        }
      }
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
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
    val triggerTime = scheduledTime.time
    if (triggerTime < System.currentTimeMillis()) {
      result.error("INVALID_TIME", "Scheduled time must be in the future", null)
      return
    }

    channel.invokeMethod("scheduleLocalNotification", mapOf(
      "title" to title,
      "body" to body,
      "scheduledTime" to triggerTime,
      "sound" to sound,
      "payload" to payload,
      "repeatInterval" to repeatInterval
    ))
    result.success(null)
  }

  private fun cancelAllNotifications(result: Result) {
    channel.invokeMethod("cancelAllLocalNotifications", null)
    result.success(null)
  }



  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}