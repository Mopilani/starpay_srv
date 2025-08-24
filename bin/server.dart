import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;

import 'lib/db_implementions.dart';

// Configure routes.
final _router = Router()
  ..all('/', _rootHandler)
  ..get('/last_ten/', last10Messages)
  ..get('/echo/<message>', _echoHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Future<Response> last10Messages(Request req) async {
  try {
    var response = await http.get(Uri.parse('http://localhost:8083/update'));
  } catch (e, s) {
    print(e);
    print(s);
  }
  // if (response.statusCode == 200) {
  // } else {}
  var r = P3Db().getLast10Message();
  return Response.ok(r);
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
}
