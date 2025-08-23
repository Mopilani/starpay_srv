import 'dart:io';
import 'package:enough_mail/enough_mail.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

String userName = '';
String password = '';
String imapServerHost = 'imap.domain.com';
int imapServerPort = 993;
bool isImapServerSecure = true;
String popServerHost = 'pop.gmail.com';
int popServerPort = 995;
bool isPopServerSecure = true;
String smtpServerHost = 'smtp.gmail.com';
int smtpServerPort = 587;
bool isSmtpServerSecure = true;
// These URLs are endpoints that are provided by the authorization
// server. They're usually included in the server's documentation of its
// OAuth2 API.
final authorizationEndpoint = Uri.parse(
  'https://accounts.google.com/o/oauth2/v2/auth',
);
final tokenEndpoint = Uri.parse('http://example.com/oauth2/token');

// The authorization server will issue each client a separate client
// identifier and secret, which allows the server to tell which client
// is accessing it. Some servers may also have an anonymous
// identifier/secret pair that any client may use.
//
// Note that clients whose source code or binary executable is readily
// available may not be able to make sure the client secret is kept a
// secret. This is fine; OAuth2 servers generally won't rely on knowing
// with certainty that a client is who it claims to be.
final identifier = 'my client identifier';
final secret = 'my client secret';

// This is a URL on your application's server. The authorization server
// will redirect the resource owner here once they've authorized the
// client. The redirection will include the authorization code in the
// query parameters.
final redirectUrl = Uri.parse('http://my-site.com/oauth2-redirect');

/// A file in which the users credentials are stored persistently. If the server
/// issues a refresh token allowing the client to refresh outdated credentials,
/// these may be valid indefinitely, meaning the user never has to
/// re-authenticate.
final credentialsFile = File('~/.myapp/credentials.json');

void main() async {
  // await discoverExample();
  // await imapExample();
  // await smtpExample();
  // var client = await createClient();

  // Once you have a Client, you can use it just like any other HTTP client.
  // print(
  //   await client.read(Uri.parse('http://example.com/protected-resources.txt')),
  // );

  // Once we're done with the client, save the credentials file. This ensures
  // that if the credentials were automatically refreshed while using the
  // client, the new credentials are available for the next run of the
  // program.
  // await credentialsFile.writeAsString(client.credentials.toJson());
  await popExample();
  exit(0);
}

/// Either load an OAuth2 client from saved credentials or authenticate a new
/// one.
Future<oauth2.Client> createClient() async {
  var exists = await credentialsFile.exists();

  // If the OAuth2 credentials have already been saved from a previous run, we
  // just want to reload them.
  if (exists) {
    var credentials = oauth2.Credentials.fromJson(
      await credentialsFile.readAsString(),
    );
    return oauth2.Client(credentials, identifier: identifier, secret: secret);
  }

  // If we don't have OAuth2 credentials yet, we need to get the resource owner
  // to authorize us. We're assuming here that we're a command-line application.
  var grant = oauth2.AuthorizationCodeGrant(
    identifier,
    authorizationEndpoint,
    tokenEndpoint,
    secret: secret,
  );

  // A URL on the authorization server (authorizationEndpoint with some additional
  // query parameters). Scopes and state can optionally be passed into this method.
  var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
  print(authorizationUrl);

  return grant.handleAuthorizationResponse({'code': "9911"});

  // Redirect the resource owner to the authorization URL. Once the resource
  // owner has authorized, they'll be redirected to `redirectUrl` with an
  // authorization code. The `redirect` should cause the browser to redirect to
  // another URL which should also have a listener.
  //
  // `redirect` and `listen` are not shown implemented here. See below for the
  // details.
  // await redirect(authorizationUrl);
  // var responseUrl = await listen(redirectUrl);

  // Once the user is redirected to `redirectUrl`, pass the query parameters to
  // the AuthorizationCodeGrant. It will validate them and extract the
  // authorization code to create a new Client.
  // return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
}

Future<void> discoverExample() async {
  var email = '';
  var config = await Discover.discover(
    email,
    isLogEnabled: false,
    forceSslConnection: true,
  );

  if (config == null) {
    print('Unable to discover settings for $email');
  } else {
    print('Settings for $email:');
    for (var provider in config.emailProviders!) {
      print('provider: ${provider.displayName}');
      print('provider-domains: ${provider.domains}');
      print('documentation-url: ${provider.documentationUrl}');
      print('Incoming:');
      print(provider.preferredIncomingServer);
      print('Outgoing:');
      print(provider.preferredOutgoingServer);
    }
  }
}

/// Low level IMAP API usage example
Future<void> imapExample() async {
  final client = ImapClient(isLogEnabled: false);
  try {
    await client.connectToServer(
      imapServerHost,
      imapServerPort,
      isSecure: isImapServerSecure,
    );
    await client.login(userName, password);
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

/// Low level SMTP API example
Future<void> smtpExample() async {
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

/// Low level POP3 API example
Future<void> popExample() async {
  final client = PopClient(isLogEnabled: false);
  try {
    await client.connectToServer(
      popServerHost,
      popServerPort,
      isSecure: isPopServerSecure,
    );
    await client.login(userName, password);
    // alternative login:
    // await client.loginWithApop(userName, password); // optional different login mechanism
    final status = await client.status();
    print(
      'status: messages count=${status.numberOfMessages}, messages size=${status.totalSizeInBytes}',
    );
    final messageList = await client.list(status.numberOfMessages);
    print(
      'last message: id=${messageList?.first?.id} size=${messageList?.first?.sizeInBytes}',
    );
    var message = await client.retrieve(status.numberOfMessages);
    printMessage(message);
    print('----------++++++++++========++++++===');
    for (var msg in messageList) {
      print(msg);
    }
    print('----------______-++++++++++========++++++===');
    // message = await client.retrieve();
    for (
      int i = status.numberOfMessages;
      i > (status.numberOfMessages - 15);
      i--
    ) {
      print('----------++++++++++========++++++=== Printing Message');
      message = await client.retrieve(i);
      printMessage(message);
    }
    print('trying to retrieve newer message succeeded');
    await client.quit();
  } catch (e) {
    print(e);
    // print('POP failed with ${e.message}');
    // print(e.stackTrace);
  }
}

void printMessage(MimeMessage message) {
  print('from: ${message.from} with subject "${message.decodeSubject()}"');
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
      }
    }
  }
}
