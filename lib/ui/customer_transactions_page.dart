import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path/path.dart' as p;

import '../data/app_database.dart';
import '../data/models/design_config.dart';
import '../logic/design_controller.dart';
import '../logic/home_logic.dart';
import 'add_transaction_page.dart';
import 'design_settings_page.dart';
import 'invoices_page.dart';
import 'login_page.dart';

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
  final Set<int> _selectedCustomerIds = <int>{};
  final List<_TxRecord> _transactions = <_TxRecord>[];
  final List<Customer> _customers = <Customer>[];
  late bool _isArabic;
  bool _isLoading = true;
  bool _isCustomersLoading = true;
  bool _isNewThemePreview = false;
  AppDesignConfig? _newThemeSnapshot;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
    _loadTransactions();
    _loadCustomers();
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

  Future<void> _loadCustomers() async {
    setState(() => _isCustomersLoading = true);
    final rows = await _db.getCustomers();
    if (!mounted) return;
    setState(() {
      _customers
        ..clear()
        ..addAll(rows);
      _selectedCustomerIds.removeWhere((id) => !_customers.any((c) => c.id == id));
      _selectedCustomerIds.add(widget.customerId);
      _isCustomersLoading = false;
    });
  }

  void _toggleCustomerSelection(int id) {
    setState(() {
      if (_selectedCustomerIds.contains(id)) {
        _selectedCustomerIds.remove(id);
      } else {
        _selectedCustomerIds.add(id);
      }
    });
  }

  void _openCustomerTransactions(Customer customer) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CustomerTransactionsPage(
          initialArabic: _isArabic,
          customerNameAr: customer.name,
          customerNameEn: customer.nameEn,
          customerId: customer.id,
        ),
      ),
    );
  }

  void _openAddCustomerDialog() {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('إضافة عميل', 'Add Customer')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: _t('اسم العميل', 'Customer Name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final rawName = nameController.text.trim();
                final parsedId = int.tryParse(idController.text.trim());
                if (rawName.isEmpty || parsedId == null) {
                  _showMsg(
                    _t('يرجى إدخال اسم صحيح و ID رقمي', 'Please enter a valid name and numeric ID'),
                    error: true,
                  );
                  return;
                }
                if (_customers.any((c) => c.id == parsedId)) {
                  _showMsg(_t('رقم ID مستخدم مسبقاً', 'ID already exists'), error: true);
                  return;
                }
                await _db.insertCustomer(Customer(id: parsedId, name: rawName, nameEn: rawName));
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showMsg(_t('تمت إضافة العميل بنجاح', 'Customer added successfully'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _openEditCustomerDialog() {
    if (_selectedCustomerIds.isEmpty) {
      _showMsg(_t('حدد عميل أولاً للتعديل', 'Select a customer first to edit'), error: true);
      return;
    }
    if (_selectedCustomerIds.length > 1) {
      _showMsg(
        _t('يمكن تعديل عميل واحد فقط في كل مرة', 'You can edit only one customer at a time'),
        error: true,
      );
      return;
    }

    final selectedId = _selectedCustomerIds.first;
    final index = _customers.indexWhere((c) => c.id == selectedId);
    if (index == -1) return;
    final target = _customers[index];
    final nameController = TextEditingController(text: target.name);
    final idController = TextEditingController(text: target.id.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('تعديل عميل', 'Edit Customer')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: _t('اسم العميل', 'Customer Name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_t('إلغاء', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final rawName = nameController.text.trim();
                final parsedId = int.tryParse(idController.text.trim());
                if (rawName.isEmpty || parsedId == null) {
                  _showMsg(
                    _t('يرجى إدخال اسم صحيح و ID رقمي', 'Please enter a valid name and numeric ID'),
                    error: true,
                  );
                  return;
                }
                final duplicated = _customers.any((c) => c.id == parsedId && c.id != target.id);
                if (duplicated) {
                  _showMsg(_t('رقم ID مستخدم مسبقاً', 'ID already exists'), error: true);
                  return;
                }
                await _db.updateCustomer(
                  target.id,
                  Customer(id: parsedId, name: rawName, nameEn: rawName),
                );
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                setState(() {
                  _selectedCustomerIds
                    ..clear()
                    ..add(parsedId);
                });
                Navigator.of(dialogContext).pop();
                _showMsg(_t('تم حفظ التعديل', 'Changes saved'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _openDeleteCustomerDialog() {
    if (_selectedCustomerIds.isEmpty) {
      _showMsg(_t('حدد عميل أولاً للحذف', 'Select a customer first to delete'), error: true);
      return;
    }
    final codeController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_t('حذف عميل', 'Delete Customer')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_t('هل أنت متأكد من حذف العميل المحدد؟', 'Are you sure you want to delete the selected customer?')),
              const SizedBox(height: 8),
              Text(
                _t('للتأكيد أدخل كود الحذف 1234', 'To confirm, enter delete code 1234'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: _t('كود التأكيد', 'Confirmation Code')),
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
                  _showMsg(_t('كود التأكيد غير صحيح', 'Invalid confirmation code'), error: true);
                  return;
                }
                await _db.deleteCustomers(_selectedCustomerIds.toList());
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showMsg(_t('تم حذف العميل بنجاح', 'Customer deleted successfully'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
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

  bool get _hasSelectedCustomer => widget.customerId > 0;

  bool _ensureSelectedCustomer() {
    if (_hasSelectedCustomer) return true;
    _showMsg(
      _t('اختر عميل أولاً من القائمة الجانبية', 'Please select a customer first from the sidebar'),
      error: true,
    );
    return false;
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
    final result = await _openTransactionEditorDialog();
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
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

    final result = await _openTransactionEditorDialog(
      initialData: source.toAddTransactionResult(),
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

  Future<AddTransactionResult?> _openTransactionEditorDialog({
    AddTransactionResult? initialData,
  }) {
    return showDialog<AddTransactionResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final size = MediaQuery.of(dialogContext).size;
        final dialogWidth = size.width > 1260 ? 1160.0 : size.width - 28;
        final dialogHeight = size.height > 860 ? 760.0 : size.height - 28;

        return Dialog(
          insetPadding: const EdgeInsets.all(14),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF93C5FD), width: 1.6),
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: AddTransactionPage(
              initialArabic: _isArabic,
              customerNameAr: widget.customerNameAr,
              customerNameEn: widget.customerNameEn,
              initialData: initialData,
            ),
          ),
        );
      },
    );
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
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
    if (!_ensureSelectedCustomer()) {
      return;
    }
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
    final hasSelectedCustomer = _hasSelectedCustomer;
    final officeNameAr = widget.customerNameAr.trim().isEmpty
        ? 'إنفورم للطباعة والتصوير'
        : widget.customerNameAr;
    final officeNameEn = widget.customerNameEn.trim().isEmpty
        ? 'Inform Typing & Photo Copy'
        : widget.customerNameEn;

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
        const double headerCardWidth = 176;
        const double headerCardHeight = 124;
        Widget buildHeaderBrandCard() {
          return Container(
            width: headerCardWidth,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: tone(cfg.sidebarColor).withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x265AA8FF)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: tone(cfg.buttonBgColor),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'EN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'INFORM TYPING',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 11,
                    letterSpacing: 1.9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _t('إنفورم للطباعة والتصوير', 'Inform Typing & Photo Copy'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFB8D2EA),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          );
        }
        Widget buildCenteredCustomerCard() {
          return Container(
            width: headerCardWidth,
            height: headerCardHeight,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: tone(cfg.tableHeaderColor).withOpacity(0.92),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x334AA3FF)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _t('رقم العميل: ${widget.customerId}', 'Customer ID: ${widget.customerId}'),
                  style: const TextStyle(
                    color: Color(0xFFE2ECFA),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        Widget buildHeaderMainNavButtons() {
          return SizedBox(
            width: 500,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _ActionBtn(
                  icon: Icons.receipt_long_outlined,
                  text: _t('الفواتير', 'Invoices'),
                  color: tone(cfg.buttonBgColor),
                  hover: tone(cfg.buttonBgColor),
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
                _ActionBtn(
                  icon: Icons.bar_chart_outlined,
                  text: _t('التقارير', 'Reports'),
                  color: tone(cfg.buttonBgColor),
                  hover: tone(cfg.buttonBgColor),
                  onPressed: () =>
                      _showMsg(_t('التقارير قيد التطوير', 'Reports feature is coming soon')),
                ),
                _ActionBtn(
                  icon: Icons.auto_awesome_outlined,
                  text: _t('نيو ثيم', 'New Theme'),
                  color: tone(cfg.buttonBgColor),
                  hover: tone(cfg.buttonBgColor),
                  onPressed: _previewNewTheme,
                ),
                _ActionBtn(
                  icon: Icons.settings_outlined,
                  text: _t('إدارة التصميم', 'Design Manager'),
                  color: tone(cfg.buttonBgColor),
                  hover: tone(cfg.buttonBgColor),
                  onPressed: _openDesignSettings,
                ),
                _ActionBtn(
                  icon: Icons.logout,
                  text: _t('تسجيل الخروج', 'Sign Out'),
                  color: const Color(0xFFB91C1C),
                  hover: const Color(0xFFB91C1C),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        }
        Widget buildHeaderLanguageButtons() {
          final active = tone(cfg.buttonBgColor);
          final inactive = tone(cfg.tableHeaderColor);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionBtn(
                icon: Icons.language,
                text: 'AR',
                color: _isArabic ? active : inactive,
                hover: active,
                onPressed: () => setState(() => _isArabic = true),
              ),
              const SizedBox(width: 6),
              _ActionBtn(
                icon: Icons.language,
                text: 'EN',
                color: _isArabic ? inactive : active,
                hover: active,
                onPressed: () => setState(() => _isArabic = false),
              ),
            ],
          );
        }
        return Scaffold(
          body: Column(
            children: [
              Container(
                height: 48,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: tone(cfg.sidebarColor),
                child: Row(
                  textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    const Text(
                      'INFORM PROJECT EXE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    buildHeaderLanguageButtons(),
                  ],
                ),
              ),
              Expanded(
                child: Row(
        textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: SizedBox(
              width: 320,
              child: Container(
                color: tone(cfg.sidebarColor),
                child: Column(
                  children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 24,
                              decoration: BoxDecoration(
                                color: tone(cfg.buttonBgColor),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _t('قائمة العملاء', 'Customer List'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.person_add_alt_1,
                                text: _t('إضافة', 'Add'),
                                color: const Color(0xFF15803D),
                                hover: const Color(0xFF15803D),
                                onPressed: _openAddCustomerDialog,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.edit,
                                text: _t('تعديل', 'Edit'),
                                color: const Color(0xFF2563EB),
                                hover: const Color(0xFF2563EB),
                                onPressed: _openEditCustomerDialog,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _ActionBtn(
                                icon: Icons.delete_outline,
                                text: _t('حذف', 'Delete'),
                                color: const Color(0xFFDC2626),
                                hover: const Color(0xFFDC2626),
                                onPressed: _openDeleteCustomerDialog,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0x2FFFFFFF)),
                      Expanded(
                        child: _isCustomersLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                                itemCount: _customers.length,
                                itemBuilder: (context, index) {
                                  final customer = _customers[index];
                                  final customerName =
                                      _isArabic ? customer.name : customer.nameEn;
                                  final selected = _selectedCustomerIds.contains(customer.id) ||
                                      customer.id == widget.customerId;

                                  // ── customer card config values ──────────
                                  final cardBgBase  = cfg.customerCardBgColor;
                                  final cardText    = cfg.customerCardTextColor;
                                  final cardBorder  = cfg.customerCardBorderColor;
                                  final cardRadius  = cfg.customerCardBorderRadius;
                                  final cardFontSz  = cfg.customerCardFontSize;
                                  final cardFamily  = cfg.customerCardFontFamily;
                                  final cardBdrW    = cfg.customerCardBorderWidth;
                                  final cardShadow  = cfg.customerCardShadowBlur;
                                  final cardStyle   = cfg.customerCardStyle;

                                  final resolvedBg = selected
                                      ? Color.alphaBlend(const Color(0x3360A5FA), cardBgBase)
                                      : cardBgBase;
                                  final resolvedBorder = selected
                                      ? const Color(0xFF60A5FA)
                                      : cardBorder;
                                  final subTextColor = Color.alphaBlend(
                                      const Color(0x88FFFFFF), cardText);

                                  BoxDecoration cardDeco;
                                  switch (cardStyle) {
                                    case 1: // Elevated
                                      cardDeco = BoxDecoration(
                                        color: resolvedBg,
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        border: Border.all(color: resolvedBorder, width: cardBdrW),
                                        boxShadow: [BoxShadow(color: cardBgBase.withOpacity(0.35), blurRadius: cardShadow == 0 ? 8 : cardShadow, offset: const Offset(0, 3))],
                                      );
                                    case 2: // Bordered
                                      cardDeco = BoxDecoration(
                                        color: resolvedBg,
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        border: Border.all(color: resolvedBorder, width: cardBdrW == 0 ? 1.5 : cardBdrW * 1.5),
                                        boxShadow: cardShadow > 0 ? [BoxShadow(color: cardBgBase.withOpacity(0.2), blurRadius: cardShadow)] : null,
                                      );
                                    case 3: // Glass
                                      cardDeco = BoxDecoration(
                                        color: resolvedBg.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        border: Border.all(color: resolvedBorder.withOpacity(0.5), width: cardBdrW),
                                        boxShadow: cardShadow > 0 ? [BoxShadow(color: cardBgBase.withOpacity(0.15), blurRadius: cardShadow)] : null,
                                      );
                                    default: // 0: Flat
                                      cardDeco = BoxDecoration(
                                        color: resolvedBg,
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        border: Border.all(color: resolvedBorder, width: cardBdrW),
                                        boxShadow: cardShadow > 0 ? [BoxShadow(color: cardBgBase.withOpacity(0.2), blurRadius: cardShadow)] : null,
                                      );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(cardRadius),
                                      onTap: () => _openCustomerTransactions(customer),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                                        decoration: cardDeco,
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: _selectedCustomerIds.contains(customer.id),
                                              onChanged: (_) =>
                                                  _toggleCustomerSelection(customer.id),
                                              side: BorderSide(color: subTextColor, width: 1.4),
                                              activeColor: const Color(0xFF2563EB),
                                              visualDensity:
                                                  const VisualDensity(horizontal: -4, vertical: -4),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    customerName,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: cardText,
                                                      fontSize: cardFontSz,
                                                      fontWeight: FontWeight.w700,
                                                      fontFamily: cardFamily,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'ID: ${customer.id}',
                                                    style: TextStyle(
                                                      color: subTextColor,
                                                      fontSize: (cardFontSz - 2).clamp(8, 18),
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: cardFamily,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: subTextColor,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: tone(cfg.tableAreaColor),
              child: Column(
                children: [
                  Material(
                    color: tone(cfg.tableAreaColor),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF2563EB), width: 1.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 10,
                              top: 10,
                              child: buildHeaderMainNavButtons(),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!_isArabic) ...[
                                  buildHeaderBrandCard(),
                                  const SizedBox(width: 14),
                                ],
                                Container(
                                  width: 4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: tone(cfg.buttonBgColor),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(child: SizedBox()),
                                if (_isArabic) ...[
                                  const SizedBox(width: 14),
                                  buildHeaderBrandCard(),
                                ],
                              ],
                            ),
                            IgnorePointer(child: buildCenteredCustomerCard()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: _isArabic
                          ? Row(
                              textDirection: TextDirection.ltr,
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _ActionBtn(
                                        icon: Icons.download_for_offline_outlined,
                                        text: _t('تحميل المرفقات', 'Download Attachments'),
                                        color: tone(cfg.buttonBgColor),
                                        hover: tone(cfg.buttonBgColor),
                                        onPressed: _downloadSelectedAttachments,
                                      ),
                                      _ActionBtn(
                                        icon: Icons.delete_sweep_outlined,
                                        text: _t('حذف المرفقات', 'Delete Attachments'),
                                        color: const Color(0xFF991B1B),
                                        hover: const Color(0xFF991B1B),
                                        onPressed: _deleteSelectedAttachments,
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
                                ),
                                const SizedBox(width: 8),
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
                                  ],
                                ),
                              ],
                            )
                          : Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Wrap(
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
                                    label:
                                        Text(_t('حذف معاملة', 'Delete Transaction')),
                                    style: OutlinedButton.styleFrom(
                                      side:
                                          const BorderSide(color: Color(0x4DEF4444)),
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
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (hasSelectedCustomer)
                    Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: tone(cfg.tableHeaderColor),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(12)),
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
                      decoration: BoxDecoration(color: tone(cfg.tableAreaColor)),
                      child: !hasSelectedCustomer
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    officeNameAr,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    officeNameEn,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFD8EBFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : data.isEmpty
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
                          padding: const EdgeInsets.only(top: 18, bottom: 8),
                          itemCount: data.length,
                          itemBuilder: (context, txIndex) {
                          final tx = data[txIndex];
                          final isSelected =
                              _selectedInvoices.contains(tx.invoiceNumber);
                          final isDelivered = tx.status == 'تم التسليم';
                          final cardBg = tone(cfg.transactionCardColor);
                          final rowBgA = _design.shiftColor(cardBg, 0.03);
                          final rowBgB = _design.shiftColor(cardBg, -0.03);

                          return Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: cardBg,
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
                                                  ? rowBgA
                                                  : rowBgB,
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

class _ButtonVisual {
  const _ButtonVisual({
    required this.color,
    required this.gradient,
    required this.shadows,
  });

  final Color? color;
  final Gradient? gradient;
  final List<BoxShadow> shadows;
}

_ButtonVisual _resolveButtonVisual(AppDesignConfig cfg, Color base) {
  final controller = DesignController.instance;
  final shine = cfg.buttonShine.clamp(0.0, 1.0);
  final blur = cfg.buttonShadowBlur.clamp(0.0, 30.0);
  final shadowOpacity = cfg.buttonShadowOpacity.clamp(0.0, 0.8);
  final dark = controller.shiftColor(base, -0.12);
  final light = controller.shiftColor(base, 0.12);
  final shadow = BoxShadow(
    color: base.withOpacity(shadowOpacity),
    blurRadius: blur,
    offset: Offset(0, (2 + blur / 10).clamp(2, 6)),
  );

  return switch (cfg.buttonPresetStyle) {
    1 => _ButtonVisual(
        color: null,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ),
        shadows: [shadow],
      ),
    2 => _ButtonVisual(
        color: null,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.alphaBlend(Colors.white.withOpacity(0.20 + (shine * 0.22)), base),
            Color.alphaBlend(Colors.white.withOpacity(0.02 + (shine * 0.06)), dark),
          ],
        ),
        shadows: [
          shadow,
          BoxShadow(
            color: Colors.white.withOpacity(0.08 + (shine * 0.16)),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
    3 => _ButtonVisual(
        color: controller.shiftColor(base, 0.08),
        gradient: null,
        shadows: [
          BoxShadow(
            color: base.withOpacity((shadowOpacity * 0.65).clamp(0, 0.8)),
            blurRadius: (blur * 0.6).clamp(0, 30),
            offset: const Offset(0, 2),
          ),
        ],
      ),
    4 => _ButtonVisual(
        color: Color.alphaBlend(Colors.white.withOpacity(0.08), base),
        gradient: null,
        shadows: const [],
      ),
    _ => _ButtonVisual(
        color: base,
        gradient: null,
        shadows: [shadow],
      ),
  };
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
    final activeVisual = _resolveButtonVisual(cfg, activeBg);
    final activeFg = controller.onColorFor(activeBg);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? activeVisual.color : Colors.transparent,
          gradient: active ? activeVisual.gradient : null,
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(
            color: active ? cfg.buttonBorderColor : Colors.transparent,
            width: cfg.buttonBorderWidth,
          ),
          boxShadow: active ? activeVisual.shadows : const <BoxShadow>[],
        ),
        child: TextButton.icon(
          onPressed: onPressed ?? () {},
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: active ? activeFg : const Color(0xFFB0CDE4),
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
    final visual = _resolveButtonVisual(cfg, color);
    final fg = controller.hasGoodContrast(cfg.buttonTextColor, color, minRatio: 3.5)
        ? cfg.buttonTextColor
        : controller.onColorFor(color);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visual.color,
        gradient: visual.gradient,
        borderRadius: BorderRadius.circular(buttonRadius),
        border: Border.all(
          color: cfg.buttonBorderColor,
          width: cfg.buttonBorderWidth,
        ),
        boxShadow: visual.shadows,
      ),
      child: TextButton.icon(
        onPressed: onPressed ?? () {},
        icon: Icon(icon, size: 16),
        label: Text(text),
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: fg,
          minimumSize: const Size(0, 36),
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
          overlayColor:
              WidgetStatePropertyAll(hover.withOpacity(0.12 + (cfg.buttonShine * 0.22))),
        ),
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
