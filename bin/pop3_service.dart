import 'dart:convert';
import 'dart:io';
// import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'lib/db_implementions.dart';
import 'lib/pop3_service_loop.dart';

String email = '';
String appPass = '';
String imapServerHost = 'imap.gmail.com';
int imapServerPort = 993;
bool isImapServerSecure = true;
String popServerHost = 'pop.gmail.com';
int popServerPort = 995;
bool isPopServerSecure = true;
String smtpServerHost = 'smtp.gmail.com';
int smtpServerPort = 587;
bool isSmtpServerSecure = true;

final router = Router()
  ..get('/update', (Request req) async {
    disclosureRequired = true;
    while (disclosureRequired) {
      await Future.delayed(Duration(seconds: 2));
    }
    return Response.ok('');
  });

/** About the Service
 * Periodic:
 * This service will get the messages from the account and load 
 * it into the db, periodicly
 * 
 * Remote:
 * Also it can be called remotly to get last messages when needed
 */
/// This service will get the messages from the account and
/// load it into the db
void main(List<String> args) async {
  // final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

  // print('Application documents DIR: ${appDocumentsDir.path}');
  var configFile = File('config.json');
  if (await configFile.exists()) {
    var data = await configFile.readAsString();
    try {
      var config = json.decode(data);
      email = config['email'];
      appPass = config['appPass'];
      print("App Config Loaded.");
    } catch (e, s) {
      print(e);
      print(s);
      print(
        "Can't find a valid data in the config file, trying parsing args...",
      );
      try {
        email = args[0];
        appPass = args[1];
        var data = json.encode({'email': email, 'appPass': appPass});
        // configFile.create();
        await configFile.writeAsString(data);
        print("App Config Written and Loaded.");
      } catch (e, s) {
        print(e);
        print(s);
      }
    }
  } else {
    print("Can't start service without configurations. Exiting");
    exit(102);
  }

  final ip = InternetAddress.loopbackIPv4;

  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8083');
  await serve(handler, ip, port);

  await P3Db().initDb();
  await popServiceLoop(
    popServerHost: popServerHost,
    popServerPort: popServerPort,
    isPopServerSecure: isPopServerSecure,
    email: email,
    appPass: appPass,
  );
  exit(0);
}
