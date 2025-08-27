import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'db_implementions.dart';

Future<Response> getAccountData(Request req) async {
  var headers = req.headers;
  final accountId = req.params['accountId'];
  if (accountId == null) return Response.badRequest();

  await P3Db().getAccount(accountId);

  return Response(200);
}
