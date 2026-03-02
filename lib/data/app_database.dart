import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../logic/home_logic.dart';
import '../ui/add_transaction_page.dart';

class DbAttachmentRecord {
  const DbAttachmentRecord({
    required this.id,
    required this.fileName,
    required this.filePath,
  });

  final int id;
  final String fileName;
  final String filePath;
}

class DbTransactionItemRecord {
  const DbTransactionItemRecord({
    required this.serviceAr,
    required this.serviceEn,
    required this.qty,
    required this.unitPrice,
    required this.discount,
    required this.benefit,
    required this.total,
    required this.attachments,
  });

  final String serviceAr;
  final String serviceEn;
  final int qty;
  final double unitPrice;
  final double discount;
  final double benefit;
  final double total;
  final List<DbAttachmentRecord> attachments;
  List<String> get attachmentPaths =>
      attachments.map((a) => a.filePath).toList(growable: false);
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
  static const String _attachmentsRoot =
      r'C:\Projects\inform-project-exe\attachments';

  Database? _db;

  Future<Directory> _attachmentsRootDir() async {
    final dir = Directory(_attachmentsRoot);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  bool _isManagedAttachmentPath(String filePath) {
    final normalizedPath = p.normalize(filePath).toLowerCase();
    final managedRoot = p.normalize(_attachmentsRoot).toLowerCase();
    return normalizedPath.startsWith(managedRoot);
  }

  String _safeSegment(String value) {
    final out = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return out.isEmpty ? 'x' : out;
  }

  Future<String?> _prepareAttachmentPath(
    String sourcePath, {
    required int customerId,
    required String invoiceNumber,
  }) async {
    final trimmed = sourcePath.trim();
    if (trimmed.isEmpty) return null;

    final sourceFile = File(trimmed);
    if (_isManagedAttachmentPath(trimmed)) {
      return await sourceFile.exists() ? sourceFile.path : null;
    }
    if (!await sourceFile.exists()) return null;

    final rootDir = await _attachmentsRootDir();
    final originalName = p.basename(trimmed);
    final baseName = _safeSegment(p.basenameWithoutExtension(originalName));
    final ext = p.extension(originalName);
    final invoicePart = _safeSegment(invoiceNumber);
    final now = DateTime.now().microsecondsSinceEpoch;

    String candidate = p.join(
      rootDir.path,
      '${customerId}_${invoicePart}_${now}_$baseName$ext',
    );
    var suffix = 1;
    while (await File(candidate).exists()) {
      candidate = p.join(
        rootDir.path,
        '${customerId}_${invoicePart}_${now}_${baseName}_$suffix$ext',
      );
      suffix++;
    }
    await sourceFile.copy(candidate);
    return candidate;
  }

  Future<List<String>> _collectAttachmentPathsForItemIds(
    DatabaseExecutor db,
    List<int> itemIds,
  ) async {
    if (itemIds.isEmpty) return const <String>[];
    final placeholders = List.filled(itemIds.length, '?').join(',');
    final rows = await db.query(
      'item_attachments',
      columns: <String>['file_path'],
      where: 'item_id IN ($placeholders)',
      whereArgs: itemIds,
    );
    return rows
        .map((r) => (r['file_path'] as String?)?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _deleteFilesSilently(Iterable<String> paths) async {
    for (final raw in paths) {
      final path = raw.trim();
      if (path.isEmpty) continue;
      final file = File(path);
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore individual file delete failures.
      }
    }
  }

  Future<void> _migrateLegacyAttachmentsToManagedStorage(Database db) async {
    final rows = await db.query(
      'item_attachments',
      columns: <String>['id', 'file_path'],
    );
    for (final row in rows) {
      final id = row['id'] as int;
      final currentPath = (row['file_path'] as String?)?.trim() ?? '';
      if (currentPath.isEmpty || _isManagedAttachmentPath(currentPath)) {
        continue;
      }
      final migrated = await _prepareAttachmentPath(
        currentPath,
        customerId: 0,
        invoiceNumber: 'legacy',
      );
      if (migrated == null) continue;
      await db.update(
        'item_attachments',
        <String, Object?>{
          'file_name': p.basename(migrated),
          'file_path': migrated,
        },
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    }
  }

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
    await _attachmentsRootDir();
    await _migrateLegacyAttachmentsToManagedStorage(_db!);
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

      for (int itemIndex = 0; itemIndex < data.items.length; itemIndex++) {
        final item = data.items[itemIndex];
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
          final preparedPath = await _prepareAttachmentPath(
            rawPath,
            customerId: customerId,
            invoiceNumber: data.invoiceNumber,
          );
          if (preparedPath == null) continue;
          final fileName = p.basename(preparedPath);
          await txn.insert(
            'item_attachments',
            <String, Object?>{
              'item_id': itemId,
              'file_name': fileName,
              'file_path': preparedPath,
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
      final oldItemIds = itemRows.map((r) => r['id'] as int).toList();
      final oldAttachmentPaths =
          await _collectAttachmentPathsForItemIds(txn, oldItemIds);

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

      final newAttachmentPaths = <String>{};
      for (int itemIndex = 0; itemIndex < data.items.length; itemIndex++) {
        final item = data.items[itemIndex];
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
          final preparedPath = await _prepareAttachmentPath(
            rawPath,
            customerId: customerId,
            invoiceNumber: data.invoiceNumber,
          );
          if (preparedPath == null) continue;
          newAttachmentPaths.add(preparedPath);
          await txn.insert(
            'item_attachments',
            <String, Object?>{
              'item_id': itemId,
              'file_name': p.basename(preparedPath),
              'file_path': preparedPath,
              'created_at': DateTime.now().toIso8601String(),
            },
          );
        }
      }

      final toDelete = oldAttachmentPaths
          .where((path) => !newAttachmentPaths.contains(path))
          .toList();
      await _deleteFilesSilently(toDelete);
    });
  }

  Future<void> deleteTransactions({
    required int customerId,
    required List<String> invoiceNumbers,
  }) async {
    if (invoiceNumbers.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(invoiceNumbers.length, '?').join(',');
    final txRows = await db.query(
      'transactions',
      columns: <String>['id'],
      where: 'customer_id = ? AND invoice_number IN ($placeholders)',
      whereArgs: <Object?>[customerId, ...invoiceNumbers],
    );
    final txIds = txRows.map((r) => r['id'] as int).toList();
    List<String> attachmentPaths = const <String>[];
    if (txIds.isNotEmpty) {
      final txPlaceholders = List.filled(txIds.length, '?').join(',');
      final itemRows = await db.query(
        'transaction_items',
        columns: <String>['id'],
        where: 'transaction_id IN ($txPlaceholders)',
        whereArgs: txIds,
      );
      final itemIds = itemRows.map((r) => r['id'] as int).toList();
      attachmentPaths = await _collectAttachmentPathsForItemIds(db, itemIds);
    }

    await db.delete(
      'transactions',
      where: 'customer_id = ? AND invoice_number IN ($placeholders)',
      whereArgs: <Object?>[customerId, ...invoiceNumbers],
    );
    await _deleteFilesSilently(attachmentPaths);
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

  Future<void> deleteAttachmentsForTransactions({
    required int customerId,
    required List<String> invoiceNumbers,
  }) async {
    if (invoiceNumbers.isEmpty) return;
    final db = await database;
    final placeholders = List.filled(invoiceNumbers.length, '?').join(',');
    final txRows = await db.query(
      'transactions',
      columns: <String>['id'],
      where: 'customer_id = ? AND invoice_number IN ($placeholders)',
      whereArgs: <Object?>[customerId, ...invoiceNumbers],
    );
    if (txRows.isEmpty) return;
    final txIds = txRows.map((r) => r['id'] as int).toList();
    final txPlaceholders = List.filled(txIds.length, '?').join(',');
    final itemRows = await db.query(
      'transaction_items',
      columns: <String>['id'],
      where: 'transaction_id IN ($txPlaceholders)',
      whereArgs: txIds,
    );
    if (itemRows.isEmpty) return;
    final itemIds = itemRows.map((r) => r['id'] as int).toList();
    final attachmentPaths = await _collectAttachmentPathsForItemIds(db, itemIds);
    final itemPlaceholders = List.filled(itemIds.length, '?').join(',');
    await db.delete(
      'item_attachments',
      where: 'item_id IN ($itemPlaceholders)',
      whereArgs: itemIds,
    );
    await _deleteFilesSilently(attachmentPaths);
  }

  Future<void> deleteAttachmentById(int attachmentId) async {
    final db = await database;
    final rows = await db.query(
      'item_attachments',
      columns: <String>['file_path'],
      where: 'id = ?',
      whereArgs: <Object?>[attachmentId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final filePath = (rows.first['file_path'] as String?)?.trim() ?? '';
    await db.delete(
      'item_attachments',
      where: 'id = ?',
      whereArgs: <Object?>[attachmentId],
    );
    await _deleteFilesSilently(<String>[filePath]);
  }

  Future<String?> getAppMetaValue(String key) async {
    final db = await database;
    final rows = await db.query(
      'app_meta',
      columns: <String>['value'],
      where: 'key = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setAppMetaValue(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_meta',
      <String, Object?>{'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
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
          columns: <String>['id', 'file_name', 'file_path'],
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
            attachments: attachmentRows
                .map(
                  (r) => DbAttachmentRecord(
                    id: (r['id'] as int?) ?? 0,
                    fileName: (r['file_name'] as String?) ?? '',
                    filePath: (r['file_path'] as String?) ?? '',
                  ),
                )
                .where((a) => a.id > 0 && a.filePath.trim().isNotEmpty)
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
