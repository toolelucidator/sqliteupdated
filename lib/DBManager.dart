import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'Student.dart';
import 'dart:io' as io;

class dbManager {
  static Database? _db;
  static const String? ID = 'controlNum';
  static const String? NAME = 'name';
  static const String? APEPA = 'apepa';
  static const String? APEMA = 'apema';
  static const String? TEL = 'tel';
  static const String? EMAIL = 'email';
  static const String? TABLE = 'Students';
  static const String? DB_NAME = 'student.db';

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDB();
      return _db;
    }
  }

  //InitDB
  initDB() async {
    io.Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = join(appDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $TABLE("
        "$ID INTEGER PRIMARY KEY, $NAME TEXT, $APEPA TEXT, "
        "$APEMA TEXT, $TEL TEXT,$EMAIL TEXT)");
  }

  //SELECT
  Future<List<Student>> getStudents() async {
    var dbClient = await (db as Future<Database?>);
    List<Map> maps = await dbClient!
        .query(TABLE!, columns: [ID!, NAME!, APEPA!, APEMA!, TEL!, EMAIL!]);
    List<Student> studentss = [];
    print(maps.length);

    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        print("Datos");
        print(Student.fromMap(maps[i] as Map<String, dynamic>));
        studentss.add(Student.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return studentss;
  }

  //SELECT BY ID

  Future<List<Student>> customQuery(String name) async {
    var dbClient = await (db as Future<Database?>);
    List<Map> maps = await dbClient!
        .query(TABLE!, columns: [ID!, NAME!, APEPA!, APEMA!, TEL!, EMAIL!], where: '$EMAIL=?', whereArgs: [name]);
    List<Student> studentss = [];
    print(maps.length);

    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        print("Datos");
        print(Student.fromMap(maps[i] as Map<String, dynamic>));
        studentss.add(Student.fromMap(maps[i] as Map<String, dynamic>));
      }
    }
    return studentss;
  }

  //INSERT
  Future<Student> save(Student student) async {
    var dbClient = await (db as Future<Database?>);
    student.controlNum = await dbClient!.insert(TABLE!, student.toMap());
    return student;
  }

  //DELETE
  Future<int> delete(int id) async {
    var dbClient = await (db as Future<Database?>);
    return await dbClient!.delete(TABLE!, where: '$ID= ?', whereArgs: [id]);
  }

  //UPDATE
  Future<int> update(Student student) async {
    var dbClient = await (db as Future<Database?>);
    return await dbClient!.update(TABLE!, student.toMap(),
        where: '$ID = ?', whereArgs: [student.controlNum]);
  }

  Future close() async {
    var dbClient = await (db as Future<Database?>);
    dbClient!.close();
  }
}
