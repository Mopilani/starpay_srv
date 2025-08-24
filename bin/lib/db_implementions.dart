import 'package:hash/hash.dart';
import 'package:mongo_dart/mongo_dart.dart';

P3Db? instance;

class P3Db {
  factory P3Db() {
    if (instance == null) {
      instance = P3Db.newIns();
      print('Creating P3Db Instance.');
      return instance!;
    } else {
      return instance!;
    }
  }

  P3Db.newIns();

  late Db db;

  Future<Db> initDb() async {
    db = Db("mongodb://13.220.217.147:8082/stpy_test");
    return await db.open();
  }

  Future<dynamic> addMail(int id, dynamic data) async {
    var coll = db.collection('emls');
    return await coll.insert({
      'hash': SHA256().update(data).digest(),
      'eid': id,
      'data': data,
    });
  }

  Future<dynamic> getMail(String id) async {
    var coll = db.collection('emls');
    // Fluent way
    return await coll.findOne(where.eq('id', id).gt('rating', 10));
  }

  Future<List<Map<String, dynamic>>> getLast10Message() async {
    var coll = db.collection('emls');
    return await coll.find(where.limit(10)).toList();
  }
}
