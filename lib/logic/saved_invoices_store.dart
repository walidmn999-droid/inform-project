import 'customer_transactions_logic.dart';

class SavedInvoiceEntry {
  const SavedInvoiceEntry({
    required this.customerNameAr,
    required this.customerNameEn,
    required this.customerId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.grandTotal,
    required this.transactions,
    required this.savedAt,
  });

  final String customerNameAr;
  final String customerNameEn;
  final int customerId;
  final String invoiceNumber;
  final String invoiceDate;
  final double grandTotal;
  final List<CustomerTransaction> transactions;
  final DateTime savedAt;
}

class SavedInvoicesStore {
  SavedInvoicesStore._();

  static final SavedInvoicesStore instance = SavedInvoicesStore._();

  final List<SavedInvoiceEntry> _items = <SavedInvoiceEntry>[];

  List<SavedInvoiceEntry> get items => List<SavedInvoiceEntry>.unmodifiable(_items);

  void add(SavedInvoiceEntry entry) {
    _items.insert(0, entry);
  }
}
