package com.neteru.n_pass

import android.content.ClipData
import android.content.ClipboardManager
import android.content.pm.ApplicationInfo
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity: required by the biometric prompt (local_auth,
// flutter_secure_storage).
class MainActivity : FlutterFragmentActivity() {
    private val clipHandler = Handler(Looper.getMainLooper())
    private var clipGeneration = 0

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
        // ClipDescription.EXTRA_IS_SENSITIVE (API 33), honored by older
        // Android 13 builds too when set by name.
        const val EXTRA_IS_SENSITIVE = "android.content.extra.IS_SENSITIVE"
    }
}
