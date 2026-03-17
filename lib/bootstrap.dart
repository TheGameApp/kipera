import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/services/notification_service.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  debugPrint('⚙️ [Bootstrap] Supabase URL: $supabaseUrl');
  debugPrint('⚙️ [Bootstrap] Anon key loaded: ${supabaseAnonKey.isNotEmpty ? '✅ yes (${supabaseAnonKey.substring(0, 20)}...)' : '❌ MISSING'}');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint('❌ [Bootstrap] ERROR: Missing Supabase credentials in .env file!');
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  debugPrint('✅ [Bootstrap] Supabase initialized successfully');

  final notificationService = NotificationService();
  await notificationService.init();
  debugPrint('✅ [Bootstrap] Notifications initialized');

  // Debug: list any pending notifications from previous sessions
  await notificationService.debugListPending();

}
