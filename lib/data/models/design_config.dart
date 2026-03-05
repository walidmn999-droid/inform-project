import 'dart:ui';

class AppDesignConfig {
  const AppDesignConfig({
    required this.tableHeaderColor,
    required this.tableAreaColor,
    required this.transactionCardColor,
    required this.sidebarColor,
    required this.mainHeaderColor,
    required this.transactionRowHeight,
    required this.rowVerticalPadding,
    required this.cardSpacing,
    required this.cardBorderWidth,
    required this.attachmentIconSize,
    required this.baseFontSize,
    required this.buttonShapeStyle,
    required this.buttonPresetStyle,
    required this.buttonBgColor,
    required this.buttonTextColor,
    required this.buttonBorderColor,
    required this.buttonBorderWidth,
    required this.buttonRadius,
    required this.buttonShadowBlur,
    required this.buttonShadowOpacity,
    required this.buttonShine,
    required this.uiBrightnessShift,
    required this.useDistinctActionButtonColors,
    required this.actionAddButtonColor,
    required this.actionEditButtonColor,
    required this.actionDeleteButtonColor,
    required this.actionStatusButtonColor,
    required this.fontFamilyName,
    required this.fontWeightLevel,
    required this.invoicePrimaryColor,
    required this.invoiceSecondaryColor,
    required this.invoiceAccentColor,
    required this.invoiceTextColor,
    required this.invoiceFontFamily,
    required this.customerCardBgColor,
    required this.customerCardTextColor,
    required this.customerCardFontSize,
    required this.customerCardFontFamily,
    required this.customerCardBorderRadius,
    required this.customerCardBorderColor,
    required this.customerCardBorderWidth,
    required this.customerCardShadowBlur,
    required this.customerCardStyle,
    required this.seedColor,
    required this.borderRadiusLevel,
    required this.densityLevel,
    required this.glassBlurStrength,
    required this.enableGlassmorphism,
    required this.surfaceToneLevel,
    required this.columnSpacingH,
    required this.cellPaddingH,
    required this.useTabularFigures,
  });

  final Color tableHeaderColor;
  final Color tableAreaColor;
  final Color transactionCardColor;
  final Color sidebarColor;
  final Color mainHeaderColor;
  final double transactionRowHeight;
  final double rowVerticalPadding;
  final double cardSpacing;
  final double cardBorderWidth;
  final double attachmentIconSize;
  final double baseFontSize;
  final int buttonShapeStyle;
  final int buttonPresetStyle;
  final Color buttonBgColor;
  final Color buttonTextColor;
  final Color buttonBorderColor;
  final double buttonBorderWidth;
  final double buttonRadius;
  final double buttonShadowBlur;
  final double buttonShadowOpacity;
  final double buttonShine;
  final double uiBrightnessShift;
  final bool useDistinctActionButtonColors;
  final Color actionAddButtonColor;
  final Color actionEditButtonColor;
  final Color actionDeleteButtonColor;
  final Color actionStatusButtonColor;
  final String fontFamilyName;
  final double fontWeightLevel;
  final Color invoicePrimaryColor;
  final Color invoiceSecondaryColor;
  final Color invoiceAccentColor;
  final Color invoiceTextColor;
  final String invoiceFontFamily;
  final Color customerCardBgColor;
  final Color customerCardTextColor;
  final double customerCardFontSize;
  final String customerCardFontFamily;
  final double customerCardBorderRadius;
  final Color customerCardBorderColor;
  final double customerCardBorderWidth;
  final double customerCardShadowBlur;
  final int customerCardStyle;

  // ─── New appearance system fields ───────────────────────────────────────────
  final Color seedColor;
  /// 0 = None, 1 = Medium (8px), 2 = Extra Round (20px)
  final int borderRadiusLevel;
  /// 0 = Compact, 1 = Normal, 2 = Spacious
  final int densityLevel;
  /// Blur strength for glassmorphism backgrounds (0 = disabled)
  final double glassBlurStrength;
  final bool enableGlassmorphism;
  /// 0-3: depth of surface tone layering (0 = flat, 3 = deep)
  final int surfaceToneLevel;
  /// Horizontal spacing between table columns (px)
  final double columnSpacingH;
  /// Horizontal cell padding inside table cells
  final double cellPaddingH;
  /// Use tabular (monospaced) figures for numeric columns
  final bool useTabularFigures;

