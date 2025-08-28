import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import 'lib/db_implementions.dart';
import 'lib/get_account_data.dart';
import 'lib/modules/star_account_data.dart';

// Configure routes.
final _router = Router()
  ..all('/', _rootHandler)
  ..all('/account/<accountId>', getAccountData)
  ..get('/last_messages/<limit>', lastMessages)
  ..get('/echo/<message>', _echoHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Future<Response> lastMessages(Request req) async {
  final limit = req.params['limit'];
  if (limit == null) return Response.badRequest();

  try {
    var response = await http.get(Uri.parse('http://localhost:8083/update'));
    print("Messages Updated: ${response.statusCode}");
  } catch (e, s) {
    print(e);
    print(s);
  }

  var r = await P3Db().getLastMessages(int.parse(limit));
  return Response.ok(json.encode(r));
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  print('Initializing DB');
  await P3Db().initDb();
  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
  print('Server listening on ip ${server.address.address}');

  orgnizeData();
}

Map<String, dynamic> foundStarAccounts = {};

Future<void> orgnizeData() async {
  print('Data Assempler V0.1 Started');

  var messagesList = await P3Db().getAllMessages();
  for (var message in messagesList) {
    print(message);
    List<dynamic> lines = message['data'];

    var lTakeAction =
        'Please take action to avoid interruption to your Starlink service.';
    bool lTakeActionCheck = false;
    var lPaymentFaild = 'Payment Failed';
    bool lPaymentFaildCheck = false;
    var lAccountNumber = 'Account Number';
    bool lAccountNumberCheck = false;
    var lPaymentAmount = 'Payment Amount';
    bool lPaymentAmountCheck = false;
    var lEUR = 'EUR ';
    bool lEURCheck = false;

    String accountNumber = '';
    String paymentAmount = '';
    int paymentAmountLineNumber = 0;
    int accountNumberLineNumber = 0;

    /// Primary Check
    for (int number = 0; number < lines.length; number++) {
      String line = lines[number].toString();

      if (lPaymentFaildCheck || line.contains(lPaymentFaild)) {
        lPaymentFaildCheck = true;
      }
      if (lAccountNumberCheck || line.contains(lAccountNumber)) {
        if (!lAccountNumberCheck) {
          accountNumberLineNumber = number;
        }
        lAccountNumberCheck = true;
      }
      if (lPaymentAmountCheck || line.contains(lPaymentAmount)) {
        if (!lPaymentAmountCheck) {
          paymentAmountLineNumber = number;
        }
        lPaymentAmountCheck = true;
      }
      if (lEURCheck || line.contains(lEUR)) {
        lEURCheck = true;
      }
    }

    if (!(lPaymentFaildCheck &&
        lAccountNumberCheck &&
        lPaymentAmountCheck &&
        lEURCheck)) {
      print('The 4 Rule Check Not Passed');
    } else {
      print('The 4 Rule Check Passed');

      /// Secondary Check
      if (lAccountNumberCheck) {
        var accountNumberLine = lines[accountNumberLineNumber + 1];
        print(accountNumberLine);
        accountNumber = '';
        if (lPaymentAmountCheck) {
          var paymentAmountLine = lines[paymentAmountLineNumber + 1];
          print(paymentAmountLine);
          paymentAmount = '';
          accountNumberLine = removeStars(accountNumberLine);
          paymentAmountLine = removeStars(paymentAmountLine);
          // if (foundStarAccounts.addAll(other))
          foundStarAccounts.addAll({accountNumberLine: paymentAmountLine});
        }
      }
    }
  }

  print('Found Accounts');
  for (var account in foundStarAccounts.entries) {
    print(account);
    var accountValue = (account.value as String).split(' ');
    var currencyV = accountValue.first;
    var amountV = double.parse(accountValue.last);
    var accountData = STRAccountData(
      due: amountV,
      accountId: account.key,
      lastPayment: DateTime.now(),
      currency: currencyV,
      period: [],
      email: '',
      password: '',
      invoices: [],
    );
    await P3Db().addStarAccount(accountData);
  }
}

String removeStars(String text) {
  var text0 = text;
  print('Remove Stars');
  text0 = text.replaceRange(0, 1, '');
  text = text0.replaceRange(text0.length - 1, text0.length, '');
  print('After Remove Stars: $text');
  return text;
}
