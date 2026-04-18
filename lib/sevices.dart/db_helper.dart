import 'package:path/path.dart';
import 'package:personal_budget_tracker/model/savinggoalmodel.dart';
import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'budget.db');

    return openDatabase(
      path,
      version: 2,
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

        await db.execute('''
          CREATE TABLE saving_goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            targetAmount REAL,
            savedAmount REAL,
            createdAt TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS saving_goals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              targetAmount REAL,
              savedAmount REAL,
              createdAt TEXT
            )
          ''');
        }
      },
    );
  }

  Future<int> insert(TransactionModel tx) async {
    final dbClient = await db;
    return dbClient.insert('transactions', tx.toMap());
  }

  Future<List<TransactionModel>> getTransactions() async {
    final dbClient = await db;
    final res = await dbClient.query('transactions');

    return res.map((e) => TransactionModel.fromMap(e)).toList();
  }

  Future<int> insertGoal(SavingGoal goal) async {
    final dbClient = await db;
    return dbClient.insert('saving_goals', goal.toMap());
  }

  Future<List<SavingGoal>> getGoals() async {
    final dbClient = await db;
    final data = await dbClient.query('saving_goals', orderBy: 'id DESC');
    return data.map((e) => SavingGoal.fromMap(e)).toList();
  }

  Future<int> updateGoal(SavingGoal goal) async {
    final dbClient = await db;
    return dbClient.update(
      'saving_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }
}
