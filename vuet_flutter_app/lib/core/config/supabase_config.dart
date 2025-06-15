import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuration class for Supabase integration
class SupabaseConfig {
  // Private constructor to prevent direct instantiation
  SupabaseConfig._();

  // Supabase project URL
  static const String supabaseUrl = 'https://vhiwshayajhjmrouddqi.supabase.co';
  
  // Anon key for public client access
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZoaXdzaGF5YWpoam1yb3VkZHFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5MzExMTMsImV4cCI6MjA2NTUwNzExM30.ixFBNk5LcqrkhslzYsqQV3aiOcig0VQQoyKlzSikxNo';

  // Storage bucket names
  static const String entityBucket = 'entities';
  static const String listsBucket = 'lists';
  static const String messagesBucket = 'messages';

  // Environment configuration
  static const bool isDevelopment = kDebugMode;
  static const int timeoutDuration = 15; // seconds

  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authFlowType: AuthFlowType.pkce,
      debug: isDevelopment,
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 40,
      ),
      storageOptions: const StorageOptions(
        retryAttempts: 3,
        uploadTimeout: Duration(minutes: 5),
      ),
    );
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Get the Supabase auth instance
  static GoTrueClient get auth => Supabase.instance.client.auth;
  
  /// Get the Supabase storage instance
  static SupabaseStorageClient get storage => Supabase.instance.client.storage;
  
  /// Get the Supabase realtime instance
  static RealtimeClient get realtime => Supabase.instance.client.realtime;
}
