import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/models/design_config.dart';

class DesignController extends ChangeNotifier {
  DesignController._internal();
  static final DesignController instance = DesignController._internal();
  static const String _metaKey = 'design_config_v1';

  final AppDatabase _db = AppDatabase.instance;
  AppDesignConfig _config = AppDesignConfig.defaults;
  bool _isLoaded = false;

  AppDesignConfig get config => _config;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    if (_isLoaded) return;
    final raw = await _db.getAppMetaValue(_metaKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _config = AppDesignConfig.fromJson(decoded);
        } else if (decoded is Map) {
          _config = AppDesignConfig.fromJson(decoded.cast<String, dynamic>());
        }
      } catch (_) {
        _config = AppDesignConfig.defaults;
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> update(AppDesignConfig next) async {
    _config = next;
    notifyListeners();
    await _persist();
  }

  Future<void> resetToDefaults() async {
    _config = AppDesignConfig.defaults;
    notifyListeners();
    await _persist();
  }

  Future<void> setTableHeaderColor(Color color) =>
      update(_config.copyWith(tableHeaderColor: color));
  Future<void> setTableAreaColor(Color color) =>
      update(_config.copyWith(tableAreaColor: color));
  Future<void> setTransactionCardColor(Color color) =>
      update(_config.copyWith(transactionCardColor: color));
  Future<void> setSidebarColor(Color color) =>
      update(_config.copyWith(sidebarColor: color));
  Future<void> setAttachmentIconSize(double value) =>
      update(_config.copyWith(attachmentIconSize: value));
  Future<void> setTransactionRowHeight(double value) =>
      update(_config.copyWith(transactionRowHeight: value));
  Future<void> setRowVerticalPadding(double value) =>
      update(_config.copyWith(rowVerticalPadding: value));
  Future<void> setCardSpacing(double value) =>
      update(_config.copyWith(cardSpacing: value));
  Future<void> setCardBorderWidth(double value) =>
      update(_config.copyWith(cardBorderWidth: value));
  Future<void> setBaseFontSize(double value) =>
      update(_config.copyWith(baseFontSize: value));
  Future<void> setButtonShapeStyle(int value) =>
      update(_config.copyWith(buttonShapeStyle: value));
  Future<void> setButtonPresetStyle(int value) =>
      update(_config.copyWith(buttonPresetStyle: value));
  Future<void> setButtonBgColor(Color value) =>
      update(_config.copyWith(buttonBgColor: value));
  Future<void> setButtonTextColor(Color value) =>
      update(_config.copyWith(buttonTextColor: value));
  Future<void> setButtonBorderColor(Color value) =>
      update(_config.copyWith(buttonBorderColor: value));
  Future<void> setButtonBorderWidth(double value) =>
      update(_config.copyWith(buttonBorderWidth: value));
  Future<void> setButtonRadius(double value) =>
      update(_config.copyWith(buttonRadius: value));
  Future<void> setButtonShadowBlur(double value) =>
      update(_config.copyWith(buttonShadowBlur: value));
  Future<void> setButtonShadowOpacity(double value) =>
      update(_config.copyWith(buttonShadowOpacity: value));
  Future<void> setButtonShine(double value) =>
      update(_config.copyWith(buttonShine: value));
  Future<void> setUiBrightnessShift(double value) =>
      update(_config.copyWith(uiBrightnessShift: value));
  Future<void> setUseDistinctActionButtonColors(bool value) =>
      update(_config.copyWith(useDistinctActionButtonColors: value));
  Future<void> setActionAddButtonColor(Color value) =>
      update(_config.copyWith(actionAddButtonColor: value));
  Future<void> setActionEditButtonColor(Color value) =>
      update(_config.copyWith(actionEditButtonColor: value));
  Future<void> setActionDeleteButtonColor(Color value) =>
      update(_config.copyWith(actionDeleteButtonColor: value));
  Future<void> setActionStatusButtonColor(Color value) =>
      update(_config.copyWith(actionStatusButtonColor: value));
  Future<void> setFontFamilyName(String value) =>
      update(_config.copyWith(fontFamilyName: value));
  Future<void> setFontWeightLevel(double value) =>
      update(_config.copyWith(fontWeightLevel: value));

  Color onColorFor(Color background, {Color light = Colors.white, Color dark = Colors.black}) {
    final contrastLight = _contrastRatio(background, light);
    final contrastDark = _contrastRatio(background, dark);
    return contrastLight >= contrastDark ? light : dark;
  }

  bool hasGoodContrast(Color foreground, Color background, {double minRatio = 4.5}) {
    return _contrastRatio(foreground, background) >= minRatio;
  }

  double _contrastRatio(Color a, Color b) {
    final l1 = a.computeLuminance();
    final l2 = b.computeLuminance();
    final brighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (brighter + 0.05) / (darker + 0.05);
  }

  Color shiftColor(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + delta).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Future<void> _persist() async {
    final jsonText = jsonEncode(_config.toJson());
    await _db.setAppMetaValue(_metaKey, jsonText);
  }
}
