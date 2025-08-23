import 'package:mongo_dart/mongo_dart.dart';

Future<void> init() async {
  var db = Db("mongodb://localhost:27017/mongo_dart-blog");
  await db.open();
}
