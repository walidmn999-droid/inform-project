import 'package:flutter/material.dart';

import '../logic/customer_transactions_logic.dart';
import 'customer_transactions_page.dart';
import 'home_page.dart';
import 'invoice_print_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({
    super.key,
    required this.initialArabic,
    required this.customerNameAr,
    required this.customerNameEn,
    this.customerId = 0,
  });

  final bool initialArabic;
  final String customerNameAr;
  final String customerNameEn;
  final int customerId;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final CustomerTransactionsLogic _logic = CustomerTransactionsLogic();
  late bool _isArabic;
  final Set<int> _selectedRows = {};

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  void _toggleRow(int index, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows.add(index);
      } else {
        _selectedRows.remove(index);
      }
    });
  }

  void _toggleAll(bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedRows.addAll(
            List.generate(_logic.transactions.length, (i) => i));
      } else {
        _selectedRows.clear();
      }
    });
  }

  Color _statusColor(String status) {
    if (status.contains('مكتمل') || status.toLowerCase().contains('complet')) {
      return const Color(0xFF16A34A);
    } else if (status.contains('ملغ') ||
        status.toLowerCase().contains('cancel')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          _Sidebar(
            isArabic: _isArabic,
            t: _t,
            onToggleLanguage: () => setState(() => _isArabic = !_isArabic),
            onGoHome: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => HomePage(initialArabic: _isArabic),
                ),
              );
            },
            onLogout: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          Expanded(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────────
                Container(
                  height: 44,
                  color: const Color(0xFF2EA2E7),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'InformTyping',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 16),
                        label: Text(
                          _t('رجوع', 'Back'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Main content ─────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Gradient header (title + subtitle only) ───
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF2563EB),
                                  Color(0xFF1E5A8A)
                                ],
                              ),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  _t('الفواتير والتقارير',
                                      'Invoices & Reports'),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _t(
                                    'ملخص معاملات الجدول مع فواتير جاهزة للعرض والطباعة',
                                    'Table transactions summary with ready invoices for view and print',
                                  ),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xE6FFFFFF),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Action buttons toolbar (above the table) ──
                          Container(
                            color: const Color(0xFFF1F5F9),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.end,
                              children: [
                                _TopActionButton(
                                  label: _t('فاتورة مجمعة',
                                      'Combined Invoice'),
                                  color: const Color(0xFF2563EB),
                                ),
                                _TopActionButton(
                                  label: _t('الفواتير المحفوظة',
                                      'Saved Invoices'),
                                  color: const Color(0xFF16A34A),
                                ),
                                _TopActionButton(
                                  label: _t('التجميع النهائي',
                                      'Final Aggregation'),
                                  color: const Color(0xFF7C3AED),
                                ),
                                _TopActionButton(
                                  label: _t('كشف المعاملات',
                                      'Transactions List'),
                                  color: const Color(0xFFEA580C),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CustomerTransactionsPage(
                                          initialArabic: _isArabic,
                                          customerNameAr:
                                              widget.customerNameAr,
                                          customerNameEn:
                                              widget.customerNameEn,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _TopActionButton(
                                  label: _t('فاتورة 2', 'Invoice 2'),
                                  color: const Color(0xFF0891B2),
                                ),
                              ],
                            ),
                          ),

                          // ── Data table (fills remaining space) ────────
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth,
                                        ),
                                        child: DataTable(
                                          headingRowColor:
                                              WidgetStateProperty.all(
                                                  const Color(0xFFEAF2FF)),
                                          horizontalMargin: 12,
                                          columnSpacing: 18,
                                          dataRowMinHeight: 44,
                                          dataRowMaxHeight: 56,
                                          onSelectAll: _toggleAll,
                                          columns: [
                                            DataColumn(
                                                label: Text(
                                                    _t('رقم مسلسل',
                                                        'Serial'))),
                                            DataColumn(
                                                label: Text(_t('رقم الفاتورة',
                                                    'Invoice No'))),
                                            DataColumn(
                                                label: Text(
                                                    _t('التاريخ', 'Date'))),
                                            DataColumn(
                                                label: Text(
                                                    _t('العميل', 'Customer'))),
                                            DataColumn(
                                                label: Text(
                                                    _t('الشركة', 'Company'))),
                                            DataColumn(
                                                label: Text(
                                                    _t('الموظف', 'Employee'))),
                                            DataColumn(
                                                label: Text(
                                                    _t('الحالة', 'Status'))),
                                            DataColumn(
                                                label: Text(_t(
                                                    'الإجراءات', 'Actions'))),
                                          ],
                                          rows: [
                                            for (int i = 0;
                                                i <
                                                    _logic.transactions.length;
                                                i++)
                                              DataRow(
                                                selected:
                                                    _selectedRows.contains(i),
                                                onSelectChanged: (v) =>
                                                    _toggleRow(i, v),
                                                color: WidgetStateProperty
                                                    .resolveWith((states) {
                                                  if (states.contains(
                                                      WidgetState.selected)) {
                                                    return const Color(
                                                        0xFFDBEAFE);
                                                  }
                                                  return i.isEven
                                                      ? Colors.white
                                                      : const Color(
                                                          0xFFF8FAFC);
                                                }),
                                                cells: [
                                                  DataCell(Text('${i + 1}')),
                                                  DataCell(Text(_logic
                                                      .transactions[i]
                                                      .invoiceNumber)),
                                                  DataCell(Text(_logic
                                                      .transactions[i].date)),
                                                  DataCell(Text(_isArabic
                                                      ? widget.customerNameAr
                                                      : widget
                                                          .customerNameEn)),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 170,
                                                      child: Text(
                                                        _isArabic
                                                            ? _logic
                                                                .transactions[i]
                                                                .items
                                                                .first
                                                                .companyAr
                                                            : _logic
                                                                .transactions[i]
                                                                .items
                                                                .first
                                                                .companyEn,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 120,
                                                      child: Text(
                                                        _isArabic
                                                            ? _logic
                                                                .transactions[i]
                                                                .items
                                                                .first
                                                                .employeeAr
                                                            : _logic
                                                                .transactions[i]
                                                                .items
                                                                .first
                                                                .employeeEn,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _statusColor(
                                                                _logic
                                                                    .transactions[
                                                                        i]
                                                                    .status)
                                                            .withOpacity(0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        border: Border.all(
                                                          color: _statusColor(
                                                              _logic
                                                                  .transactions[
                                                                      i]
                                                                  .status),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        _logic.transactions[i]
                                                            .status,
                                                        style: TextStyle(
                                                          color: _statusColor(
                                                              _logic
                                                                  .transactions[
                                                                      i]
                                                                  .status),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SizedBox(
                                                      width: 160,
                                                      child: Row(
                                                        children: [
                                                          _RowActionButton(
                                                            label: _t('فاتورة',
                                                                'Invoice'),
                                                            color: const Color(
                                                                0xFF2563EB),
                                                            onPressed: () {
                                                              Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                  builder: (_) => InvoicePrintPage(
                                                                    transaction: _logic.transactions[i],
                                                                    customerNameAr: widget.customerNameAr,
                                                                    customerNameEn: widget.customerNameEn,
                                                                    customerId: widget.customerId,
                                                                    initialArabic: _isArabic,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          _RowActionButton(
                                                            label: _t(
                                                                'عرض', 'View'),
                                                            color: const Color(
                                                                0xFF16A34A),
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // ── Footer ────────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              _t('جميع الحقوق محفوظة © 2026',
                                  'All rights reserved © 2026'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _RowActionButton extends StatelessWidget {
  const _RowActionButton({
    required this.label,
    required this.color,
    this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 30),
          side: BorderSide(color: color),
          foregroundColor: color,
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.isArabic,
    required this.t,
    required this.onToggleLanguage,
    required this.onGoHome,
    required this.onLogout,
  });

  final bool isArabic;
  final String Function(String ar, String en) t;
  final VoidCallback onToggleLanguage;
  final VoidCallback onGoHome;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF2B6CB0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'EN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'INFORM TYPING',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
            ),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onToggleLanguage,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5A8A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isArabic ? 'عربي / EN' : 'EN / عربي'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _SideItem(
                    icon: Icons.home_outlined,
                    text: t('الرئيسية', 'Home'),
                    onPressed: onGoHome),
                _SideItem(
                    icon: Icons.receipt_long_outlined,
                    text: t('الفواتير', 'Invoices'),
                    active: true),
                _SideItem(
                    icon: Icons.logout,
                    text: t('تسجيل الخروج', 'Sign Out'),
                    onPressed: onLogout),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'v1.0.0 - inform typing',
              style: TextStyle(
                  color: Color(0xFF7BA3C4),
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.icon,
    required this.text,
    this.active = false,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor:
              active ? const Color(0xFF2563EB) : Colors.transparent,
          foregroundColor:
              active ? Colors.white : const Color(0xFFB0CDE4),
          minimumSize: const Size(double.infinity, 40),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
