import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDatabase();
    return _database;
  }

  initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'database.db');
    var db = await openDatabase(path, version: 1, onCreate: onCreate);
    return db;
  }

  onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE RecordSong (id INTEGER,title TEXT,audioPath TEXT,time TEXT, PRIMARY KEY(id AUTOINCREMENT))');
  }

  /// Add Record
  addRecordSong(RecordAudio recordAudio) async {
    final db = await database;
    var res = await db!.insert('RecordSong', recordAudio.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  /// Get Record
  Future<List<RecordAudio>> getRecordSongs() async {
    var db = await database;
    List<Map> maps = await db!.query('RecordSong', orderBy: 'time DESC');
    List<RecordAudio> recordSongs = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        recordSongs.add(
            RecordAudio(id: maps[i]['id'], title: maps[i]['title'].toString(), audioPath: maps[i]['audioPath'].toString(), time: maps[i]['time']));
      }
    }
    return recordSongs;
  }

  /// Delete Record
  Future<void> deleteRecord(id) async {
    var db = await database;
    db!.delete('RecordSong', where: 'id = ?', whereArgs: [id]);
  }
}
