import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../logic/home_logic.dart';
import 'customer_transactions_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialArabic = true});

  final bool initialArabic;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDatabase _db = AppDatabase.instance;
  final List<Customer> _customers = <Customer>[];
  final Set<int> _selectedIds = <int>{};
  late bool _isArabic;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.initialArabic;
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final rows = await _db.getCustomers();
    if (!mounted) return;
    setState(() {
      _customers
        ..clear()
        ..addAll(rows);
      _selectedIds.removeWhere((id) => !_customers.any((c) => c.id == id));
      _isLoading = false;
    });
  }

  void _toggleCustomer(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });
  }

  String _t(String ar, String en) => _isArabic ? ar : en;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
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
                decoration: InputDecoration(
                  labelText: _t('اسم العميل', 'Customer Name'),
                ),
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
                final rawId = idController.text.trim();
                final parsedId = int.tryParse(rawId);

                if (rawName.isEmpty || parsedId == null) {
                  _showMessage(
                    _t('يرجى إدخال اسم صحيح و ID رقمي', 'Please enter a valid name and numeric ID'),
                    isError: true,
                  );
                  return;
                }
                if (_customers.any((c) => c.id == parsedId)) {
                  _showMessage(
                    _t('رقم ID مستخدم مسبقاً', 'ID already exists'),
                    isError: true,
                  );
                  return;
                }

                await _db.insertCustomer(
                  Customer(
                    id: parsedId,
                    name: rawName,
                    nameEn: rawName,
                  ),
                );
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showMessage(_t('تمت إضافة العميل بنجاح', 'Customer added successfully'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _openEditCustomerDialog() {
    if (_selectedIds.isEmpty) {
      _showMessage(_t('حدد عميل أولاً للتعديل', 'Select a customer first to edit'), isError: true);
      return;
    }
    if (_selectedIds.length > 1) {
      _showMessage(
        _t('يمكن تعديل عميل واحد فقط في كل مرة', 'You can edit only one customer at a time'),
        isError: true,
      );
      return;
    }

    final selectedId = _selectedIds.first;
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
                decoration: InputDecoration(
                  labelText: _t('اسم العميل', 'Customer Name'),
                ),
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
                final rawId = idController.text.trim();
                final parsedId = int.tryParse(rawId);

                if (rawName.isEmpty || parsedId == null) {
                  _showMessage(
                    _t('يرجى إدخال اسم صحيح و ID رقمي', 'Please enter a valid name and numeric ID'),
                    isError: true,
                  );
                  return;
                }
                final duplicated = _customers.any(
                  (c) => c.id == parsedId && c.id != target.id,
                );
                if (duplicated) {
                  _showMessage(
                    _t('رقم ID مستخدم مسبقاً', 'ID already exists'),
                    isError: true,
                  );
                  return;
                }

                await _db.updateCustomer(
                  target.id,
                  Customer(
                    id: parsedId,
                    name: rawName,
                    nameEn: rawName,
                  ),
                );
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                setState(() {
                  _selectedIds
                    ..clear()
                    ..add(parsedId);
                });
                Navigator.of(dialogContext).pop();
                _showMessage(_t('تم حفظ التعديل', 'Changes saved'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  void _openDeleteCustomerDialog() {
    if (_selectedIds.isEmpty) {
      _showMessage(_t('حدد عميل أولاً للحذف', 'Select a customer first to delete'), isError: true);
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
              Text(
                _t(
                  'هل أنت متأكد من حذف العميل المحدد؟',
                  'Are you sure you want to delete the selected customer?',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _t('للتأكيد أدخل كود الحذف 1234', 'To confirm, enter delete code 1234'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _t('كود التأكيد', 'Confirmation Code'),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: () async {
                if (codeController.text.trim() != '1234') {
                  _showMessage(_t('كود التأكيد غير صحيح', 'Invalid confirmation code'), isError: true);
                  return;
                }
                await _db.deleteCustomers(_selectedIds.toList());
                await _loadCustomers();
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                _showMessage(_t('تم حذف العميل بنجاح', 'Customer deleted successfully'));
              },
              child: Text(_t('حفظ', 'Save')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 12,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x332563EB),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.groups,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _t('إدارة العملاء', 'Customer Management'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_customers.length} ${_t('عميل', 'Customers')}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeaderButton(
                        color: const Color(0xFF16A34A),
                        hoverColor: const Color(0xFF15803D),
                        icon: Icons.person_add_alt_1,
                        text: _t('إضافة عميل', 'Add Customer'),
                        onPressed: _openAddCustomerDialog,
                      ),
                      _HeaderButton(
                        color: const Color(0xFF2563EB),
                        hoverColor: const Color(0xFF1D4ED8),
                        icon: Icons.edit,
                        text: _t('تعديل عميل', 'Edit Customer'),
                        onPressed: _openEditCustomerDialog,
                      ),
                      OutlinedButton.icon(
                        onPressed: _openDeleteCustomerDialog,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(_t('حذف عميل', 'Delete Customer')),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0x4DEF4444)),
                          foregroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      Container(
                          width: 1, height: 24, color: const Color(0xFFE2E8F0)),
                      OutlinedButton.icon(
                        onPressed: _toggleLanguage,
                        icon: const Icon(Icons.language, size: 15),
                        label: Text(_isArabic ? 'EN' : 'عربي'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xFFF8FAFC),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                      _HeaderButton(
                        color: const Color(0xFF2B6CB0),
                        hoverColor: const Color(0xFF1E5A8A),
                        icon: Icons.logout,
                        text: _t('تسجيل الخروج', 'Sign Out'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _CentralBanner(
                text:
                    _t('INFORM TYPING PHOTO COPY', 'INFORM TYPING PHOTO COPY')),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _t('قائمة العملاء', 'Customer List'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                              itemCount: _customers.length,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 220,
                                childAspectRatio: 0.95,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemBuilder: (context, index) {
                                final customer = _customers[index];
                                final isSelected =
                                    _selectedIds.contains(customer.id);

                                return _CustomerCard(
                                  customer: customer,
                                  isSelected: isSelected,
                                  name: _isArabic
                                      ? customer.name
                                      : customer.nameEn,
                                  onToggle: () => _toggleCustomer(customer.id),
                                  onOpen: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CustomerTransactionsPage(
                                          initialArabic: _isArabic,
                                          customerNameAr: customer.name,
                                          customerNameEn: customer.nameEn,
                                          customerId: customer.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
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
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.color,
    required this.hoverColor,
    required this.icon,
    required this.text,
    this.onPressed,
  });

  final Color color;
  final Color hoverColor;
  final IconData icon;
  final String text;
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
        overlayColor: WidgetStatePropertyAll(
          Color.fromARGB(0x1A, hoverColor.red, hoverColor.green, hoverColor.blue),
        ),
      ),
    );
  }
}

class _CentralBanner extends StatelessWidget {
  const _CentralBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF1E5A8A), Color(0xFF2B6CB0), Color(0xFF2563EB)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: <Color>[Color(0xFF2B6CB0), Color(0xFF2563EB)],
                  radius: 0.7,
                  center: Alignment.center,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _PrinterBadge(),
              const SizedBox(width: 34),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Color(0x4D000000), blurRadius: 6),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 34),
              const _PrinterBadge(),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrinterBadge extends StatelessWidget {
  const _PrinterBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child:
            const Icon(Icons.print_rounded, color: Color(0xE6FFFFFF), size: 32),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.customer,
    required this.name,
    required this.isSelected,
    required this.onToggle,
    required this.onOpen,
  });

  final Customer customer;
  final String name;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? const Color(0x262563EB) : const Color(0x140F172A),
              blurRadius: isSelected ? 18 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (_) => onToggle(),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    activeColor: const Color(0xFF2563EB),
                  ),
                  const Spacer(),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x402563EB),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      name.characters.first,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 18),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
              child: Column(
                children: [
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID: ${customer.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
