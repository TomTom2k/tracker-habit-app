import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/routes/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/services/deep_link_service.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // .env file không tồn tại, sẽ sử dụng environment variables hoặc defaults
    print('Note: .env file not found. Using environment variables or defaults.');
  }
  
  // Khởi tạo Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Warning: Failed to initialize Supabase: $e');
    // App vẫn có thể chạy nhưng Supabase features sẽ không hoạt động
  }
  
  // Khởi tạo deep link service để handle OAuth callbacks
  DeepLinkService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => InjectionContainer.getAuthProvider()),
        ChangeNotifierProvider(create: (_) => InjectionContainer.getUserProfileProvider()),
        ChangeNotifierProvider(create: (_) => InjectionContainer.getHabitProvider()),
        ChangeNotifierProvider(create: (_) => InjectionContainer.getTodoProvider()),
        ChangeNotifierProvider(create: (_) => InjectionContainer.getPomodoroProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}