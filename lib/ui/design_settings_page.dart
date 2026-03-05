import 'package:flutter/material.dart';

import '../logic/design_controller.dart';

Color _mixOpaque(Color a, Color b, double t) {
  final clamped = t.clamp(0.0, 1.0);
  final r = (a.red + ((b.red - a.red) * clamped)).round();
  final g = (a.green + ((b.green - a.green) * clamped)).round();
  final bCh = (a.blue + ((b.blue - a.blue) * clamped)).round();
  return Color.fromARGB(0xFF, r, g, bCh);
}

class DesignSettingsPage extends StatelessWidget {
  const DesignSettingsPage({
    super.key,
    required this.isArabic,
    this.asOverlay = false,
  });

  final bool isArabic;
  final bool asOverlay;

  String _t(String ar, String en) => isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final controller = DesignController.instance;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final cfg = controller.config;
        const textBlack = Color(0xFF0F172A);
        const panelBg = Color(0xFFFFFFFF);
        const panelBorder = Color(0xFFE2E8F0);
        const neonAccent = Color(0xFF0EA5E9);
        const neonAccentSoft = Color(0x330EA5E9);
        const fontOptions = <String>[
          'Cairo',
          'Tajawal',
          'Almarai',
          'Changa',
          'ElMessiri',
          'NotoNaskhArabic',
          'NotoKufiArabic',
          'Amiri',
          'ReemKufi',
          'ArefRuqaa',
          'Inter',
          'Poppins',
          'Arial',
          'Tahoma',
          'Calibri',
          'Courier New',
        ];
        final modernTheme = Theme.of(context).copyWith(
          scaffoldBackgroundColor: panelBg,
          cardTheme: CardTheme(
            color: panelBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: panelBorder),
            ),
            shadowColor: neonAccentSoft,
            margin: const EdgeInsets.symmetric(vertical: 4),
          ),
          sliderTheme: Theme.of(context).sliderTheme.copyWith(
                activeTrackColor: neonAccent,
                thumbColor: neonAccent,
                overlayColor: neonAccentSoft,
                inactiveTrackColor: const Color(0xFFD5E3F2),
              ),
          switchTheme: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? neonAccent
                  : const Color(0xFF94A3B8),
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? neonAccentSoft
                  : const Color(0x446B8AAD),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: neonAccent,
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0x664A90D9), width: 1.1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.35,
              ),
              elevation: 0,
              shadowColor: neonAccentSoft,
            ),
          ),
          textTheme: Theme.of(context).textTheme.apply(
                fontFamily: cfg.fontFamilyName,
                bodyColor: textBlack,
                displayColor: textBlack,
              ).copyWith(
                bodyMedium: const TextStyle(
                  letterSpacing: 0.15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: textBlack,
                ),
                titleMedium: const TextStyle(
                  letterSpacing: 0.1,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: textBlack,
                ),
              ),
          listTileTheme: const ListTileThemeData(
            textColor: textBlack,
            iconColor: textBlack,
          ),
          dividerColor: panelBorder,
        );

        final body = ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
          children: [
            // ── Info hint ──────────────────────────────────────────────────
            Card(
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.info_outline, color: Color(0xFF0EA5E9), size: 20),
                title: Text(
                  _t('كل تغيير يظهر فورًا. التطبيق الدائم فقط عند الضغط "تطبيق وحفظ".', 'Changes are live. Save permanently only after "Apply & Save".'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textBlack),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ── Saved themes ───────────────────────────────────────────────
            _SectionTitle(_t('الثيمات المحفوظة', 'Saved Themes')),
            _SavedThemesPanel(isArabic: isArabic, t: _t),
            const SizedBox(height: 6),

            // ── Palette presets ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_t('باليتات جاهزة', 'Ready Palettes'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final id in DesignController.paletteIds)
                          OutlinedButton(
                            onPressed: () => controller.applyPalettePreset(id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textBlack,
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              backgroundColor: panelBg,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            child: Text(
                              id == 'new_theme_linked'
                                  ? _t('نيو ثيم', 'New Theme')
                                  : DesignController.paletteTitle(id),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Section 0: Appearance System ───────────────────────────────
            _CollapsibleSection(
              title: _t('نظام المظهر', 'Appearance System'),
              icon: Icons.auto_awesome_rounded,
              accentColor: const Color(0xFF6366F1),
              initiallyOpen: true,
              children: [
                // Seed Color + Generate
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t('اللون الجذر (Seed Color)', 'Seed Color'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t('اختر لون أساسي ويتولى البرنامج توليد كامل لوحة الألوان تلقائياً.',
                             'Pick a base color and the app derives the full palette automatically.'),
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await showDialog<void>(
                                  context: context,
                                  builder: (_) => _RgbColorPickerDialog(
                                    initial: cfg.seedColor,
                                    onChanged: (c) => controller.setSeedColor(c),
                                  ),
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cfg.seedColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cfg.seedColor.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.colorize, color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => controller.generateFromSeed(cfg.seedColor),
                                icon: const Icon(Icons.auto_fix_high, size: 16),
                                label: Text(_t('توليد اللوحة', 'Generate Palette'),
                                    style: const TextStyle(fontSize: 12)),
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Border Radius Level
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('استدارة الحواف', 'Border Radius'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final entry in [
                              (0, _t('بدون', 'None')),
                              (1, _t('متوسط', 'Medium')),
                              (2, _t('ناعم جداً', 'Extra Round')),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: cfg.borderRadiusLevel == entry.$1
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: cfg.borderRadiusLevel == entry.$1
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => controller.setBorderRadiusLevel(entry.$1),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Text(entry.$2,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: cfg.borderRadiusLevel == entry.$1
                                                  ? Colors.white
                                                  : const Color(0xFF475569),
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Density Level
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('كثافة البيانات', 'Data Density'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack)),
                        const SizedBox(height: 4),
                        Text(_t('Compact للمحاسبين، Spacious للمظهر العصري',
                                'Compact for accountants, Spacious for modern look'),
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (final entry in [
                              (0, _t('مضغوط', 'Compact'), Icons.density_small),
                              (1, _t('عادي', 'Normal'), Icons.density_medium),
                              (2, _t('واسع', 'Spacious'), Icons.density_large),
                            ])
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    decoration: BoxDecoration(
                                      color: cfg.densityLevel == entry.$1
                                          ? const Color(0xFF0EA5E9)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: cfg.densityLevel == entry.$1
                                            ? const Color(0xFF0EA5E9)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => controller.setDensityLevel(entry.$1),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Column(
                                          children: [
                                            Icon(entry.$3,
                                                size: 14,
                                                color: cfg.densityLevel == entry.$1
                                                    ? Colors.white
                                                    : const Color(0xFF64748B)),
                                            const SizedBox(height: 2),
                                            Text(entry.$2,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: cfg.densityLevel == entry.$1
                                                      ? Colors.white
                                                      : const Color(0xFF475569),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Surface Tone Level
                _SliderTile(
                  label: _t('عمق طبقات الخلفية (Surface Tones)', 'Surface Tone Depth'),
                  value: cfg.surfaceToneLevel.toDouble(),
                  min: 0, max: 3,
                  onChanged: (v) => controller.setSurfaceToneLevel(v.round()),
                ),

                // Glassmorphism
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_t('تأثير الزجاج (Glassmorphism)', 'Glassmorphism'),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack)),
                          subtitle: Text(_t('خلفية شفافة مع ضبابية ناعمة',
                                          'Frosted glass backgrounds'),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          value: cfg.enableGlassmorphism,
                          onChanged: (v) => controller.setEnableGlassmorphism(v),
                        ),
                        if (cfg.enableGlassmorphism) ...[
                          const SizedBox(height: 4),
                          _SliderTile(
                            label: _t('قوة الضبابية', 'Blur strength'),
                            value: cfg.glassBlurStrength,
                            min: 0, max: 40,
                            onChanged: (v) => controller.setGlassBlurStrength(v),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Section 0b: Table Spacing ───────────────────────────────────
            _CollapsibleSection(
              title: _t('مسافات الجدول', 'Table Spacing'),
              icon: Icons.space_bar_rounded,
              accentColor: const Color(0xFF0EA5E9),
              children: [
                _SliderTile(
                  label: _t('المسافة الأفقية بين الأعمدة', 'Column spacing (horizontal)'),
                  value: cfg.columnSpacingH, min: 0, max: 32,
                  onChanged: (v) => controller.setColumnSpacingH(v),
                ),
                _SliderTile(
                  label: _t('الحشوة الأفقية داخل الخلايا', 'Cell horizontal padding'),
                  value: cfg.cellPaddingH, min: 4, max: 40,
                  onChanged: (v) => controller.setCellPaddingH(v),
                ),
                Card(
                  child: SwitchListTile(
                    title: Text(_t('أرقام محاسبية (Tabular Figures)', 'Tabular Figures'),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textBlack)),
                    subtitle: Text(
                      _t('تثبيت عرض الأرقام لاصطفاف محاسبي دقيق',
                         'Fixed-width digits for precise accounting alignment'),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    value: cfg.useTabularFigures,
                    onChanged: (v) => controller.setUseTabularFigures(v),
                  ),
                ),
              ],
            ),

            // ── Section 1: General ─────────────────────────────────────────
            _CollapsibleSection(
              title: _t('إعدادات عامة', 'General Settings'),
              icon: Icons.tune_rounded,
              accentColor: const Color(0xFF64748B),
              children: [
                _BrightnessIndicator(value: cfg.uiBrightnessShift, isArabic: isArabic),
                _SliderTile(
                  label: _t('تفتيح/تغميق التصميم', 'Lighten/Darken'),
                  value: cfg.uiBrightnessShift, min: -0.35, max: 0.35,
                  onChanged: (v) => controller.setUiBrightnessShift(v),
                ),
                Card(
                  child: ListTile(
                    title: Text(_t('نوع خط التطبيق', 'App font family')),
                    trailing: DropdownButton<String>(
                      value: fontOptions.contains(cfg.fontFamilyName) ? cfg.fontFamilyName : 'Inter',
                      items: fontOptions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) { if (v != null) controller.setFontFamilyName(v); },
                    ),
                  ),
                ),
                _SliderTile(label: _t('سماكة الخط', 'Font weight'), value: cfg.fontWeightLevel, min: 300, max: 800, onChanged: (v) => controller.setFontWeightLevel(v)),
                _SliderTile(label: _t('حجم الخط الأساسي', 'Base font size'), value: cfg.baseFontSize, min: 11, max: 22, onChanged: (v) => controller.setBaseFontSize(v)),
              ],
            ),

            // ── Section 2: Customer Table ──────────────────────────────────
            _CollapsibleSection(
              title: _t('جدول العملاء', 'Customer Table'),
              icon: Icons.table_rows_rounded,
              accentColor: const Color(0xFF0EA5E9),
              children: [
                _ColorTile(label: _t('لون الهيدر الرئيسي (اسم العميل + الإجراءات)', 'Main header color (customer + actions)'), color: cfg.mainHeaderColor, onPicked: (c) => controller.setMainHeaderColor(c)),
                _ColorTile(label: _t('لون هيدر الجدول', 'Table header color'), color: cfg.tableHeaderColor, onPicked: (c) => controller.setTableHeaderColor(c)),
                _ColorTile(label: _t('لون خلفية الجدول', 'Table area color'), color: cfg.tableAreaColor, onPicked: (c) => controller.setTableAreaColor(c)),
                _ColorTile(label: _t('لون كروت المعاملات', 'Transaction card color'), color: cfg.transactionCardColor, onPicked: (c) => controller.setTransactionCardColor(c)),
                _SliderTile(label: _t('ارتفاع الصف', 'Row height'), value: cfg.transactionRowHeight, min: 34, max: 74, onChanged: (v) => controller.setTransactionRowHeight(v)),
                _SliderTile(label: _t('المسافة الرأسية داخل الصف', 'Row vertical spacing'), value: cfg.rowVerticalPadding, min: 2, max: 24, onChanged: (v) => controller.setRowVerticalPadding(v)),
                _SliderTile(label: _t('المسافة بين الكروت', 'Card spacing'), value: cfg.cardSpacing, min: 2, max: 24, onChanged: (v) => controller.setCardSpacing(v)),
                _SliderTile(label: _t('سماكة إطار الكارت', 'Card border width'), value: cfg.cardBorderWidth, min: 0.6, max: 3.5, onChanged: (v) => controller.setCardBorderWidth(v)),
                _SliderTile(label: _t('حجم أيقونة المرفقات', 'Attachment icon size'), value: cfg.attachmentIconSize, min: 8, max: 24, onChanged: (v) => controller.setAttachmentIconSize(v)),
                Card(
                  child: ListTile(
                    leading: Icon(
                      controller.hasGoodContrast(controller.onColorFor(cfg.tableHeaderColor), cfg.tableHeaderColor) ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: controller.hasGoodContrast(controller.onColorFor(cfg.tableHeaderColor), cfg.tableHeaderColor) ? Colors.green : Colors.orange,
                    ),
                    title: Text(_t('فحص التباين', 'Contrast check')),
                    subtitle: Text(_t('يتم ضبط لون النص تلقائياً.', 'Text color is auto-adjusted.')),
                  ),
                ),
              ],
            ),

            // ── Section 3: Sidebar & Customer Cards ────────────────────────
            _CollapsibleSection(
              title: _t('السايدبار وكروت العملاء', 'Sidebar & Customer Cards'),
              icon: Icons.view_sidebar_rounded,
              accentColor: const Color(0xFF6366F1),
              children: [
                _ColorTile(label: _t('لون خلفية السايدبار', 'Sidebar background'), color: cfg.sidebarColor, onPicked: (c) => controller.setSidebarColor(c)),
                const Divider(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(_t('تصميم كروت العملاء', 'Customer Card Design'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF6366F1))),
                ),
                _ColorTile(label: _t('لون خلفية الكارت', 'Card background'), color: cfg.customerCardBgColor, onPicked: (c) => controller.setCustomerCardBgColor(c)),
                _ColorTile(label: _t('لون النص', 'Text color'), color: cfg.customerCardTextColor, onPicked: (c) => controller.setCustomerCardTextColor(c)),
                _ColorTile(label: _t('لون الحدود', 'Border color'), color: cfg.customerCardBorderColor, onPicked: (c) => controller.setCustomerCardBorderColor(c)),
                _SliderTile(label: _t('حجم الخط', 'Font size'), value: cfg.customerCardFontSize, min: 9, max: 20, onChanged: (v) => controller.setCustomerCardFontSize(v)),
                Card(
                  child: ListTile(
                    title: Text(_t('نوع الخط', 'Font family')),
                    trailing: DropdownButton<String>(
                      value: fontOptions.contains(cfg.customerCardFontFamily) ? cfg.customerCardFontFamily : 'Cairo',
                      items: fontOptions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (v) { if (v != null) controller.setCustomerCardFontFamily(v); },
                    ),
                  ),
                ),
                _SliderTile(label: _t('استدارة الزوايا', 'Border radius'), value: cfg.customerCardBorderRadius, min: 0, max: 24, onChanged: (v) => controller.setCustomerCardBorderRadius(v)),
                _SliderTile(label: _t('سماكة الحدود', 'Border width'), value: cfg.customerCardBorderWidth, min: 0, max: 4, onChanged: (v) => controller.setCustomerCardBorderWidth(v)),
                _SliderTile(label: _t('قوة الظل', 'Shadow blur'), value: cfg.customerCardShadowBlur, min: 0, max: 24, onChanged: (v) => controller.setCustomerCardShadowBlur(v)),
                Card(
                  child: ListTile(
                    title: Text(_t('ستايل الكارت', 'Card style')),
                    trailing: DropdownButton<int>(
                      value: cfg.customerCardStyle,
                      items: [
                        DropdownMenuItem(value: 0, child: Text(_t('عادي', 'Flat'))),
                        DropdownMenuItem(value: 1, child: Text(_t('مرتفع بظل', 'Elevated'))),
                        DropdownMenuItem(value: 2, child: Text(_t('حدودي بارز', 'Bordered'))),
                        DropdownMenuItem(value: 3, child: Text(_t('زجاجي', 'Glass'))),
                      ],
                      onChanged: (v) { if (v != null) controller.setCustomerCardStyle(v); },
                    ),
                  ),
                ),
              ],
            ),

            // ── Section 4: Invoice ─────────────────────────────────────────
            _CollapsibleSection(
              title: _t('الفاتورة', 'Invoice'),
              icon: Icons.receipt_long_rounded,
              accentColor: const Color(0xFFF59E0B),
              children: [
                _ColorTile(label: _t('لون هيدر الجدول', 'Table header color'), color: cfg.invoicePrimaryColor, onPicked: (c) => controller.setInvoicePrimaryColor(c)),
                _ColorTile(label: _t('لون الصفوف البديلة', 'Alt row color'), color: cfg.invoiceSecondaryColor, onPicked: (c) => controller.setInvoiceSecondaryColor(c)),
                _ColorTile(label: _t('لون التمييز والعنوان', 'Accent / title color'), color: cfg.invoiceAccentColor, onPicked: (c) => controller.setInvoiceAccentColor(c)),
                _ColorTile(label: _t('لون النص الرئيسي', 'Main text color'), color: cfg.invoiceTextColor, onPicked: (c) => controller.setInvoiceTextColor(c)),
                Card(
                  child: ListTile(
                    title: Text(_t('خط الفاتورة', 'Invoice font')),
                    trailing: DropdownButton<String>(
                      value: fontOptions.contains(cfg.invoiceFontFamily)
                          ? cfg.invoiceFontFamily
                          : 'Cairo',
                      items: fontOptions
                          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.setInvoiceFontFamily(v);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // ── Section 5: Buttons ─────────────────────────────────────────
            _CollapsibleSection(
              title: _t('الأزرار', 'Buttons'),
              icon: Icons.smart_button_rounded,
              accentColor: const Color(0xFF10B981),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('خصائص التصميم الزجاجي', 'Glass design'),
                            style: const TextStyle(fontWeight: FontWeight.w700, color: textBlack)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          FilledButton.icon(
                            onPressed: () => controller.preview(cfg.copyWith(
                              buttonPresetStyle: 2, buttonShapeStyle: 0, buttonBorderWidth: 1.2,
                              buttonRadius: 10, buttonShadowBlur: 18, buttonShadowOpacity: 0.3,
                              buttonShine: 0.42, buttonBorderColor: const Color(0x8893C5DB),
                            )),
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(_t('تفعيل زجاجي', 'Apply glass')),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => controller.preview(cfg.copyWith(
                              buttonPresetStyle: 0, buttonShadowBlur: 8,
                              buttonShadowOpacity: 0.12, buttonShine: 0.1,
                            )),
                            icon: const Icon(Icons.layers_clear),
                            label: Text(_t('تقليل الزجاج', 'Reduce glass')),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
                SwitchListTile(
                  title: Text(_t('تمييز ألوان أزرار الإجراءات', 'Distinct action button colors')),
                  value: cfg.useDistinctActionButtonColors,
                  onChanged: (v) => controller.setUseDistinctActionButtonColors(v),
                ),
                Card(
                  child: ListTile(
                    title: Text(_t('ستايل الزر', 'Button style')),
                    trailing: DropdownButton<int>(
                      value: cfg.buttonPresetStyle,
                      items: [0, 1, 2, 3, 4].map((v) => DropdownMenuItem(value: v, child: Text(['Custom', 'Gradient', 'Glass', 'Soft', 'Minimal'][v]))).toList(),
                      onChanged: (v) { if (v != null) controller.setButtonPresetStyle(v); },
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text(_t('شكل الأزرار', 'Button shape')),
                    trailing: DropdownButton<int>(
                      value: cfg.buttonShapeStyle,
                      items: [
                        DropdownMenuItem(value: 0, child: Text(_t('منحني', 'Rounded'))),
                        DropdownMenuItem(value: 1, child: Text(_t('كبسولة', 'Pill'))),
                        DropdownMenuItem(value: 2, child: Text(_t('مربع', 'Square'))),
                        DropdownMenuItem(value: 3, child: Text(_t('ناعم', 'Soft'))),
                      ],
                      onChanged: (v) { if (v != null) controller.setButtonShapeStyle(v); },
                    ),
                  ),
                ),
                _ColorTile(label: _t('لون خلفية الأزرار', 'Button bg'), color: cfg.buttonBgColor, onPicked: (c) => controller.setButtonBgColor(c)),
                _ColorTile(label: _t('لون نص الأزرار', 'Button text'), color: cfg.buttonTextColor, onPicked: (c) => controller.setButtonTextColor(c)),
                _ColorTile(label: _t('لون حدود الأزرار', 'Button border'), color: cfg.buttonBorderColor, onPicked: (c) => controller.setButtonBorderColor(c)),
                _SliderTile(label: _t('سماكة الحدود', 'Border width'), value: cfg.buttonBorderWidth, min: 0, max: 4, onChanged: (v) => controller.setButtonBorderWidth(v)),
                _SliderTile(label: _t('استدارة الزوايا', 'Corner radius'), value: cfg.buttonRadius, min: 0, max: 24, onChanged: (v) => controller.setButtonRadius(v)),
                _SliderTile(label: _t('قوة الظل', 'Shadow blur'), value: cfg.buttonShadowBlur, min: 0, max: 30, onChanged: (v) => controller.setButtonShadowBlur(v)),
                _SliderTile(label: _t('شفافية الظل', 'Shadow opacity'), value: cfg.buttonShadowOpacity, min: 0, max: 0.8, onChanged: (v) => controller.setButtonShadowOpacity(v)),
                _SliderTile(label: _t('لمعة الزجاج', 'Glass shine'), value: cfg.buttonShine, min: 0, max: 1, onChanged: (v) => controller.setButtonShine(v)),
                if (cfg.useDistinctActionButtonColors) ...[
                  _ColorTile(label: _t('زر إضافة', 'Add btn'), color: cfg.actionAddButtonColor, onPicked: (c) => controller.setActionAddButtonColor(c)),
                  _ColorTile(label: _t('زر تعديل', 'Edit btn'), color: cfg.actionEditButtonColor, onPicked: (c) => controller.setActionEditButtonColor(c)),
                  _ColorTile(label: _t('زر حذف', 'Delete btn'), color: cfg.actionDeleteButtonColor, onPicked: (c) => controller.setActionDeleteButtonColor(c)),
                  _ColorTile(label: _t('زر الحالة', 'Status btn'), color: cfg.actionStatusButtonColor, onPicked: (c) => controller.setActionStatusButtonColor(c)),
                ],
              ],
            ),

            const SizedBox(height: 20),

            // ── Apply / Cancel / Reset ─────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.resetToDefaults,
                    icon: const Icon(Icons.restore),
                    label: Text(_t('الافتراضي', 'Defaults')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                    label: Text(_t('إلغاء', 'Cancel')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textBlack,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await controller.applyChanges();
                      const appliedThemeName = 'Applied Theme';
                      final savedThemes = await controller.getSavedThemes();
                      final existing = savedThemes.where((t) => t.name == appliedThemeName);
                      if (existing.isNotEmpty) {
                        await controller.saveCurrentTheme(appliedThemeName, id: existing.first.id);
                      } else {
                        await controller.saveCurrentTheme(appliedThemeName);
                      }
                      if (context.mounted) Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.check),
                    label: Text(_t('تطبيق وحفظ', 'Apply & Save')),
                  ),
                ),
              ],
            ),
          ],
        );

        if (asOverlay) {
          return SafeArea(
            child: Align(
              alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 420,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: panelBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x18000000), blurRadius: 24, offset: Offset(0, 8)),
                    ],
                    border: Border.all(color: panelBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.design_services_rounded, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _t('إعدادات التصميم', 'Design Settings'),
                                style: const TextStyle(color: textBlack, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              icon: const Icon(Icons.close, color: textBlack, size: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Theme(data: modernTheme, child: body)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: panelBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: textBlack,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(_t('إعدادات التصميم', 'Design Settings'),
                style: const TextStyle(color: textBlack, fontWeight: FontWeight.w700)),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: Color(0xFFE2E8F0)),
            ),
          ),
          body: Theme(data: modernTheme, child: body),
        );
      },
    );
  }
}

// ─── Collapsible section container ───────────────────────────────────────────
class _CollapsibleSection extends StatefulWidget {
  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
    this.initiallyOpen = false,
  });
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;
  final bool initiallyOpen;

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromARGB(
            0x26,
            widget.accentColor.red,
            widget.accentColor.green,
            widget.accentColor.blue,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _open
                    ? _mixOpaque(Colors.white, widget.accentColor, 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _mixOpaque(Colors.white, widget.accentColor, 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.accentColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.children,
              ),
            ),
        ],
      ),
    );
  }
}

class _SavedThemesPanel extends StatefulWidget {
  const _SavedThemesPanel({
    required this.isArabic,
    required this.t,
  });

  final bool isArabic;
  final String Function(String ar, String en) t;

  @override
  State<_SavedThemesPanel> createState() => _SavedThemesPanelState();
}

class _SavedThemesPanelState extends State<_SavedThemesPanel> {
  final TextEditingController _nameController = TextEditingController();
  final DesignController _controller = DesignController.instance;
  List<SavedDesignTheme> _themes = <SavedDesignTheme>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final rows = await _controller.getSavedThemes();
    if (!mounted) return;
    setState(() {
      _themes = rows;
      _isLoading = false;
    });
  }

  void _showMsg(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      ),
    );
  }

  Future<void> _saveTheme() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMsg(widget.t('اكتب اسم للثيم أولاً', 'Enter a theme name first'), error: true);
      return;
    }
    try {
      await _controller.saveCurrentTheme(name);
      _nameController.clear();
      await _reload();
      _showMsg(widget.t('تم حفظ الثيم بنجاح', 'Theme saved successfully'));
    } on ArgumentError catch (e) {
      final msg = (e.message ?? '').toString().toLowerCase().contains('exists')
          ? widget.t('اسم الثيم موجود مسبقًا', 'Theme name already exists')
          : widget.t('الاسم غير صالح', 'Invalid theme name');
      _showMsg(msg, error: true);
    }
  }

  Future<void> _applyTheme(SavedDesignTheme theme) async {
    await _controller.previewSavedTheme(theme.id);
    if (!mounted) return;
    _showMsg(widget.t('تم تطبيق الثيم كمعاينة', 'Theme applied as preview'));
  }

  Future<void> _renameTheme(SavedDesignTheme theme) async {
    final nameController = TextEditingController(text: theme.name);
    final next = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.t('إعادة تسمية الثيم', 'Rename Theme')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: widget.t('اسم الثيم', 'Theme name'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(widget.t('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(nameController.text.trim()),
              child: Text(widget.t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
    nameController.dispose();

    if (next == null) return;
    if (next.trim().isEmpty) {
      _showMsg(widget.t('اسم الثيم لا يمكن أن يكون فارغًا', 'Theme name cannot be empty'),
          error: true);
      return;
    }

    try {
      await _controller.renameSavedTheme(theme.id, next);
      await _reload();
      _showMsg(widget.t('تم تعديل اسم الثيم', 'Theme renamed successfully'));
    } on ArgumentError {
      _showMsg(widget.t('الاسم موجود مسبقًا أو غير صالح', 'Name already exists or invalid'),
          error: true);
    }
  }

  Future<void> _deleteTheme(SavedDesignTheme theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.t('حذف الثيم', 'Delete Theme')),
          content: Text(
            widget.t(
              'هل تريد حذف الثيم "${theme.name}"؟',
              'Do you want to delete "${theme.name}"?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(widget.t('إلغاء', 'Cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(widget.t('حذف', 'Delete')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await _controller.deleteSavedTheme(theme.id);
    await _reload();
    _showMsg(widget.t('تم حذف الثيم', 'Theme deleted'));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: widget.t('اسم الثيم', 'Theme Name'),
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText:
                          widget.t('مثال: ثيم أزرق احترافي', 'e.g. Pro Blue Theme'),
                      hintStyle: const TextStyle(color: Colors.black54),
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saveTheme,
                  icon: const Icon(Icons.save),
                  label: Text(widget.t('حفظ كثيم', 'Save Theme')),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              )
            else if (_themes.isEmpty)
              Text(
                widget.t('لا توجد ثيمات محفوظة بعد', 'No saved themes yet'),
                style: const TextStyle(color: Colors.black),
              )
            else
              Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final theme in _themes)
                          OutlinedButton(
                            onPressed: () => _applyTheme(theme),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF000000),
                              side: const BorderSide(color: Color(0xFF94A3B8)),
                              backgroundColor: const Color(0xFFFFFFFF),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                            child: Text(theme.name),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final theme in _themes)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: ListTile(
                        title: Text(
                          theme.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          widget.t(
                            'آخر تحديث: ${theme.updatedAt.toLocal().toString().split('.').first}',
                            'Updated: ${theme.updatedAt.toLocal().toString().split('.').first}',
                          ),
                          style: const TextStyle(color: Colors.black87),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            TextButton(
                              onPressed: () => _applyTheme(theme),
                              child: Text(widget.t('تطبيق', 'Apply')),
                            ),
                            TextButton(
                              onPressed: () => _renameTheme(theme),
                              child: Text(widget.t('تعديل اسم', 'Rename')),
                            ),
                            TextButton(
                              onPressed: () => _deleteTheme(theme),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFB91C1C),
                              ),
                              child: Text(widget.t('حذف', 'Delete')),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHint extends StatelessWidget {
  const _SectionHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF000000),
          height: 1.35,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1.3,
          color: Color(0xFF000000),
        ),
      ),
    );
  }
}

class _BrightnessIndicator extends StatelessWidget {
  const _BrightnessIndicator({required this.value, required this.isArabic});

  final double value;
  final bool isArabic;

  String _label() {
    if (value > 0.08) return isArabic ? 'مُفَتَّح' : 'Lightened';
    if (value < -0.08) return isArabic ? 'مُغَمَّق' : 'Darkened';
    return isArabic ? 'محايد' : 'Neutral';
  }

  Color _chipColor() {
    if (value > 0.08) return const Color(0xFF0EA5E9);
    if (value < -0.08) return const Color(0xFF334155);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((value + 0.35) / 0.7).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isArabic ? 'مؤشر الإضاءة' : 'Brightness indicator',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _mixOpaque(Colors.white, _chipColor(), 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Color.fromARGB(
                        0x26,
                        _chipColor().red,
                        _chipColor().green,
                        _chipColor().blue,
                      ),
                    ),
                  ),
                  child: Text(
                    '${_label()}  ${value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: const Color(0x5522D3EE),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ${value.toStringAsFixed(1)}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.12,
                height: 1.35,
                color: Color(0xFF000000),
              ),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.label,
    required this.color,
    required this.onPicked,
  });

  final String label;
  final Color color;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: const Color(0x5522D3EE),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
            height: 1.35,
            color: Color(0xFF000000),
          ),
        ),
        trailing: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: const Color(0x663B4E6A)),
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4422D3EE),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        onTap: () async {
          await showDialog<void>(
            context: context,
            builder: (_) => _RgbColorPickerDialog(
              initial: color,
              onChanged: onPicked,
            ),
          );
        },
      ),
    );
  }
}

