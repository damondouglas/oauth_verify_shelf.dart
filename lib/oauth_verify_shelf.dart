library oauth_verify_shelf;

import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'package:googleapis/oauth2/v2.dart' as oauth show Tokeninfo;
import 'tokeninfo.dart' as info;

final AUTHORIZATION = 'authorization';
final BEARER = 'Bearer ';
final RESPONSE_404 = new shelf.Response.notFound(null);

class OauthTokenVerifier {
  String clientId;
  OauthTokenVerifier(this.clientId);
  shelf.Middleware verifyAuthorizationHeader() => (shelf.Handler innerHandler) {
        return (shelf.Request request) async {
          bool isTokenValid = false;
          if (_validateHeaders(request)) {
            var oauthToken = _extractOauthTokenFromAuthorizationHeader(
                request.headers[AUTHORIZATION]);
            isTokenValid = await verify(clientId, oauthToken)
                .then((_isValid) => _isValid, onError: (_) {
              print("Invalid token request:");
              print("${request.headers}");
            });
          }

          if (isTokenValid) {
            return new Future.sync(() => innerHandler(request)).then(
                (shelf.Response response) {
              return response;
            }, onError: (error, stackTrace) {
              print(error);
              print(stackTrace);
              return _create404();
            });
          } else {
            return _create404();
          }
        };
      };
}

shelf.Response _create404() => new shelf.Response.notFound(null);

bool _validateHeaders(shelf.Request request) =>
    request.headers.containsKey(AUTHORIZATION);

String _extractOauthTokenFromAuthorizationHeader(String authorizationHeader) =>
    authorizationHeader.replaceAll(BEARER, '');

Future<bool> verify(String clientId, String oauthToken) async {
  bool isTokenValid = false;
  oauth.Tokeninfo tokenInfo =
      await info.load(oauthToken).then((_info) => _info, onError: (_) => null);

  if (tokenInfo != null) {
    isTokenValid = tokenInfo.expiresIn > 0 && tokenInfo.issuedTo == clientId;
  }

  return isTokenValid;
}
