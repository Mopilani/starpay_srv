import 'package:enough_mail/enough_mail.dart';

/// Low level SMTP API example
Future<void> smtpExample({
  required String smtpServerHost,
  required int smtpServerPort,
  required bool isSmtpServerSecure,
}) async {
  final client = SmtpClient('enough.de', isLogEnabled: true);
  try {
    await client.connectToServer(
      smtpServerHost,
      smtpServerPort,
      isSecure: isSmtpServerSecure,
    );
    await client.ehlo();
    if (client.serverInfo.supportsAuth(AuthMechanism.plain)) {
      await client.authenticate('user.name', 'password', AuthMechanism.plain);
    } else if (client.serverInfo.supportsAuth(AuthMechanism.login)) {
      await client.authenticate('user.name', 'password', AuthMechanism.login);
    } else {
      return;
    }
    final builder =
        MessageBuilder.prepareMultipartAlternativeMessage(
            plainText: 'hello world.',
            htmlText: '<p>hello <b>world</b></p>',
          )
          ..from = [MailAddress('My name', 'sender@domain.com')]
          ..to = [MailAddress('Your name', 'recipient@domain.com')]
          ..subject = 'My first message';
    final mimeMessage = builder.buildMimeMessage();
    final sendResponse = await client.sendMessage(mimeMessage);
    print('message sent: ${sendResponse.isOkStatus}');
  } on SmtpException catch (e) {
    print('SMTP failed with $e');
  }
}
