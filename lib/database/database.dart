import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final cardTABLE = 'Card';
final userTABLE = 'User';
final logTABLE = 'Log';
final companyTABLE = 'Company';
final typeTABLE = 'Type';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ReactiveCard.db");

    var database = await openDatabase(path,
        version: 1, onCreate: initDB, onUpgrade: onUpgrade);
    return database;
  }

  //This is optional, and only used for changing DB schema migrations
  void onUpgrade(Database database, int oldVersion, int newVersion) {
    if (newVersion > oldVersion) {}
  }

  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $cardTABLE ("
        "id INTEGER PRIMARY KEY autoincrement,"
        "cardNumber TEXT NOT NULL, "
        "typeId INTEGER NOT NULL "
        ")");
    await database.execute("CREATE TABLE IF NOT EXISTS $userTABLE "
        "(id integer NOT NULL primary key autoincrement ,"
        "name TEXT NOT NULL ,"
        "number TEXT NOT NULL ,"
        "balance REAL NOT NULL DEFAULT '0')");
    await database.execute("CREATE TABLE IF NOT EXISTS $companyTABLE ("
        "id integer NOT NULL primary key autoincrement,"
        "name TEXT NOT NULL)");
    await database.execute("CREATE TABLE IF NOT EXISTS $Type"
        "(id integer NOT NULL primary key autoincrement,"
        "brandPrice REAL NOT NULL,"
        "price REAL NOT NULL,"
        "companyId integer NOT NULL)");
    await database.execute("CREATE TABLE IF NOT EXISTS $logTABLE"
        "(id integer NOT NULL primary key autoincrement,"
        "userId integer NOT NULL ,"
        "amount REAL NOT NULL ,"
        "label TEXT NOT NULL,"
        "date INTEGER NOT NULL)");
  }
}
