import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../constants/app_constants.dart';
import 'deep_link_service.dart';

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

      // Handle notification clicks: Prevent browser opening and route directly into app
      OneSignal.Notifications.addClickListener((event) {
        debugPrint('NOTIFICATION CLICK LISTENER FIRED: ${event.notification.jsonRepresentation()}');
        
        // Prevent default external browser opening by OneSignal SDK
        event.preventDefault();

        // Extract launch URL or custom data attached to the notification
        final launchUrl = event.notification.launchUrl;
        final additionalData = event.notification.additionalData;

        int? postId;
        if (additionalData != null) {
          if (additionalData['post_id'] != null) {
            postId = int.tryParse(additionalData['post_id'].toString());
          } else if (additionalData['id'] != null) {
            postId = int.tryParse(additionalData['id'].toString());
          }
        }

        final targetUrl = launchUrl ??
            (additionalData?['post_url'] as String?) ??
            (additionalData?['url'] as String?) ??
            (additionalData?['custom_url'] as String?);

        // Also extract post ID directly from targetUrl if present (e.g. ?p=4343 or &p=4343)
        if (postId == null && targetUrl != null) {
          final pMatch = RegExp(r'[?&](?:p|id)=(\d+)').firstMatch(targetUrl);
          if (pMatch != null) {
            postId = int.tryParse(pMatch.group(1)!);
          }
        }

        if (postId != null && postId > 0) {
          debugPrint('Routing notification post ID into app: $postId');
          DeepLinkService().openPostById(postId);
          onNotificationClicked?.call(postId.toString());
          return;
        }

        if (targetUrl != null && targetUrl.isNotEmpty) {
          debugPrint('Routing notification target URL into app: $targetUrl');
          DeepLinkService().handleRawRoute(targetUrl);
        }

        onNotificationClicked?.call(targetUrl);
      });

      // Request push notification permissions from user
      await OneSignal.Notifications.requestPermission(true);

      // Explicitly opt-in to push notifications
      OneSignal.User.pushSubscription.optIn();

      // Debug subscription status
      debugPrint('OneSignal: Push Subscription ID = ${OneSignal.User.pushSubscription.id}');
      debugPrint('OneSignal: Push Opted In = ${OneSignal.User.pushSubscription.optedIn}');

      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint('OneSignal: Subscription state changed -> ID: ${state.current.id}, Opted In: ${state.current.optedIn}');
      });
    } catch (e) {
      debugPrint('OneSignal initialization error: $e');
    }
  }
}
