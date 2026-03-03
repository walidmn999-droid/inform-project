import 'dart:ui';

class AppDesignConfig {
  const AppDesignConfig({
    required this.tableHeaderColor,
    required this.tableAreaColor,
    required this.transactionCardColor,
    required this.sidebarColor,
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
  });

  final Color tableHeaderColor;
  final Color tableAreaColor;
  final Color transactionCardColor;
  final Color sidebarColor;
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

  static const AppDesignConfig defaults = AppDesignConfig(
    tableHeaderColor: Color(0xFF1E293B),
    tableAreaColor: Color(0xFF0F172A),
    transactionCardColor: Color(0xFF1E293B),
    sidebarColor: Color(0xFF111827),
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
  );

  AppDesignConfig copyWith({
    Color? tableHeaderColor,
    Color? tableAreaColor,
    Color? transactionCardColor,
    Color? sidebarColor,
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
  }) {
    return AppDesignConfig(
      tableHeaderColor: tableHeaderColor ?? this.tableHeaderColor,
      tableAreaColor: tableAreaColor ?? this.tableAreaColor,
      transactionCardColor: transactionCardColor ?? this.transactionCardColor,
      sidebarColor: sidebarColor ?? this.sidebarColor,
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
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'tableHeaderColor': tableHeaderColor.value,
      'tableAreaColor': tableAreaColor.value,
      'transactionCardColor': transactionCardColor.value,
      'sidebarColor': sidebarColor.value,
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
