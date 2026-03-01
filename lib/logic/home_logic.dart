class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.nameEn,
  });

  final int id;
  final String name;
  final String nameEn;
}

class HomeLogic {
  final List<Customer> customers = const <Customer>[
    Customer(id: 1, name: 'أحمد محمد', nameEn: 'Ahmed Mohammed'),
    Customer(id: 2, name: 'فاطمة علي', nameEn: 'Fatima Ali'),
    Customer(id: 3, name: 'خالد إبراهيم', nameEn: 'Khaled Ibrahim'),
    Customer(id: 4, name: 'نورة سالم', nameEn: 'Noura Salem'),
    Customer(id: 5, name: 'عبدالله حسن', nameEn: 'Abdullah Hassan'),
    Customer(id: 6, name: 'مريم يوسف', nameEn: 'Mariam Youssef'),
    Customer(id: 7, name: 'سعود عبدالعزيز', nameEn: 'Saud Abdulaziz'),
    Customer(id: 8, name: 'هند خالد', nameEn: 'Hind Khaled'),
    Customer(id: 9, name: 'ياسر عمر', nameEn: 'Yasser Omar'),
    Customer(id: 10, name: 'ليلى أحمد', nameEn: 'Layla Ahmed'),
    Customer(id: 11, name: 'محمد سعيد', nameEn: 'Mohammed Saeed'),
  ];

  int get totalCustomers => customers.length;
}
