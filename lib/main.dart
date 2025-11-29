import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // ← 추가: 화면 방향 제어용
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quick_call/providers/speed_dial_provider.dart';
import 'package:quick_call/providers/settings_provider.dart';
import 'package:quick_call/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 화면 방향을 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,  // 정방향 세로만 허용
  ]);
  
  runApp(const QuickCallApp());
}

class QuickCallApp extends StatelessWidget {
  const QuickCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // 🆕 SettingsProvider 추가
            ChangeNotifierProvider(
              create: (_) => SettingsProvider()..initialize(),
            ),
            ChangeNotifierProvider(
              create: (_) => SpeedDialProvider()..initialize(),
            ),
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return MaterialApp(
                title: 'Quick Call',
                debugShowCheckedModeBanner: false,
                // 🆕 다크 모드 지원
                themeMode: settings.themeMode,
                // 라이트 테마
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  primaryColor: const Color(0xFF2196F3),
                  scaffoldBackgroundColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    backgroundColor: Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    centerTitle: true,
                  ),
                  floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Color(0xFF2196F3),
                  ),
                  cardTheme: const CardThemeData(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  useMaterial3: true,
                  brightness: Brightness.light,
                ),
                // 🆕 다크 테마
                darkTheme: ThemeData(
                  primarySwatch: Colors.blue,
                  primaryColor: const Color(0xFF2196F3),
                  scaffoldBackgroundColor: const Color(0xFF121212),
                  appBarTheme: const AppBarTheme(
                    elevation: 0,
                    backgroundColor: Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    centerTitle: true,
                  ),
                  floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Color(0xFF2196F3),
                  ),
                  cardTheme: const CardThemeData(
                    elevation: 2,
                    color: Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  dialogTheme: DialogThemeData(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  popupMenuTheme: PopupMenuThemeData(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  snackBarTheme: const SnackBarThemeData(
                    backgroundColor: Color(0xFF2C2C2C),
                    contentTextStyle: TextStyle(color: Colors.white),
                  ),
                  useMaterial3: true,
                  brightness: Brightness.dark,
                  // 다크 모드 색상 스킴
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF2196F3),
                    secondary: Color(0xFF03DAC6),
                    surface: Color(0xFF1E1E1E),
                    error: Color(0xFFCF6679),
                  ),
                ),
                home: child,
              );
            },
            child: const HomeScreen(),
          ),
        );
      },
    );
  }
}