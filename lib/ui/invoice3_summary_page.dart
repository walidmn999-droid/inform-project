import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/customer_transactions_logic.dart';
import '../logic/design_controller.dart';

// ─── Derived soft text = text color at 60% opacity ────────────────────────
Color _soft(Color base) => base.withOpacity(0.60);
Color _brd(Color accent) => accent.withOpacity(0.35);

class Invoice3SummaryPage extends StatefulWidget {
  const Invoice3SummaryPage({
    super.key,
    required this.isArabic,
    required this.customerNameAr,
    required this.customerNameEn,
    required this.transactions,
  });

  final bool isArabic;
  final String customerNameAr;
  final String customerNameEn;
  final List<CustomerTransaction> transactions;

  @override
  State<Invoice3SummaryPage> createState() => _Invoice3SummaryPageState();
}

class _Invoice3SummaryPageState extends State<Invoice3SummaryPage> {
  final _ctrl = DesignController.instance;
  bool _panelOpen = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  String _t(String ar, String en) => widget.isArabic ? ar : en;

  String _fmt(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final sb = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) sb.write(',');
      sb.write(parts[0][i]);
    }
    return '${sb.toString()}.${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cfg         = _ctrl.config;
    final primary     = cfg.invoicePrimaryColor;
    final accent      = cfg.invoiceAccentColor;
    final secondary   = cfg.invoiceSecondaryColor;
    final textColor   = cfg.invoiceTextColor;
    final softColor   = _soft(textColor);
    final borderColor = _brd(accent);

    final txs        = widget.transactions;
    final items      = <_LineRow>[];
    for (final tx in txs) {
      for (final it in tx.items) {
        items.add(_LineRow(
          nameAr: it.serviceAr,
          nameEn: it.serviceEn,
          unitPrice: it.unitPrice,
          qty: it.qty,
          total: it.total,
        ));
      }
    }
    if (items.isEmpty) {
      items.add(const _LineRow(nameAr: '-', nameEn: '-', unitPrice: 0, qty: 0, total: 0));
    }

    final grandTotal = txs.fold<double>(0, (s, tx) => s + tx.grandTotal);
    final tax        = grandTotal * 0.05;
    final beforeTax  = grandTotal - tax;
    final invNo      = txs.isNotEmpty ? txs.first.invoiceNumber : '---';
    final invDate    = txs.isNotEmpty ? txs.first.date : '---';
    const phone      = '+971 556 428 050';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: secondary.withOpacity(0.4),
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(_t('فاتورة 3', 'Invoice 3')),
          actions: [
            IconButton(
              tooltip: _t('تعديل التصميم', 'Design Panel'),
              icon: Icon(_panelOpen ? Icons.tune : Icons.tune_outlined),
              onPressed: () => setState(() => _panelOpen = !_panelOpen),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── A4 Invoice preview ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 794),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderColor),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CustomPaint(
                            painter: _CornersPainter(accent: accent, secondary: secondary),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(40, 32, 40, 36),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeader(invDate, invNo, accent, textColor, softColor),
                                  const SizedBox(height: 10),
                                  Divider(color: borderColor, thickness: 1.2),
                                  const SizedBox(height: 10),
                                  _buildCustomerBlock(
                                    widget.customerNameAr, widget.customerNameEn,
                                    phone, textColor, softColor, accent, borderColor,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildItemsTable(items, primary, secondary, borderColor, textColor, softColor),
                                  const SizedBox(height: 20),
                                  _buildTotals(beforeTax, tax, grandTotal, accent, textColor, softColor, borderColor),
                                  const SizedBox(height: 28),
                                  _buildStampAndLogo(accent, softColor),
                                  const SizedBox(height: 20),
                                  Text(
                                    'الاستبدال والاسترجاع خلال 14 يومًا من تاريخ تسليم السلعة / Returns & exchanges within 14 days of delivery.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: softColor, fontSize: 9.5, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildFooter(softColor, accent),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ── Side design panel ───────────────────────────────────────
              if (_panelOpen)
                _InvoiceDesignPanel(ctrl: _ctrl, isArabic: widget.isArabic),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header: logo + company info on start, big title on end ───────────────
  Widget _buildHeader(String invDate, String invNo, Color accent, Color textColor, Color softColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company identity block
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('شركة الإعلام',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900)),
                    Text('Inform Company',
                        style: TextStyle(color: softColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            _metaLine('التاريخ / Date', invDate, textColor, softColor),
            const SizedBox(height: 5),
            _metaLine('رقم الفاتورة / Invoice No.', invNo, textColor, softColor),
          ],
        ),
        const Spacer(),
        // Invoice title
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('فـاتـورة',
                style: TextStyle(color: accent, fontSize: 46, fontWeight: FontWeight.w900, height: 0.95)),
            Text('INVOICE',
                style: TextStyle(color: accent, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 5)),
          ],
        ),
      ],
    );
  }

  Widget _metaLine(String label, String value, Color textColor, Color softColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 11.5)),
        Text(value, style: TextStyle(color: softColor, fontWeight: FontWeight.w600, fontSize: 11.5)),
      ],
    );
  }

  // ── Customer block ────────────────────────────────────────────────────────
  Widget _buildCustomerBlock(String customerAr, String customerEn, String phone,
      Color textColor, Color softColor, Color accent, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.05),
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('فاتورة إلى / Bill To',
                    style: TextStyle(color: accent, fontSize: 10.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(customerAr,
                    style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900)),
                Text(customerEn,
                    style: TextStyle(color: softColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 12, color: softColor),
                  const SizedBox(width: 4),
                  Text(phone, style: TextStyle(color: softColor, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Items table (bilingual headers + bilingual item names) ────────────────
  Widget _buildItemsTable(List<_LineRow> rows, Color primary, Color secondary,
      Color borderColor, Color textColor, Color softColor) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                _hCell('#', 1),
                _hCell('الوصف / Description', 5),
                _hCell('الكمية / Qty', 2),
                _hCell('سعر الوحدة / Unit Price', 3),
                _hCell('الإجمالي / Total', 2),
              ],
            ),
          ),
          // Data rows
          for (int i = 0; i < rows.length; i++)
            Container(
              color: i.isOdd ? secondary.withOpacity(0.3) : const Color(0xFFFBFCFD),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _dCell('${i + 1}', 1, TextAlign.center, textColor),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].nameAr,
                            style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
                        Text(rows[i].nameEn,
                            style: TextStyle(color: softColor, fontSize: 10, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  _dCell('${rows[i].qty}', 2, TextAlign.center, textColor),
                  _dCell(_fmt(rows[i].unitPrice), 3, TextAlign.center, textColor),
                  _dCell(_fmt(rows[i].total), 2, TextAlign.center, textColor, bold: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _hCell(String t, int flex) => Expanded(
        flex: flex,
        child: Text(t,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10.5)),
      );

  Widget _dCell(String t, int flex, TextAlign align, Color textColor, {bool bold = false}) =>
      Expanded(
        flex: flex,
        child: Text(t,
            textAlign: align,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      );

  // ── Totals ────────────────────────────────────────────────────────────────
  Widget _buildTotals(double beforeTax, double tax, double grandTotal,
      Color accent, Color textColor, Color softColor, Color borderColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.04),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            _totalRow('قبل الضريبة / Before Tax', _fmt(beforeTax), textColor, softColor),
            const SizedBox(height: 5),
            _totalRow('ضريبة القيمة المضافة / VAT (5%)', _fmt(tax), textColor, softColor),
            Divider(color: accent, height: 18, thickness: 1.5),
            _totalRow('الإجمالي / Grand Total', _fmt(grandTotal), accent, accent, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, Color labelColor, Color valueColor,
      {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                  color: labelColor,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: bold ? 13 : 11.5)),
        ),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 15 : 12)),
      ],
    );
  }

  // ── Stamp + Logo (always after last item) ─────────────────────────────────
  Widget _buildStampAndLogo(Color accent, Color softColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Official stamp
        SizedBox(
          width: 110,
          height: 110,
          child: CustomPaint(
            painter: _StampPainter(accent),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('مدفوع',
                      style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          letterSpacing: 1)),
                  Text('PAID',
                      style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 4)),
                ],
              ),
            ),
          ),
        ),
        // Logo
        Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: const Icon(Icons.business_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 6),
            Text('شركة الإعلام',
                style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 13)),
            Text('Inform Company',
                style: TextStyle(color: softColor, fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(Color softColor, Color accent) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: _brd(accent), width: 1.2))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _footerItem(Icons.location_on_outlined,
              'العنوان: شارع الاتحاد، أبوظبي / Union St., Abu Dhabi', softColor),
          _footerItem(Icons.phone_outlined, '+971 556 428 050', softColor),
          _footerItem(Icons.email_outlined, 'info@inform.ae', softColor),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _LineRow {
  const _LineRow({
    required this.nameAr,
    required this.nameEn,
    required this.unitPrice,
    required this.qty,
    required this.total,
  });

  final String nameAr;
  final String nameEn;
  final double unitPrice;
  final int qty;
  final double total;
}

