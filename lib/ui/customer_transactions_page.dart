import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as p;

import '../data/app_database.dart';
import '../data/models/design_config.dart';
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
  final ScrollController _tableScrollController = ScrollController();
  final Set<String> _selectedInvoices = <String>{};
  final List<_TxRecord> _transactions = <_TxRecord>[];
  late bool _isArabic;
  bool _isLoading = true;
  bool _isNewThemePreview = false;
  AppDesignConfig? _newThemeSnapshot;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
    _loadTransactions();
  }

  @override
  void dispose() {
    final snapshot = _newThemeSnapshot;
    if (_isNewThemePreview && snapshot != null) {
      _design.restoreSnapshot(snapshot);
    }
    _tableScrollController.dispose();
    super.dispose();
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

  Color _blockBorderColor(int index) {
    const palette = <Color>[
      Color(0xFF5B8CFF),
      Color(0xFF58C4A3),
      Color(0xFFF4A94B),
      Color(0xFF9D84F7),
      Color(0xFF5DA8F2),
    ];
    return palette[index % palette.length];
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
                _t('أدخل كود الحذف 123 (إجباري)',
                    'Enter delete code 123 (required)'),
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
                if (codeController.text.trim() != '123') {
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
    final snapshot = _design.config;
    final applied = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        opaque: false,
        barrierColor: const Color(0x22000000),
        pageBuilder: (_, __, ___) => DesignSettingsPage(
          isArabic: _isArabic,
          asOverlay: true,
        ),
      ),
    );
    if (applied != true) {
      _design.restoreSnapshot(snapshot);
    }
  }

  AppDesignConfig _buildNewThemePreviewConfig(AppDesignConfig base) {
    return base.copyWith(
      tableHeaderColor: const Color(0xFF22345F),
      tableAreaColor: const Color(0xFF21335E),
      transactionCardColor: const Color(0xFFF3F5F9),
      sidebarColor: const Color(0xFF22345F),
      buttonBgColor: const Color(0xFF0C4A7C),
      buttonTextColor: const Color(0xFFFFFFFF),
      buttonBorderColor: const Color(0x994CC9F0),
      buttonBorderWidth: 1,
      buttonRadius: 8,
      buttonShadowBlur: 14,
      buttonShadowOpacity: 0.2,
      buttonShine: 0.18,
      useDistinctActionButtonColors: true,
      actionAddButtonColor: const Color(0xFF0F766E),
      actionEditButtonColor: const Color(0xFF0369A1),
      actionDeleteButtonColor: const Color(0xFF7F1D1D),
      actionStatusButtonColor: const Color(0xFFF59E0B),
      transactionRowHeight: 48,
      rowVerticalPadding: 10,
      cardSpacing: 10,
      cardBorderWidth: 1,
      attachmentIconSize: 12,
      baseFontSize: 14,
      fontWeightLevel: 500,
      uiBrightnessShift: 0,
      fontFamilyName: 'Inter',
      buttonPresetStyle: 2,
      buttonShapeStyle: 0,
    );
  }

  void _previewNewTheme() {
    if (_isNewThemePreview) return;
    _newThemeSnapshot = _design.config;
    _design.preview(_buildNewThemePreviewConfig(_design.config));
    setState(() => _isNewThemePreview = true);
  }

  Future<void> _approveNewTheme() async {
    if (!_isNewThemePreview) return;
    await _design.applyChanges();
    if (!mounted) return;
    setState(() {
      _isNewThemePreview = false;
      _newThemeSnapshot = null;
    });
    _showMsg(_t('تم اعتماد نيو ثيم', 'New theme approved'));
  }

  void _rejectNewTheme() {
    if (!_isNewThemePreview) return;
    final snapshot = _newThemeSnapshot;
    if (snapshot != null) {
      _design.restoreSnapshot(snapshot);
    }
    setState(() {
      _isNewThemePreview = false;
      _newThemeSnapshot = null;
    });
    _showMsg(_t('تم رفض نيو ثيم والعودة للوضع السابق',
        'New theme rejected and reverted'));
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
        final addBtn = cfg.useDistinctActionButtonColors
            ? cfg.actionAddButtonColor
            : cfg.buttonBgColor;
        final editBtn = cfg.useDistinctActionButtonColors
            ? cfg.actionEditButtonColor
            : cfg.buttonBgColor;
        final statusBtn = cfg.useDistinctActionButtonColors
            ? cfg.actionStatusButtonColor
            : cfg.buttonBgColor;
        return Scaffold(
          body: Row(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 240,
            color: tone(cfg.sidebarColor),
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
                          color: tone(cfg.buttonBgColor),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: tone(cfg.buttonBgColor).withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
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
                        backgroundColor: tone(cfg.buttonBgColor),
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
                          icon: Icons.groups_outlined,
                          text: _t('العملاء', 'Customers'),
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
                          onPressed: _downloadSelectedAttachments,
                        ),
                        _SideItem(
                          icon: Icons.delete_sweep_outlined,
                          text: _t('حذف المرفقات', 'Delete Attachments'),
                          onPressed: _deleteSelectedAttachments,
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
                          onPressed: () => _showMsg(
                            _t('التقارير قيد التطوير', 'Reports feature is coming soon'),
                          ),
                        ),
                        _SideItem(
                          icon: Icons.settings_outlined,
                          text: _t('إدارة التصميم', 'Design Manager'),
                          onPressed: _openDesignSettings,
                        ),
                        _SideItem(
                          icon: Icons.auto_awesome_outlined,
                          text: _t('نيو ثيم', 'New Theme'),
                          active: _isNewThemePreview,
                          onPressed: _previewNewTheme,
                        ),
                        if (_isNewThemePreview)
                          _SideItem(
                            icon: Icons.check_circle_outline,
                            text: _t('اعتماد نيو ثيم', 'Approve New Theme'),
                            onPressed: _approveNewTheme,
                          ),
                        if (_isNewThemePreview)
                          _SideItem(
                            icon: Icons.cancel_outlined,
                            text: _t('رفض نيو ثيم', 'Reject New Theme'),
                            onPressed: _rejectNewTheme,
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
                              color: tone(cfg.buttonBgColor),
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: tone(cfg.buttonBgColor),
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
                                color: addBtn,
                                hover: addBtn,
                                onPressed: _openAddTransaction,
                              ),
                              _ActionBtn(
                                icon: Icons.edit,
                                text: _t('تعديل معاملة', 'Edit Transaction'),
                                color: editBtn,
                                hover: editBtn,
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
                                color: statusBtn,
                                hover: statusBtn,
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
                      decoration: BoxDecoration(
                        color: tone(cfg.tableHeaderColor),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(12)),
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
                            _HeaderCell(_t('بند الخدمة', 'Service'), 2.5),
                            _HeaderCell(_t('العدد', 'Qty'), 0.8,
                                align: TextAlign.center),
                            _HeaderCell(_t('سعر الوحدة', 'Unit Price'), 1.1,
                                align: TextAlign.center),
                            _HeaderCell(_t('الإجمالي', 'Total'), 1.2,
                                align: TextAlign.center),
                            _HeaderCell(_t('اسم الشركة', 'Company'), 1.8),
                            _HeaderCell(_t('اسم الموظف', 'Employee'), 1.3),
                            _HeaderCell(_t('المرفقات', 'Files'), 1.8,
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
                      decoration: const BoxDecoration(color: Colors.transparent),
                      child: data.isEmpty
                          ? Center(
                              child: Text(
                                _t('لا توجد معاملات محفوظة', 'No saved transactions'),
                                style: const TextStyle(color: Color(0xFF64748B)),
                              ),
                            )
                          : Scrollbar(
                        controller: _tableScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        radius: const Radius.circular(8),
                        child: ListView.builder(
                          controller: _tableScrollController,
                          padding: const EdgeInsets.only(bottom: 8),
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
                                        color: const Color(0xFFF1F5F9),
                                        border: Border.all(
                                          color: isSelected
                                              ? tone(cfg.buttonBgColor)
                                              : _blockBorderColor(txIndex),
                                          width: cfg.cardBorderWidth + 0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 7,
                                            ),
                                            decoration: BoxDecoration(
                                              color: tone(cfg.tableHeaderColor),
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(9),
                                              ),
                                            ),
                                            child: Directionality(
                                              textDirection: tableDirection,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 22,
                                                    height: 22,
                                                    child: Checkbox(
                                                      value: isSelected,
                                                      activeColor:
                                                          const Color(0xFF38BDF8),
                                                      checkColor: Colors.white,
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      onChanged: (_) =>
                                                          _toggleSelection(
                                                        tx.invoiceNumber,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Wrap(
                                                      spacing: 8,
                                                      runSpacing: 6,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment.center,
                                                      children: [
                                                        _TopMetaPill(
                                                          label:
                                                              _t('فاتورة', 'Invoice'),
                                                          value: tx.invoiceNumber,
                                                          valueColor: const Color(
                                                              0xFF0EA5E9),
                                                        ),
                                                        _TopMetaPill(
                                                          label:
                                                              _t('الحالة', 'Status'),
                                                          value: _statusLabel(
                                                              tx.status),
                                                          valueColor:
                                                              _statusColor(tx.status),
                                                        ),
                                                        _TopMetaPill(
                                                          label:
                                                              _t('الإجمالي', 'Total'),
                                                          value:
                                                              'AED ${tx.grandTotal.toStringAsFixed(2)}',
                                                          valueColor: const Color(
                                                              0xFF38BDF8),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    tx.date,
                                                    style: const TextStyle(
                                                      color: Color(0xFF9DD6EA),
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          for (int i = 0; i < tx.items.length; i++)
                                            Container(
                                              constraints: BoxConstraints(
                                                minHeight: cfg.transactionRowHeight,
                                              ),
                                              color: i.isEven
                                                  ? const Color(0xFFF8FAFC)
                                                  : const Color(0xFFEFF3F8),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: cfg.rowVerticalPadding,
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
                                                      color: const Color(0xFF0E7490),
                                                      weight: FontWeight.w500,
                                                    ),
                                                    Expanded(
                                                      flex: 18,
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                            vertical: 2,
                                                            horizontal: 4,
                                                          ),
                                                          child: _AttachmentIcons(
                                                            attachmentPaths:
                                                                tx.items[i]
                                                                    .attachmentPaths,
                                                            iconSize:
                                                                cfg.attachmentIconSize,
                                                            onTapFile: (index) =>
                                                                _onAttachmentIconTap(
                                                              tx.items[i]
                                                                  .attachmentPaths,
                                                              index,
                                                            ),
                                                          ),
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
                                SizedBox(height: cfg.cardSpacing),
                            ],
                          );
                          },
                        ),
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

FontWeight _weightFromLevel(double level) {
  if (level < 350) return FontWeight.w300;
  if (level < 450) return FontWeight.w400;
  if (level < 550) return FontWeight.w500;
  if (level < 650) return FontWeight.w600;
  if (level < 750) return FontWeight.w700;
  return FontWeight.w800;
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
    final cfg = DesignController.instance.config;
    final controller = DesignController.instance;
    final buttonRadius = switch (cfg.buttonShapeStyle) {
      1 => 999.0,
      2 => 2.0,
      3 => 14.0,
      _ => cfg.buttonRadius,
    };
    final activeBg = controller.shiftColor(cfg.buttonBgColor, cfg.uiBrightnessShift);
    final activeFg = controller.onColorFor(activeBg);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: active ? activeBg : Colors.transparent,
          foregroundColor: active ? activeFg : const Color(0xFFB0CDE4),
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
            fontSize: (cfg.baseFontSize - 0.5).clamp(11, 18),
            fontWeight: _weightFromLevel(cfg.fontWeightLevel),
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
    final cfg = DesignController.instance.config;
    final controller = DesignController.instance;
    final buttonRadius = switch (cfg.buttonShapeStyle) {
      1 => 999.0,
      2 => 2.0,
      3 => 14.0,
      _ => cfg.buttonRadius,
    };
    final fg = controller.hasGoodContrast(cfg.buttonTextColor, color, minRatio: 3.5)
        ? cfg.buttonTextColor
        : controller.onColorFor(color);
    return TextButton.icon(
      onPressed: onPressed ?? () {},
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: TextButton.styleFrom(
        backgroundColor: color,
        foregroundColor: fg,
        minimumSize: const Size(0, 36),
        side: BorderSide(
          color: cfg.buttonBorderColor,
          width: cfg.buttonBorderWidth,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: TextStyle(
          fontSize: (cfg.baseFontSize - 1).clamp(10, 16),
          fontWeight: _weightFromLevel(cfg.fontWeightLevel),
          letterSpacing: 0.1,
          height: 1.3,
        ),
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
    final cfg = DesignController.instance.config;
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: Colors.white,
          fontSize: (cfg.baseFontSize - 1).clamp(11, 18),
          fontWeight: _weightFromLevel(cfg.fontWeightLevel),
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
    final cfg = DesignController.instance.config;
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          color: color,
          fontSize: cfg.baseFontSize,
          fontWeight: weight,
          height: 1.35,
          letterSpacing: 0.08,
        ),
      ),
    );
  }
}

class _AttachmentIcons extends StatelessWidget {
  const _AttachmentIcons({
    required this.attachmentPaths,
    required this.iconSize,
    required this.onTapFile,
  });

  final List<String> attachmentPaths;
  final double iconSize;
  final ValueChanged<int> onTapFile;

  @override
  Widget build(BuildContext context) {
    final validPaths = attachmentPaths.where((e) => e.trim().isNotEmpty).toList();
    if (validPaths.isEmpty) {
      return const Text(
        '-',
        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteWidth = constraints.maxWidth.isFinite;
        final availableWidth = hasFiniteWidth ? constraints.maxWidth : 360.0;
        final chipWidth = (availableWidth - 12) / 3;

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 0; i < validPaths.length; i++)
              SizedBox(
                width: chipWidth > 84 ? chipWidth : 84,
                child: ActionChip(
                  onPressed: () => onTapFile(i),
                  avatar: Icon(
                    Icons.attach_file,
                    size: iconSize,
                    color: const Color(0xFF2563EB),
                  ),
                  label: Text(
                    p.basename(validPaths[i]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:
                      const VisualDensity(horizontal: -2, vertical: -2),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopMetaPill extends StatelessWidget {
  const _TopMetaPill({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2E93C5DB)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFD1E5F2),
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
