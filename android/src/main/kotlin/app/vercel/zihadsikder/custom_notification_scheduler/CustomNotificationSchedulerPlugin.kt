package app.vercel.zihadsikder.custom_notification_scheduler

import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.text.SimpleDateFormat
import java.util.*

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
          val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault())
          sdf.timeZone = TimeZone.getTimeZone("UTC")
          sdf.parse(scheduledTimeStr) ?: throw IllegalArgumentException("Invalid date format")
        } catch (e: Exception) {
          result.error("INVALID_TIME", "Invalid scheduled time format: ${e.message}", e)
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
          channel.invokeMethod("updateSound", mapOf("soundPath" to soundPath))
          result.success(true)
        } else {
          result.error("INVALID_SOUND", "Sound path is required", null)
        }
      }
      "getDeviceTimezone" -> {
        val timezone = TimeZone.getDefault().id // e.g., "Asia/Dhaka"
        result.success(timezone)
      }
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
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

    val args = mapOf(
      "title" to title,
      "body" to body,
      "scheduledTime" to triggerTime,
      "sound" to sound,
      "payload" to payload,
      "repeatInterval" to repeatInterval
    )

    val resultCallback = result

    channel.invokeMethod("scheduleLocalNotification", args, object : MethodChannel.Result {
      override fun success(response: Any?) {
        resultCallback.success(null)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        resultCallback.error(errorCode, errorMessage, errorDetails)
      }

      override fun notImplemented() {
        resultCallback.notImplemented()
      }
    })
  }

  private fun cancelAllNotifications(result: Result) {
    val resultCallback = result

    channel.invokeMethod("cancelAllLocalNotifications", null, object : MethodChannel.Result {
      override fun success(response: Any?) {
        resultCallback.success(null)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        resultCallback.error(errorCode, errorMessage, errorDetails)
      }

      override fun notImplemented() {
        resultCallback.notImplemented()
      }
    })
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}