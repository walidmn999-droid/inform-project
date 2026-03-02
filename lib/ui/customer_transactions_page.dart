import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as p;

import '../data/app_database.dart';
import '../logic/design_controller.dart';
import 'add_transaction_page.dart';
import 'design_settings_page.dart';
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
  final DesignController _design = DesignController.instance;
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
      _showMsg(_t('تعذر فتح الملف', 'Unable to open file'), error: true);
      return;
    }

    try {
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        if (!mounted) return;
        _showMsg(_t('تعذر فتح الملف', 'Unable to open file'), error: true);
      }
    } catch (_) {
      if (!mounted) return;
      _showMsg(_t('تعذر فتح الملف', 'Unable to open file'), error: true);
    }
  }

  List<String> _selectedAttachmentPaths() {
    final selectedTx = _transactions
        .where((tx) => _selectedInvoices.contains(tx.invoiceNumber))
        .toList();
    final paths = <String>{};
    for (final tx in selectedTx) {
      for (final item in tx.items) {
        for (final path in item.attachmentPaths) {
          final trimmed = path.trim();
          if (trimmed.isNotEmpty) {
            paths.add(trimmed);
          }
        }
      }
    }
    return paths.toList();
  }

  Future<void> _downloadSelectedAttachments() async {
    if (_selectedInvoices.isEmpty) {
      _showMsg(
        _t('حدد معاملة أو أكثر أولاً', 'Select one or more transactions first'),
        error: true,
      );
      return;
    }
    final paths = _selectedAttachmentPaths();
    if (paths.isEmpty) {
      _showMsg(_t('لا توجد مرفقات في المعاملات المحددة', 'No attachments found'),
          error: true);
      return;
    }

    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile == null || userProfile.trim().isEmpty) {
      _showMsg(_t('تعذر الوصول لمجلد التنزيلات', 'Unable to access Downloads folder'),
          error: true);
      return;
    }
    final downloadsDir = Directory(p.join(userProfile, 'Downloads'));
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    final existingFiles = <File>[];
    for (final filePath in paths) {
      final source = File(filePath);
      if (await source.exists()) {
        existingFiles.add(source);
      }
    }

    if (existingFiles.isEmpty) {
      _showMsg(_t('لم يتم العثور على ملفات فعلية للتحميل',
          'No valid files were found to download'), error: true);
      return;
    }

    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final zipName = 'attachments_$timestamp.zip';
    final zipPath = p.join(downloadsDir.path, zipName);
    final encoder = ZipFileEncoder();
    final usedEntryNames = <String>{};

    String uniqueEntryName(String originalName) {
      if (!usedEntryNames.contains(originalName)) {
        usedEntryNames.add(originalName);
        return originalName;
      }
      final base = p.basenameWithoutExtension(originalName);
      final ext = p.extension(originalName);
      var i = 1;
      var candidate = '${base}_$i$ext';
      while (usedEntryNames.contains(candidate)) {
        i++;
        candidate = '${base}_$i$ext';
      }
      usedEntryNames.add(candidate);
      return candidate;
    }

    encoder.create(zipPath);
    for (final f in existingFiles) {
      encoder.addFile(f, uniqueEntryName(p.basename(f.path)));
    }
    encoder.close();

    _showMsg(_t('تم تحميل المرفقات في ملف مضغوط واحد',
        'Attachments downloaded as a single ZIP file'));
  }

  void _deleteSelectedAttachments() {
    if (_selectedInvoices.isEmpty) {
      _showMsg(
        _t('حدد معاملة أو أكثر أولاً', 'Select one or more transactions first'),
        error: true,
      );
      return;
    }

    final codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('حذف المرفقات', 'Delete Attachments')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  'سيتم حذف كل المرفقات من المعاملات المحددة.',
                  'All attachments for selected transactions will be deleted.',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('أدخل كود الحذف 1234 (إجباري)',
                    'Enter delete code 1234 (required)'),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (codeController.text.trim() != '1234') {
                  _showMsg(_t('كود الحذف غير صحيح', 'Invalid delete code'),
                      error: true);
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _db.deleteAttachmentsForTransactions(
                  customerId: widget.customerId,
                  invoiceNumbers: _selectedInvoices.toList(),
                );
                await _loadTransactions();
                if (!mounted) return;
                _showMsg(_t('تم حذف المرفقات من المعاملات المحددة',
                    'Attachments deleted from selected transactions'));
              },
              child: Text(_t('حذف', 'Delete')),
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

  void _onAttachmentIconTap(List<String> allPaths, int index) {
    final validPaths = allPaths.where((e) => e.trim().isNotEmpty).toList();
    if (validPaths.isEmpty || index < 0 || index >= validPaths.length) {
      _showMsg(_t('لا توجد مرفقات صالحة', 'No valid attachments'), error: true);
      return;
    }
    _openAttachmentFile(validPaths[index]);
  }

  Future<void> _deleteSingleAttachment(_TxAttachment attachment) async {
    if (attachment.id == null) {
      _showMsg(_t('لا يمكن حذف هذا المرفق', 'Cannot delete this attachment'),
          error: true);
      return;
    }

    final codeController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('تأكيد حذف المرفق', 'Confirm attachment deletion')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t(
                  'سيتم حذف هذا المرفق نهائياً. هل تريد المتابعة؟',
                  'This attachment will be deleted permanently. Continue?',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _t('أدخل كود الحذف 1234 (إجباري)',
                    'Enter delete code 1234 (required)'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('كود التأكيد', 'Confirmation code'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (codeController.text.trim() != '1234') {
                  _showMsg(_t('كود الحذف غير صحيح', 'Invalid delete code'),
                      error: true);
                  return;
                }
                Navigator.of(dialogContext).pop();
                await _db.deleteAttachmentById(attachment.id!);
                await _loadTransactions();
                if (!mounted) return;
                _showMsg(_t('تم حذف المرفق', 'Attachment deleted'));
              },
              child: Text(_t('حذف', 'Delete')),
            ),
          ],
        );
      },
    );
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

  Future<void> _openDesignSettings() async {
    await Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: const Color(0x22000000),
        pageBuilder: (_, __, ___) => DesignSettingsPage(
          isArabic: _isArabic,
          asOverlay: true,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {});
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
    return AnimatedBuilder(
      animation: _design,
      builder: (context, _) {
        final cfg = _design.config;
        Color tone(Color c) => _design.shiftColor(c, cfg.uiBrightnessShift);
        Color ensureVisibleBg(Color c) {
          const canvas = Color(0xFFF8FAFC);
          if (_design.hasGoodContrast(c, canvas, minRatio: 1.35)) return c;
          final makeDarker = c.computeLuminance() > canvas.computeLuminance();
          return _design.shiftColor(c, makeDarker ? -0.22 : 0.22);
        }
        Color safeTextFor(Color bg) => _design.hasGoodContrast(cfg.buttonTextColor, bg,
                minRatio: 3.5)
            ? cfg.buttonTextColor
            : _design.onColorFor(bg);
        final buttonRadius = switch (cfg.buttonShapeStyle) {
          1 => 999.0,
          2 => 2.0,
          3 => 14.0,
          _ => cfg.buttonRadius,
        };
        final buttonBgColor = ensureVisibleBg(tone(cfg.buttonBgColor));
        final addBtnColor = cfg.useDistinctActionButtonColors
            ? ensureVisibleBg(tone(cfg.actionAddButtonColor))
            : buttonBgColor;
        final editBtnColor = cfg.useDistinctActionButtonColors
            ? ensureVisibleBg(tone(cfg.actionEditButtonColor))
            : buttonBgColor;
        final deleteBtnColor = cfg.useDistinctActionButtonColors
            ? ensureVisibleBg(tone(cfg.actionDeleteButtonColor))
            : buttonBgColor;
        final statusBtnColor = cfg.useDistinctActionButtonColors
            ? ensureVisibleBg(tone(cfg.actionStatusButtonColor))
            : buttonBgColor;
        final addBtnTextColor = safeTextFor(addBtnColor);
        final editBtnTextColor = safeTextFor(editBtnColor);
        final deleteBtnTextColor = safeTextFor(deleteBtnColor);
        final statusBtnTextColor = safeTextFor(statusBtnColor);
        final headerTextColor = _design.onColorFor(tone(cfg.tableHeaderColor));
        final onCardTextColor = _design.onColorFor(tone(cfg.transactionCardColor));
    return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(
            width: 240,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tone(cfg.sidebarColor),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F0F172A),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
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
                          _t('إنفورم للطباعة والتصوير', 'Inform Typing & Photo Copy'),
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
                      border: Border(bottom: BorderSide(color: Color(0x26FFFFFF))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => setState(() => _isArabic = !_isArabic),
                      style: TextButton.styleFrom(
                        backgroundColor: buttonBgColor,
                        foregroundColor: safeTextFor(buttonBgColor),
                        side: BorderSide(
                          color: cfg.buttonBorderColor,
                          width: cfg.buttonBorderWidth,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(buttonRadius),
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
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => HomePage(initialArabic: _isArabic),
                              ),
                            );
                          },
                        ),
                        _SideItem(
                          icon: Icons.groups_outlined,
                          text: _t('العملاء', 'Customers'),
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => HomePage(initialArabic: _isArabic),
                              ),
                            );
                          },
                        ),
                        _SideItem(
                          icon: Icons.download_for_offline_outlined,
                          text: _t('تحميل المرفقات', 'Download Attachments'),
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: _downloadSelectedAttachments,
                        ),
                        _SideItem(
                          icon: Icons.delete_sweep_outlined,
                          text: _t('حذف المرفقات', 'Delete Attachments'),
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: _deleteSelectedAttachments,
                        ),
                        _SideItem(
                          icon: Icons.receipt_long_outlined,
                          text: _t('الفواتير', 'Invoices'),
                          active: true,
                          fontWeightLevel: cfg.fontWeightLevel,
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
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: () => _showMsg(
                            _t('التقارير قيد التطوير', 'Reports feature is coming soon'),
                          ),
                        ),
                        _SideItem(
                          icon: Icons.settings_outlined,
                          text: _t('إدارة التصميم', 'Design Manager'),
                          fontWeightLevel: cfg.fontWeightLevel,
                          onPressed: _openDesignSettings,
                        ),
                        const Spacer(),
                        _SideItem(
                          icon: Icons.logout,
                          text: _t('تسجيل الخروج', 'Sign Out'),
                          fontWeightLevel: cfg.fontWeightLevel,
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
          ),
          const SizedBox(width: 14),
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
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: tone(cfg.tableHeaderColor),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Align(
                      alignment:
                          _isArabic ? Alignment.centerRight : Alignment.centerLeft,
                      child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ActionBtn(
                                icon: Icons.add,
                                text: _t('إضافة معاملة', 'Add Transaction'),
                                presetStyle: cfg.buttonPresetStyle,
                                bgColor: addBtnColor,
                                textColor: addBtnTextColor,
                                borderColor: cfg.buttonBorderColor,
                                borderWidth: cfg.buttonBorderWidth,
                                radius: buttonRadius,
                                shadowBlur: cfg.buttonShadowBlur,
                                shadowOpacity: cfg.buttonShadowOpacity,
                                shine: cfg.buttonShine,
                                fontWeightLevel: cfg.fontWeightLevel,
                                onPressed: _openAddTransaction,
                              ),
                              _ActionBtn(
                                icon: Icons.edit,
                                text: _t('تعديل معاملة', 'Edit Transaction'),
                                presetStyle: cfg.buttonPresetStyle,
                                bgColor: editBtnColor,
                                textColor: editBtnTextColor,
                                borderColor: cfg.buttonBorderColor,
                                borderWidth: cfg.buttonBorderWidth,
                                radius: buttonRadius,
                                shadowBlur: cfg.buttonShadowBlur,
                                shadowOpacity: cfg.buttonShadowOpacity,
                                shine: cfg.buttonShine,
                                fontWeightLevel: cfg.fontWeightLevel,
                                onPressed: _openEditTransaction,
                              ),
                              OutlinedButton.icon(
                                onPressed: _openDeleteDialog,
                                icon: const Icon(Icons.delete_outline, size: 16),
                                label: Text(_t('حذف معاملة', 'Delete Transaction')),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: cfg.buttonBorderColor,
                                    width: cfg.buttonBorderWidth,
                                  ),
                                  foregroundColor: deleteBtnTextColor,
                                  backgroundColor: deleteBtnColor,
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(buttonRadius),
                                  ),
                                ),
                              ),
                              _ActionBtn(
                                  icon: Icons.check_circle_outline,
                                  text: _t('الحالة', 'Status'),
                                  presetStyle: cfg.buttonPresetStyle,
                                  bgColor: statusBtnColor,
                                  textColor: statusBtnTextColor,
                                  borderColor: cfg.buttonBorderColor,
                                  borderWidth: cfg.buttonBorderWidth,
                                  radius: buttonRadius,
                                  shadowBlur: cfg.buttonShadowBlur,
                                  shadowOpacity: cfg.buttonShadowOpacity,
                                  shine: cfg.buttonShine,
                                  fontWeightLevel: cfg.fontWeightLevel,
                                  onPressed: _openStatusDialog,
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
                      decoration: BoxDecoration(
                        color: tone(cfg.tableHeaderColor),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        boxShadow: const [
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
                            _HeaderCell(_t('بند الخدمة', 'Service'), 2.5,
                                textColor: headerTextColor),
                            _HeaderCell(_t('العدد', 'Qty'), 0.8,
                                align: TextAlign.center, textColor: headerTextColor),
                            _HeaderCell(_t('سعر الوحدة', 'Unit Price'), 1.1,
                                align: TextAlign.center, textColor: headerTextColor),
                            _HeaderCell(_t('الإجمالي', 'Total'), 1.2,
                                align: TextAlign.center, textColor: headerTextColor),
                            _HeaderCell(_t('اسم الشركة', 'Company'), 1.8,
                                textColor: headerTextColor),
                            _HeaderCell(_t('اسم الموظف', 'Employee'), 1.3,
                                textColor: headerTextColor),
                            _HeaderCell(_t('المرفقات', 'Files'), 2.4,
                                align: TextAlign.center, textColor: headerTextColor),
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
                        color: tone(cfg.tableAreaColor),
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

                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              10,
                              cfg.cardSpacing,
                              10,
                              cfg.cardSpacing,
                            ),
                            child: Stack(
                            children: [
                                  Container(
                                      clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                        color: tone(cfg.transactionCardColor),
                                        border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFA5C8F4),
                                          width: isSelected
                                              ? cfg.cardBorderWidth + 0.6
                                              : cfg.cardBorderWidth,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x140F172A),
                                            blurRadius: 10,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                  ),
                                  child: Column(
                                    children: [
                                      for (int i = 0; i < tx.items.length; i++)
                                        Container(
                                          color: i.isEven
                                              ? Colors.white
                                                  : tone(cfg.tableAreaColor).withOpacity(0.32),
                                              padding: EdgeInsets.symmetric(
                                            horizontal: 18,
                                                vertical: cfg.rowVerticalPadding,
                                              ),
                                              constraints: BoxConstraints(
                                                minHeight: cfg.transactionRowHeight,
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
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _BodyCell(
                                                      '${tx.items[i].qty}',
                                                      0.8,
                                                      align: TextAlign.center,
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _BodyCell(
                                                    tx.items[i].unitPrice
                                                        .toStringAsFixed(2),
                                                    1.1,
                                                  align: TextAlign.center,
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _BodyCell(
                                                  tx.items[i].total
                                                      .toStringAsFixed(2),
                                                  1.2,
                                                  align: TextAlign.center,
                                                  weight: FontWeight.w600,
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _BodyCell(
                                                  _isArabic
                                                      ? tx.items[i].companyAr
                                                      : tx.items[i].companyEn,
                                                  1.8,
                                                  color: const Color(0xFF1E5A8A),
                                                  weight: FontWeight.w500,
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _BodyCell(
                                                  _isArabic
                                                      ? tx.items[i].employeeAr
                                                      : tx.items[i].employeeEn,
                                                  1.3,
                                                  color: const Color(0xFF7C3AED),
                                                  weight: FontWeight.w500,
                                                  fontSize: cfg.baseFontSize,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                Expanded(
                                                      flex: 24,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                            vertical: 2,
                                                            horizontal: 4,
                                                          ),
                                                          child: _AttachmentIcons(
                                                            attachments:
                                                                tx.items[i]
                                                                    .attachments,
                                                            iconSize:
                                                                cfg.attachmentIconSize,
                                                            onTapFile: (index) =>
                                                                _onAttachmentIconTap(
                                                              tx.items[i]
                                                                  .attachmentPaths,
                                                              index,
                                                            ),
                                                            onDeleteFile: (index) =>
                                                                _deleteSingleAttachment(
                                                              tx.items[i]
                                                                  .attachments[index],
                                                            ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                          Padding(
                                        padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 8,
                                              runSpacing: 2,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Checkbox(
                                                      value: isSelected,
                                                      activeColor:
                                                          const Color(0xFFBFDBFE),
                                                      checkColor:
                                                          const Color(0xFF1E3A8A),
                                                      onChanged: (_) =>
                                                          _toggleSelection(
                                                        tx.invoiceNumber,
                                                      ),
                                                    ),
                                                    Text(
                                                      _t('تحديد', 'Select'),
                                                      style: TextStyle(
                                                        fontSize: cfg.baseFontSize - 3,
                                                      fontWeight:
                                                            FontWeight.w600,
                                                        color: onCardTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                _CompactInfoText(
                                                  '${_t('فاتورة:', 'Invoice:')} ${tx.invoiceNumber}',
                                                  valueColor: onCardTextColor,
                                                  baseColor: onCardTextColor,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _CompactInfoText(
                                                  '${_t('التاريخ:', 'Date:')} ${tx.date}',
                                                  baseColor: onCardTextColor,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _CompactInfoText(
                                                  '${_t('الحالة:', 'Status:')} ${_statusLabel(tx.status)}',
                                                  valueColor:
                                                      _statusColor(tx.status),
                                                  baseColor: onCardTextColor,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                ),
                                                _CompactInfoText(
                                                  '${_t('الإجمالي:', 'Total:')} AED ${tx.grandTotal.toStringAsFixed(2)}',
                                                  valueColor: onCardTextColor,
                                                  baseColor: onCardTextColor,
                                                  fontWeightLevel: cfg.fontWeightLevel,
                                                      ),
                                                    ],
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
          ),
        );
      },
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
              attachments: it.attachments
                  .map(
                    (a) => _TxAttachment(
                      id: a.id,
                      fileName: a.fileName,
                      filePath: a.filePath,
                    ),
                  )
                  .toList(),
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
    required this.attachments,
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
  final List<_TxAttachment> attachments;
  List<String> get attachmentPaths =>
      attachments.map((a) => a.filePath).toList(growable: false);
  int get attachmentCount => attachmentPaths.length;
  bool get hasAttachment => attachmentPaths.isNotEmpty;
}

class _TxAttachment {
  const _TxAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
  });

  final int? id;
  final String fileName;
  final String filePath;
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.icon,
    required this.text,
    this.active = false,
    this.fontWeightLevel = 500,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final bool active;
  final double fontWeightLevel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cfg = DesignController.instance.config;
    final controller = DesignController.instance;
    final buttonRadius = switch (cfg.buttonShapeStyle) {
      1 => 999.0,
      2 => 2.0,
      3 => 14.0,
      _ => cfg.buttonRadius,
    };
    final bg = active
        ? controller.shiftColor(cfg.buttonBgColor, cfg.uiBrightnessShift)
        : Colors.transparent;
    final fg = active ? cfg.buttonTextColor : const Color(0xFFB0CDE4);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(
            color: active ? cfg.buttonBorderColor : Colors.transparent,
            width: cfg.buttonBorderWidth,
          ),
          minimumSize: const Size(double.infinity, 40),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: _shiftWeight(FontWeight.w500, fontWeightLevel),
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.text,
    required this.presetStyle,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
    required this.shadowBlur,
    required this.shadowOpacity,
    required this.shine,
    required this.fontWeightLevel,
    this.onPressed,
  });

  final IconData icon;
  final String text;
  final int presetStyle;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;
  final double shadowBlur;
  final double shadowOpacity;
  final double shine;
  final double fontWeightLevel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final top = HSLColor.fromColor(bgColor)
        .withLightness((HSLColor.fromColor(bgColor).lightness + (shine * 0.18))
            .clamp(0.0, 1.0))
        .toColor();
    final soft = HSLColor.fromColor(bgColor)
        .withLightness((HSLColor.fromColor(bgColor).lightness + 0.16).clamp(0.0, 1.0))
        .toColor();
    final glass = Colors.white.withOpacity(0.22);
    final isMinimal = presetStyle == 4;
    final isSoft = presetStyle == 3;
    final isGlass = presetStyle == 2;
    final isGradient = presetStyle == 1;
    final gradientColors = isGradient
        ? [top, bgColor]
        : isGlass
            ? [glass, bgColor.withOpacity(0.75)]
            : isSoft
                ? [soft, bgColor]
                : [bgColor, bgColor];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMinimal ? 4 : radius),
        boxShadow: (shadowBlur <= 0 || isMinimal)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: shadowBlur,
                  offset: const Offset(0, 2),
                ),
              ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isGradient || isGlass || isSoft
              ? gradientColors
              : (shine > 0 ? [top, bgColor] : [bgColor, bgColor]),
        ),
      ),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16),
        label: Text(
          text,
          style: TextStyle(
            fontWeight: _shiftWeight(FontWeight.w600, fontWeightLevel),
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: isSoft ? Colors.black87 : textColor,
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMinimal ? 4 : radius),
            side: BorderSide(
              color: isMinimal ? textColor.withOpacity(0.25) : borderColor,
              width: isMinimal ? 1 : borderWidth,
            ),
          ),
        ).copyWith(
          backgroundColor: WidgetStatePropertyAll(
              isMinimal ? Colors.transparent : Colors.transparent),
          overlayColor: WidgetStatePropertyAll(textColor.withOpacity(0.12)),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, this.flex,
      {this.align = TextAlign.start, this.textColor = Colors.white});

  final String text;
  final double flex;
  final TextAlign align;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: textColor,
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
    this.fontSize = 15,
    this.fontWeightLevel = 500,
  });

  final String text;
  final double flex;
  final TextAlign align;
  final Color color;
  final FontWeight weight;
  final double fontSize;
  final double fontWeightLevel;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: _shiftWeight(weight, fontWeightLevel),
        ),
      ),
    );
  }
}

