import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class dbHelper {
  dbHelper._(); //private constructor

  static final dbHelper getinstance = dbHelper._();

  //create database object
  Database? myDB;

  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  // db open (path -> if exists then open it else create it)
  Future<Database> getDB() async {
    myDB ??= await openDB();
    return myDB!;

    //same logic as above just difference in process
    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, "notesdb.db");
    Database myDB = await openDatabase(
      dbpath,
      onCreate: (db, version) {
        //creating tables here
        db.execute(
          "CREATE TABLE $TABLE_NOTE($COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT, $COLUMN_NOTE_TITLE TEXT, $COLUMN_NOTE_DESC TEXT)",
        );
      },
      version: 1,
    );
    return myDB;
  }

  //queries based on the operation
  //insertion
  Future<bool> addNote({required String title, required String desc}) async {
    Database db = await getDB();
    int rowsAffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc,
    });
    return rowsAffected > 0;
  }

  //reading all Data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    //because the data is in form of Map in a list and returns a Future value so the function return type should also be accordingly
    var db = await getDB();
    //select * from note
    List<Map<String, dynamic?>> mData = await db.query(TABLE_NOTE);

    return mData;
  }

  //update notes
  Future<bool> updateNotes({
    required String title,
    required String desc,
    required int sno,
  }) async {
    var db = await getDB();
    int check = await db.update(
      TABLE_NOTE,
      {COLUMN_NOTE_TITLE: title, COLUMN_NOTE_DESC: desc},
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );

    return check > 0;
  }

  //delete notes
  Future<bool> deleteNotes({required int sno}) async {
    var db = await getDB();
    int check = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return check > 0;
  }
}
