class AddTransactionLogic {
  const AddTransactionLogic();

  static const List<String> servicesAr = <String>[
    'طباعة مستندات A4',
    'تصوير ملون A3',
    'تجليد مستندات',
    'تصميم شعار',
    'طباعة بروشورات',
  ];

  static const List<String> servicesEn = <String>[
    'A4 Document Printing',
    'A3 Color Copy',
    'Document Binding',
    'Logo Design',
    'Brochure Printing',
  ];

  static const List<String> companiesAr = <String>[
    'شركة النور للتجارة',
    'مؤسسة الخليج',
    'شركة الأمل العقارية',
    'بنك الاتحاد الوطني',
  ];

  static const List<String> companiesEn = <String>[
    'Al Noor Trading Co.',
    'Gulf Foundation',
    'Al Amal Real Estate',
    'National Union Bank',
  ];

  static const List<String> employeesAr = <String>[
    'أحمد محمد',
    'فاطمة علي',
    'خالد إبراهيم',
    'نورة سالم',
  ];

  static const List<String> employeesEn = <String>[
    'Ahmed Mohammed',
    'Fatima Ali',
    'Khaled Ibrahim',
    'Noura Salem',
  ];

  double calcTotal({required int qty, required double unitPrice}) {
    return qty * unitPrice;
  }
}
