import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_helper.dart';
import 'core/database/analytics_database_helper.dart';
import 'features/health_records/providers/health_record_provider.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/analytics/services/analytics_service.dart';
import 'features/health_records/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database and insert dummy data
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database; // This will create the database
  await dbHelper.insertDummyData(); // Insert sample data if database is empty
  
  // Initialize analytics database
  final analyticsDbHelper = AnalyticsDatabaseHelper.instance;
  await analyticsDbHelper.database; // This will create the analytics database
  
  // Start analytics session
  await AnalyticsService.instance.startSession();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HealthRecordProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'HealthMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