  // ─── Computed getters ────────────────────────────────────────────────────────
  /// Resolved global border radius from level
  double get globalRadius {
    switch (borderRadiusLevel) {
      case 0: return 0;
      case 2: return 20;
      default: return 8;
    }
  }

  /// Row height multiplied by density factor
  double get effectiveRowHeight {
    const f = [0.82, 1.0, 1.28];
    final factor = densityLevel.clamp(0, 2);
    return transactionRowHeight * f[factor];
  }

  /// Vertical padding multiplied by density factor
  double get effectiveRowPadding {
    const f = [0.6, 1.0, 1.4];
    final factor = densityLevel.clamp(0, 2);
    return rowVerticalPadding * f[factor];
  }

  /// Surface tone colors derived from tableAreaColor and surfaceToneLevel
  Color get surface0 => _forceOpaque(tableAreaColor);
  Color get surface1 {
    final base = _forceOpaque(tableAreaColor);
    if (surfaceToneLevel == 0) return base;
    return _lerpBrightness(base, 0.08 * surfaceToneLevel);
  }
  Color get surface2 {
    final base = _forceOpaque(transactionCardColor);
    if (surfaceToneLevel == 0) return base;
    return _lerpBrightness(base, 0.04 * surfaceToneLevel);
  }
  Color get surface3 {
    final base = _forceOpaque(transactionCardColor);
    if (surfaceToneLevel == 0) return _lerpBrightness(base, 0.07);
    return _lerpBrightness(base, 0.10 + (0.04 * surfaceToneLevel));
  }

  static Color _forceOpaque(Color c) =>
      Color.fromARGB(0xFF, c.red, c.green, c.blue);

  static Color _lerpBrightness(Color c, double delta) {
    final base = _forceOpaque(c);
    final r = (c.red + (delta * 255).round()).clamp(0, 255);
    final g = (c.green + (delta * 255).round()).clamp(0, 255);
    final b = (c.blue + (delta * 255).round()).clamp(0, 255);
    return Color.fromARGB(base.alpha, r, g, b);
  }

  static const AppDesignConfig defaults = AppDesignConfig(
    tableHeaderColor: Color(0xFF1E293B),
    tableAreaColor: Color(0xFF0F172A),
    transactionCardColor: Color(0xFF1E293B),
    sidebarColor: Color(0xFF111827),
    mainHeaderColor: Color(0xFF1E293B),
    transactionRowHeight: 46,
    rowVerticalPadding: 8,
    cardSpacing: 7,
    cardBorderWidth: 1.1,
    attachmentIconSize: 11,
    baseFontSize: 15,
    buttonShapeStyle: 0,
    buttonPresetStyle: 2,
    buttonBgColor: Color(0xFF22D3EE),
    buttonTextColor: Color(0xFFFFFFFF),
    buttonBorderColor: Color(0x6656CCF2),
    buttonBorderWidth: 1.2,
    buttonRadius: 10,
    buttonShadowBlur: 16,
    buttonShadowOpacity: 0.28,
    buttonShine: 0.35,
    uiBrightnessShift: 0.0,
    useDistinctActionButtonColors: false,
    actionAddButtonColor: Color(0xFF34D399),
    actionEditButtonColor: Color(0xFF22D3EE),
    actionDeleteButtonColor: Color(0xFFFB7185),
    actionStatusButtonColor: Color(0xFFF59E0B),
    fontFamilyName: 'Inter',
    fontWeightLevel: 500,
    invoicePrimaryColor: Color(0xFF8E9FB1),
    invoiceSecondaryColor: Color(0xFFE9EDF2),
    invoiceAccentColor: Color(0xFF6F8297),
    invoiceTextColor: Color(0xFF243241),
    invoiceFontFamily: 'Cairo',
    customerCardBgColor: Color(0xFF1E293B),
    customerCardTextColor: Color(0xFFE2E8F0),
    customerCardFontSize: 12,
    customerCardFontFamily: 'Cairo',
    customerCardBorderRadius: 10,
    customerCardBorderColor: Color(0x2FFFFFFF),
    customerCardBorderWidth: 1.0,
    customerCardShadowBlur: 0,
    customerCardStyle: 0,
    seedColor: Color(0xFF22D3EE),
    borderRadiusLevel: 1,
    densityLevel: 1,
    glassBlurStrength: 0,
    enableGlassmorphism: false,
    surfaceToneLevel: 1,
    columnSpacingH: 8,
    cellPaddingH: 12,
    useTabularFigures: false,
  );

