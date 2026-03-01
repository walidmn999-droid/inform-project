import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../logic/home_logic.dart';
import '../ui/add_transaction_page.dart';

class DbTransactionItemRecord {
  const DbTransactionItemRecord({
    required this.serviceAr,
    required this.serviceEn,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.benefit,
    required this.total,
    required this.attachmentPaths,
  });

  final String serviceAr;
  final String serviceEn;
  final int qty;
  final double unitPrice;
  final double discount;
  final double benefit;
  final double total;
  final List<String> attachmentPaths;
}

class DbTransactionRecord {
  const DbTransactionRecord({
    required this.invoiceNumber,
    required this.date,
    required this.status,
    required this.grandTotal,
    required this.company,
    required this.employee,
    required this.items,
  });

  final String invoiceNumber;
  final String date;
  final String status;
  final double grandTotal;
  final String company;
  final String employee;
  final List<DbTransactionItemRecord> items;
}

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();
  static const int _dbVersion = 2;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = p.join(r'C:\Projects', 'inform_project.db');
    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _dbVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await _createSchemaV1(db);
          await _runMigrations(db, 1, version);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          await _runMigrations(db, oldVersion, newVersion);
        },
      ),
    );
    return _db!;
  }

  Future<void> _createSchemaV1(Database db) async {
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY,
        name_ar TEXT NOT NULL,
        name_en TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        invoice_number TEXT NOT NULL,
        company TEXT NOT NULL,
        employee TEXT,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        grand_total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
        UNIQUE (customer_id, invoice_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        service_ar TEXT NOT NULL,
        service_en TEXT NOT NULL,
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        discount REAL NOT NULL,
        benefit REAL NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE item_attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES transaction_items(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _runMigrations(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 2:
          await _migrateToV2(db);
          break;
      }
    }
  }

  Future<void> _migrateToV2(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transactions_customer_status
      ON transactions(customer_id, status)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_transaction_items_transaction
      ON transaction_items(transaction_id)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_item_attachments_item
      ON item_attachments(item_id)
    ''');

    // Defensive upgrades for databases created before discount/benefit columns existed.
    if (!await _columnExists(db, 'transaction_items', 'discount')) {
      await db.execute(
        'ALTER TABLE transaction_items ADD COLUMN discount REAL NOT NULL DEFAULT 0',
      );
    }
    if (!await _columnExists(db, 'transaction_items', 'benefit')) {
      await db.execute(
        'ALTER TABLE transaction_items ADD COLUMN benefit REAL NOT NULL DEFAULT 0',
      );
    }
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final rows = await db.rawQuery('PRAGMA table_info($tableName)');
    for (final row in rows) {
      if ((row['name'] as String?) == columnName) return true;
    }
    return false;
  }

  Future<List<Customer>> getCustomers() async {
    final db = await database;
    final rows = await db.query('customers', orderBy: 'id ASC');
    return rows
        .map(
          (r) => Customer(
            id: r['id'] as int,
            name: (r['name_ar'] as String?) ?? '',
            nameEn: (r['name_en'] as String?) ?? '',
          ),
        )
        .toList();
  }

  Future<void> insertCustomer(Customer customer) async {
    final db = await database;
    await db.insert(
      'customers',
      <String, Object?>{
        'id': customer.id,
        'name_ar': customer.name,
        'name_en': customer.nameEn,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateCustomer(int oldId, Customer customer) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'customers',
        <String, Object?>{
          'id': customer.id,
          'name_ar': customer.name,
          'name_en': customer.nameEn,
        },
        where: 'id = ?',
        whereArgs: <Object?>[oldId],
      );
      if (oldId != customer.id) {
        await txn.update(
          'transactions',
          <String, Object?>{'customer_id': customer.id},
          where: 'customer_id = ?',
          whereArgs: <Object?>[oldId],
        );
      }
    });
  }

  Future<void> deleteCustomers(List<int> ids) async {
    if (ids.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    await db.delete(
      'customers',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  Future<void> saveTransaction({
    required int customerId,
    required AddTransactionResult data,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final txId = await txn.insert(
        'transactions',
        <String, Object?>{
          'customer_id': customerId,
          'invoice_number': data.invoiceNumber,
          'company': data.company,
          'employee': data.employee,
          'date': data.date,
          'status': data.status,
          'grand_total': data.grandTotal,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      for (final item in data.items) {
        final itemId = await txn.insert(
          'transaction_items',
          <String, Object?>{
            'transaction_id': txId,
            'service_ar': item.service,
            'service_en': item.service,
            'qty': item.qty,
            'unit_price': item.unitPrice,
            'discount': item.discount,
            'benefit': item.benefit,
            'total': item.total,
            'created_at': DateTime.now().toIso8601String(),
          },
        );

        for (final rawPath in item.attachments) {
          final fullPath = rawPath.trim();
          if (fullPath.isEmpty) continue;
          final fileName = p.basename(fullPath);
          await txn.insert(
            'item_attachments',
            <String, Object?>{
              'item_id': itemId,
              'file_name': fileName,
              'file_path': fullPath,
              'created_at': DateTime.now().toIso8601String(),
            },
          );
        }
      }
    });
  }

  Future<void> updateTransaction({
    required int customerId,
    required String oldInvoiceNumber,
    required AddTransactionResult data,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final txRows = await txn.query(
        'transactions',
        columns: <String>['id'],
        where: 'customer_id = ? AND invoice_number = ?',
        whereArgs: <Object?>[customerId, oldInvoiceNumber],
      );
      if (txRows.isEmpty) return;
      final txId = txRows.first['id'] as int;

      final itemRows = await txn.query(
        'transaction_items',
        columns: <String>['id'],
        where: 'transaction_id = ?',
        whereArgs: <Object?>[txId],
      );
      for (final r in itemRows) {
        final itemId = r['id'] as int;
        await txn.delete(
          'item_attachments',
          where: 'item_id = ?',
          whereArgs: <Object?>[itemId],
        );
      }
      await txn.delete(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: <Object?>[txId],
      );

      await txn.update(
        'transactions',
        <String, Object?>{
          'invoice_number': data.invoiceNumber,
          'company': data.company,
          'employee': data.employee,
          'date': data.date,
          'status': data.status,
          'grand_total': data.grandTotal,
        },
        where: 'id = ?',
        whereArgs: <Object?>[txId],
      );

      for (final item in data.items) {
        final itemId = await txn.insert(
          'transaction_items',
          <String, Object?>{
            'transaction_id': txId,
            'service_ar': item.service,
            'service_en': item.service,
            'qty': item.qty,
            'unit_price': item.unitPrice,
            'discount': item.discount,
            'benefit': item.benefit,
            'total': item.total,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
        for (final rawPath in item.attachments) {
          final fullPath = rawPath.trim();
          if (fullPath.isEmpty) continue;
          await txn.insert(
            'item_attachments',
            <String, Object?>{
              'item_id': itemId,
              'file_name': p.basename(fullPath),
              'file_path': fullPath,
              'created_at': DateTime.now().toIso8601String(),
            },
          );
        }
      }
    });
  }

  Future<void> deleteTransactions({
    required int customerId,
    required List<String> invoiceNumbers,
  }) async {
    if (invoiceNumbers.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(invoiceNumbers.length, '?').join(',');
    await db.delete(
      'transactions',
      where: 'customer_id = ? AND invoice_number IN ($placeholders)',
      whereArgs: <Object?>[customerId, ...invoiceNumbers],
    );
  }

  Future<void> updateTransactionsStatus({
    required int customerId,
    required List<String> invoiceNumbers,
    required String status,
  }) async {
    if (invoiceNumbers.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(invoiceNumbers.length, '?').join(',');
    await db.update(
      'transactions',
      <String, Object?>{'status': status},
      where: 'customer_id = ? AND invoice_number IN ($placeholders)',
      whereArgs: <Object?>[customerId, ...invoiceNumbers],
    );
  }

  Future<List<DbTransactionRecord>> getTransactionsForCustomer(int customerId) async {
    final db = await database;
    final txRows = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: <Object?>[customerId],
      orderBy: 'id DESC',
    );

    final List<DbTransactionRecord> out = <DbTransactionRecord>[];
    for (final tx in txRows) {
      final txId = tx['id'] as int;
      final itemRows = await db.query(
        'transaction_items',
        where: 'transaction_id = ?',
        whereArgs: <Object?>[txId],
        orderBy: 'id ASC',
      );

      final List<DbTransactionItemRecord> items = <DbTransactionItemRecord>[];
      for (final item in itemRows) {
        final itemId = item['id'] as int;
        final attachmentRows = await db.query(
          'item_attachments',
          where: 'item_id = ?',
          whereArgs: <Object?>[itemId],
          orderBy: 'id ASC',
        );
        items.add(
          DbTransactionItemRecord(
            serviceAr: (item['service_ar'] as String?) ?? '',
            serviceEn: (item['service_en'] as String?) ?? '',
            qty: (item['qty'] as int?) ?? 0,
            unitPrice: ((item['unit_price'] as num?) ?? 0).toDouble(),
            discount: ((item['discount'] as num?) ?? 0).toDouble(),
            benefit: ((item['benefit'] as num?) ?? 0).toDouble(),
            total: ((item['total'] as num?) ?? 0).toDouble(),
            attachmentPaths: attachmentRows
                .map((r) => (r['file_path'] as String?) ?? '')
                .where((e) => e.isNotEmpty)
                .toList(),
          ),
        );
      }

      out.add(
        DbTransactionRecord(
          invoiceNumber: (tx['invoice_number'] as String?) ?? '',
          date: (tx['date'] as String?) ?? '',
          status: (tx['status'] as String?) ?? 'معلق',
          grandTotal: ((tx['grand_total'] as num?) ?? 0).toDouble(),
          company: (tx['company'] as String?) ?? '',
          employee: (tx['employee'] as String?) ?? '',
          items: items,
        ),
      );
    }
    return out;
  }
}
