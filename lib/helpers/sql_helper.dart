import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""CREATE TABLE notes_table(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    favorite INTEGER,
    color INTEGER,
    date TIMESTAMP NOT NULL
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'notes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTable(database);
      },
    );
  }

  static Future<int> createNote(
      String title, String description, int color) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'favorite': 0,
      'color': color,
      'date': DateTime.now().toString()
    };
    final id = await db.insert('notes_table', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await SQLHelper.db();
    return db.query('notes_table', orderBy: "date DESC");
  }

  static Future<List<Map<String, dynamic>>> getNoteById(int id) async {
    final db = await SQLHelper.db();
    return db.query('notes_table', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<List<Map<String, dynamic>>> getNote(String text) async {
    final db = await SQLHelper.db();
    return db.query('notes_table',
        where: "title = %$text% OR desc = %$text%" /* , limit: 1 */);
  }

  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final db = await SQLHelper.db();
    return db.query('notes_table',
        orderBy: "date DESC", where: "favorite = ?", whereArgs: [1]);
  }

  static Future<int> updateNote(
      int id, String title, String description, int color) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'color': color,
      'date': DateTime.now().toString()
    };

    final result =
        await db.update('notes_table', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteNote(int id) async {
    final db = await SQLHelper.db();

    try {
      await db.delete("notes_table", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting note: $err");
    }
  }

  static Future<int> addRemoveFavorite(int id, int favorite) async {
    final db = await SQLHelper.db();

    final data = {'favorite': favorite};
    final result =
        await db.update('notes_table', data, where: "id = ?", whereArgs: [id]);
    return result;
  }
}
