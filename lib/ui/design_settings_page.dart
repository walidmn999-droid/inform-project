import 'package:flutter/material.dart';

import '../logic/design_controller.dart';

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
        const panelBg = Color(0xFFF4F8FC);
        const panelSurface = Color(0xFFFFFFFF);
        const panelBorder = Color(0x22315574);
        const neonAccent = Color(0xFF0EA5E9);
        const neonAccentSoft = Color(0x330EA5E9);
        final modernTheme = Theme.of(context).copyWith(
          scaffoldBackgroundColor: panelBg,
          cardTheme: CardTheme(
            color: panelSurface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: panelBorder),
            ),
            shadowColor: neonAccentSoft,
            margin: const EdgeInsets.symmetric(vertical: 6),
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
                bodyColor: const Color(0xFF0F172A),
                displayColor: const Color(0xFF0F172A),
              ).copyWith(
                bodyMedium: const TextStyle(
                  letterSpacing: 0.15,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
                titleMedium: const TextStyle(
                  letterSpacing: 0.1,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                ),
              ),
          dividerColor: const Color(0x22315574),
        );
        final body = ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFF22D3EE)),
                  title: Text(
                    _t('طريقة الاستخدام', 'How to use'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    _t(
                      'كل تغيير هنا يظهر مباشرة كمعاينة. لن يتم الحفظ الدائم إلا بعد الضغط على "تطبيق".\nلإلغاء التغييرات الحالية اضغط "إلغاء".',
                      'All changes here are live preview. Permanent save happens only after "Apply".\nUse "Cancel" to discard current changes.',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SectionTitle(_t('الأحجام', 'Sizing')),
              _SectionHint(_t(
                'هذه الإعدادات تتحكم في المقاسات والمسافات داخل جدول المعاملات.',
                'These settings control dimensions and spacing inside the transactions table.',
              )),
              _SliderTile(
                label: _t('حجم أيقونة المرفقات', 'Attachment icon size'),
                value: cfg.attachmentIconSize,
                min: 8,
                max: 24,
                onChanged: (v) => controller.setAttachmentIconSize(v),
              ),
              _SliderTile(
                label: _t('ارتفاع صف المعاملة', 'Transaction row height'),
                value: cfg.transactionRowHeight,
                min: 34,
                max: 74,
                onChanged: (v) => controller.setTransactionRowHeight(v),
              ),
              _SliderTile(
                label: _t('المسافة الرأسية داخل الصف', 'Row vertical spacing'),
                value: cfg.rowVerticalPadding,
                min: 2,
                max: 24,
                onChanged: (v) => controller.setRowVerticalPadding(v),
              ),
              _SliderTile(
                label: _t('المسافة بين كروت المعاملات', 'Spacing between cards'),
                value: cfg.cardSpacing,
                min: 2,
                max: 24,
                onChanged: (v) => controller.setCardSpacing(v),
              ),
              _SliderTile(
                label: _t('سماكة إطار الكارت', 'Card border thickness'),
                value: cfg.cardBorderWidth,
                min: 0.6,
                max: 3.5,
                onChanged: (v) => controller.setCardBorderWidth(v),
              ),
              _SliderTile(
                label: _t('حجم الخط الأساسي', 'Base font size'),
                value: cfg.baseFontSize,
                min: 11,
                max: 22,
                onChanged: (v) => controller.setBaseFontSize(v),
              ),
              Builder(
                builder: (context) {
                  const fontOptions = <String>[
                    'Inter',
                    'Poppins',
                    'Segoe UI',
                    'Arial',
                    'Tahoma',
                    'Calibri',
                    'Courier New',
                  ];
                  final selectedFont = fontOptions.contains(cfg.fontFamilyName)
                      ? cfg.fontFamilyName
                      : fontOptions.first;
                  return Card(
                    child: ListTile(
                      title: Text(_t('نوع الخط', 'Font family')),
                      trailing: DropdownButton<String>(
                        value: selectedFont,
                        items: const [
                          DropdownMenuItem(value: 'Inter', child: Text('Inter')),
                          DropdownMenuItem(value: 'Poppins', child: Text('Poppins')),
                          DropdownMenuItem(value: 'Segoe UI', child: Text('Segoe UI')),
                          DropdownMenuItem(value: 'Arial', child: Text('Arial')),
                          DropdownMenuItem(value: 'Tahoma', child: Text('Tahoma')),
                          DropdownMenuItem(value: 'Calibri', child: Text('Calibri')),
                          DropdownMenuItem(
                            value: 'Courier New',
                            child: Text('Courier New'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.setFontFamilyName(v);
                        },
                      ),
                    ),
                  );
                },
              ),
              _SliderTile(
                label: _t('سماكة الخط', 'Font weight'),
                value: cfg.fontWeightLevel,
                min: 300,
                max: 800,
                onChanged: (v) => controller.setFontWeightLevel(v),
              ),
              _SectionTitle(_t('خيارات التصميم العامة', 'Global design options')),
              _SectionHint(_t(
                'تفتيح/تغميق سريع على كامل المظهر بدون تغيير القيم الأساسية.',
                'Quick brighten/darken over the whole look without replacing your base values.',
              )),
              _BrightnessIndicator(
                value: cfg.uiBrightnessShift,
                isArabic: isArabic,
              ),
              _SliderTile(
                label: _t('تفتيح/تغميق التصميم', 'Lighten/Darken design'),
                value: cfg.uiBrightnessShift,
                min: -0.35,
                max: 0.35,
                onChanged: (v) => controller.setUiBrightnessShift(v),
              ),
              const SizedBox(height: 16),
              _SectionTitle(_t('الألوان', 'Colors')),
              _SectionHint(_t(
                'اختر باليتة جاهزة أو عدّل كل لون يدويًا.',
                'Choose a ready palette or customize each color manually.',
              )),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final id in DesignController.paletteIds)
                        OutlinedButton(
                          onPressed: () => controller.applyPalettePreset(id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE2E8F0),
                            side: const BorderSide(color: Color(0x6640E0FF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0x2218243A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            id == 'new_theme_linked'
                                ? _t('نيو ثيم (مرتبط بزر السايدبار)',
                                    'New Theme (linked to sidebar button)')
                                : DesignController.paletteTitle(id),
                            style: const TextStyle(
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _ColorTile(
                label: _t('لون هيدر الجدول', 'Table header color'),
                color: cfg.tableHeaderColor,
                onPicked: (c) => controller.setTableHeaderColor(c),
              ),
              _ColorTile(
                label: _t('لون خلفية الجدول', 'Table area color'),
                color: cfg.tableAreaColor,
                onPicked: (c) => controller.setTableAreaColor(c),
              ),
              _ColorTile(
                label: _t('لون كروت المعاملات', 'Transaction card color'),
                color: cfg.transactionCardColor,
                onPicked: (c) => controller.setTransactionCardColor(c),
              ),
              _ColorTile(
                label: _t('لون السايدبار', 'Sidebar color'),
                color: cfg.sidebarColor,
                onPicked: (c) => controller.setSidebarColor(c),
              ),
              _SectionTitle(_t('الأزرار', 'Buttons')),
              _SectionHint(_t(
                'هذه الإعدادات تؤثر على أزرار الإجراءات في الصفحة.',
                'These settings affect action buttons on the page.',
              )),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('خصائص التصميم الزجاجي', 'Glass design properties'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _t(
                          'هذا القسم يعطي مظهر زجاجي (Glass) عبر الحدود والشفافية واللمعة، بدون إجبار أي تغيير دائم إلا عند تطبيق.',
                          'This section creates a glass look via border, opacity and shine, with no permanent change until Apply.',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () {
                              controller.preview(
                                cfg.copyWith(
                                  buttonPresetStyle: 2,
                                  buttonShapeStyle: 0,
                                  buttonBorderWidth: 1.2,
                                  buttonRadius: 10,
                                  buttonShadowBlur: 18,
                                  buttonShadowOpacity: 0.3,
                                  buttonShine: 0.42,
                                  buttonBorderColor: const Color(0x8893C5DB),
                                ),
                              );
                            },
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(_t('تفعيل مظهر زجاجي جاهز',
                                'Apply ready glass look')),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              controller.preview(
                                cfg.copyWith(
                                  buttonPresetStyle: 0,
                                  buttonShadowBlur: 8,
                                  buttonShadowOpacity: 0.12,
                                  buttonShine: 0.1,
                                ),
                              );
                            },
                            icon: const Icon(Icons.layers_clear),
                            label: Text(_t('تقليل التأثير الزجاجي',
                                'Reduce glass effect')),
                          ),
                        ],
                      ),
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
                  title: Text(_t('ستايل الزر الحديث', 'Modern button style')),
                  trailing: DropdownButton<int>(
                    value: cfg.buttonPresetStyle,
                    items: [
                      DropdownMenuItem(
                          value: 0, child: Text(_t('مخصص', 'Custom'))),
                      DropdownMenuItem(
                          value: 1, child: Text(_t('Gradient', 'Gradient'))),
                      DropdownMenuItem(
                          value: 2, child: Text(_t('Glass', 'Glass'))),
                      DropdownMenuItem(
                          value: 3, child: Text(_t('Soft', 'Soft'))),
                      DropdownMenuItem(
                          value: 4, child: Text(_t('Minimal', 'Minimal'))),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.setButtonPresetStyle(v);
                    },
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text(_t('شكل الأزرار', 'Button shape')),
                  trailing: DropdownButton<int>(
                    value: cfg.buttonShapeStyle,
                    items: [
                      DropdownMenuItem(
                          value: 0, child: Text(_t('منحني', 'Rounded'))),
                      DropdownMenuItem(value: 1, child: Text(_t('كبسولة', 'Pill'))),
                      DropdownMenuItem(value: 2, child: Text(_t('مربع', 'Square'))),
                      DropdownMenuItem(value: 3, child: Text(_t('ناعم جداً', 'Soft'))),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.setButtonShapeStyle(v);
                    },
                  ),
                ),
              ),
              _ColorTile(
                label: _t('لون خلفية الأزرار', 'Button background color'),
                color: cfg.buttonBgColor,
                onPicked: (c) => controller.setButtonBgColor(c),
              ),
              _ColorTile(
                label: _t('لون نص الأزرار', 'Button text color'),
                color: cfg.buttonTextColor,
                onPicked: (c) => controller.setButtonTextColor(c),
              ),
              _ColorTile(
                label: _t('لون حدود الأزرار', 'Button border color'),
                color: cfg.buttonBorderColor,
                onPicked: (c) => controller.setButtonBorderColor(c),
              ),
              _SliderTile(
                label: _t('سماكة حدود الأزرار', 'Button border width'),
                value: cfg.buttonBorderWidth,
                min: 0,
                max: 4,
                onChanged: (v) => controller.setButtonBorderWidth(v),
              ),
              _SliderTile(
                label: _t('استدارة الأزرار', 'Button corner radius'),
                value: cfg.buttonRadius,
                min: 0,
                max: 24,
                onChanged: (v) => controller.setButtonRadius(v),
              ),
              _SliderTile(
                label: _t('قوة ضباب الزجاج (الظل)', 'Glass blur strength (shadow blur)'),
                value: cfg.buttonShadowBlur,
                min: 0,
                max: 30,
                onChanged: (v) => controller.setButtonShadowBlur(v),
              ),
              _SliderTile(
                label: _t('شفافية الزجاج (الظل)', 'Glass opacity (shadow opacity)'),
                value: cfg.buttonShadowOpacity,
                min: 0,
                max: 0.8,
                onChanged: (v) => controller.setButtonShadowOpacity(v),
              ),
              _SliderTile(
                label: _t('لمعة الزجاج', 'Glass shine intensity'),
                value: cfg.buttonShine,
                min: 0,
                max: 1,
                onChanged: (v) => controller.setButtonShine(v),
              ),
              if (cfg.useDistinctActionButtonColors) ...[
                _ColorTile(
                  label: _t('لون زر إضافة', 'Add button color'),
                  color: cfg.actionAddButtonColor,
                  onPicked: (c) => controller.setActionAddButtonColor(c),
                ),
                _ColorTile(
                  label: _t('لون زر تعديل', 'Edit button color'),
                  color: cfg.actionEditButtonColor,
                  onPicked: (c) => controller.setActionEditButtonColor(c),
                ),
                _ColorTile(
                  label: _t('لون زر حذف', 'Delete button color'),
                  color: cfg.actionDeleteButtonColor,
                  onPicked: (c) => controller.setActionDeleteButtonColor(c),
                ),
                _ColorTile(
                  label: _t('لون زر الحالة', 'Status button color'),
                  color: cfg.actionStatusButtonColor,
                  onPicked: (c) => controller.setActionStatusButtonColor(c),
                ),
              ],
              Card(
                child: ListTile(
                  leading: Icon(
                    controller.hasGoodContrast(
                            controller.onColorFor(cfg.tableHeaderColor),
                            cfg.tableHeaderColor)
                        ? Icons.check_circle
                        : Icons.warning_amber_rounded,
                    color: controller.hasGoodContrast(
                            controller.onColorFor(cfg.tableHeaderColor),
                            cfg.tableHeaderColor)
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text(_t('فحص التباين', 'Contrast check')),
                  subtitle: Text(
                    _t(
                      'يتم ضبط لون النص تلقائياً لضمان الوضوح.',
                      'Text color is auto-adjusted for readability.',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.resetToDefaults,
                      icon: const Icon(Icons.restore),
                      label: Text(_t('استعادة الافتراضي (معاينة)',
                          'Restore defaults (preview)')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                      label: Text(_t('إلغاء بدون حفظ', 'Cancel without saving')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await controller.applyChanges();
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
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
                      BoxShadow(
                        color: neonAccentSoft,
                        blurRadius: 20,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: panelBorder),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: cfg.sidebarColor,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _t('إعدادات التصميم', 'Design Settings'),
                                style: TextStyle(
                                  color: controller.onColorFor(cfg.sidebarColor),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              icon: Icon(
                                Icons.close,
                                color: controller.onColorFor(cfg.sidebarColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Theme(
                          data: modernTheme,
                          child: body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(_t('إعدادات التصميم', 'Design Settings')),
            backgroundColor: cfg.sidebarColor,
            foregroundColor: controller.onColorFor(cfg.sidebarColor),
          ),
          body: Theme(
            data: modernTheme,
            child: body,
          ),
        );
      },
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
          color: Color(0xFF475569),
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
          color: Color(0xFF0F172A),
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
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _chipColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _chipColor().withOpacity(0.4)),
                  ),
                  child: Text(
                    '${_label()}  ${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _chipColor(),
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

  @override
  void initState() {
    super.initState();
    _r = widget.initial.red.toDouble();
    _g = widget.initial.green.toDouble();
    _b = widget.initial.blue.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final current = Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);
    const modernSwatches = <Color>[
      Color(0xFF0B1220),
      Color(0xFF111827),
      Color(0xFF1E293B),
      Color(0xFF334155),
      Color(0xFF475569),
      Color(0xFF64748B),
      Color(0xFF94A3B8),
      Color(0xFFCBD5E1),
      Color(0xFFE2E8F0),
      Color(0xFFF8FAFC),
      Color(0xFF22D3EE),
      Color(0xFF14F1D9),
      Color(0xFF60A5FA),
      Color(0xFF6366F1),
      Color(0xFF34D399),
      Color(0xFFF59E0B),
      Color(0xFFFB7185),
    ];
    return AlertDialog(
      backgroundColor: const Color(0xFFF8FAFC),
      title: const Text('Pick color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: current,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 10),
          _rgbSlider('R', _r, (v) => setState(() => _r = v)),
          _rgbSlider('G', _g, (v) => setState(() => _g = v)),
          _rgbSlider('B', _b, (v) => setState(() => _b = v)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final swatch in modernSwatches)
                InkWell(
                  onTap: () => setState(() {
                    _r = swatch.red.toDouble();
                    _g = swatch.green.toDouble();
                    _b = swatch.blue.toDouble();
                    widget.onChanged(
                        Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1));
                  }),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: swatch,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: swatch == const Color(0xFFF8FAFC)
                            ? const Color(0xAA334155)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _rgbSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 18, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            onChanged: (v) {
              onChanged(v);
              final now = Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);
              widget.onChanged(now);
            },
          ),
        ),
      ],
    );
  }
}
