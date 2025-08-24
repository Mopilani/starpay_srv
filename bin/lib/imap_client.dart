import 'package:enough_mail/enough_mail.dart';
import 'print_message_function.dart';

/// Low level IMAP API usage example
Future<void> imapExample({
  required String imapServerHost,
  required int imapServerPort,
  required bool isImapServerSecure,
  required String email,
  required String appPass,
}) async {
  final client = ImapClient(isLogEnabled: false);
  try {
    await client.connectToServer(
      imapServerHost,
      imapServerPort,
      isSecure: isImapServerSecure,
    );
    await client.login(email, appPass);
    final mailboxes = await client.listMailboxes();
    print('mailboxes: $mailboxes');
    await client.selectInbox();
    // fetch 10 most recent messages:
    final fetchResult = await client.fetchRecentMessages(
      messageCount: 10,
      criteria: 'BODY.PEEK[]',
    );
    for (final message in fetchResult.messages) {
      printMessage(message);
    }
    await client.logout();
  } on ImapException catch (e) {
    print('IMAP failed with $e');
  }
}
