import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:oauth_verify_shelf/oauth_verify_shelf.dart' as oauth_verify;
import 'common.dart' as common;

main() async {
  var port = 9999;
  var oauthVerifier = new oauth_verify.OauthTokenVerifier(common.CLIENT_ID);
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(oauthVerifier.verifyAuthorizationHeader())
      .addHandler(_handler);

  var server = await io.serve(handler, '0.0.0.0', port);
  print("$server serving at $port");
  server.autoCompress = true;
}

shelf.Response _handler(shelf.Request request) {
  return new shelf.Response.ok('Request received: ${request.url}');
}
