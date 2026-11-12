import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class NativeAudioService {
  static const MethodChannel _channel = MethodChannel('com.lumyra.lumyra/audio');

  static Future<bool> checkPermission() async {
    try {
      final res = await _channel.invokeMethod<bool>('checkPermission');
      return res ?? false;
    } catch (_) {
      return true;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } catch (_) {}
  }

  static Future<String?> startRecording() async {
    try {
      final hasPerm = await checkPermission();
      if (!hasPerm) {
        await requestPermission();
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final res = await _channel.invokeMethod<String>('startRecording', {'path': path});
      return res ?? path;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> stopRecording() async {
    try {
      final res = await _channel.invokeMethod<String>('stopRecording');
      return res;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> startPlaying(String path) async {
    try {
      if (!File(path).existsSync()) return false;
      final res = await _channel.invokeMethod<bool>('startPlaying', {'path': path});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> stopPlaying() async {
    try {
      await _channel.invokeMethod('stopPlaying');
    } catch (_) {}
  }
}
