class TransactionItem {
  const TransactionItem({
    required this.serviceAr,
    required this.serviceEn,
    required this.qty,
    required this.unitPrice,
    required this.total,
    required this.companyAr,
    required this.companyEn,
    required this.employeeAr,
    required this.employeeEn,
    required this.hasAttachment,
  });

  final String serviceAr;
  final String serviceEn;
  final int qty;
  final double unitPrice;
  final double total;
  final String companyAr;
  final String companyEn;
  final String employeeAr;
  final String employeeEn;
  final bool hasAttachment;
}

class CustomerTransaction {
  const CustomerTransaction({
    required this.invoiceNumber,
    required this.date,
    required this.status,
    required this.grandTotal,
    required this.items,
  });

  final String invoiceNumber;
  final String date;
  final String status;
  final double grandTotal;
  final List<TransactionItem> items;
}

class CustomerTransactionsLogic {
  final List<CustomerTransaction> transactions = const <CustomerTransaction>[
    CustomerTransaction(
      invoiceNumber: 'INV-2024-001',
      date: '2024-12-15',
      status: 'مكتمل',
      grandTotal: 1850,
      items: <TransactionItem>[
        TransactionItem(
          serviceAr: 'طباعة مستندات A4',
          serviceEn: 'A4 Document Printing',
          qty: 500,
          unitPrice: 1,
          total: 500,
          companyAr: 'شركة النور للتجارة',
          companyEn: 'Al Noor Trading Co.',
          employeeAr: 'أحمد محمد',
          employeeEn: 'Ahmed Mohammed',
          hasAttachment: true,
        ),
        TransactionItem(
          serviceAr: 'تصوير ملون A3',
          serviceEn: 'A3 Color Copy',
          qty: 200,
          unitPrice: 3,
          total: 600,
          companyAr: 'شركة النور للتجارة',
          companyEn: 'Al Noor Trading Co.',
          employeeAr: 'أحمد محمد',
          employeeEn: 'Ahmed Mohammed',
          hasAttachment: false,
        ),
        TransactionItem(
          serviceAr: 'تجليد مستندات',
          serviceEn: 'Document Binding',
          qty: 50,
          unitPrice: 15,
          total: 750,
          companyAr: 'شركة النور للتجارة',
          companyEn: 'Al Noor Trading Co.',
          employeeAr: 'فاطمة علي',
          employeeEn: 'Fatima Ali',
          hasAttachment: true,
        ),
      ],
    ),
    CustomerTransaction(
      invoiceNumber: 'INV-2024-002',
      date: '2024-12-18',
      status: 'قيد التنفيذ',
      grandTotal: 3200,
      items: <TransactionItem>[
        TransactionItem(
          serviceAr: 'طباعة بروشورات',
          serviceEn: 'Brochure Printing',
          qty: 1000,
          unitPrice: 2,
          total: 2000,
          companyAr: 'مؤسسة الخليج',
          companyEn: 'Gulf Foundation',
          employeeAr: 'خالد إبراهيم',
          employeeEn: 'Khaled Ibrahim',
          hasAttachment: true,
        ),
        TransactionItem(
          serviceAr: 'تصميم شعار',
          serviceEn: 'Logo Design',
          qty: 1,
          unitPrice: 500,
          total: 500,
          companyAr: 'مؤسسة الخليج',
          companyEn: 'Gulf Foundation',
          employeeAr: 'نورة سالم',
          employeeEn: 'Noura Salem',
          hasAttachment: false,
        ),
        TransactionItem(
          serviceAr: 'طباعة كروت شخصية',
          serviceEn: 'Business Card Printing',
          qty: 200,
          unitPrice: 3.5,
          total: 700,
          companyAr: 'مؤسسة الخليج',
          companyEn: 'Gulf Foundation',
          employeeAr: 'خالد إبراهيم',
          employeeEn: 'Khaled Ibrahim',
          hasAttachment: true,
        ),
      ],
    ),
    CustomerTransaction(
      invoiceNumber: 'INV-2024-003',
      date: '2024-12-20',
      status: 'ملغي',
      grandTotal: 450,
      items: <TransactionItem>[
        TransactionItem(
          serviceAr: 'تصوير مستندات',
          serviceEn: 'Document Copying',
          qty: 150,
          unitPrice: 1.5,
          total: 225,
          companyAr: 'شركة الأمل العقارية',
          companyEn: 'Al Amal Real Estate',
          employeeAr: 'ياسر عمر',
          employeeEn: 'Yasser Omar',
          hasAttachment: false,
        ),
        TransactionItem(
          serviceAr: 'لمينيشن A4',
          serviceEn: 'A4 Lamination',
          qty: 50,
          unitPrice: 4.5,
          total: 225,
          companyAr: 'شركة الأمل العقارية',
          companyEn: 'Al Amal Real Estate',
          employeeAr: 'ياسر عمر',
          employeeEn: 'Yasser Omar',
          hasAttachment: false,
        ),
      ],
    ),
  ];
}
