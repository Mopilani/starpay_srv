import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
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
    await db.open();
    return db;
  }

  // Future<dynamic> addMail(int id, MimeMessage mime) async {
  Future<dynamic> addMail(int id, List<String> messageLines) async {
    var coll = db.collection('emls');
    var messageHash = SHA256()
        // .update(mime.decodeContentBinary()!.toList())
        .update(messageLines.join('\n').codeUnits)
        .digest();
    var result = await coll.findOne(where.eq('hash', messageHash));
    if (result == null) {
      try {
        return await coll.insert({
          'hash': messageHash,
          'eid': id,
          'data': messageLines,
          // 'data': mime.body!.bodyRaw,
          // 'data': utf8.decode(data.decodeContentBinary()!.toList()),
        });
      } catch (e) {
        return await coll.insert({
          'hash': messageHash,
          'eid': id,
          'data': messageLines,
          // 'data': mime.decodeContentBinary()!.toList(),
          // 'data': utf8.decode(),
        });
      }
    } else {
      print('Message Was Inserted');
    }
  }

  Future<dynamic> getMail(String id) async {
    var coll = db.collection('emls');
    // Fluent way
    return await coll.findOne(where.eq('id', id).gt('rating', 10));
  }

  Future<List<Map<String, dynamic>>> getLast10Message() async {
    var coll = db.collection('emls');
    return await coll.find(where.raw({'\$natural': -1}).limit(10)).toList();
  }
}
