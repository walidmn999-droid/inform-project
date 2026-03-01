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
  static final List<Customer> _sharedCustomers = <Customer>[];
  List<Customer> get customers => _sharedCustomers;

  int get totalCustomers => customers.length;
}
