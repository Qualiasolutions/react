// lib/core/constants/app_constants.dart
// Core constants for the Vuet Flutter app

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Information
class AppInfo {
  static const String name = 'Vuet';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const String copyright = '© ${DateTime.now().year} Vuet';
  static const String supportEmail = 'support@vuet.app';
}

/// Supabase Configuration
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get serviceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  
  // Storage buckets
  static const String entityBucket = 'entities';
  static const String listBucket = 'lists';
  static const String messageBucket = 'messages';
}

/// Category Constants
class Categories {
  // Core category IDs (matching database)
  static const int family = 1;
  static const int pets = 2;
  static const int socialInterests = 3;
  static const int education = 4;
  static const int career = 5;
  static const int travel = 6;
  static const int healthBeauty = 7;
  static const int home = 8;
  static const int garden = 9;
  static const int food = 10;
  static const int laundry = 11;
  static const int finance = 12;
  static const int transport = 13;
  
  // Category names
  static const Map<int, String> names = {
    family: 'Family',
    pets: 'Pets',
    socialInterests: 'Social & Interests',
    education: 'Education',
    career: 'Career',
    travel: 'Travel',
    healthBeauty: 'Health & Beauty',
    home: 'Home',
    garden: 'Garden',
    food: 'Food',
    laundry: 'Laundry',
    finance: 'Finance',
    transport: 'Transport',
  };
  
  // Category icons (material icon names)
  static const Map<int, IconData> icons = {
    family: Icons.family_restroom,
    pets: Icons.pets,
    socialInterests: Icons.people,
    education: Icons.school,
    career: Icons.work,
    travel: Icons.flight,
    healthBeauty: Icons.favorite,
    home: Icons.home,
    garden: Icons.eco,
    food: Icons.restaurant,
    laundry: Icons.local_laundry_service,
    finance: Icons.account_balance_wallet,
    transport: Icons.directions_car,
  };
  
  // Category colors
  static const Map<int, Color> colors = {
    family: Color(0xFF4CAF50),      // Green
    pets: Color(0xFFFF9800),        // Orange
    socialInterests: Color(0xFF2196F3), // Blue
    education: Color(0xFF9C27B0),   // Purple
    career: Color(0xFF607D8B),      // Blue Grey
    travel: Color(0xFF00BCD4),      // Cyan
    healthBeauty: Color(0xFFE91E63), // Pink
    home: Color(0xFF795548),        // Brown
    garden: Color(0xFF8BC34A),      // Light Green
    food: Color(0xFFFFC107),        // Amber
    laundry: Color(0xFF3F51B5),     // Indigo
    finance: Color(0xFF009688),     // Teal
    transport: Color(0xFFF44336),   // Red
  };
}

/// Entity Types
class EntityTypes {
  // Family
  static const String person = 'PERSON';
  static const String pet = 'PET';
  
  // Social
  static const String event = 'EVENT';
  static const String club = 'CLUB';
  static const String hobby = 'HOBBY';
  
  // Education
  static const String school = 'SCHOOL';
  static const String course = 'COURSE';
  static const String assignment = 'ASSIGNMENT';
  
  // Career
  static const String job = 'JOB';
  static const String project = 'PROJECT';
  static const String professionalEntity = 'PROFESSIONAL_ENTITY';
  
  // Travel
  static const String trip = 'TRIP';
  static const String flight = 'FLIGHT';
  static const String accommodation = 'ACCOMMODATION';
  
  // Health
  static const String medication = 'MEDICATION';
  static const String appointment = 'APPOINTMENT';
  static const String exercise = 'EXERCISE';
  
  // Home
  static const String home = 'HOME';
  static const String room = 'ROOM';
  static const String appliance = 'APPLIANCE';
  
  // Garden
  static const String plant = 'PLANT';
  static const String gardenArea = 'GARDEN_AREA';
  
  // Food
  static const String recipe = 'RECIPE';
  static const String mealPlan = 'MEAL_PLAN';
  
  // Transport
  static const String car = 'CAR';
  static const String bicycle = 'BICYCLE';
  static const String publicTransport = 'PUBLIC_TRANSPORT';
  
  // Finance
  static const String account = 'ACCOUNT';
  static const String subscription = 'SUBSCRIPTION';
  
  // All types list
  static const List<String> allTypes = [
    person, pet, event, club, hobby, school, course, assignment,
    job, project, professionalEntity, trip, flight, accommodation,
    medication, appointment, exercise, home, room, appliance,
    plant, gardenArea, recipe, mealPlan, car, bicycle, publicTransport,
    account, subscription
  ];
}

/// Task Types
class TaskTypes {
  static const String task = 'TASK';
  static const String appointment = 'APPOINTMENT';
  static const String dueDate = 'DUE_DATE';
  static const String flight = 'FLIGHT';
  static const String userBirthday = 'USER_BIRTHDAY';
  
  // Task urgency levels
  static const String low = 'LOW';
  static const String medium = 'MEDIUM';
  static const String high = 'HIGH';
  
  // Recurrence types
  static const String daily = 'DAILY';
  static const String weekly = 'WEEKLY';
  static const String monthly = 'MONTHLY';
  static const String yearly = 'YEARLY';
}

/// List Types
class ListTypes {
  static const String shopping = 'SHOPPING';
  static const String planning = 'PLANNING';
}

/// Date & Time Formats
class DateTimeFormats {
  static const String dateOnly = 'yyyy-MM-dd';
  static const String timeOnly = 'HH:mm';
  static const String dateTime = 'yyyy-MM-dd HH:mm';
  static const String dateTimeWithSeconds = 'yyyy-MM-dd HH:mm:ss';
  static const String dayMonth = 'dd MMM';
  static const String monthYear = 'MMM yyyy';
  static const String dayMonthYear = 'dd MMM yyyy';
  static const String weekday = 'EEEE';
  static const String weekdayShort = 'EEE';
}

/// UI Constants
class UIConstants {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Animation durations
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
  
  // Toast durations
  static const Duration toastShort = Duration(seconds: 2);
  static const Duration toastMedium = Duration(seconds: 4);
  static const Duration toastLong = Duration(seconds: 6);
}

/// Storage Keys
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String darkMode = 'dark_mode';
  static const String appLanguage = 'app_language';
  static const String notificationsEnabled = 'notifications_enabled';
}

/// API Endpoints (for any non-Supabase APIs)
class ApiEndpoints {
  static const String holidaysApi = 'https://date.nager.at/api/v3/publicholidays';
}
