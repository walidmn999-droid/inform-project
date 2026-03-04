import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../logic/customer_transactions_logic.dart';
import '../logic/design_controller.dart';
import '../logic/saved_invoices_store.dart';

// ─── Derived soft text = text color at 60% opacity ────────────────────────
Color _soft(Color base) => _mixOpaque(base, Colors.white, 0.34);
Color _brd(Color accent) => Color.fromARGB(0x26, accent.red, accent.green, accent.blue);
Color _mixOpaque(Color a, Color b, double t) {
  final clamped = t.clamp(0.0, 1.0);
  final r = (a.red + ((b.red - a.red) * clamped)).round();
  final g = (a.green + ((b.green - a.green) * clamped)).round();
  final bCh = (a.blue + ((b.blue - a.blue) * clamped)).round();
  return Color.fromARGB(0xFF, r, g, bCh);
}
const List<String> _invoiceFontOptions = <String>[
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

class Invoice3SummaryPage extends StatefulWidget {
  const Invoice3SummaryPage({
    super.key,
    required this.isArabic,
    required this.customerNameAr,
    required this.customerNameEn,
    required this.transactions,
    this.customerId = 0,
    this.isPrintPreview = false,
  });

  final bool isArabic;
  final String customerNameAr;
  final String customerNameEn;
  final List<CustomerTransaction> transactions;
  final int customerId;
  final bool isPrintPreview;

  @override
  State<Invoice3SummaryPage> createState() => _Invoice3SummaryPageState();
}

class _Invoice3SummaryPageState extends State<Invoice3SummaryPage> {
  final _ctrl = DesignController.instance;
  final GlobalKey _invoiceCaptureKey = GlobalKey();
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

  TextTheme _resolveInvoiceTextTheme(TextTheme base, String family) {
    switch (family) {
      case 'Cairo':
        return GoogleFonts.cairoTextTheme(base);
      case 'Tajawal':
        return GoogleFonts.tajawalTextTheme(base);
      case 'Almarai':
        return GoogleFonts.almaraiTextTheme(base);
      case 'Changa':
        return GoogleFonts.changaTextTheme(base);
      case 'ElMessiri':
        return GoogleFonts.elMessiriTextTheme(base);
      case 'NotoNaskhArabic':
        return GoogleFonts.notoNaskhArabicTextTheme(base);
      case 'NotoKufiArabic':
        return GoogleFonts.notoKufiArabicTextTheme(base);
      case 'Amiri':
        return GoogleFonts.amiriTextTheme(base);
      case 'ReemKufi':
        return GoogleFonts.reemKufiTextTheme(base);
      case 'ArefRuqaa':
        return GoogleFonts.arefRuqaaTextTheme(base);
      case 'Inter':
        return GoogleFonts.interTextTheme(base);
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(base);
      default:
        return base.apply(fontFamily: family);
    }
  }

  TextStyle _resolveInvoiceBaseTextStyle(String family) {
    switch (family) {
      case 'Cairo':
        return GoogleFonts.cairo();
      case 'Tajawal':
        return GoogleFonts.tajawal();
      case 'Almarai':
        return GoogleFonts.almarai();
      case 'Changa':
        return GoogleFonts.changa();
      case 'ElMessiri':
        return GoogleFonts.elMessiri();
      case 'NotoNaskhArabic':
        return GoogleFonts.notoNaskhArabic();
      case 'NotoKufiArabic':
        return GoogleFonts.notoKufiArabic();
      case 'Amiri':
        return GoogleFonts.amiri();
      case 'ReemKufi':
        return GoogleFonts.reemKufi();
      case 'ArefRuqaa':
        return GoogleFonts.arefRuqaa();
      case 'Inter':
        return GoogleFonts.inter();
      case 'Poppins':
        return GoogleFonts.poppins();
      default:
        return TextStyle(fontFamily: family);
    }
  }

  Future<Uint8List> _captureInvoicePng() async {
    final mediaQuery = MediaQuery.maybeOf(context);
    final deviceRatio = mediaQuery?.devicePixelRatio ?? View.of(context).devicePixelRatio;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      throw StateError('Widget is no longer mounted');
    }
    final boundary = _invoiceCaptureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('Invoice boundary is not ready');
    }

    final pixelRatio = (deviceRatio * 2).clamp(2.5, 5.0);
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('Failed to capture invoice image');
    }
    return bytes.buffer.asUint8List();
  }

  void _saveCurrentInvoice() {
    if (widget.transactions.isEmpty) return;
    final txs = widget.transactions;
    final grandTotal = txs.fold<double>(0, (sum, tx) => sum + tx.grandTotal);
    final first = txs.first;
    SavedInvoicesStore.instance.add(
      SavedInvoiceEntry(
        customerNameAr: widget.customerNameAr,
        customerNameEn: widget.customerNameEn,
        customerId: widget.customerId,
        invoiceNumber: first.invoiceNumber,
        invoiceDate: first.date,
        grandTotal: grandTotal,
        transactions: List<CustomerTransaction>.from(txs),
        savedAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('تم حفظ الفاتورة', 'Invoice saved'))),
    );
  }

  Widget _headerContactLine(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 8.9,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _buildInvoicePdf(PdfPageFormat format) async {
    final doc = pw.Document();
    final imageBytes = await _captureInvoicePng();
    final invoiceImage = pw.MemoryImage(imageBytes);

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.zero,
        build: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(
            color: PdfColors.white,
            child: pw.FittedBox(
              fit: pw.BoxFit.contain,
              child: pw.Image(invoiceImage),
            ),
          ),
        ),
      ),
    );

    return doc.save();
  }

  Future<void> _printCurrentInvoice() async {
    if (widget.transactions.isEmpty) return;
    try {
      await Printing.layoutPdf(
        name: 'invoice3_${widget.transactions.first.invoiceNumber}',
        onLayout: _buildInvoicePdf,
        usePrinterSettings: true,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('تعذر فتح نافذة الطباعة', 'Unable to open print dialog'))),
      );
    }
  }

  Future<void> _savePdfFile() async {
    if (widget.transactions.isEmpty) return;
    final suggestedName = 'invoice3_${widget.transactions.first.invoiceNumber}.pdf';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: _t('حفظ الفاتورة PDF', 'Save Invoice PDF'),
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (path == null || path.isEmpty) return;

    try {
      final bytes = await _buildInvoicePdf(PdfPageFormat.a4);
      await File(path).writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('تم حفظ ملف PDF', 'PDF file saved'))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('فشل حفظ ملف PDF', 'Failed to save PDF file'))),
      );
    }
  }

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
    final invoiceFont = cfg.invoiceFontFamily;
    final invoiceBaseTextStyle = _resolveInvoiceBaseTextStyle(invoiceFont);
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
    final invNo      = txs.isNotEmpty ? txs.first.invoiceNumber : '---';
    final invDate    = txs.isNotEmpty ? txs.first.date : '---';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _mixOpaque(secondary, Colors.white, 0.4),
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.isPrintPreview
                ? _t('معاينة طباعة فاتورة 3', 'Invoice 3 Print Preview')
                : _t('فاتورة 3', 'Invoice 3'),
          ),
          actions: [
            if (!widget.isPrintPreview) ...[
              TextButton.icon(
                onPressed: _printCurrentInvoice,
                icon: const Icon(Icons.print_rounded, color: Colors.white, size: 18),
                label: Text(
                  _t('طباعة', 'Print'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _saveCurrentInvoice,
                icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                label: Text(
                  _t('حفظ', 'Save'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: _savePdfFile,
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                label: Text(
                  _t('حفظ PDF', 'Save PDF'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: _t('تعديل التصميم', 'Design Panel'),
                icon: Icon(_panelOpen ? Icons.tune : Icons.tune_outlined),
                onPressed: () => setState(() => _panelOpen = !_panelOpen),
              ),
            ],
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
                      child: RepaintBoundary(
                        key: _invoiceCaptureKey,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: _resolveInvoiceTextTheme(
                              Theme.of(context).textTheme,
                              invoiceFont,
                            ),
                          ),
                          child: DefaultTextStyle.merge(
                            style: invoiceBaseTextStyle,
                            child: Container(
                              height: 1123,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: borderColor),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 8),
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
                                        _buildHeader(accent, textColor, softColor),
                                        const SizedBox(height: 10),
                                        Divider(color: borderColor, thickness: 1.2),
                                        const SizedBox(height: 10),
                                        _buildCustomerBlock(
                                          widget.customerNameAr,
                                          widget.customerNameEn,
                                          invDate,
                                          invNo,
                                          textColor,
                                          softColor,
                                          accent,
                                          borderColor,
                                        ),
                                        const SizedBox(height: 16),
                                        _buildItemsTable(items, primary, secondary, borderColor, textColor, softColor),
                                        const SizedBox(height: 20),
                                        _buildTotals(grandTotal, accent, borderColor),
                                        const Spacer(),
                                        Center(
                                          child: Image.asset(
                                            'assets/images/stamp.png',
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildSignaturesAndStamp(primary, textColor),
                                        const SizedBox(height: 8),
                                        _buildFooter(primary),
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

  // ── Header: office name + meta on start | INVOICE centered ───────────────
  Widget _buildHeader(Color accent, Color textColor, Color softColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Start side: office name + meta (no logo area)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'انفورم للطباعة والتصوير',
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Inform Typing Photocopy',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 210,
              child: Column(
                children: [
                  Container(height: 1.4, color: accent),
                  const SizedBox(height: 3),
                  Container(height: 1.0, color: _mixOpaque(accent, Colors.white, 0.18)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _headerContactLine(
              Icons.phone_rounded,
              '971528047909 / 971556428050',
              softColor,
            ),
            const SizedBox(height: 3),
            _headerContactLine(
              Icons.location_on_outlined,
              'مصفح الصناعية م7 - أبوظبي',
              softColor,
            ),
            const SizedBox(height: 3),
            _headerContactLine(
              Icons.email_outlined,
              'alzaeemtyping@hotmail.com',
              softColor,
            ),
          ],
        ),
        // Centre: INVOICE big + فاتورة small + decorative line
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'INVOICE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 7,
                  height: 1.0,
                ),
              ),
              Text(
                'فاتورة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 90,
                height: 2.5,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 210),
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
  Widget _buildCustomerBlock(
    String customerAr,
    String customerEn,
    String invDate,
    String invNo,
    Color textColor,
    Color softColor,
    Color accent,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _mixOpaque(Colors.white, accent, 0.07),
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
              _metaLine('التاريخ / Date', invDate, textColor, softColor),
              const SizedBox(height: 5),
              _metaLine('رقم الفاتورة', invNo, textColor, softColor),
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
                _hCell(widget.isArabic ? 'الوصف' : 'Description', 5),
                _hCell(widget.isArabic ? 'الكمية' : 'Qty', 2),
                _hCell(widget.isArabic ? 'سعر الوحدة' : 'Unit Price', 3),
                _hCell(widget.isArabic ? 'الإجمالي' : 'Total', 2),
              ],
            ),
          ),
          // Data rows
          for (int i = 0; i < rows.length; i++)
            Container(
              color: i.isOdd ? const Color(0xFFF3F4F6) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _dCell('${i + 1}', 1, TextAlign.center, textColor),
                  Expanded(
                    flex: 5,
                    child: Text(
                      widget.isArabic ? rows[i].nameAr : rows[i].nameEn,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
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
  Widget _buildTotals(double grandTotal, Color accent, Color borderColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _mixOpaque(Colors.white, accent, 0.06),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
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

  Widget _buildSignaturesAndStamp(Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _signatureBlock(
              title: 'INFORM TYPING PHOTOCOPY',
              textColor: textColor,
              lineColor: primary,
              align: CrossAxisAlignment.end,
            ),
          ),
          const SizedBox(width: 150),
          Expanded(
            child: _signatureBlock(
              title: 'توقيع المستلم / Recipient Signature',
              textColor: textColor,
              lineColor: primary,
              align: CrossAxisAlignment.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _signatureBlock({
    required String title,
    required Color textColor,
    required Color lineColor,
    required CrossAxisAlignment align,
  }) {
    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '······························',
          style: TextStyle(
            color: lineColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 10.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(Color primary) {
    return Container(
      width: double.infinity,
      height: 16,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(3),
      ),
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
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD5DDE7)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _t('خط الفاتورة', 'Invoice Font'),
                            style: const TextStyle(
                              color: Color(0xFF243241),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _invoiceFontOptions.contains(cfg.invoiceFontFamily)
                              ? cfg.invoiceFontFamily
                              : 'Cairo',
                          items: _invoiceFontOptions
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) widget.ctrl.setInvoiceFontFamily(v);
                          },
                        ),
                      ],
                    ),
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
