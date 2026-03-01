import 'package:flutter/material.dart';

import '../logic/customer_transactions_logic.dart';
import 'add_transaction_page.dart';
import 'home_page.dart';
import 'invoices_page.dart';

class CustomerTransactionsPage extends StatefulWidget {
  const CustomerTransactionsPage({
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
  State<CustomerTransactionsPage> createState() =>
      _CustomerTransactionsPageState();
}

class _CustomerTransactionsPageState extends State<CustomerTransactionsPage> {
  final CustomerTransactionsLogic _logic = CustomerTransactionsLogic();
  String? _selectedInvoice;
  late bool _isArabic;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  String _statusText(String status) {
    if (!_isArabic) {
      if (status == 'مكتمل') return 'Completed';
      if (status == 'قيد التنفيذ') return 'Pending';
      if (status == 'ملغي') return 'Cancelled';
    }
    return status;
  }

  Color _statusColor(String status) {
    if (status == 'مكتمل') return const Color(0xFF16A34A);
    if (status == 'قيد التنفيذ') return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final customerName =
        _isArabic ? widget.customerNameAr : widget.customerNameEn;
    final tableDirection = _isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      body: Row(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 240,
            color: const Color(0xFF2B6CB0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D2563EB),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'EN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
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
                      const SizedBox(height: 3),
                      Text(
                        _t('إنفورم للطباعة والتصوير',
                            'Inform Typing & Photo Copy'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF93B5D3),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => setState(() => _isArabic = !_isArabic),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(_isArabic ? 'عربي / EN' : 'EN / عربي'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        _SideItem(
                          icon: Icons.home_outlined,
                          text: _t('الرئيسية', 'Home'),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HomePage(initialArabic: _isArabic),
                              ),
                            );
                          },
                        ),
                        _SideItem(
                          icon: Icons.upload_file_outlined,
                          text: _t('تحميل المرفقات', 'Upload Files'),
                        ),
                        _SideItem(
                          icon: Icons.delete_outline,
                          text: _t('حذف المرفقات', 'Delete Files'),
                        ),
                        _SideItem(
                          icon: Icons.receipt_long_outlined,
                          text: _t('الفواتير', 'Invoices'),
                          active: true,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => InvoicesPage(
                                  initialArabic: _isArabic,
                                  customerNameAr: widget.customerNameAr,
                                  customerNameEn: widget.customerNameEn,
                                  customerId: widget.customerId,
                                ),
                              ),
                            );
                          },
                        ),
                        _SideItem(
                          icon: Icons.bar_chart_outlined,
                          text: _t('التقارير', 'Reports'),
                        ),
                        _SideItem(
                          icon: Icons.settings_outlined,
                          text: _t('الاعدادات', 'Settings'),
                        ),
                        const Spacer(),
                        _SideItem(
                          icon: Icons.logout,
                          text: _t('تسجيل الخروج', 'Sign Out'),
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'v1.0.0 - inform typing',
                    style: TextStyle(
                      color: Color(0xFF7BA3C4),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  Material(
                    color: const Color(0xFFF8FAFC),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('معاملات العميل', 'Customer Transactions'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  customerName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ActionBtn(
                                icon: Icons.add,
                                text: _t('إضافة معاملة', 'Add Transaction'),
                                color: const Color(0xFF16A34A),
                                hover: const Color(0xFF15803D),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddTransactionPage(
                                        initialArabic: _isArabic,
                                        customerNameAr: widget.customerNameAr,
                                        customerNameEn: widget.customerNameEn,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _ActionBtn(
                                icon: Icons.edit,
                                text: _t('تعديل معاملة', 'Edit Transaction'),
                                color: const Color(0xFF2563EB),
                                hover: const Color(0xFF1D4ED8),
                              ),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.delete_outline, size: 16),
                                label: Text(
                                    _t('حذف معاملة', 'Delete Transaction')),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Color(0x4DEF4444)),
                                  foregroundColor: const Color(0xFFEF4444),
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              _ActionBtn(
                                  icon: Icons.check_circle_outline,
                                  text: _t('الحالة', 'Status'),
                                  color: const Color(0xFFF59E0B),
                                  hover: const Color(0xFFD97706)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    elevation: 2,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B6CB0),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Directionality(
                        textDirection: tableDirection,
                        child: Row(
                          children: [
                            _HeaderCell(_t('بند الخدمة', 'Service'), 2.5),
                            _HeaderCell(_t('العدد', 'Qty'), 0.8,
                                align: TextAlign.center),
                            _HeaderCell(_t('سعر الوحدة', 'Unit Price'), 1.1,
                                align: TextAlign.center),
                            _HeaderCell(_t('الإجمالي', 'Total'), 1.2,
                                align: TextAlign.center),
                            _HeaderCell(_t('اسم الشركة', 'Company'), 1.8),
                            _HeaderCell(_t('اسم الموظف', 'Employee'), 1.3),
                            _HeaderCell(_t('المرفقات', 'Files'), 0.8,
                                align: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12)),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 10,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: _logic.transactions.length,
                        itemBuilder: (context, txIndex) {
                          final tx = _logic.transactions[txIndex];
                          final isSelected =
                              _selectedInvoice == tx.invoiceNumber;

                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedInvoice =
                                        _selectedInvoice == tx.invoiceNumber
                                            ? null
                                            : tx.invoiceNumber;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      for (int i = 0; i < tx.items.length; i++)
                                        Container(
                                          color: i.isEven
                                              ? Colors.white
                                              : const Color(0xFFF8FAFC),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 12,
                                          ),
                                          child: Directionality(
                                            textDirection: tableDirection,
                                            child: Row(
                                              children: [
                                                _BodyCell(
                                                  _isArabic
                                                      ? tx.items[i].serviceAr
                                                      : tx.items[i].serviceEn,
                                                  2.5,
                                                  weight: FontWeight.w500,
                                                ),
                                                _BodyCell(
                                                    '${tx.items[i].qty}', 0.8,
                                                    align: TextAlign.center),
                                                _BodyCell(
                                                    tx.items[i].unitPrice
                                                        .toStringAsFixed(2),
                                                    1.1,
                                                    align: TextAlign.center),
                                                _BodyCell(
                                                  tx.items[i].total
                                                      .toStringAsFixed(2),
                                                  1.2,
                                                  align: TextAlign.center,
                                                  weight: FontWeight.w600,
                                                ),
                                                _BodyCell(
                                                  _isArabic
                                                      ? tx.items[i].companyAr
                                                      : tx.items[i].companyEn,
                                                  1.8,
                                                  color:
                                                      const Color(0xFF1E5A8A),
                                                  weight: FontWeight.w500,
                                                ),
                                                _BodyCell(
                                                  _isArabic
                                                      ? tx.items[i].employeeAr
                                                      : tx.items[i].employeeEn,
                                                  1.3,
                                                  color:
                                                      const Color(0xFF7C3AED),
                                                  weight: FontWeight.w500,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Center(
                                                    child: tx.items[i]
                                                            .hasAttachment
                                                        ? Container(
                                                            width: 28,
                                                            height: 28,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFF2563EB),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                            child: const Icon(
                                                              Icons.attach_file,
                                                              color:
                                                                  Colors.white,
                                                              size: 14,
                                                            ),
                                                          )
                                                        : const Text(
                                                            '-',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFFCBD5E1),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Container(
                                        width: double.infinity,
                                        color: const Color(0xFFDBEAFE),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              border: Border.all(
                                                  color:
                                                      const Color(0x332563EB)),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 10,
                                              runSpacing: 4,
                                              children: [
                                                _InfoText(
                                                  '${_t('فاتورة:', 'Invoice:')} ${tx.invoiceNumber}',
                                                  valueColor:
                                                      const Color(0xFF2563EB),
                                                ),
                                                const _Sep(),
                                                _InfoText(
                                                  '${_t('التاريخ:', 'Date:')} ${tx.date}',
                                                ),
                                                const _Sep(),
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                          text:
                                                              '${_t('الحالة:', 'Status:')} '),
                                                      WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _statusColor(
                                                                tx.status),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                          ),
                                                          child: Text(
                                                            _statusText(
                                                                tx.status),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const _Sep(),
                                                _InfoText(
                                                  '${_t('الإجمالي:', 'Total:')} AED ${tx.grandTotal.toStringAsFixed(2)}',
                                                  valueColor:
                                                      const Color(0xFF2563EB),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (txIndex < _logic.transactions.length - 1)
                                Container(
                                    height: 3, color: const Color(0x332563EB)),
                            ],
                          );
                        },
                      ),
                    ),
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
          foregroundColor: active ? Colors.white : const Color(0xFFB0CDE4),
          minimumSize: const Size(double.infinity, 40),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.text,
    required this.color,
    required this.hover,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final Color color;
  final Color hover;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor: WidgetStatePropertyAll(hover.withOpacity(0.2)),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, this.flex, {this.align = TextAlign.start});

  final String text;
  final double flex;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell(
    this.text,
    this.flex, {
    this.align = TextAlign.start,
    this.color = Colors.black,
    this.weight = FontWeight.w400,
  });

  final String text;
  final double flex;
  final TextAlign align;
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(color: color, fontSize: 15, fontWeight: weight),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text, {this.valueColor = Colors.black});

  final String text;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' ');
    final label = parts.first;
    final value = parts.skip(1).join(' ');

    return RichText(
      text: TextSpan(
        style: const TextStyle(
            fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 14, color: const Color(0xFFCBD5E1));
  }
}
