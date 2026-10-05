package com.neteru.n_pass

import android.content.ClipData
import android.content.ClipboardManager
import android.Manifest
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.provider.Settings
import android.view.WindowManager
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity: required by the biometric prompt (local_auth,
// flutter_secure_storage).
class MainActivity : FlutterFragmentActivity() {
    private val clipHandler = Handler(Looper.getMainLooper())
    private var clipGeneration = 0

    private var pendingSave: Pair<ByteArray, MethodChannel.Result>? = null
    private val createDocument = registerForActivityResult(ActivityResultContracts.CreateDocument(BACKUP_MIME_TYPE)) { uri ->
        val (bytes, result) = pendingSave ?: return@registerForActivityResult
        pendingSave = null
        if (uri == null) {
            result.success(false)
            return@registerForActivityResult
        }
        try {
            contentResolver.openOutputStream(uri, "wt")!!.use { it.write(bytes) }
            result.success(true)
        } catch (e: Exception) {
            result.error("write_failed", e.message, null)
        }
    }

    // Camera permission for the QR scanner. Requested here rather than by the
    // scanner plugin, which asks again on every resume while it is denied.
    private var pendingCameraRequest: MethodChannel.Result? = null
    private val requestCamera = registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
        pendingCameraRequest?.success(granted)
        pendingCameraRequest = null
    }

    private val hasCameraPermission
        get() = checkSelfPermission(Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep vault content out of screenshots, screen recordings and the
        // recent apps thumbnail. Left off in debug builds so the UI can be
        // checked with screenshots.
        val debuggable = applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
        if (!debuggable) {
            window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "npass/clipboard").setMethodCallHandler { call, result ->
            when (call.method) {
                "copySensitive" -> {
                    copySensitive(call.argument<String>("text")!!, call.argument<Int>("clearAfterMs")!!.toLong())
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "npass/camera").setMethodCallHandler { call, result ->
            when (call.method) {
                "check" -> result.success(hasCameraPermission)
                "request" -> {
                    if (hasCameraPermission) {
                        result.success(true)
                    } else {
                        pendingCameraRequest?.success(false)
                        pendingCameraRequest = result
                        requestCamera.launch(Manifest.permission.CAMERA)
                    }
                }
                "openSettings" -> {
                    startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null)))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        // Saves a file where the user picks through the system document picker
        // (Storage Access Framework): no storage permission needed.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "npass/files").setMethodCallHandler { call, result ->
            when (call.method) {
                "saveFile" -> {
                    pendingSave?.second?.success(false)
                    pendingSave = call.argument<ByteArray>("bytes")!! to result
                    createDocument.launch(call.argument<String>("name")!!)
                }
                else -> result.notImplemented()
            }
        }
    }

    /**
     * Copies [text] flagged as sensitive (hidden from the Android 13+ clipboard
     * preview and keyboard suggestions), then clears it after [clearAfterMs]
     * unless something else was copied meanwhile. The check only reads the clip
     * description, so it never triggers the "app pasted from your clipboard"
     * toast.
     */
    private fun copySensitive(text: String, clearAfterMs: Long) {
        val clipboard = getSystemService(ClipboardManager::class.java)
        val clip = ClipData.newPlainText(CLIP_LABEL, text)
        clip.description.extras = PersistableBundle().apply { putBoolean(EXTRA_IS_SENSITIVE, true) }
        clipboard.setPrimaryClip(clip)

        val generation = ++clipGeneration
        clipHandler.postDelayed({
            if (generation != clipGeneration) return@postDelayed
            if (clipboard.primaryClipDescription?.label != CLIP_LABEL) return@postDelayed
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                clipboard.clearPrimaryClip()
            } else {
                clipboard.setPrimaryClip(ClipData.newPlainText("", ""))
            }
        }, clearAfterMs)
    }

    private companion object {
        const val CLIP_LABEL = "NPass"
        const val BACKUP_MIME_TYPE = "application/octet-stream"
        // ClipDescription.EXTRA_IS_SENSITIVE (API 33), honored by older
        // Android 13 builds too when set by name.
        const val EXTRA_IS_SENSITIVE = "android.content.extra.IS_SENSITIVE"
    }
}
