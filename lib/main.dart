import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'logic/design_controller.dart';
import 'ui/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await DesignController.instance.load();
  runApp(const InformDesktopApp());
}

class InformDesktopApp extends StatelessWidget {
  const InformDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final design = DesignController.instance;
    return AnimatedBuilder(
      animation: design,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'inform typing photo copy',
          theme: ThemeData(
            fontFamily: design.config.fontFamilyName,
            colorScheme: ColorScheme.fromSeed(seedColor: design.config.sidebarColor),
            textTheme: ThemeData.light().textTheme.copyWith(
                  bodyLarge: TextStyle(
                    fontSize: design.config.baseFontSize,
                    height: 1.5,
                    letterSpacing: 0.12,
                    fontWeight: FontWeight.w500,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: design.config.baseFontSize - 1,
                    height: 1.45,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w500,
                  ),
                  titleMedium: TextStyle(
                    fontSize: design.config.baseFontSize + 1,
                    height: 1.35,
                    letterSpacing: 0.08,
                    fontWeight: FontWeight.w700,
                  ),
                  titleLarge: TextStyle(
                    fontSize: design.config.baseFontSize + 3,
                    height: 1.3,
                    letterSpacing: 0.06,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            useMaterial3: true,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
