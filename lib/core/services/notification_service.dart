import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'supabase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  debugPrint('[NotificationService] Background message received: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Timezones
      tz.initializeTimeZones();
      try {
        final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('[NotificationService] Timezone successfully set to $timeZoneName');
      } catch (e) {
        debugPrint('[NotificationService] Failed to set local timezone, falling back to UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      // 1. Initialize Firebase
      await Firebase.initializeApp();

      // 2. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Initialize Local Notifications for Foreground Displays
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Local notification tapped: ${response.payload}');
        },
      );

      // Create Android Notification Channels
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'motherhood_high_importance_channel_v2',
        'Moms of Tomorrow Notifications',
        description: 'This channel is used for Moms of Tomorrow push notifications.',
        importance: Importance.max,
      );

      const AndroidNotificationChannel inactivityChannel = AndroidNotificationChannel(
        'motherhood_inactivity_channel_v2',
        'Inactivity Reminders',
        description: 'Reminders sent when you have not opened the app today.',
        importance: Importance.max,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
        await androidPlugin.createNotificationChannel(inactivityChannel);
      }

      // 4. Request Permissions
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('[NotificationService] User granted notification permission');
      } else {
        debugPrint('[NotificationService] User declined notification permission');
      }

      // Also request Android local notification permission explicitly for Android 13+
      if (defaultTargetPlatform == TargetPlatform.android && androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('[NotificationService] Android local notification permission granted: $granted');
      }

      // 5. Configure Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[NotificationService] Foreground message received: ${message.notification?.title}');
        
        final RemoteNotification? notification = message.notification;
        final AndroidNotification? android = message.notification?.android;

        if (notification != null && !kIsWeb) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // 6. Configure Click-To-Open Handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[NotificationService] App opened via notification: ${message.notification?.title}');
      });

      // 7. Try Syncing FCM Token (if logged in)
      await syncTokenToSupabase();

      // Listen to Auth State Changes to sync token on login
      SupabaseService.authStateChanges.listen((state) async {
        if (state.event == AuthChangeEvent.signedIn) {
          await syncTokenToSupabase();
        }
      });

      _initialized = true;
      debugPrint('[NotificationService] Successfully initialized');
    } catch (e) {
      debugPrint('[NotificationService] Initialization skipped/failed: $e');
      debugPrint('[NotificationService] Note: This is normal if google-services.json is not yet added.');
    }
  }

  /// Sync FCM device token to current user's profile in Supabase
  static Future<void> syncTokenToSupabase() async {
    try {
      if (!SupabaseService.isLoggedIn) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) {
        debugPrint('[NotificationService] Could not retrieve FCM token');
        return;
      }

      debugPrint('[NotificationService] Syncing FCM token to Supabase: $token');
      
      final userId = SupabaseService.currentUser?.id;
      if (userId != null) {
        await SupabaseService.client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', userId);
        debugPrint('[NotificationService] FCM token successfully updated in Supabase');
      }
    } catch (e) {
      debugPrint('[NotificationService] Failed to sync FCM token to Supabase: $e');
    }
  }

  static const bool isTestingMode = false; // Set to false for production
  static const int _inactivityStartId = 900;
  static const int _numReminders = 12;
  static final List<Timer> _testTimers = []; // Store active Dart timers for testing

  /// Schedules inactivity notifications.
  /// DISABLED: Local inactivity notifications have been removed in favor of the Google Sheets push notification system.
  static Future<void> scheduleInactivityNotifications() async {
    // Simply ensure any existing local notifications are cancelled
    await cancelInactivityNotifications();
    debugPrint('[NotificationService] Local inactivity scheduling disabled in favor of Google Sheets push system.');
  }

  /// Cancels all scheduled inactivity reminders when the user returns
  static Future<void> cancelInactivityNotifications() async {
    // Cancel any active test timers
    for (final timer in _testTimers) {
      timer.cancel();
    }
    _testTimers.clear();

    // Cancel OS alarms
    for (int i = 0; i < _numReminders; i++) {
      final id = _inactivityStartId + i;
      try {
        await _localNotifications.cancel(id);
      } catch (e) {
        debugPrint('[NotificationService] Failed to cancel notification #$id: $e');
      }
    }
    debugPrint('[NotificationService] Inactivity notifications cancelled.');
  }
}
