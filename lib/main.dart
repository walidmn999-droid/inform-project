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
            useMaterial3: true,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
