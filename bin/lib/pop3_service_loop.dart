import 'dart:async';

import 'db_implementions.dart';
import 'pop3_client.dart';

bool disclosureRequired = false;

/// Low level POP3 API example
Future<void> popServiceLoop({
  required String popServerHost,
  required int popServerPort,
  required bool isPopServerSecure,
  required String email,
  required String appPass,
}) async {
  try {
    var status = await P3Client.pop3ClientInit(
      popServerHost: popServerHost,
      popServerPort: popServerPort,
      isPopServerSecure: isPopServerSecure,
      email: email,
      appPass: appPass,
    );

    print(
      'status: messages count=${status?.numberOfMessages}, messages size=${status?.totalSizeInBytes}',
    );

    final messageList = await P3Client.list();
    for (int i = 0; i < messageList.length; i++) {
      print('Trying to get messages');
      print('Fetched Message Count: ${messageList.length}');

      for (var msgRef in messageList.reversed) {
        print('Message Id: ${msgRef.id}');
        var message = await P3Client.retrieve(msgRef.id);
        // print(message);
        print(
          '-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-',
        );
        // printMessage(message);
        // var _message = P3Client.decodeMessage(message);
        await P3Db().addMail(msgRef.id, message);
      }

      disclosureRequired = false;

      int count = 0;
      int maxSeconds = 120;
      while (!disclosureRequired) {
        if (count < maxSeconds) {
          count++;
        } else {
          disclosureRequired = true;
        }
        print('In Delay $count');
        await Future.delayed(Duration(seconds: 1));
      }
    }
  } catch (e, s) {
    print(e);
    print(s);
    // print('POP failed with ${e.message}');
  }
}
