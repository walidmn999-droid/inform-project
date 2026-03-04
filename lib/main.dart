import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'logic/design_controller.dart';
import 'ui/login_page.dart';

Color _opaque(Color c) => Color.fromARGB(0xFF, c.red, c.green, c.blue);

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
        final cfg = design.config;
        final area = _opaque(cfg.tableAreaColor);
        final scheme = ColorScheme.light(
          primary: _opaque(cfg.buttonBgColor),
          onPrimary: _opaque(cfg.buttonTextColor),
          secondary: _opaque(cfg.actionEditButtonColor),
          onSecondary: Colors.white,
          error: _opaque(cfg.actionDeleteButtonColor),
          onError: Colors.white,
          surface: _opaque(cfg.transactionCardColor),
          onSurface: _opaque(cfg.customerCardTextColor),
          // ignore: deprecated_member_use
          background: area,
          // ignore: deprecated_member_use
          onBackground: _opaque(cfg.customerCardTextColor),
          // ignore: deprecated_member_use
          surfaceVariant: _opaque(cfg.surface2),
          outline: _opaque(design.shiftColor(cfg.customerCardBorderColor, 0.18)),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'inform typing photo copy',
          theme: ThemeData(
            fontFamily: cfg.fontFamilyName,
            colorScheme: scheme,
            scaffoldBackgroundColor: area,
            canvasColor: area,
            appBarTheme: AppBarTheme(
              backgroundColor: _opaque(cfg.tableHeaderColor),
              foregroundColor: _opaque(cfg.customerCardTextColor),
              surfaceTintColor: Colors.transparent,
            ),
            cardTheme: CardTheme(
              color: _opaque(cfg.transactionCardColor),
              surfaceTintColor: Colors.transparent,
            ),
            dialogTheme: const DialogTheme(
              surfaceTintColor: Colors.transparent,
            ),
            bottomSheetTheme: const BottomSheetThemeData(
              surfaceTintColor: Colors.transparent,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: _opaque(cfg.tableHeaderColor),
              contentTextStyle: TextStyle(color: scheme.onSurface),
              actionTextColor: scheme.primary,
            ),
            popupMenuTheme: PopupMenuThemeData(
              color: scheme.surface,
              surfaceTintColor: Colors.transparent,
              textStyle: TextStyle(color: scheme.onSurface),
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: scheme.surface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: _opaque(design.shiftColor(cfg.buttonBgColor, 0.12)),
              labelTextStyle: WidgetStatePropertyAll(
                TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                shadowColor: Colors.transparent,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: scheme.primary,
              ),
            ),
            iconTheme: IconThemeData(color: scheme.onSurface),
            textTheme: ThemeData.light().textTheme.copyWith(
                  bodyLarge: TextStyle(
                    fontSize: cfg.baseFontSize,
                    height: 1.5,
                    letterSpacing: 0.12,
                    fontWeight: FontWeight.w500,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: cfg.baseFontSize - 1,
                    height: 1.45,
                    letterSpacing: 0.1,
                    fontWeight: FontWeight.w500,
                  ),
                  titleMedium: TextStyle(
                    fontSize: cfg.baseFontSize + 1,
                    height: 1.35,
                    letterSpacing: 0.08,
                    fontWeight: FontWeight.w700,
                  ),
                  titleLarge: TextStyle(
                    fontSize: cfg.baseFontSize + 3,
                    height: 1.3,
                    letterSpacing: 0.06,
                    fontWeight: FontWeight.w700,
                  ),
                ).apply(
                  bodyColor: scheme.onSurface,
                  displayColor: scheme.onSurface,
                ),
            useMaterial3: true,
          ),
          home: const LoginPage(),
        );
      },
    );
  }
}
