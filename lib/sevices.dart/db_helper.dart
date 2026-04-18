import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path =  join (await getDatabasesPath(), 'budget.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            amount REAL,
            type TEXT,
            category TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<int> insert(TransactionModel tx) async {
    final dbClient = await db;
    return await dbClient.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final dbClient = await db;
    final res = await dbClient.query('transactions');

    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }
}
