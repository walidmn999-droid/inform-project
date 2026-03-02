import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class AddTransactionResult {
  const AddTransactionResult({
    required this.invoiceNumber,
    required this.company,
    required this.employee,
    required this.date,
    required this.items,
    this.status = 'معلق',
  });

  final String invoiceNumber;
  final String company;
  final String employee;
  final String date;
  final String status;
  final List<AddTransactionItemResult> items;

  double get grandTotal =>
      items.fold<double>(0, (sum, item) => sum + item.total);

  bool get hasAttachment => items.any((item) => item.attachments.isNotEmpty);
}

class AddTransactionItemResult {
  const AddTransactionItemResult({
    required this.service,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.benefit,
    required this.total,
    required this.attachments,
  });

  final String service;
  final int qty;
  final double unitPrice;
  final double discount;
  final double benefit;
  final double total;
  final List<String> attachments;
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    required this.initialArabic,
    required this.customerNameAr,
    required this.customerNameEn,
    this.initialData,
  });

  final bool initialArabic;
  final String customerNameAr;
  final String customerNameEn;
  final AddTransactionResult? initialData;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late bool _isArabic;
  bool _isSaving = false;

  late final TextEditingController _invoiceController;
  late final TextEditingController _companyController;
  late final TextEditingController _employeeController;
  late final TextEditingController _dateController;

  final List<_ItemData> _items = <_ItemData>[];

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;

    final seed = 100 + DateTime.now().millisecond % 900;
    _invoiceController = TextEditingController(
      text: widget.initialData?.invoiceNumber ?? '$seed',
    );
    _companyController = TextEditingController(
      text: widget.initialData?.company ?? '',
    );
    _employeeController = TextEditingController(
      text: widget.initialData?.employee ?? '',
    );
    _dateController = TextEditingController(
      text: widget.initialData?.date ??
          DateTime.now().toIso8601String().split('T').first,
    );

    if (widget.initialData != null) {
      for (final item in widget.initialData!.items) {
        _items.add(_ItemData.fromResult(item));
      }
    }
    if (_items.isEmpty) {
      _items.add(_ItemData(id: DateTime.now().microsecondsSinceEpoch.toString()));
    }
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _companyController.dispose();
    _employeeController.dispose();
    _dateController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  double get _grandTotal =>
      _items.fold<double>(0, (sum, item) => sum + item.total);

  void _addItem() {
    setState(() {
      _items.add(_ItemData(id: DateTime.now().microsecondsSinceEpoch.toString()));
    });
  }

  void _removeItem(String id) {
    if (_items.length == 1) return;
    setState(() {
      final item = _items.firstWhere((element) => element.id == id);
      item.dispose();
      _items.removeWhere((element) => element.id == id);
    });
  }

  Future<void> _pickAttachments(_ItemData item) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result == null) return;

    setState(() {
      item.attachments = result.files
          .map((f) => (f.path ?? '').trim())
          .where((value) => value.isNotEmpty)
          .toList();
    });

    if (item.attachments.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'تعذر قراءة مسارات الملفات، أعد الاختيار',
              'Unable to read file paths, please reselect files',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_companyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('أدخل اسم الشركة', 'Please enter company name'))),
      );
      return;
    }
    if (_items.any((item) => item.service.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('أدخل نوع الخدمة لكل بند', 'Please enter service type for each item'),
          ),
        ),
      );
      return;
    }

    final parsedItems = _items.map((item) {
      final qty = int.tryParse(item.qty.text.trim()) ?? 0;
      final price = double.tryParse(item.unitPrice.text.trim()) ?? 0;
      final discount = double.tryParse(item.discount.text.trim()) ?? 0;
      final benefit = double.tryParse(item.benefit.text.trim()) ?? 0;
      return AddTransactionItemResult(
        service: item.service.text.trim(),
        qty: qty,
        unitPrice: price,
        discount: discount,
        benefit: benefit,
        total: item.total,
        attachments: List<String>.from(item.attachments),
      );
    }).toList();

    final payload = AddTransactionResult(
      invoiceNumber: _invoiceController.text.trim(),
      company: _companyController.text.trim(),
      employee: _employeeController.text.trim(),
      date: _dateController.text.trim(),
      items: parsedItems,
      status: widget.initialData?.status ?? 'معلق',
    );

    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final direction = _isArabic ? TextDirection.rtl : TextDirection.ltr;
    final currency = _isArabic ? 'د.إ' : 'AED';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: direction,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Text(
                  widget.initialData == null
                      ? _t('إضافة معاملة', 'Add Transaction')
                      : _t('تعديل معاملة', 'Edit Transaction'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x402563EB), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: _t('رقم الفاتورة', 'Invoice Number'),
                          controller: _invoiceController,
                          readOnly: widget.initialData != null,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _Field(
                          label: _t('الشركة', 'Company'),
                          controller: _companyController,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _Field(
                          label: _t('الموظف', 'Employee'),
                          controller: _employeeController,
                          hint: _t('اختياري', 'Optional'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _Field(
                          label: _t('التاريخ', 'Date'),
                          controller: _dateController,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            _t('بنود المعاملة', 'Transaction Items'),
                            style: const TextStyle(
                              color: Color(0xFF2B6CB0),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 16),
                            label: Text(_t('إضافة بند', 'Add Item')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2563EB),
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: _items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ItemCard(
                              index: index,
                              item: item,
                              t: _t,
                              onChanged: () => setState(() {}),
                              onAdd: _addItem,
                              onRemove: () => _removeItem(item.id),
                              disableRemove: _items.length == 1,
                              onPickAttachments: () => _pickAttachments(item),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFF2B6CB0), width: 2)),
                ),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_t('إلغاء', 'Cancel')),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_t('حفظ', 'Save')),
                    ),
                    const Spacer(),
                    Text(
                      _t('الإجمالي:', 'Total:'),
                      style: const TextStyle(
                        color: Color(0xFF2B6CB0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0x402563EB), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$currency ${_grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.index,
    required this.item,
    required this.t,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
    required this.disableRemove,
    required this.onPickAttachments,
  });

  final int index;
  final _ItemData item;
  final String Function(String ar, String en) t;
  final VoidCallback onChanged;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool disableRemove;
  final Future<void> Function() onPickAttachments;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x332563EB), width: 2),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${t('بند', 'Item')} #${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: disableRemove ? null : onRemove,
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: Text(t('حذف', 'Delete')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0x4DEF4444)),
                    minimumSize: const Size(80, 32),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Field(
                  label: t('نوع الخدمة', 'Service Type'),
                  controller: item.service,
                  hint: t('مثال: طباعة', 'e.g. Printing'),
                  onChanged: (_) => onChanged(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _NumberField(
                        label: t('العدد', 'Qty'),
                        controller: item.qty,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: t('سعر الوحدة', 'Unit Price'),
                        controller: item.unitPrice,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: t('الخصم', 'Discount'),
                        controller: item.discount,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _NumberField(
                        label: t('الفائدة', 'Benefit'),
                        controller: item.benefit,
                        onChanged: onChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ReadOnlyValue(
                        label: t('الإجمالي', 'Total'),
                        value: item.total.toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      t('المرفقات', 'Attachments'),
                      style: const TextStyle(color: Color(0xFF2B6CB0), fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onPickAttachments,
                        icon: const Icon(Icons.attach_file, size: 14),
                        label: Text(
                          item.attachments.isEmpty
                              ? t('اختيار ملفات (أي امتداد)',
                                  'Choose files (any extension)')
                              : item.attachments.map(p.basename).join(', '),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2B6CB0),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: Text(t('إضافة بند جديد', 'Add New Item')),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _Field(
      label: label,
      controller: controller,
      textAlign: TextAlign.center,
      hint: '0',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => onChanged(),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2B6CB0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.readOnly = false,
    this.textAlign,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool readOnly;
  final TextAlign? textAlign;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2B6CB0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          onChanged: onChanged,
          textAlign: textAlign ?? TextAlign.start,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemData {
  _ItemData({required this.id});

  factory _ItemData.fromResult(AddTransactionItemResult result) {
    final data = _ItemData(id: DateTime.now().microsecondsSinceEpoch.toString());
    data.service.text = result.service;
    data.qty.text = result.qty.toString();
    data.unitPrice.text = result.unitPrice.toStringAsFixed(2);
    data.discount.text = result.discount.toStringAsFixed(2);
    data.benefit.text = result.benefit.toStringAsFixed(2);
    data.attachments = List<String>.from(result.attachments);
    return data;
  }

  final String id;
  final TextEditingController service = TextEditingController();
  final TextEditingController qty = TextEditingController(text: '1');
  final TextEditingController unitPrice = TextEditingController(text: '0');
  final TextEditingController discount = TextEditingController(text: '0');
  final TextEditingController benefit = TextEditingController(text: '0');
  List<String> attachments = <String>[];

  double get total {
    final q = double.tryParse(qty.text.trim()) ?? 0;
    final u = double.tryParse(unitPrice.text.trim()) ?? 0;
    final d = double.tryParse(discount.text.trim()) ?? 0;
    final b = double.tryParse(benefit.text.trim()) ?? 0;
    final value = (q * u) - d + b;
    return value < 0 ? 0 : value;
  }

  void dispose() {
    service.dispose();
    qty.dispose();
    unitPrice.dispose();
    discount.dispose();
    benefit.dispose();
  }
}
