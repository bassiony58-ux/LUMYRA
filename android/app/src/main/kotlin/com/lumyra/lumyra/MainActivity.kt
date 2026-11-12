package com.lumyra.lumyra

import android.Manifest
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lumyra.lumyra/audio"
    private var mediaRecorder: MediaRecorder? = null
    private var mediaPlayer: MediaPlayer? = null
    private var currentRecordingPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermission" -> {
                    val granted = ContextCompat.checkSelfPermission(
                        this,
                        Manifest.permission.RECORD_AUDIO
                    ) == PackageManager.PERMISSION_GRANTED
                    result.success(granted)
                }
                "requestPermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.RECORD_AUDIO),
                        1001
                    )
                    result.success(true)
                }
                "startRecording" -> {
                    try {
                        val path = call.argument<String>("path")
                            ?: "${cacheDir.absolutePath}/voice_${System.currentTimeMillis()}.m4a"
                        currentRecordingPath = path

                        val recorder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            MediaRecorder(this)
                        } else {
                            @Suppress("DEPRECATION")
                            MediaRecorder()
                        }

                        recorder.setAudioSource(MediaRecorder.AudioSource.MIC)
                        recorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                        recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                        recorder.setAudioEncodingBitRate(128000)
                        recorder.setAudioSamplingRate(44100)
                        recorder.setOutputFile(path)
                        recorder.prepare()
                        recorder.start()

                        mediaRecorder = recorder
                        result.success(path)
                    } catch (e: Exception) {
                        result.error("RECORD_ERROR", e.message, null)
                    }
                }
                "stopRecording" -> {
                    try {
                        mediaRecorder?.let {
                            it.stop()
                            it.release()
                        }
                        mediaRecorder = null
                        result.success(currentRecordingPath)
                    } catch (e: Exception) {
                        mediaRecorder?.release()
                        mediaRecorder = null
                        result.success(currentRecordingPath)
                    }
                }
                "startPlaying" -> {
                    try {
                        val path = call.argument<String>("path")
                        if (path == null || !File(path).exists()) {
                            result.error("FILE_NOT_FOUND", "Audio file does not exist", null)
                            return@setMethodCallHandler
                        }

                        mediaPlayer?.release()
                        mediaPlayer = MediaPlayer().apply {
                            setDataSource(path)
                            prepare()
                            start()
                            setOnCompletionListener {
                                it.release()
                                mediaPlayer = null
                            }
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("PLAY_ERROR", e.message, null)
                    }
                }
                "stopPlaying" -> {
                    try {
                        mediaPlayer?.let {
                            if (it.isPlaying) it.stop()
                            it.release()
                        }
                        mediaPlayer = null
                        result.success(true)
                    } catch (e: Exception) {
                        mediaPlayer = null
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            mediaRecorder?.release()
            mediaPlayer?.release()
        } catch (_: Exception) {}
    }
}
