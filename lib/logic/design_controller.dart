import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../data/models/design_config.dart';

class SavedDesignTheme {
  const SavedDesignTheme({
    required this.id,
    required this.name,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final AppDesignConfig config;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedDesignTheme copyWith({
    int? id,
    String? name,
    AppDesignConfig? config,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedDesignTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      config: config ?? this.config,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'config': config.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static SavedDesignTheme? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final map = raw.cast<Object?, Object?>();

    final idRaw = map['id'];
    final id = idRaw is num ? idRaw.toInt() : int.tryParse('$idRaw');
    if (id == null) return null;

    final name = (map['name']?.toString() ?? '').trim();
    if (name.isEmpty) return null;

    final configRaw = map['config'];
    if (configRaw is! Map) return null;
    final config = AppDesignConfig.fromJson(configRaw.cast<String, dynamic>());

    final createdAtRaw = map['createdAt']?.toString();
    final updatedAtRaw = map['updatedAt']?.toString();
    final now = DateTime.now();

    return SavedDesignTheme(
      id: id,
      name: name,
      config: config,
      createdAt: DateTime.tryParse(createdAtRaw ?? '') ?? now,
      updatedAt: DateTime.tryParse(updatedAtRaw ?? '') ?? now,
    );
  }
}

class DesignController extends ChangeNotifier {
  DesignController._internal();
  static final DesignController instance = DesignController._internal();
  static const String _metaKey = 'design_config_v1';
  static const String _savedThemesMetaKey = 'design_saved_themes_v1';

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

  void preview(AppDesignConfig next) {
    _config = next;
    notifyListeners();
  }

  Future<void> applyChanges() async {
    await _persist();
  }

  void restoreSnapshot(AppDesignConfig snapshot) {
    _config = snapshot;
    notifyListeners();
  }

  Future<void> _previewUpdate(AppDesignConfig next) {
    preview(next);
    return Future<void>.value();
  }

  Future<void> resetToDefaults() async {
    _config = AppDesignConfig.defaults;
    notifyListeners();
  }

  Future<void> setTableHeaderColor(Color color) =>
      _previewUpdate(_config.copyWith(tableHeaderColor: color));
  Future<void> setTableAreaColor(Color color) =>
      _previewUpdate(_config.copyWith(tableAreaColor: color));
  Future<void> setTransactionCardColor(Color color) =>
      _previewUpdate(_config.copyWith(transactionCardColor: color));
  Future<void> setSidebarColor(Color color) =>
      _previewUpdate(_config.copyWith(sidebarColor: color));
  Future<void> setAttachmentIconSize(double value) =>
      _previewUpdate(_config.copyWith(attachmentIconSize: value));
  Future<void> setTransactionRowHeight(double value) =>
      _previewUpdate(_config.copyWith(transactionRowHeight: value));
  Future<void> setRowVerticalPadding(double value) =>
      _previewUpdate(_config.copyWith(rowVerticalPadding: value));
  Future<void> setCardSpacing(double value) =>
      _previewUpdate(_config.copyWith(cardSpacing: value));
  Future<void> setCardBorderWidth(double value) =>
      _previewUpdate(_config.copyWith(cardBorderWidth: value));
  Future<void> setBaseFontSize(double value) =>
      _previewUpdate(_config.copyWith(baseFontSize: value));
  Future<void> setButtonShapeStyle(int value) =>
      _previewUpdate(_config.copyWith(buttonShapeStyle: value));
  Future<void> setButtonPresetStyle(int value) =>
      _previewUpdate(_config.copyWith(buttonPresetStyle: value));
  Future<void> setButtonBgColor(Color value) =>
      _previewUpdate(_config.copyWith(buttonBgColor: value));
  Future<void> setButtonTextColor(Color value) =>
      _previewUpdate(_config.copyWith(buttonTextColor: value));
  Future<void> setButtonBorderColor(Color value) =>
      _previewUpdate(_config.copyWith(buttonBorderColor: value));
  Future<void> setButtonBorderWidth(double value) =>
      _previewUpdate(_config.copyWith(buttonBorderWidth: value));
  Future<void> setButtonRadius(double value) =>
      _previewUpdate(_config.copyWith(buttonRadius: value));
  Future<void> setButtonShadowBlur(double value) =>
      _previewUpdate(_config.copyWith(buttonShadowBlur: value));
  Future<void> setButtonShadowOpacity(double value) =>
      _previewUpdate(_config.copyWith(buttonShadowOpacity: value));
  Future<void> setButtonShine(double value) =>
      _previewUpdate(_config.copyWith(buttonShine: value));
  Future<void> setUiBrightnessShift(double value) =>
      _previewUpdate(_config.copyWith(uiBrightnessShift: value));
  Future<void> setUseDistinctActionButtonColors(bool value) =>
      _previewUpdate(_config.copyWith(useDistinctActionButtonColors: value));
  Future<void> setActionAddButtonColor(Color value) =>
      _previewUpdate(_config.copyWith(actionAddButtonColor: value));
  Future<void> setActionEditButtonColor(Color value) =>
      _previewUpdate(_config.copyWith(actionEditButtonColor: value));
  Future<void> setActionDeleteButtonColor(Color value) =>
      _previewUpdate(_config.copyWith(actionDeleteButtonColor: value));
  Future<void> setActionStatusButtonColor(Color value) =>
      _previewUpdate(_config.copyWith(actionStatusButtonColor: value));
  Future<void> setFontFamilyName(String value) =>
      _previewUpdate(_config.copyWith(fontFamilyName: value));
  Future<void> setFontWeightLevel(double value) =>
      _previewUpdate(_config.copyWith(fontWeightLevel: value));
  Future<void> setInvoicePrimaryColor(Color value) =>
      _previewUpdate(_config.copyWith(invoicePrimaryColor: value));
  Future<void> setInvoiceSecondaryColor(Color value) =>
      _previewUpdate(_config.copyWith(invoiceSecondaryColor: value));
  Future<void> setInvoiceAccentColor(Color value) =>
      _previewUpdate(_config.copyWith(invoiceAccentColor: value));
  Future<void> setInvoiceTextColor(Color value) =>
      _previewUpdate(_config.copyWith(invoiceTextColor: value));
  Future<void> setCustomerCardBgColor(Color value) =>
      _previewUpdate(_config.copyWith(customerCardBgColor: value));
  Future<void> setCustomerCardTextColor(Color value) =>
      _previewUpdate(_config.copyWith(customerCardTextColor: value));
  Future<void> setCustomerCardFontSize(double value) =>
      _previewUpdate(_config.copyWith(customerCardFontSize: value));
  Future<void> setCustomerCardFontFamily(String value) =>
      _previewUpdate(_config.copyWith(customerCardFontFamily: value));
  Future<void> setCustomerCardBorderRadius(double value) =>
      _previewUpdate(_config.copyWith(customerCardBorderRadius: value));
  Future<void> setCustomerCardBorderColor(Color value) =>
      _previewUpdate(_config.copyWith(customerCardBorderColor: value));
  Future<void> setCustomerCardBorderWidth(double value) =>
      _previewUpdate(_config.copyWith(customerCardBorderWidth: value));
  Future<void> setCustomerCardShadowBlur(double value) =>
      _previewUpdate(_config.copyWith(customerCardShadowBlur: value));
  Future<void> setCustomerCardStyle(int value) =>
      _previewUpdate(_config.copyWith(customerCardStyle: value));

  Future<List<SavedDesignTheme>> getSavedThemes() async {
    final list = await _loadSavedThemes();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  Future<SavedDesignTheme> saveCurrentTheme(String rawName, {int? id}) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      throw ArgumentError('Theme name cannot be empty');
    }

    final items = await _loadSavedThemes();
    final normalizedName = name.toLowerCase();
    final duplicated = items.any(
      (item) => item.id != id && item.name.trim().toLowerCase() == normalizedName,
    );
    if (duplicated) {
      throw ArgumentError('Theme name already exists');
    }

    final now = DateTime.now();
    SavedDesignTheme saved;
    if (id == null) {
      final nextId =
          items.isEmpty ? 1 : (items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      saved = SavedDesignTheme(
        id: nextId,
        name: name,
        config: _config,
        createdAt: now,
        updatedAt: now,
      );
      items.add(saved);
    } else {
      final index = items.indexWhere((item) => item.id == id);
      if (index == -1) {
        throw ArgumentError('Theme not found');
      }
      final base = items[index];
      saved = base.copyWith(
        name: name,
        config: _config,
        updatedAt: now,
      );
      items[index] = saved;
    }

    await _persistSavedThemes(items);
    return saved;
  }

  Future<void> renameSavedTheme(int id, String rawName) async {
    final name = rawName.trim();
    if (name.isEmpty) {
      throw ArgumentError('Theme name cannot be empty');
    }
    final items = await _loadSavedThemes();
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw ArgumentError('Theme not found');
    }

    final normalizedName = name.toLowerCase();
    final duplicated = items.any(
      (item) => item.id != id && item.name.trim().toLowerCase() == normalizedName,
    );
    if (duplicated) {
      throw ArgumentError('Theme name already exists');
    }

    items[index] = items[index].copyWith(name: name, updatedAt: DateTime.now());
    await _persistSavedThemes(items);
  }

  Future<void> deleteSavedTheme(int id) async {
    final items = await _loadSavedThemes();
    items.removeWhere((item) => item.id == id);
    await _persistSavedThemes(items);
  }

  Future<void> previewSavedTheme(int id) async {
    final items = await _loadSavedThemes();
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw ArgumentError('Theme not found');
    }
    preview(items[index].config);
  }

  static const List<String> paletteIds = <String>[
    'new_theme_linked',
    'linear_midnight',
    'arctic_neon',
    'ocean_glow',
    'slate_pro',
  ];

  static String paletteTitle(String id) {
    switch (id) {
      case 'new_theme_linked':
        return 'New Theme (Linked)';
      case 'linear_midnight':
        return 'Linear Midnight';
      case 'arctic_neon':
        return 'Arctic Neon';
      case 'ocean_glow':
        return 'Ocean Glow';
      case 'slate_pro':
        return 'Slate Pro';
      default:
        return 'Linear Midnight';
    }
  }

  Future<void> applyPalettePreset(String id) {
    final next = switch (id) {
      'new_theme_linked' => _config.copyWith(
          tableHeaderColor: const Color(0xFF22345F),
          tableAreaColor: const Color(0xFF21335E),
          transactionCardColor: const Color(0xFFF3F5F9),
          sidebarColor: const Color(0xFF22345F),
          buttonBgColor: const Color(0xFF0C4A7C),
          buttonTextColor: const Color(0xFFFFFFFF),
          buttonBorderColor: const Color(0x994CC9F0),
          actionAddButtonColor: const Color(0xFF0F766E),
          actionEditButtonColor: const Color(0xFF0369A1),
          actionDeleteButtonColor: const Color(0xFF7F1D1D),
          actionStatusButtonColor: const Color(0xFFF59E0B),
          transactionRowHeight: 48,
          rowVerticalPadding: 10,
          cardSpacing: 10,
          cardBorderWidth: 1,
          attachmentIconSize: 12,
          baseFontSize: 14,
          fontWeightLevel: 500,
          uiBrightnessShift: 0,
          buttonPresetStyle: 2,
          buttonShapeStyle: 0,
          buttonBorderWidth: 1,
          buttonRadius: 8,
          buttonShadowBlur: 14,
          buttonShadowOpacity: 0.2,
          buttonShine: 0.18,
          useDistinctActionButtonColors: true,
          fontFamilyName: 'Inter',
        ),
      'arctic_neon' => _config.copyWith(
          tableHeaderColor: const Color(0xFF1E293B),
          tableAreaColor: const Color(0xFF0B1324),
          transactionCardColor: const Color(0xFF172033),
          sidebarColor: const Color(0xFF0E172A),
          buttonBgColor: const Color(0xFF14F1D9),
          buttonTextColor: const Color(0xFF06131E),
          buttonBorderColor: const Color(0x9937E9F9),
          actionAddButtonColor: const Color(0xFF22C55E),
          actionEditButtonColor: const Color(0xFF22D3EE),
          actionDeleteButtonColor: const Color(0xFFFB7185),
          actionStatusButtonColor: const Color(0xFFFBBF24),
          buttonPresetStyle: 2,
          buttonRadius: 10,
          buttonShadowBlur: 18,
          buttonShadowOpacity: 0.30,
          buttonShine: 0.38,
          fontFamilyName: 'Inter',
        ),
      'ocean_glow' => _config.copyWith(
          tableHeaderColor: const Color(0xFF1D2A44),
          tableAreaColor: const Color(0xFF0A1020),
          transactionCardColor: const Color(0xFF14213B),
          sidebarColor: const Color(0xFF0B162B),
          buttonBgColor: const Color(0xFF00D4FF),
          buttonTextColor: const Color(0xFF03101D),
          buttonBorderColor: const Color(0x9948C6FF),
          actionAddButtonColor: const Color(0xFF34D399),
          actionEditButtonColor: const Color(0xFF38BDF8),
          actionDeleteButtonColor: const Color(0xFFFB7185),
          actionStatusButtonColor: const Color(0xFFF59E0B),
          buttonPresetStyle: 1,
          buttonRadius: 10,
          buttonShadowBlur: 16,
          buttonShadowOpacity: 0.27,
          buttonShine: 0.30,
          fontFamilyName: 'Inter',
        ),
      'slate_pro' => _config.copyWith(
          tableHeaderColor: const Color(0xFF1F2937),
          tableAreaColor: const Color(0xFF111827),
          transactionCardColor: const Color(0xFF1F2937),
          sidebarColor: const Color(0xFF0F172A),
          buttonBgColor: const Color(0xFF6366F1),
          buttonTextColor: const Color(0xFFFFFFFF),
          buttonBorderColor: const Color(0x997D8CFF),
          actionAddButtonColor: const Color(0xFF22C55E),
          actionEditButtonColor: const Color(0xFF60A5FA),
          actionDeleteButtonColor: const Color(0xFFF43F5E),
          actionStatusButtonColor: const Color(0xFFF59E0B),
          buttonPresetStyle: 4,
          buttonRadius: 9,
          buttonShadowBlur: 14,
          buttonShadowOpacity: 0.22,
          buttonShine: 0.22,
          fontFamilyName: 'Poppins',
        ),
      _ => _config.copyWith(
          tableHeaderColor: const Color(0xFF1E293B),
          tableAreaColor: const Color(0xFF0F172A),
          transactionCardColor: const Color(0xFF1E293B),
          sidebarColor: const Color(0xFF111827),
          buttonBgColor: const Color(0xFF22D3EE),
          buttonTextColor: const Color(0xFFFFFFFF),
          buttonBorderColor: const Color(0x6656CCF2),
          actionAddButtonColor: const Color(0xFF34D399),
          actionEditButtonColor: const Color(0xFF22D3EE),
          actionDeleteButtonColor: const Color(0xFFFB7185),
          actionStatusButtonColor: const Color(0xFFF59E0B),
          buttonPresetStyle: 2,
          buttonRadius: 10,
          buttonShadowBlur: 16,
          buttonShadowOpacity: 0.28,
          buttonShine: 0.35,
          fontFamilyName: 'Inter',
        ),
    };
    preview(next);
    return Future<void>.value();
  }

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

  Future<List<SavedDesignTheme>> _loadSavedThemes() async {
    final raw = await _db.getAppMetaValue(_savedThemesMetaKey);
    if (raw == null || raw.trim().isEmpty) {
      return <SavedDesignTheme>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <SavedDesignTheme>[];
      }
      final output = <SavedDesignTheme>[];
      for (final item in decoded) {
        final parsed = SavedDesignTheme.fromJson(item);
        if (parsed != null) {
          output.add(parsed);
        }
      }
      return output;
    } catch (_) {
      return <SavedDesignTheme>[];
    }
  }

  Future<void> _persistSavedThemes(List<SavedDesignTheme> themes) async {
    final jsonText = jsonEncode(themes.map((e) => e.toJson()).toList());
    await _db.setAppMetaValue(_savedThemesMetaKey, jsonText);
  }
}
