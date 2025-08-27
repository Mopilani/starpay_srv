import 'package:hash/hash.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'modules/account_data.dart';
import 'modules/star_account_data.dart';

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
  static const String accountsCollName = 'accs';
  static const String starAccountsCollName = 'strAccs';
  static const String emailsCollName = 'emls';

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

  Future<dynamic> addAccount(String id, AccountData accountData) async {
    var coll = db.collection(P3Db.accountsCollName);
    return await coll.insert(accountData.asMap());
  }

  Future<dynamic> addStarAccount(STRAccountData strAccountData) async {
    var coll = db.collection(P3Db.starAccountsCollName);
    return await coll.insert(strAccountData.asMap());
  }

  Future<dynamic> getAccount(String id) async {
    var coll = db.collection(P3Db.accountsCollName);
    return await coll.findOne(where.eq('id', id));
  }

  Future<dynamic> getMail(String id) async {
    var coll = db.collection(P3Db.emailsCollName);
    return await coll.findOne(where.eq('id', id));
  }

  Future<List<Map<String, dynamic>>> getLast10Message() async {
    var coll = db.collection(P3Db.emailsCollName);
    return await coll.find(where.raw({'\$natural': -1}).limit(10)).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMessages() async {
    var coll = db.collection(P3Db.emailsCollName);
    return await coll.find(where.raw({'\$natural': -1})).toList();
  }
}
