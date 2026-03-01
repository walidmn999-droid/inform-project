import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../logic/customer_transactions_logic.dart';

const _kPrimary = Color(0xFF6B8ED6);
const _kPrimaryMed = Color(0xFF5A7DC8);
const _kPrimaryDark = Color(0xFF3D5FA8);
const _kPrimaryBg = Color(0xFFEEF3FF);
const _kBorder = Color(0xFFBECFF5);

TextStyle _c({
  double s = 13,
  FontWeight w = FontWeight.w400,
  Color color = const Color(0xFF1E293B),
}) {
  return GoogleFonts.cairo(fontSize: s, fontWeight: w, color: color);
}

class InvoicePrintPage extends StatelessWidget {
  const InvoicePrintPage({
    super.key,
    required this.transaction,
    required this.customerNameAr,
    required this.customerNameEn,
    required this.customerId,
    required this.initialArabic,
  });

  final CustomerTransaction transaction;
  final String customerNameAr;
  final String customerNameEn;
  final int customerId;
  final bool initialArabic;

  String _fmt(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final out = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) out.write(',');
      out.write(whole[i]);
    }
    return '${out.toString()}.$decimal';
  }

  @override
  Widget build(BuildContext context) {
    final ar = initialArabic;
    return Directionality(
      textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE6F5),
        appBar: AppBar(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            ar ? 'فاتورة' : 'Invoice',
            style: _c(s: 15, w: FontWeight.w700, color: Colors.white),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print, color: Colors.white, size: 18),
              label: Text(
                ar ? 'طباعة' : 'Print',
                style: _c(w: FontWeight.w700, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(ar: ar),
                    _MetaStrip(
                      ar: ar,
                      invoiceNumber: transaction.invoiceNumber,
                      date: transaction.date,
                      customerNameAr: customerNameAr,
                      customerNameEn: customerNameEn,
                      customerId: customerId,
                    ),
                    _ItemsTable(ar: ar, items: transaction.items, fmt: _fmt),
                    _TotalBar(ar: ar, total: transaction.grandTotal, fmt: _fmt),
                    _SignatureRow(ar: ar),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ar});
  final bool ar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: _kPrimaryBg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 64,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _kBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'IT',
                        style: _c(s: 21, w: FontWeight.w900, color: _kPrimary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'إنفورم للطباعة والتصوير',
                        textAlign: TextAlign.center,
                        style: _c(s: 18, w: FontWeight.w800, color: _kPrimaryDark),
                      ),
                      Text(
                        'Inform Typing Photocopy',
                        textAlign: TextAlign.center,
                        style: _c(s: 12, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'INVOICE',
                        style: _c(s: 14, w: FontWeight.w900, color: Colors.white),
                      ),
                      Text(
                        'فاتورة',
                        style: _c(s: 12, w: FontWeight.w700, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              spacing: 18,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.phone_outlined,
                  text: '+971556428050 / +971528047909',
                ),
                _InfoChip(
                  icon: Icons.email_outlined,
                  text: 'alzaeemtyping@hotmail.com',
                ),
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: ar
                      ? 'مصفح الصناعية، م-7، أبوظبي'
                      : 'Mussafah Industrial Area, M-7, Abu Dhabi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _kPrimary),
        const SizedBox(width: 4),
        Text(text, style: _c(s: 11, color: const Color(0xFF475569))),
      ],
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip({
    required this.ar,
    required this.invoiceNumber,
    required this.date,
    required this.customerNameAr,
    required this.customerNameEn,
    required this.customerId,
  });

  final bool ar;
  final String invoiceNumber;
  final String date;
  final String customerNameAr;
  final String customerNameEn;
  final int customerId;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kPrimaryBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MetaField(
                      labelAr: 'رقم الفاتورة',
                      labelEn: 'Invoice No',
                      value: invoiceNumber,
                      icon: Icons.receipt_outlined,
                      valueColor: _kPrimaryDark,
                    ),
                    const SizedBox(height: 12),
                    _MetaField(
                      labelAr: 'التاريخ',
                      labelEn: 'Date',
                      value: date,
                      icon: Icons.calendar_today_outlined,
                      valueColor: const Color(0xFF1E293B),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 15, color: _kPrimary),
                        const SizedBox(width: 5),
                        Text(
                          ar ? 'فاتورة إلى' : 'Invoice To',
                          style: _c(
                            s: 12,
                            w: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ar ? customerNameAr : customerNameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _c(s: 19, w: FontWeight.w800, color: _kPrimaryDark),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.tag, size: 14, color: _kPrimary),
                        const SizedBox(width: 5),
                        Text(
                          ar ? 'رقم العميل:' : 'Client No:',
                          style: _c(s: 12, color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '#$customerId',
                          style: _c(s: 14, w: FontWeight.w800, color: _kPrimaryDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  const _MetaField({
    required this.labelAr,
    required this.labelEn,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  final String labelAr;
  final String labelEn;
  final String value;
  final IconData icon;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$labelAr / $labelEn',
                style: _c(s: 11, w: FontWeight.w600, color: const Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _c(s: 16, w: FontWeight.w800, color: valueColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({
    required this.ar,
    required this.items,
    required this.fmt,
  });

  final bool ar;
  final List<TransactionItem> items;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: _kPrimaryMed,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: _TRow(
              isHeader: true,
              sl: ar ? 'م' : 'SL',
              desc: ar
                  ? 'وصف البند / Item Description'
                  : 'Item Description / وصف البند',
              qty: ar ? 'العدد\nQty' : 'Qty\nالعدد',
              price: ar ? 'سعر الوحدة\nUnit Price' : 'Unit Price\nسعر الوحدة',
              total: ar ? 'الإجمالي\nTotal' : 'Total\nالإجمالي',
            ),
          ),
          ...List.generate(items.length, (i) {
            final item = items[i];
            return Container(
              color: i.isEven ? Colors.white : const Color(0xFFF8FAFF),
              child: _TRow(
                isHeader: false,
                sl: '${i + 1}',
                desc: '${item.serviceAr}\n${item.serviceEn}',
                qty: '${item.qty}',
                price: fmt(item.unitPrice),
                total: fmt(item.total),
              ),
            );
          }),
          Container(
            height: 2,
            decoration: const BoxDecoration(
              color: _kPrimaryMed,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TRow extends StatelessWidget {
  const _TRow({
    required this.isHeader,
    required this.sl,
    required this.desc,
    required this.qty,
    required this.price,
    required this.total,
  });

  final bool isHeader;
  final String sl;
  final String desc;
  final String qty;
  final String price;
  final String total;

  @override
  Widget build(BuildContext context) {
    final h = _c(s: 12, w: FontWeight.w700, color: Colors.white);
    final d = _c(s: 12, color: const Color(0xFF1E293B));
    final sub = _c(s: 10, color: const Color(0xFF64748B));

    Widget col(String txt, TextAlign align, {double? w}) {
      final lines = txt.split('\n');
      Widget content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align == TextAlign.center
            ? CrossAxisAlignment.center
            : align == TextAlign.end
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Text(lines[0], style: isHeader ? h : d, textAlign: align),
          if (lines.length > 1)
            Text(lines[1], style: isHeader ? h : sub, textAlign: align),
        ],
      );
      return w == null ? content : SizedBox(width: w, child: content);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Row(
        children: [
          col(sl, TextAlign.center, w: 26),
          const SizedBox(width: 8),
          Expanded(child: col(desc, TextAlign.start)),
          const SizedBox(width: 8),
          col(qty, TextAlign.end, w: 48),
          const SizedBox(width: 8),
          col(price, TextAlign.end, w: 86),
          const SizedBox(width: 8),
          col(total, TextAlign.end, w: 88),
        ],
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({
    required this.ar,
    required this.total,
    required this.fmt,
  });

  final bool ar;
  final double total;
  final String Function(double) fmt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kPrimaryMed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(child: Container()),
          Text(
            ar ? 'الإجمالي الكلي:' : 'Grand Total:',
            style: _c(s: 13, w: FontWeight.w700, color: const Color(0xFFD6E4FF)),
          ),
          const SizedBox(width: 6),
          Text(
            'AED ${fmt(total)}',
            style: _c(s: 20, w: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SignatureRow extends StatelessWidget {
  const _SignatureRow({required this.ar});
  final bool ar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar
                      ? 'توقيع المستلم / Recipient Signature'
                      : 'Recipient Signature / توقيع المستلم',
                  style: _c(
                    s: 11,
                    w: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),
                Container(height: 2, width: 200, color: _kBorder),
              ],
            ),
          ),
          Image.asset(
            'assets/images/stamp.png',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: _kPrimary, width: 1.5),
                borderRadius: BorderRadius.circular(45),
                color: _kPrimaryBg,
              ),
              alignment: Alignment.center,
              child: Text(
                'IT',
                style: _c(s: 22, w: FontWeight.w900, color: _kPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
