import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../data/app_database.dart';
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
  final AppDatabase _db = AppDatabase.instance;
  final Set<String> _selectedInvoices = <String>{};
  final List<_TxRecord> _transactions = <_TxRecord>[];
  late bool _isArabic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final rows = await _db.getTransactionsForCustomer(widget.customerId);
    if (!mounted) return;
    setState(() {
      _transactions
        ..clear()
        ..addAll(rows.map(_TxRecord.fromDb));
      _isLoading = false;
      _selectedInvoices.removeWhere(
        (invoice) => !_transactions.any((tx) => tx.invoiceNumber == invoice),
      );
    });
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  List<_TxRecord> get _sortedTransactions {
    final copy = List<_TxRecord>.from(_transactions);
    copy.sort((a, b) {
      final aDelivered = a.status == 'تم التسليم';
      final bDelivered = b.status == 'تم التسليم';
      if (aDelivered == bDelivered) return 0;
      return aDelivered ? 1 : -1;
    });
    return copy;
  }

  void _toggleSelection(String invoiceNumber) {
    setState(() {
      if (_selectedInvoices.contains(invoiceNumber)) {
        _selectedInvoices.remove(invoiceNumber);
      } else {
        _selectedInvoices.add(invoiceNumber);
      }
    });
  }

  Color _statusColor(String status) {
    if (status == 'تم التسليم') return const Color(0xFF16A34A);
    return const Color(0xFFF59E0B);
  }

  String _statusLabel(String status) {
    if (_isArabic) return status;
    if (status == 'تم التسليم') return 'Delivered';
    return 'Pending';
  }

  void _showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
      ),
    );
  }

  Future<void> _openAttachmentFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      if (!mounted) return;
      _showMsg(_t('الملف غير موجود على الجهاز', 'File does not exist'), error: true);
      return;
    }

    try {
      if (Platform.isWindows) {
        await Process.start('cmd', <String>['/c', 'start', '', file.path]);
      } else if (Platform.isMacOS) {
        await Process.start('open', <String>[file.path]);
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', <String>[file.path]);
      }
    } catch (_) {
      if (!mounted) return;
      _showMsg(_t('تعذر فتح الملف', 'Unable to open file'), error: true);
    }
  }

  Future<void> _downloadAttachment(String filePath) async {
    final source = File(filePath);
    if (!await source.exists()) {
      if (!mounted) return;
      _showMsg(_t('الملف غير موجود على الجهاز', 'File does not exist'), error: true);
      return;
    }

    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile == null || userProfile.trim().isEmpty) {
      if (!mounted) return;
      _showMsg(_t('تعذر الوصول لمجلد التنزيلات', 'Unable to access Downloads folder'),
          error: true);
      return;
    }

    final downloadsDir = Directory(p.join(userProfile, 'Downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final sourceName = p.basename(source.path);
    String targetPath = p.join(downloadsDir.path, sourceName);
    int suffix = 1;
    while (await File(targetPath).exists()) {
      final base = p.basenameWithoutExtension(sourceName);
      final ext = p.extension(sourceName);
      targetPath = p.join(downloadsDir.path, '${base}_$suffix$ext');
      suffix++;
    }

    await source.copy(targetPath);
    if (!mounted) return;
    _showMsg(_t('تم تحميل الملف إلى التنزيلات', 'File downloaded to Downloads'));
  }

  void _showAttachmentsDialog(List<String> paths) {
    final validPaths = paths.where((e) => e.trim().isNotEmpty).toList();
    if (validPaths.isEmpty) {
      _showMsg(_t('لا توجد مرفقات صالحة', 'No valid attachments'), error: true);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('مرفقات المعاملة', 'Transaction Attachments')),
          content: SizedBox(
            width: 560,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: validPaths.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final filePath = validPaths[index];
                final fileName = p.basename(filePath);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: Color(0xFF2563EB), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openAttachmentFile(filePath),
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(_t('فتح', 'Open')),
                      ),
                      TextButton.icon(
                        onPressed: () => _downloadAttachment(filePath),
                        icon: const Icon(Icons.download, size: 16),
                        label: Text(_t('تحميل', 'Download')),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_t('إغلاق', 'Close')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openAddTransaction() async {
    final result = await Navigator.of(context).push<AddTransactionResult>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(
          initialArabic: _isArabic,
          customerNameAr: widget.customerNameAr,
          customerNameEn: widget.customerNameEn,
        ),
      ),
    );
    if (result == null) return;
    await _db.saveTransaction(customerId: widget.customerId, data: result);
    await _loadTransactions();
    _showMsg(_t('تم حفظ المعاملة', 'Transaction saved'));
  }

  Future<void> _openEditTransaction() async {
    if (_selectedInvoices.isEmpty) {
      _showMsg(_t('حدد معاملة واحدة للتعديل', 'Select one transaction to edit'),
          error: true);
      return;
    }
    if (_selectedInvoices.length > 1) {
      _showMsg(
        _t('يمكن تعديل معاملة واحدة فقط', 'Only one transaction can be edited'),
        error: true,
      );
      return;
    }

    final invoice = _selectedInvoices.first;
    final index = _transactions.indexWhere((tx) => tx.invoiceNumber == invoice);
    if (index == -1) return;
    final source = _transactions[index];

    final result = await Navigator.of(context).push<AddTransactionResult>(
      MaterialPageRoute(
        builder: (_) => AddTransactionPage(
          initialArabic: _isArabic,
          customerNameAr: widget.customerNameAr,
          customerNameEn: widget.customerNameEn,
          initialData: source.toAddTransactionResult(),
        ),
      ),
    );
    if (result == null) return;
    final updated = AddTransactionResult(
      invoiceNumber: result.invoiceNumber,
      company: result.company,
      employee: result.employee,
      date: result.date,
      items: result.items,
      status: source.status,
    );
    await _db.updateTransaction(
      customerId: widget.customerId,
      oldInvoiceNumber: source.invoiceNumber,
      data: updated,
    );
    await _loadTransactions();
    setState(() {
      _selectedInvoices
        ..clear()
        ..add(updated.invoiceNumber);
    });
    _showMsg(_t('تم تعديل المعاملة', 'Transaction updated'));
  }

  void _openDeleteDialog() {
    if (_selectedInvoices.isEmpty) {
      _showMsg(_t('حدد معاملة أو أكثر للحذف', 'Select one or more transactions'),
          error: true);
      return;
    }

    final codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('حذف معاملة', 'Delete Transaction')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('هل أنت متأكد من حذف المعاملات المحددة؟',
                  'Are you sure you want to delete selected transactions?')),
              const SizedBox(height: 10),
              Text(
                _t('أدخل كود التأكيد 1234 (إجباري)',
                    'Enter confirmation code 1234 (required)'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: _t('كود التأكيد', 'Confirmation code')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: () async {
                if (codeController.text.trim() != '1234') {
                  _showMsg(_t('كود الحذف غير صحيح', 'Invalid delete code'),
                      error: true);
                  return;
                }
                final toDelete = List<String>.from(_selectedInvoices);
                Navigator.of(dialogContext).pop();
                await _db.deleteTransactions(
                  customerId: widget.customerId,
                  invoiceNumbers: toDelete,
                );
                await _loadTransactions();
                if (!mounted) return;
                _showMsg(_t('تم حذف المعاملات', 'Transactions deleted'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _openStatusDialog() {
    if (_selectedInvoices.isEmpty) {
      _showMsg(_t('حدد معاملة أو أكثر لتغيير الحالة',
          'Select one or more transactions to change status'), error: true);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('تغيير الحالة', 'Change status')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _db.updateTransactionsStatus(
                      customerId: widget.customerId,
                      invoiceNumbers: _selectedInvoices.toList(),
                      status: 'معلق',
                    );
                    await _loadTransactions();
                  },
                  child: Text(_t('معلق', 'Pending')),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _db.updateTransactionsStatus(
                      customerId: widget.customerId,
                      invoiceNumbers: _selectedInvoices.toList(),
                      status: 'تم التسليم',
                    );
                    await _loadTransactions();
                  },
                  child: Text(_t('تم التسليم', 'Delivered')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName =
        _isArabic ? widget.customerNameAr : widget.customerNameEn;
    final tableDirection = _isArabic ? TextDirection.rtl : TextDirection.ltr;
    final data = _sortedTransactions;

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
                                builder: (_) => HomePage(initialArabic: _isArabic),
                              ),
                            );
                          },
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
                                onPressed: _openAddTransaction,
                              ),
                              _ActionBtn(
                                icon: Icons.edit,
                                text: _t('تعديل معاملة', 'Edit Transaction'),
                                color: const Color(0xFF2563EB),
                                hover: const Color(0xFF1D4ED8),
                                onPressed: _openEditTransaction,
                              ),
                              OutlinedButton.icon(
                                onPressed: _openDeleteDialog,
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: Text(_t('حذف معاملة', 'Delete Transaction')),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0x4DEF4444)),
                                  foregroundColor: const Color(0xFFEF4444),
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              _ActionBtn(
                                icon: Icons.check_circle_outline,
                                text: _t('الحالة', 'Status'),
                                color: const Color(0xFFF59E0B),
                                hover: const Color(0xFFD97706),
                                onPressed: _openStatusDialog,
                              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2B6CB0),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
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
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius:
                            const BorderRadius.vertical(bottom: Radius.circular(12)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: data.isEmpty
                          ? Center(
                              child: Text(
                                _t('لا توجد معاملات محفوظة', 'No saved transactions'),
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, txIndex) {
                          final tx = data[txIndex];
                          final isSelected =
                              _selectedInvoices.contains(tx.invoiceNumber);
                          final isDelivered = tx.status == 'تم التسليم';

                          return Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
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
                                                      '${tx.items[i].qty}',
                                                      0.8,
                                                      align: TextAlign.center,
                                                    ),
                                                    _BodyCell(
                                                      tx.items[i].unitPrice
                                                          .toStringAsFixed(2),
                                                      1.1,
                                                      align: TextAlign.center,
                                                    ),
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
                                                      color: const Color(0xFF1E5A8A),
                                                      weight: FontWeight.w500,
                                                    ),
                                                    _BodyCell(
                                                      _isArabic
                                                          ? tx.items[i].employeeAr
                                                          : tx.items[i].employeeEn,
                                                      1.3,
                                                      color: const Color(0xFF7C3AED),
                                                      weight: FontWeight.w500,
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: tx.items[i]
                                                                      .attachmentCount >
                                                                  0
                                                              ? _AttachmentBadge(
                                                                  count: tx.items[i]
                                                                      .attachmentCount,
                                                                  onTap: () => _showAttachmentsDialog(
                                                                    tx.items[i].attachmentPaths,
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
                                                    color: const Color(0x332563EB),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing: 10,
                                                  runSpacing: 4,
                                                  children: [
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Checkbox(
                                                          value: isSelected,
                                                          activeColor:
                                                              const Color(0xFF2563EB),
                                                          onChanged: (_) =>
                                                              _toggleSelection(
                                                            tx.invoiceNumber,
                                                          ),
                                                        ),
                                                        Text(
                                                          _t('تحديد', 'Select'),
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                Color(0xFF334155),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const _Sep(),
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
                                                                '${_t('الحالة:', 'Status:')} ',
                                                          ),
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
                                                                _statusLabel(
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
                                  if (isDelivered)
                                    Positioned.fill(
                                      child: IgnorePointer(
                                        child: Center(
                                          child: Transform.rotate(
                                            angle: -0.25,
                                            child: Text(
                                              _t('تم التسليم', 'DELIVERED'),
                                              style: const TextStyle(
                                                fontSize: 64,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0x22000000),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (txIndex < data.length - 1)
                                Container(height: 3, color: const Color(0x332563EB)),
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

class _TxRecord {
  _TxRecord({
    required this.invoiceNumber,
    required this.date,
    required this.status,
    required this.grandTotal,
    required this.items,
  });

  factory _TxRecord.fromDb(DbTransactionRecord tx) {
    return _TxRecord(
      invoiceNumber: tx.invoiceNumber,
      date: tx.date,
      status: tx.status,
      grandTotal: tx.grandTotal,
      items: tx.items
          .map(
            (it) => _TxItem(
              serviceAr: it.serviceAr,
              serviceEn: it.serviceEn,
              qty: it.qty,
              unitPrice: it.unitPrice,
              total: it.total,
              discount: it.discount,
              benefit: it.benefit,
              companyAr: tx.company,
              companyEn: tx.company,
              employeeAr: tx.employee,
              employeeEn: tx.employee,
              attachmentPaths: it.attachmentPaths,
            ),
          )
          .toList(),
    );
  }

  String invoiceNumber;
  String date;
  String status;
  double grandTotal;
  List<_TxItem> items;

  AddTransactionResult toAddTransactionResult() {
    final company = items.isEmpty ? '' : items.first.companyAr;
    final employee = items.isEmpty ? '' : items.first.employeeAr;
    return AddTransactionResult(
      invoiceNumber: invoiceNumber,
      company: company,
      employee: employee,
      date: date,
      status: status,
      items: items
          .map(
            (it) => AddTransactionItemResult(
              service: it.serviceAr,
              qty: it.qty,
              unitPrice: it.unitPrice,
              discount: it.discount,
              benefit: it.benefit,
              total: it.total,
              attachments: List<String>.from(it.attachmentPaths),
            ),
          )
          .toList(),
    );
  }

  _TxRecord copyWith({
    String? invoiceNumber,
    String? date,
    String? status,
    double? grandTotal,
    List<_TxItem>? items,
  }) {
    return _TxRecord(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      status: status ?? this.status,
      grandTotal: grandTotal ?? this.grandTotal,
      items: items ?? this.items,
    );
  }
}

class _TxItem {
  _TxItem({
    required this.serviceAr,
    required this.serviceEn,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.benefit,
    required this.total,
    required this.companyAr,
    required this.companyEn,
    required this.employeeAr,
    required this.employeeEn,
    required this.attachmentPaths,
  });

  final String serviceAr;
  final String serviceEn;
  final int qty;
  final double unitPrice;
  final double discount;
  final double benefit;
  final double total;
  final String companyAr;
  final String companyEn;
  final String employeeAr;
  final String employeeEn;
  final List<String> attachmentPaths;
  int get attachmentCount => attachmentPaths.length;
  bool get hasAttachment => attachmentPaths.isNotEmpty;
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
        label: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(color: color, fontSize: 15, fontWeight: weight),
      ),
    );
  }
}

class _AttachmentBadge extends StatelessWidget {
  const _AttachmentBadge({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 28),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_file, color: Colors.white, size: 12),
            const SizedBox(width: 2),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
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