  AppDesignConfig copyWith({
    Color? tableHeaderColor,
    Color? tableAreaColor,
    Color? transactionCardColor,
    Color? sidebarColor,
    Color? mainHeaderColor,
    double? transactionRowHeight,
    double? rowVerticalPadding,
    double? cardSpacing,
    double? cardBorderWidth,
    double? attachmentIconSize,
    double? baseFontSize,
    int? buttonShapeStyle,
    int? buttonPresetStyle,
    Color? buttonBgColor,
    Color? buttonTextColor,
    Color? buttonBorderColor,
    double? buttonBorderWidth,
    double? buttonRadius,
    double? buttonShadowBlur,
    double? buttonShadowOpacity,
    double? buttonShine,
    double? uiBrightnessShift,
    bool? useDistinctActionButtonColors,
    Color? actionAddButtonColor,
    Color? actionEditButtonColor,
    Color? actionDeleteButtonColor,
    Color? actionStatusButtonColor,
    String? fontFamilyName,
    double? fontWeightLevel,
    Color? invoicePrimaryColor,
    Color? invoiceSecondaryColor,
    Color? invoiceAccentColor,
    Color? invoiceTextColor,
    String? invoiceFontFamily,
    Color? customerCardBgColor,
    Color? customerCardTextColor,
    double? customerCardFontSize,
    String? customerCardFontFamily,
    double? customerCardBorderRadius,
    Color? customerCardBorderColor,
    double? customerCardBorderWidth,
    double? customerCardShadowBlur,
    int? customerCardStyle,
    Color? seedColor,
    int? borderRadiusLevel,
    int? densityLevel,
    double? glassBlurStrength,
    bool? enableGlassmorphism,
    int? surfaceToneLevel,
    double? columnSpacingH,
    double? cellPaddingH,
    bool? useTabularFigures,
  }) {
    return AppDesignConfig(
      tableHeaderColor: tableHeaderColor ?? this.tableHeaderColor,
      tableAreaColor: tableAreaColor ?? this.tableAreaColor,
      transactionCardColor: transactionCardColor ?? this.transactionCardColor,
      sidebarColor: sidebarColor ?? this.sidebarColor,
      mainHeaderColor: mainHeaderColor ?? this.mainHeaderColor,
      transactionRowHeight: _clamp(transactionRowHeight ?? this.transactionRowHeight, 34, 74),
      rowVerticalPadding: _clamp(rowVerticalPadding ?? this.rowVerticalPadding, 2, 24),
      cardSpacing: _clamp(cardSpacing ?? this.cardSpacing, 2, 24),
      cardBorderWidth: _clamp(cardBorderWidth ?? this.cardBorderWidth, 0.6, 3.5),
      attachmentIconSize: _clamp(attachmentIconSize ?? this.attachmentIconSize, 8, 24),
      baseFontSize: _clamp(baseFontSize ?? this.baseFontSize, 11, 22),
      buttonShapeStyle: (buttonShapeStyle ?? this.buttonShapeStyle).clamp(0, 3).toInt(),
      buttonPresetStyle: (buttonPresetStyle ?? this.buttonPresetStyle).clamp(0, 4).toInt(),
      buttonBgColor: buttonBgColor ?? this.buttonBgColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      buttonBorderColor: buttonBorderColor ?? this.buttonBorderColor,
      buttonBorderWidth: _clamp(buttonBorderWidth ?? this.buttonBorderWidth, 0, 4),
      buttonRadius: _clamp(buttonRadius ?? this.buttonRadius, 0, 24),
      buttonShadowBlur: _clamp(buttonShadowBlur ?? this.buttonShadowBlur, 0, 30),
      buttonShadowOpacity: _clamp(buttonShadowOpacity ?? this.buttonShadowOpacity, 0, 0.8),
      buttonShine: _clamp(buttonShine ?? this.buttonShine, 0, 1),
      uiBrightnessShift: _clamp(uiBrightnessShift ?? this.uiBrightnessShift, -0.35, 0.35),
      useDistinctActionButtonColors:
          useDistinctActionButtonColors ?? this.useDistinctActionButtonColors,
      actionAddButtonColor: actionAddButtonColor ?? this.actionAddButtonColor,
      actionEditButtonColor: actionEditButtonColor ?? this.actionEditButtonColor,
      actionDeleteButtonColor: actionDeleteButtonColor ?? this.actionDeleteButtonColor,
      actionStatusButtonColor: actionStatusButtonColor ?? this.actionStatusButtonColor,
      fontFamilyName: fontFamilyName ?? this.fontFamilyName,
      fontWeightLevel: _clamp(fontWeightLevel ?? this.fontWeightLevel, 300, 800),
      invoicePrimaryColor: invoicePrimaryColor ?? this.invoicePrimaryColor,
      invoiceSecondaryColor: invoiceSecondaryColor ?? this.invoiceSecondaryColor,
      invoiceAccentColor: invoiceAccentColor ?? this.invoiceAccentColor,
      invoiceTextColor: invoiceTextColor ?? this.invoiceTextColor,
      invoiceFontFamily: invoiceFontFamily ?? this.invoiceFontFamily,
      customerCardBgColor: customerCardBgColor ?? this.customerCardBgColor,
      customerCardTextColor: customerCardTextColor ?? this.customerCardTextColor,
      customerCardFontSize: _clamp(customerCardFontSize ?? this.customerCardFontSize, 9, 20),
      customerCardFontFamily: customerCardFontFamily ?? this.customerCardFontFamily,
      customerCardBorderRadius: _clamp(customerCardBorderRadius ?? this.customerCardBorderRadius, 0, 24),
      customerCardBorderColor: customerCardBorderColor ?? this.customerCardBorderColor,
      customerCardBorderWidth: _clamp(customerCardBorderWidth ?? this.customerCardBorderWidth, 0, 4),
      customerCardShadowBlur: _clamp(customerCardShadowBlur ?? this.customerCardShadowBlur, 0, 24),
      customerCardStyle: (customerCardStyle ?? this.customerCardStyle).clamp(0, 3).toInt(),
      seedColor: seedColor ?? this.seedColor,
      borderRadiusLevel: (borderRadiusLevel ?? this.borderRadiusLevel).clamp(0, 2).toInt(),
      densityLevel: (densityLevel ?? this.densityLevel).clamp(0, 2).toInt(),
      glassBlurStrength: _clamp(glassBlurStrength ?? this.glassBlurStrength, 0, 40),
      enableGlassmorphism: enableGlassmorphism ?? this.enableGlassmorphism,
      surfaceToneLevel: (surfaceToneLevel ?? this.surfaceToneLevel).clamp(0, 3).toInt(),
      columnSpacingH: _clamp(columnSpacingH ?? this.columnSpacingH, 0, 32),
      cellPaddingH: _clamp(cellPaddingH ?? this.cellPaddingH, 4, 40),
      useTabularFigures: useTabularFigures ?? this.useTabularFigures,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'tableHeaderColor': tableHeaderColor.value,
      'tableAreaColor': tableAreaColor.value,
      'transactionCardColor': transactionCardColor.value,
      'sidebarColor': sidebarColor.value,
      'mainHeaderColor': mainHeaderColor.value,
      'transactionRowHeight': transactionRowHeight,
      'rowVerticalPadding': rowVerticalPadding,
      'cardSpacing': cardSpacing,
      'cardBorderWidth': cardBorderWidth,
      'attachmentIconSize': attachmentIconSize,
      'baseFontSize': baseFontSize,
      'buttonShapeStyle': buttonShapeStyle,
      'buttonPresetStyle': buttonPresetStyle,
      'buttonBgColor': buttonBgColor.value,
      'buttonTextColor': buttonTextColor.value,
      'buttonBorderColor': buttonBorderColor.value,
      'buttonBorderWidth': buttonBorderWidth,
      'buttonRadius': buttonRadius,
      'buttonShadowBlur': buttonShadowBlur,
      'buttonShadowOpacity': buttonShadowOpacity,
      'buttonShine': buttonShine,
      'uiBrightnessShift': uiBrightnessShift,
      'useDistinctActionButtonColors': useDistinctActionButtonColors ? 1 : 0,
      'actionAddButtonColor': actionAddButtonColor.value,
      'actionEditButtonColor': actionEditButtonColor.value,
      'actionDeleteButtonColor': actionDeleteButtonColor.value,
      'actionStatusButtonColor': actionStatusButtonColor.value,
      'fontFamilyName': fontFamilyName,
      'fontWeightLevel': fontWeightLevel,
      'invoicePrimaryColor': invoicePrimaryColor.value,
      'invoiceSecondaryColor': invoiceSecondaryColor.value,
      'invoiceAccentColor': invoiceAccentColor.value,
      'invoiceTextColor': invoiceTextColor.value,
      'invoiceFontFamily': invoiceFontFamily,
      'customerCardBgColor': customerCardBgColor.value,
      'customerCardTextColor': customerCardTextColor.value,
      'customerCardFontSize': customerCardFontSize,
      'customerCardFontFamily': customerCardFontFamily,
      'customerCardBorderRadius': customerCardBorderRadius,
      'customerCardBorderColor': customerCardBorderColor.value,
      'customerCardBorderWidth': customerCardBorderWidth,
      'customerCardShadowBlur': customerCardShadowBlur,
      'customerCardStyle': customerCardStyle,
      'seedColor': seedColor.value,
      'borderRadiusLevel': borderRadiusLevel,
      'densityLevel': densityLevel,
      'glassBlurStrength': glassBlurStrength,
      'enableGlassmorphism': enableGlassmorphism ? 1 : 0,
      'surfaceToneLevel': surfaceToneLevel,
      'columnSpacingH': columnSpacingH,
      'cellPaddingH': cellPaddingH,
      'useTabularFigures': useTabularFigures ? 1 : 0,
    };
  }

