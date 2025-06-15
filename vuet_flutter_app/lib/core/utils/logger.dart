// lib/core/utils/logger.dart
// Centralized logging and error reporting utility

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A utility class for logging messages and reporting errors.
/// It integrates with Sentry for error tracking in production.
class Logger {
  // Private constructor to prevent instantiation
  Logger._();

  /// Logs a debug message.
  /// Only logs in debug mode.
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _log('DEBUG', message, error, stackTrace);
    }
  }

  /// Logs an informational message.
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  /// Logs a warning message.
  /// Reports to Sentry in production.
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
    if (kReleaseMode) {
      Sentry.captureMessage(
        message,
        level: SentryLevel.warning,
      );
    }
  }

  /// Logs an error message.
  /// Reports to Sentry in production.
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
    if (kReleaseMode) {
      Sentry.captureException(
        error ?? Exception(message),
        stackTrace: stackTrace,
      );
    }
  }

  /// Logs a fatal error message.
  /// Reports to Sentry as fatal in production.
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('FATAL', message, error, stackTrace);
    if (kReleaseMode) {
      Sentry.captureException(
        error ?? Exception(message),
        stackTrace: stackTrace,
        level: SentryLevel.fatal,
      );
    }
  }

  /// Internal logging function.
  static void _log(
      String level, String message, dynamic error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [$level] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