class _AttachmentIcons extends StatelessWidget {
  const _AttachmentIcons({
    required this.attachments,
    required this.iconSize,
    required this.onTapFile,
    required this.onDeleteFile,
  });

  final List<_TxAttachment> attachments;
  final double iconSize;
  final ValueChanged<int> onTapFile;
  final ValueChanged<int> onDeleteFile;

  @override
  Widget build(BuildContext context) {
    final valid = attachments
        .where((e) => e.filePath.trim().isNotEmpty)
        .toList(growable: false);
    if (valid.isEmpty) {
      return const Text(
        '-',
        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < valid.length; i++) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                border: Border.all(color: const Color(0xFFFCA5A5)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => onTapFile(i),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.attach_file,
                        size: iconSize,
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: () => onDeleteFile(i),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.close,
                        size: ((iconSize - 1).clamp(8, 24)).toDouble(),
                        color: const Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i != valid.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _CompactInfoText extends StatelessWidget {
  const _CompactInfoText(
    this.text, {
    this.valueColor = const Color(0xFFE2ECFA),
    this.baseColor = const Color(0xFFE2ECFA),
    this.fontWeightLevel = 500,
  });

  final String text;
  final Color valueColor;
  final Color baseColor;
  final double fontWeightLevel;

  @override
  Widget build(BuildContext context) {
    final parts = text.split(' ');
    final label = parts.first;
    final value = parts.skip(1).join(' ');

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 11.5,
          color: baseColor,
          fontWeight: _shiftWeight(FontWeight.w500, fontWeightLevel),
        ),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor,
              fontWeight: _shiftWeight(FontWeight.w600, fontWeightLevel),
            ),
          ),
        ],
      ),
    );
  }
}

FontWeight _shiftWeight(FontWeight base, double weightLevel) {
  const weights = <FontWeight>[
    FontWeight.w100,
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900,
  ];
  int baseIdx = 4;
  switch (base) {
    case FontWeight.w100:
      baseIdx = 0;
      break;
    case FontWeight.w200:
      baseIdx = 1;
      break;
    case FontWeight.w300:
      baseIdx = 2;
      break;
    case FontWeight.w400:
      baseIdx = 3;
      break;
    case FontWeight.w500:
      baseIdx = 4;
      break;
    case FontWeight.w600:
      baseIdx = 5;
      break;
    case FontWeight.w700:
      baseIdx = 6;
      break;
    case FontWeight.w800:
      baseIdx = 7;
      break;
    case FontWeight.w900:
      baseIdx = 8;
      break;
    default:
      baseIdx = 4;
  }
  final delta = ((weightLevel - 500) / 100).round();
  final idx = (baseIdx + delta).clamp(0, 8);
  return weights[idx];
}

