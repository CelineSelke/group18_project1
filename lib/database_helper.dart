import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class DatabaseHelper {
  static const _databaseName = "RecipesDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'recipes';
  static const columnId = '_id';
  static const columnTitle = 'title';
  static const columnIngredients = 'ingredients';
  static const columnInstructions = 'instructions';
  //Add ImageURL, cook time, vegan/gluten free tag
  late Database _db;
  late Future<void> _initialization;

  DatabaseHelper() {
    _initialization = init();
  }

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT NOT NULL,
      $columnIngredients TEXT NOT NULL,
      $columnInstructions TEXT NOT NULL
    )
    ''');
    final jsonString = await rootBundle.loadString('assets/recipes.json');
    final List<dynamic> jsonRecipes = json.decode(jsonString);
    await _insertDefaultRecipes(db, jsonRecipes);
  }

  Future<void> _insertDefaultRecipes(Database db, List<dynamic> recipes) async {
    for (final recipe in recipes) {
      await db.insert(table, {
        columnTitle: recipe['title'],
        columnIngredients: recipe['ingredients'],
        columnInstructions: recipe['instructions'],
      });
    }
  }


  Future<int> insert(Map<String, dynamic> row) async {
    await _initialization;
    return await _db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    await _initialization;
    return await _db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllRecipes() async {
    await _initialization;
    return await _db.query(table);
  }

  Future<int> queryRowCount() async {
    await _initialization;
    final results = await _db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    await _initialization;
    int id = row[columnId];
    return await _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    await _initialization;
    return await _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}