class _RgbColorPickerDialog extends StatefulWidget {
  const _RgbColorPickerDialog({
    required this.initial,
    required this.onChanged,
  });
  final Color initial;
  final ValueChanged<Color> onChanged;

  @override
  State<_RgbColorPickerDialog> createState() => _RgbColorPickerDialogState();
}

class _RgbColorPickerDialogState extends State<_RgbColorPickerDialog> {
  late double _r;
  late double _g;
  late double _b;

  // ── Tailwind / Radix-inspired palette ──────────────────────────────────────
  // Each entry: (family label, [shade100..shade900])
  static const _swatchGroups = <(String, List<Color>)>[
    ('Slate', [
      Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFCBD5E1),
      Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF475569),
      Color(0xFF334155), Color(0xFF1E293B), Color(0xFF0F172A),
    ]),
    ('Indigo', [
      Color(0xFFEEF2FF), Color(0xFFC7D2FE), Color(0xFFA5B4FC),
      Color(0xFF818CF8), Color(0xFF6366F1), Color(0xFF4F46E5),
      Color(0xFF4338CA), Color(0xFF3730A3), Color(0xFF312E81),
    ]),
    ('Sky', [
      Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFF7DD3FC),
      Color(0xFF38BDF8), Color(0xFF0EA5E9), Color(0xFF0284C7),
      Color(0xFF0369A1), Color(0xFF075985), Color(0xFF0C4A6E),
    ]),
    ('Emerald', [
      Color(0xFFECFDF5), Color(0xFFA7F3D0), Color(0xFF6EE7B7),
      Color(0xFF34D399), Color(0xFF10B981), Color(0xFF059669),
      Color(0xFF047857), Color(0xFF065F46), Color(0xFF064E3B),
    ]),
    ('Rose', [
      Color(0xFFFFF1F2), Color(0xFFFECDD3), Color(0xFFFDA4AF),
      Color(0xFFFB7185), Color(0xFFF43F5E), Color(0xFFE11D48),
      Color(0xFFBE123C), Color(0xFF9F1239), Color(0xFF881337),
    ]),
    ('Amber', [
      Color(0xFFFFFBEB), Color(0xFFFDE68A), Color(0xFFFCD34D),
      Color(0xFFFBBF24), Color(0xFFF59E0B), Color(0xFFD97706),
      Color(0xFFB45309), Color(0xFF92400E), Color(0xFF78350F),
    ]),
  ];

  static const _slate900 = Color(0xFF0F172A);
  static const _slate600 = Color(0xFF475569);

  @override
  void initState() {
    super.initState();
    _r = widget.initial.red.toDouble();
    _g = widget.initial.green.toDouble();
    _b = widget.initial.blue.toDouble();
  }

  void _pick(Color c) {
    setState(() {
      _r = c.red.toDouble();
      _g = c.green.toDouble();
      _b = c.blue.toDouble();
    });
    widget.onChanged(c);
  }

  @override
  Widget build(BuildContext context) {
    final current = Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);
    // hex string for display
    final hex =
        '#${current.red.toRadixString(16).padLeft(2, '0')}'
        '${current.green.toRadixString(16).padLeft(2, '0')}'
        '${current.blue.toRadixString(16).padLeft(2, '0')}'.toUpperCase();

    return AlertDialog(
      backgroundColor: const Color(0xFFF8FAFC),
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: current,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            hex,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _slate900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Preview bar ────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: current,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
              ),
              const SizedBox(height: 12),

              // ── RGB sliders ─────────────────────────────────────────────
              _rgbSlider('R', _r, const Color(0xFFE11D48),
                  (v) => setState(() => _r = v)),
              _rgbSlider('G', _g, const Color(0xFF059669),
                  (v) => setState(() => _g = v)),
              _rgbSlider('B', _b, const Color(0xFF4F46E5),
                  (v) => setState(() => _b = v)),
              const SizedBox(height: 10),

              // ── Tailwind swatches ───────────────────────────────────────
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 10),
              for (final group in _swatchGroups) ...[
                Text(
                  group.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _slate600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    for (final swatch in group.$2)
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _pick(swatch),
                          child: Container(
                            height: 26,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: swatch,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 0.6,
                              ),
                              boxShadow: swatch == current
                                  ? [
                                      BoxShadow(
                                        color: swatch.withOpacity(0.5),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: _slate900),
          child: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _rgbSlider(
      String label, double value, Color trackColor, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: trackColor,
              thumbColor: trackColor,
              overlayColor: trackColor.withOpacity(0.15),
              inactiveTrackColor: trackColor.withOpacity(0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 255,
              onChanged: (v) {
                onChanged(v);
                final now =
                    Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);
                widget.onChanged(now);
              },
            ),
          ),
        ),
        SizedBox(
          width: 30,
          child: Text(
            value.round().toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _slate600,
            ),
          ),
        ),
      ],
    );
  }
}