  factory AppDesignConfig.fromJson(Map<String, dynamic> json) {
    const defaults = AppDesignConfig.defaults;
    return AppDesignConfig(
      tableHeaderColor: _colorOrDefault(json['tableHeaderColor'], defaults.tableHeaderColor),
      tableAreaColor: _colorOrDefault(json['tableAreaColor'], defaults.tableAreaColor),
      transactionCardColor:
          _colorOrDefault(json['transactionCardColor'], defaults.transactionCardColor),
      sidebarColor: _colorOrDefault(json['sidebarColor'], defaults.sidebarColor),
      mainHeaderColor: _colorOrDefault(json['mainHeaderColor'], defaults.mainHeaderColor),
      transactionRowHeight:
          _doubleOrDefault(json['transactionRowHeight'], defaults.transactionRowHeight),
      rowVerticalPadding:
          _doubleOrDefault(json['rowVerticalPadding'], defaults.rowVerticalPadding),
      cardSpacing: _doubleOrDefault(json['cardSpacing'], defaults.cardSpacing),
      cardBorderWidth:
          _doubleOrDefault(json['cardBorderWidth'], defaults.cardBorderWidth),
      attachmentIconSize:
          _doubleOrDefault(json['attachmentIconSize'], defaults.attachmentIconSize),
      baseFontSize: _doubleOrDefault(json['baseFontSize'], defaults.baseFontSize),
      buttonShapeStyle:
          _doubleOrDefault(json['buttonShapeStyle'], defaults.buttonShapeStyle.toDouble())
              .toInt()
              .clamp(0, 3),
      buttonPresetStyle:
          _doubleOrDefault(json['buttonPresetStyle'], defaults.buttonPresetStyle.toDouble())
              .toInt()
              .clamp(0, 4),
      buttonBgColor: _colorOrDefault(json['buttonBgColor'], defaults.buttonBgColor),
      buttonTextColor: _colorOrDefault(json['buttonTextColor'], defaults.buttonTextColor),
      buttonBorderColor:
          _colorOrDefault(json['buttonBorderColor'], defaults.buttonBorderColor),
      buttonBorderWidth:
          _doubleOrDefault(json['buttonBorderWidth'], defaults.buttonBorderWidth),
      buttonRadius: _doubleOrDefault(json['buttonRadius'], defaults.buttonRadius),
      buttonShadowBlur:
          _doubleOrDefault(json['buttonShadowBlur'], defaults.buttonShadowBlur),
      buttonShadowOpacity:
          _doubleOrDefault(json['buttonShadowOpacity'], defaults.buttonShadowOpacity),
      buttonShine: _doubleOrDefault(json['buttonShine'], defaults.buttonShine),
      uiBrightnessShift:
          _doubleOrDefault(json['uiBrightnessShift'], defaults.uiBrightnessShift),
      useDistinctActionButtonColors:
          _doubleOrDefault(json['useDistinctActionButtonColors'], 0) > 0,
      actionAddButtonColor:
          _colorOrDefault(json['actionAddButtonColor'], defaults.actionAddButtonColor),
      actionEditButtonColor:
          _colorOrDefault(json['actionEditButtonColor'], defaults.actionEditButtonColor),
      actionDeleteButtonColor:
          _colorOrDefault(json['actionDeleteButtonColor'], defaults.actionDeleteButtonColor),
      actionStatusButtonColor:
          _colorOrDefault(json['actionStatusButtonColor'], defaults.actionStatusButtonColor),
      fontFamilyName: (json['fontFamilyName'] as String?)?.trim().isNotEmpty == true
          ? json['fontFamilyName'] as String
          : defaults.fontFamilyName,
      fontWeightLevel:
          _doubleOrDefault(json['fontWeightLevel'], defaults.fontWeightLevel),
      invoicePrimaryColor:
          _colorOrDefault(json['invoicePrimaryColor'], defaults.invoicePrimaryColor),
      invoiceSecondaryColor:
          _colorOrDefault(json['invoiceSecondaryColor'], defaults.invoiceSecondaryColor),
      invoiceAccentColor:
          _colorOrDefault(json['invoiceAccentColor'], defaults.invoiceAccentColor),
      invoiceTextColor:
          _colorOrDefault(json['invoiceTextColor'], defaults.invoiceTextColor),
      invoiceFontFamily: (json['invoiceFontFamily'] as String?)?.trim().isNotEmpty == true
          ? json['invoiceFontFamily'] as String
          : defaults.invoiceFontFamily,
      customerCardBgColor:
          _colorOrDefault(json['customerCardBgColor'], defaults.customerCardBgColor),
      customerCardTextColor:
          _colorOrDefault(json['customerCardTextColor'], defaults.customerCardTextColor),
      customerCardFontSize:
          _doubleOrDefault(json['customerCardFontSize'], defaults.customerCardFontSize),
      customerCardFontFamily:
          (json['customerCardFontFamily'] as String?)?.trim().isNotEmpty == true
              ? json['customerCardFontFamily'] as String
              : defaults.customerCardFontFamily,
      customerCardBorderRadius:
          _doubleOrDefault(json['customerCardBorderRadius'], defaults.customerCardBorderRadius),
      customerCardBorderColor:
          _colorOrDefault(json['customerCardBorderColor'], defaults.customerCardBorderColor),
      customerCardBorderWidth:
          _doubleOrDefault(json['customerCardBorderWidth'], defaults.customerCardBorderWidth),
      customerCardShadowBlur:
          _doubleOrDefault(json['customerCardShadowBlur'], defaults.customerCardShadowBlur),
      customerCardStyle:
          _doubleOrDefault(json['customerCardStyle'], defaults.customerCardStyle.toDouble())
              .toInt()
              .clamp(0, 3),
      seedColor: _colorOrDefault(json['seedColor'], defaults.seedColor),
      borderRadiusLevel:
          _doubleOrDefault(json['borderRadiusLevel'], defaults.borderRadiusLevel.toDouble())
              .toInt().clamp(0, 2),
      densityLevel:
          _doubleOrDefault(json['densityLevel'], defaults.densityLevel.toDouble())
              .toInt().clamp(0, 2),
      glassBlurStrength:
          _doubleOrDefault(json['glassBlurStrength'], defaults.glassBlurStrength),
      enableGlassmorphism:
          _doubleOrDefault(json['enableGlassmorphism'], 0) > 0,
      surfaceToneLevel:
          _doubleOrDefault(json['surfaceToneLevel'], defaults.surfaceToneLevel.toDouble())
              .toInt().clamp(0, 3),
      columnSpacingH:
          _doubleOrDefault(json['columnSpacingH'], defaults.columnSpacingH),
      cellPaddingH:
          _doubleOrDefault(json['cellPaddingH'], defaults.cellPaddingH),
      useTabularFigures:
          _doubleOrDefault(json['useTabularFigures'], 0) > 0,
    );
  }

  static double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static Color _colorOrDefault(Object? raw, Color fallback) {
    final v = raw;
    if (v is int) return Color(v);
    if (v is num) return Color(v.toInt());
    return fallback;
  }

  static double _doubleOrDefault(Object? raw, double fallback) {
    final v = raw;
    if (v is num) return v.toDouble();
    return fallback;
  }
}
