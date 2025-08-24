import 'package:hash/hash.dart';
import 'package:mongo_dart/mongo_dart.dart';

late Db db;

Future<Db> initDb() async {
  db = Db("mongodb://localhost:27017/mongo_dart-blog");
  return await db.open();
}

Future<dynamic> addMail(int id, dynamic data) async {
  var coll = db.collection('emls');
  return await coll.insert({'hash': SHA256().update(data).digest(),'eid': id, 'data': data});
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
