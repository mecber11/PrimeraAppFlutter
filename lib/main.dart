import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Notificador global para alternar entre Modo Claro y Modo Oscuro
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Asegura que los bindings de Flutter estén inicializados antes de SQLite
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiPrimeraApp());
}

class MiPrimeraApp extends StatelessWidget {
  const MiPrimeraApp({super.key});

  // Colores distintivos Hatsune Miku
  static const Color mikuTeal = Color(0xFF39C5BB);
  static const Color mikuPink = Color(0xFFE12885);
  static const Color mikuDarkBg = Color(0xFF12131A);       // Negro profundo
  static const Color mikuDarkSurface = Color(0xFF1C1E26);  // Superficie oscura

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Mi Primera App',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // ☀️ MODO DÍA: Predomina el blanco y celeste Miku
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF7FBFB),
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.light,
              seedColor: mikuTeal,
              primary: mikuTeal,
              secondary: mikuPink,
              surface: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: mikuTeal,
              foregroundColor: Colors.white,
              elevation: 2,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: mikuTeal,
              foregroundColor: Colors.white,
            ),
          ),
          // 🌙 MODO NOCHE: Predomina el negro y carbón, con celeste Miku brillante
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: mikuDarkBg,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: mikuTeal,
              primary: mikuTeal,
              secondary: mikuPink,
              surface: mikuDarkSurface,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF161720),
              foregroundColor: mikuTeal,
              elevation: 2,
              titleTextStyle: TextStyle(
                color: mikuTeal,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: mikuTeal),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: mikuTeal,
              foregroundColor: Colors.black87,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              backgroundColor: mikuDarkSurface,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: mikuDarkSurface,
            ),
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
