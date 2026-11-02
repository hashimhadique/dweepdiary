import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize OneSignal Push Notifications
  Future<void> initialize({Function(String? postUrl)? onNotificationClicked}) async {
    // Only initialize if a valid App ID is configured
    if (AppConstants.oneSignalAppId == 'YOUR_ONESIGNAL_APP_ID_HERE') {
      debugPrint('OneSignal: App ID not configured yet. Skipping initialization.');
      return;
    }

    try {
      // Debug logging in development
      if (kDebugMode) {
        OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      }

      // Initialize OneSignal
      OneSignal.initialize(AppConstants.oneSignalAppId);

      // Request push notification permissions from user
      await OneSignal.Notifications.requestPermission(true);

      // Handle notification clicks
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('NOTIFICATION CLICK LISTENER FIRED: ${event.notification.jsonRepresentation()}');
        
        // Extract launch URL or custom data attached to the notification
        final launchUrl = event.notification.launchUrl;
        final additionalData = event.notification.additionalData;
        final targetUrl = launchUrl ?? (additionalData?['post_url'] as String?);

        onNotificationClicked?.call(targetUrl);
      });
    } catch (e) {
      debugPrint('OneSignal initialization error: $e');
    }
  }
}
