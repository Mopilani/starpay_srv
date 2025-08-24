import 'package:enough_mail/enough_mail.dart';
import 'print_message_function.dart';

late PopClient client;

class P3Client {
  P3Client();

  /// Low level POP3 API example
  static Future<PopStatus?> pop3ClientInit({
    required String popServerHost,
    required int popServerPort,
    required bool isPopServerSecure,
    required String email,
    required String appPass,
  }) async {
    client = PopClient(isLogEnabled: false);
    try {
      await client.connectToServer(
        popServerHost,
        popServerPort,
        isSecure: isPopServerSecure,
      );
      await client.login(email, appPass);
      var status = await client.status();
      print(status);
      return status;
    } catch (e, s) {
      print(e);
      print(s);
      return null;
    }
  }

  static Future<List<MessageListing>> list([int? messageId]) async {
    return await client.list(messageId);
  }

  static Future retrieve(int messageId) async {
    return decodeMessage(await client.retrieve(messageId));
  }

  static Future<void> close() async {
    // await client.status();
    await client.quit();
  }

  static List<String> decodeMessage(MimeMessage message) {
    print('from: ${message.from} with subject "${message.decodeSubject()}"');
    List<String> messageLines = <String>[];
    if (!message.isTextPlainMessage()) {
      print(' content-type: ${message.mediaType}');
    } else {
      final plainText = message.decodeTextPlainPart();
      if (plainText != null) {
        final lines = plainText.split('\r\n');
        for (final line in lines) {
          if (line.startsWith('>')) {
            // break when quoted text starts
            break;
          }
          print(line);
          messageLines.add(line);
        }
      }
    }

    return messageLines;
  }
}
