import 'dart:async';

import 'package:flutter/services.dart';

/// سرویسی برای مانیتور کردن کلیپ‌بورد سیستم
///
/// این سرویس در پس‌زمینه به صورت دوره‌ای کلیپ‌بورد را چک می‌کند
/// و در صورت تشخیص متن جدید، یک رویداد را فعال می‌کند.
class ClipboardService {
  // Singleton pattern for a single instance
  static final ClipboardService _instance = ClipboardService._internal();

  factory ClipboardService() => _instance;

  ClipboardService._internal();

  Timer? _clipboardTimer;
  String _lastClipboardText = '';

  // A stream that emits new clipboard text
  final _clipboardStreamController = StreamController<String>.broadcast();

  Stream<String> get onClipboardChanged => _clipboardStreamController.stream;

  /// Starts monitoring the clipboard for changes.
  void startMonitoring() {
    // Stop any existing timer to avoid duplicates
    stopMonitoring();

    // Check clipboard periodically (e.g., every 2 seconds)
    _clipboardTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        final clipboardText = clipboardData?.text?.trim();

        if (clipboardText != null &&
            clipboardText.isNotEmpty &&
            clipboardText != _lastClipboardText) {
          _lastClipboardText = clipboardText;
          // Notify listeners about the new clipboard content
          _clipboardStreamController.add(clipboardText);
        }
      } catch (e) {
        // Could fail if clipboard is empty or in use
        // print("Error reading clipboard: $e");
      }
    });
  }

  /// Stops monitoring the clipboard.
  void stopMonitoring() {
    _clipboardTimer?.cancel();
    _clipboardTimer = null;
  }

  /// Manually retrieves the last known clipboard text.
  String get lastText => _lastClipboardText;

  // Close the stream controller when the service is no longer needed.
  void dispose() {
    _clipboardStreamController.close();
  }
}
