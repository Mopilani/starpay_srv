import 'dart:async';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'print_message_function.dart';
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

    for (int i = 0; i < 10; i++) {
      print('Trying to get messages');
      final messageList = await P3Client.list();
      print('Fetched Message Count: ${messageList.length}');

      for (var msgRef in messageList) {
        print('Message Id: ${msgRef.id}');
        var message = await P3Client.retrieve(msgRef.id);
        // print(message);
        print(
          '-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-',
        );
        printMessage(message);
        // var _message = P3Client.decodeMessage(message);
        await P3Db().addMail(msgRef.id, message);
      }

      disclosureRequired = false;

      while (!disclosureRequired) {
        await Future.delayed(Duration(seconds: 1));
        print('In Delay +');
      }
    }
  } catch (e, s) {
    print(e);
    print(s);
    // print('POP failed with ${e.message}');
  }
}
