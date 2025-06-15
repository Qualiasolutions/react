// lib/core/utils/logger.dart
// Comprehensive logging utility for Vuet Flutter app

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/material.dart';

/// Logger utility for consistent logging throughout the app
/// Integrates with Sentry for production error tracking
class Logger {
  // Private constructor to prevent instantiation
  Logger._();
  
  // Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;
  static const int _levelNone = 4;
  
  // Current minimum log level
  // In production, this should be set to _levelWarning or higher
  static int _minLevel = kDebugMode ? _levelDebug : _levelWarning;
  
  // Colors for console output
  static const String _resetColor = '\x1B[0m';
  static const String _debugColor = '\x1B[36m'; // Cyan
  static const String _infoColor = '\x1B[32m';  // Green
  static const String _warnColor = '\x1B[33m';  // Yellow
  static const String _errorColor = '\x1B[31m'; // Red
  
  /// Configure the minimum log level
  static void setLogLevel(int level) {
    _minLevel = level;
  }
  
  /// Enable all logs (for development)
  static void enableAllLogs() {
    _minLevel = _levelDebug;
  }
  
  /// Disable all logs (for production)
  static void disableAllLogs() {
    _minLevel = _levelNone;
  }
  
  /// Log a debug message
  static void debug(String message) {
    if (_minLevel <= _levelDebug) {
      _printLog('DEBUG', message, _debugColor);
    }
  }
  
  /// Log an info message
  static void info(String message) {
    if (_minLevel <= _levelInfo) {
      _printLog('INFO', message, _infoColor);
    }
  }
  
  /// Log a warning message
  static void warning(String message) {
    if (_minLevel <= _levelWarning) {
      _printLog('WARNING', message, _warnColor);
    }
  }
  
  /// Log an error message
  /// Optionally include exception and stack trace
  static void error(String message, [dynamic exception, StackTrace? stackTrace]) {
    if (_minLevel <= _levelError) {
      _printLog('ERROR', message, _errorColor);
      
      if (exception != null) {
        debugPrint('$_errorColor[ERROR] Exception: $exception$_resetColor');
      }
      
      if (stackTrace != null) {
        debugPrint('$_errorColor[ERROR] StackTrace: $stackTrace$_resetColor');
      }
    }
    
    // In production, send to Sentry
    if (!kDebugMode && exception != null) {
      _sendToSentry(message, exception, stackTrace);
    }
  }
  
  /// Log a critical error and send to Sentry regardless of environment
  static void critical(String message, dynamic exception, StackTrace stackTrace) {
    _printLog('CRITICAL', message, _errorColor);
    debugPrint('$_errorColor[CRITICAL] Exception: $exception$_resetColor');
    debugPrint('$_errorColor[CRITICAL] StackTrace: $stackTrace$_resetColor');
    
    // Always send critical errors to Sentry
    _sendToSentry(message, exception, stackTrace, SentryLevel.fatal);
  }
  
  /// Log a UI error with BuildContext for better debugging
  static void uiError(String message, BuildContext context, [dynamic exception, StackTrace? stackTrace]) {
    if (_minLevel <= _levelError) {
      final widget = context.widget.runtimeType.toString();
      _printLog('UI ERROR', '$message (in $widget)', _errorColor);
      
      if (exception != null) {
        debugPrint('$_errorColor[UI ERROR] Exception: $exception$_resetColor');
      }
      
      if (stackTrace != null) {
        debugPrint('$_errorColor[UI ERROR] StackTrace: $stackTrace$_resetColor');
      }
    }
    
    // In production, send to Sentry with widget info
    if (!kDebugMode && exception != null) {
      final widget = context.widget.runtimeType.toString();
      _sendToSentry('$message (in $widget)', exception, stackTrace);
    }
  }
  
  /// Log network-related errors
  static void networkError(String message, String url, [dynamic exception, StackTrace? stackTrace]) {
    if (_minLevel <= _levelError) {
      _printLog('NETWORK ERROR', '$message (URL: $url)', _errorColor);
      
      if (exception != null) {
        debugPrint('$_errorColor[NETWORK ERROR] Exception: $exception$_resetColor');
      }
      
      if (stackTrace != null) {
        debugPrint('$_errorColor[NETWORK ERROR] StackTrace: $stackTrace$_resetColor');
      }
    }
    
    // In production, send to Sentry with URL info
    if (!kDebugMode && exception != null) {
      final sentryEvent = SentryEvent(
        message: SentryMessage('$message (URL: $url)'),
        throwable: exception,
        level: SentryLevel.error,
      );
      
      Sentry.captureEvent(sentryEvent, stackTrace: stackTrace);
    }
  }
  
  /// Print a formatted log message
  static void _printLog(String level, String message, String color) {
    final timestamp = DateTime.now().toString().split('.').first;
    debugPrint('$color[$level][$timestamp] $message$_resetColor');
  }
  
  /// Send an error to Sentry
  static Future<void> _sendToSentry(
    String message, 
    dynamic exception, 
    StackTrace? stackTrace, 
    [SentryLevel level = SentryLevel.error]
  ) async {
    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace ?? StackTrace.current,
        hint: message,
      );
    } catch (e) {
      // If Sentry fails, at least print to console
      debugPrint('Failed to send error to Sentry: $e');
    }
  }
  
  /// Add breadcrumb for Sentry tracking
  static void breadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        timestamp: DateTime.now(),
        level: SentryLevel.info,
      ),
    );
  }
  
  /// Start performance monitoring for a specific operation
  static ISentrySpan? startPerformanceTracking(String operation, {String? description}) {
    try {
      final transaction = Sentry.startTransaction(operation, description ?? 'Performance Monitoring');
      return transaction;
    } catch (e) {
      debug('Failed to start performance tracking: $e');
      return null;
    }
  }
  
  /// Finish performance monitoring
  static void finishPerformanceTracking(ISentrySpan? span) {
    try {
      span?.finish();
    } catch (e) {
      debug('Failed to finish performance tracking: $e');
    }
  }
}
