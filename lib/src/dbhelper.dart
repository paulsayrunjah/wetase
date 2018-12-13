import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DBHelper {
  var database = null;

  DBHelper(){
    (()async{
      database = await startDBops();
    });
    
  }

  Future<Database> startDBops() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "wetase.db");

  
    var database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return database;
  }

  void _onCreate(Database db, int version) async {
        await db.execute('CREATE TABLE MyContacts (id INTEGER PRIMARY KEY, name TEXT, number TEXT)');
    print("Created tables");
  }

   getAll(table) async{
    final db = (database != null) ? database : await startDBops();
    return await db.rawQuery("SELECT * FROM "+ table +"");
  }

  getWhere(table, where) async{
    final db = (database != null) ? database : await startDBops();
    return await db.rawQuery("SELECT * FROM "+ table +" "+where);
  }

  insert(table, fields ,values) async{
    final db = (database != null) ? database : await startDBops();
    await db.rawQuery("INSERT INTO "+table+" ("+fields+") VALUES ("+values+")");
  }

  update(table, update, id) async {
    final db = (database != null) ? database : await startDBops();
    return await db.rawQuery("UPDATE "+ table +" SET "+ update +" WHERE id="+id);
  }

  deleteAll(table) async{
    final db = (database != null) ? database : await startDBops();
    return await db.rawQuery("DELETE  FROM "+ table);
  }

}