// ─── Side design panel ────────────────────────────────────────────────────
class _InvoiceDesignPanel extends StatefulWidget {
  const _InvoiceDesignPanel({required this.ctrl, required this.isArabic});
  final DesignController ctrl;
  final bool isArabic;

  @override
  State<_InvoiceDesignPanel> createState() => _InvoiceDesignPanelState();
}

class _InvoiceDesignPanelState extends State<_InvoiceDesignPanel> {
  String _t(String ar, String en) => widget.isArabic ? ar : en;

  @override
  Widget build(BuildContext context) {
    final cfg = widget.ctrl.config;
    return Container(
      width: 270,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(left: BorderSide(color: Color(0xFFD5DDE7))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF6F8297),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              _t('ألوان الفاتورة', 'Invoice Colors'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InvoiceColorRow(
                    label: _t('هيدر الجدول', 'Table Header'),
                    color: cfg.invoicePrimaryColor,
                    onPicked: (c) => widget.ctrl.setInvoicePrimaryColor(c),
                  ),
                  const SizedBox(height: 10),
                  _InvoiceColorRow(
                    label: _t('صفوف بديلة / شريط', 'Alt Rows / Stripe'),
                    color: cfg.invoiceSecondaryColor,
                    onPicked: (c) => widget.ctrl.setInvoiceSecondaryColor(c),
                  ),
                  const SizedBox(height: 10),
                  _InvoiceColorRow(
                    label: _t('العنوان / الزوايا', 'Title / Corners'),
                    color: cfg.invoiceAccentColor,
                    onPicked: (c) => widget.ctrl.setInvoiceAccentColor(c),
                  ),
                  const SizedBox(height: 10),
                  _InvoiceColorRow(
                    label: _t('النص الرئيسي', 'Main Text'),
                    color: cfg.invoiceTextColor,
                    onPicked: (c) => widget.ctrl.setInvoiceTextColor(c),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F8297),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => widget.ctrl.applyChanges(),
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: Text(_t('حفظ', 'Save')),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6F8297),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      await widget.ctrl.resetToDefaults();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(_t('إعادة ضبط', 'Reset')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceColorRow extends StatefulWidget {
  const _InvoiceColorRow({
    required this.label,
    required this.color,
    required this.onPicked,
  });
  final String label;
  final Color color;
  final ValueChanged<Color> onPicked;

  @override
  State<_InvoiceColorRow> createState() => _InvoiceColorRowState();
}

class _InvoiceColorRowState extends State<_InvoiceColorRow> {
  late double _r, _g, _b;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant _InvoiceColorRow old) {
    super.didUpdateWidget(old);
    if (old.color != widget.color) _syncFromWidget();
  }

  void _syncFromWidget() {
    _r = widget.color.red.toDouble();
    _g = widget.color.green.toDouble();
    _b = widget.color.blue.toDouble();
  }

  Color get _current => Color.fromRGBO(_r.round(), _g.round(), _b.round(), 1);

  void _emit() => widget.onPicked(_current);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD5DDE7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: const Color(0x663B4E6A)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Color(0xFF243241),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _slider('R', _r, (v) => setState(() { _r = v; _emit(); }), const Color(0xFFDC2626)),
          _slider('G', _g, (v) => setState(() { _g = v; _emit(); }), const Color(0xFF16A34A)),
          _slider('B', _b, (v) => setState(() { _b = v; _emit(); }), const Color(0xFF2563EB)),
          const SizedBox(height: 6),
          // quick swatches
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final sw in const <Color>[
                Color(0xFF8E9FB1), Color(0xFF6F8297), Color(0xFFE9EDF2),
                Color(0xFF243241), Color(0xFF1E293B), Color(0xFF334155),
                Color(0xFF64748B), Color(0xFF94A3B8), Color(0xFFCBD5E1),
                Color(0xFFF8FAFC), Color(0xFF22D3EE), Color(0xFF6366F1),
              ])
                GestureDetector(
                  onTap: () => setState(() {
                    _r = sw.red.toDouble();
                    _g = sw.green.toDouble();
                    _b = sw.blue.toDouble();
                    _emit();
                  }),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: sw,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: sw == widget.color
                            ? const Color(0xFF6F8297)
                            : const Color(0x33000000),
                        width: sw == widget.color ? 2 : 0.8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged, Color trackColor) {
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF4E5E6F), fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: trackColor,
              thumbColor: trackColor,
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 255,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 26,
          child: Text(
            value.round().toString(),
            style: const TextStyle(fontSize: 9, color: Color(0xFF4E5E6F), fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ─── Stamp painter: circular seal with tick marks ─────────────────────────
class _StampPainter extends CustomPainter {
  const _StampPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center  = Offset(size.width / 2, size.height / 2);
    final outerR  = size.width / 2 - 3;
    final innerR  = outerR - 11;
    final paint   = Paint()..style = PaintingStyle.stroke;

    paint
      ..color = color.withOpacity(0.55)
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, outerR, paint);

    paint
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, innerR, paint);

    paint
      ..color = color.withOpacity(0.28)
      ..strokeWidth = 1.1;
    const tickCount = 36;
    for (int i = 0; i < tickCount; i++) {
      if (i % 3 == 0) continue;
      final angle = (i * 2 * math.pi) / tickCount;
      final x1 = center.dx + (innerR + 2)  * math.cos(angle);
      final y1 = center.dy + (innerR + 2)  * math.sin(angle);
      final x2 = center.dx + (outerR - 2)  * math.cos(angle);
      final y2 = center.dy + (outerR - 2)  * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_StampPainter old) => old.color != color;
}

// ─── Corner painter: sizes itself to child → no zero-size issue ────────────
class _CornersPainter extends CustomPainter {
  const _CornersPainter({required this.accent, required this.secondary});
  final Color accent;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    _drawTopLeft(canvas, size);
    _drawBottomRight(canvas, size);
  }

  void _drawTopLeft(Canvas canvas, Size size) {
    final w = size.width * 0.22;
    final h = size.height * 0.18;

    final p1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.58, 0)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p1, Paint()..color = accent);

    final p2 = Path()
      ..moveTo(w * 0.58, 0)
      ..lineTo(w * 0.88, 0)
      ..lineTo(w * 0.24, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(p2, Paint()..color = secondary);
  }

  void _drawBottomRight(Canvas canvas, Size size) {
    final w = size.width * 0.22;
    final h = size.height * 0.18;
    final rx = size.width;
    final ry = size.height;

    final p1 = Path()
      ..moveTo(rx - w * 0.42, ry)
      ..lineTo(rx, ry)
      ..lineTo(rx, ry - h)
      ..close();
    canvas.drawPath(p1, Paint()..color = accent);

    final p2 = Path()
      ..moveTo(rx - w * 0.15, ry)
      ..lineTo(rx - w * 0.42, ry)
      ..lineTo(rx, ry - h)
      ..lineTo(rx - w * 0.74, ry - h)
      ..close();
    canvas.drawPath(p2, Paint()..color = secondary);
  }

  @override
  bool shouldRepaint(covariant _CornersPainter old) =>
      old.accent != accent || old.secondary != secondary;
}
