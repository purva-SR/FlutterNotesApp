import 'dart:ffi';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  DBHelper._();
  static final DBHelper getInstance = DBHelper._();

  static final String TABLE_NOTE = "note";
  static final String TABLE_COLUMN_SNO = "s_no";
  static final String TABLE_COLUMN_TITLE = "title";
  static final String TABLE_COLUMN_DESC = "desc";


  Database? myDB;

  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {

    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "notes.db");

    return await openDatabase(dbPath, onCreate: (db, version) {
      db.execute("create table $TABLE_NOTE ($TABLE_COLUMN_SNO integer primary key autoincrement, $TABLE_COLUMN_TITLE text, $TABLE_COLUMN_DESC text)");

    }, version: 1);

  }


  Future<bool> addNote({required String title, required String desc}) async {
    var db = await getDB();

    int rowsEffected = await db.insert(TABLE_NOTE, {TABLE_COLUMN_TITLE: title, TABLE_COLUMN_DESC: desc});
    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;

  }

  Future<bool> updateNote({required String title, required String desc, required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db.update(TABLE_NOTE, {
      TABLE_COLUMN_TITLE: title,
      TABLE_COLUMN_DESC: desc
    }, where: "$TABLE_COLUMN_SNO = $sno");
    return rowsEffected > 0;
  }

  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db.delete(TABLE_NOTE, where: "$TABLE_COLUMN_SNO = ?", whereArgs: [sno]);
    return rowsEffected > 0;

  }
}