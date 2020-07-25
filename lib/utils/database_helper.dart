import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/Images.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String imgId = 'image_id';
  String imgLink = 'imglink';
  String imgTable = 'ImagesTable';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'img.db';

    // Open/create the database at a given path
    var imgDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return imgDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $imgTable($imgId INTEGER PRIMARY KEY AUTOINCREMENT, $imgLink TEXT)');
  }

  //Insert
  Future<int> insertImg(Images img) async {
    Database db = await this.database;
    var result = await db.insert(imgTable, img.toMap());
    return result;
  }

  //Fetch
  Future<List<Map<String, dynamic>>> getImgMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(imgTable);
    return result;
  }

  //Delete
  Future<int> deleteImg() async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $imgTable');
    return result;
  }
  Future<List<Images>> getImagesList() async {
    var imgMapList = await getImgMapList(); // Get 'Map List' from database
    int count =
        imgMapList.length; // Count the number of map entries in db table

    List<Images> imgList = List<Images>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      imgList.add(Images.fromMapObject(imgMapList[i]));
    }
    print(imgMapList);
    return imgList;
  }
}
