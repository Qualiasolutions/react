import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vuet_flutter/core/config/supabase_config.dart';

/// Severity levels for logged errors.
///
/// Placed outside of [ErrorHandler] so that build-runner and analyzers
/// treat the enum as a top-level declaration and do not raise the
/// “Enums can't be declared inside classes” error.
enum ErrorLevel {
  info,
  warning,
  error,
  fatal,
}

/// A comprehensive error handling utility for the Vuet app
/// 
/// Provides methods for capturing, logging, and reporting errors
/// throughout the application with appropriate user feedback.
class ErrorHandler {
  // Private constructor to prevent instantiation
  ErrorHandler._();
  
  // Logger tag for filtering logs
  static const String _tag = 'VUET_ERROR';
  
  // Flag to check if error handler is initialized
  static bool _isInitialized = false;
  
  // In-memory log storage for recent errors (useful for debugging)
  static final List<String> _recentLogs = [];
  static const int _maxRecentLogs = 100;
  
  /// Initialize the error handler
  /// 
  /// Sets up global error catching for the app
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log error to console in debug mode
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      
      // Report to error tracking service
      reportError(
        'Flutter framework error',
        details.exception,
        stackTrace: details.stack,
        level: ErrorLevel.error,
      );
    };
    
    // Handle errors that occur during async operations
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(
        'Uncaught async error',
        error,
        stackTrace: stack,
        level: ErrorLevel.error,
      );
      return true; // Prevents the error from being propagated
    };
    
    _isInitialized = true;
    log('Error handler initialized', level: ErrorLevel.info);
  }
  
  /// Report an error to the logging system and crash reporting service
  /// 
  /// [message] A user-friendly description of the error
  /// [error] The actual error or exception object
  /// [stackTrace] Stack trace for the error
  /// [level] Severity level of the error
  /// [userId] Optional user ID for tracking errors by user
  static void reportError(
    String message,
    dynamic error, {
    StackTrace? stackTrace,
    ErrorLevel level = ErrorLevel.error,
    String? userId,
  }) {
    // Ensure we have a stack trace for better debugging
    stackTrace ??= StackTrace.current;
    
    // Format the error message
    final formattedMessage = _formatErrorMessage(message, error, stackTrace);
    
    // Log to console
    log(formattedMessage, level: level);
    
    // Store in recent logs
    _addToRecentLogs('${level.name.toUpperCase()}: $formattedMessage');
    
    // Send to crash reporting service if it's a significant error
    if (level == ErrorLevel.error || level == ErrorLevel.fatal) {
      _reportToCrashService(message, error, stackTrace, userId);
    }
    
    // For fatal errors, we might want to show a dialog or navigate to an error screen
    if (level == ErrorLevel.fatal && !kDebugMode) {
      // This would be implemented based on the app's navigation system
      // For example: NavigationService.navigateToErrorScreen();
    }
  }
  
  /// Log a message with appropriate formatting and level
  static void log(String message, {ErrorLevel level = ErrorLevel.info}) {
    final emoji = _getEmojiForLevel(level);
    final logMessage = '$emoji $_tag [${level.name.toUpperCase()}] $message';
    
    // Log based on level
    switch (level) {
      case ErrorLevel.info:
        debugPrint(logMessage);
        break;
      case ErrorLevel.warning:
        debugPrint('\x1B[33m$logMessage\x1B[0m'); // Yellow in debug console
        break;
      case ErrorLevel.error:
      case ErrorLevel.fatal:
        debugPrint('\x1B[31m$logMessage\x1B[0m'); // Red in debug console
        break;
    }
  }
  
  /// Get recent error logs (useful for displaying in debug screens)
  static List<String> getRecentLogs() {
    return List.unmodifiable(_recentLogs);
  }
  
  /// Clear recent error logs
  static void clearRecentLogs() {
    _recentLogs.clear();
  }
  
  /// Handle network-specific errors with user-friendly messages
  static String handleNetworkError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return 'Unable to connect to the server. Please check your internet connection and try again.';
    } else if (error is PlatformException) {
      return 'A device error occurred: ${error.message}';
    } else if (error is FormatException) {
      return 'Unexpected response from server. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }
  
  /// Handle Supabase-specific errors
  static String handleSupabaseError(dynamic error) {
    // Extract error message from Supabase error object
    final errorMessage = error.toString();
    
    if (errorMessage.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'Please verify your email address before logging in.';
    } else if (errorMessage.contains('User already registered')) {
      return 'An account with this email already exists.';
    } else if (errorMessage.contains('JWT expired')) {
      return 'Your session has expired. Please log in again.';
    } else {
      return 'An error occurred with the database. Please try again later.';
    }
  }
  
  /// Format error message with relevant details
  static String _formatErrorMessage(
    String message,
    dynamic error,
    StackTrace stackTrace,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(message);
    buffer.writeln('Error: ${error.toString()}');
    
    // Only include stack trace in debug mode or for severe errors
    if (kDebugMode) {
      buffer.writeln('Stack trace:');
      buffer.writeln(stackTrace.toString().split('\n').take(10).join('\n'));
      if (stackTrace.toString().split('\n').length > 10) {
        buffer.writeln('... (stack trace truncated)');
      }
    }
    
    return buffer.toString();
  }
  
  /// Add a log message to the recent logs list
  static void _addToRecentLogs(String log) {
    final timestamp = DateTime.now().toIso8601String();
    _recentLogs.add('[$timestamp] $log');
    
    // Keep the list at a reasonable size
    if (_recentLogs.length > _maxRecentLogs) {
      _recentLogs.removeAt(0);
    }
  }
  
  /// Report error to a crash reporting service
  static void _reportToCrashService(
    String message,
    dynamic error,
    StackTrace stackTrace,
    String? userId,
  ) {
    // This would be implemented with a specific crash reporting service
    // For example, Firebase Crashlytics or Sentry
    
    // For now, just log that we would report this
    if (kDebugMode) {
      debugPrint('$_tag: Would report to crash service: $message');
    }
    
    // Example integration with a crash reporting service:
    // if (FirebaseCrashlytics.instance != null) {
    //   FirebaseCrashlytics.instance.recordError(
    //     error,
    //     stackTrace,
    //     reason: message,
    //     information: ['User ID: ${userId ?? 'unknown'}'],
    //   );
    // }
    
    // We could also log to Supabase for server-side error tracking
    _logErrorToSupabase(message, error, userId);
  }
  
  /// Log error to Supabase for server-side tracking
  static Future<void> _logErrorToSupabase(
    String message,
    dynamic error,
    String? userId,
  ) async {
    try {
      // Only log to Supabase if we're in production
      if (kReleaseMode) {
        await SupabaseConfig.client.from('error_logs').insert({
          'user_id': userId,
          'message': message,
          'error': error.toString(),
          'created_at': DateTime.now().toIso8601String(),
          'app_version': '1.0.0', // This should come from package_info
          'platform': Platform.operatingSystem,
        });
      }
    } catch (e) {
      // Don't report errors that happen while reporting errors
      if (kDebugMode) {
        debugPrint('$_tag: Failed to log error to Supabase: $e');
      }
    }
  }
  
  /// Get emoji for error level (makes logs more scannable)
  static String _getEmojiForLevel(ErrorLevel level) {
    switch (level) {
      case ErrorLevel.info:
        return 'ℹ️';
      case ErrorLevel.warning:
        return '⚠️';
      case ErrorLevel.error:
        return '❌';
      case ErrorLevel.fatal:
        return '💥';
    }
  }
  
  /// Show a user-friendly error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
