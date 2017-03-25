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
  shelf.Middleware get middleware =>
      shelf.createMiddleware(requestHandler: (shelf.Request request) async {
        var headers = request.headers;
        if (!headers.containsKey(AUTHORIZATION)) return RESPONSE_404;

        var authorization = headers[AUTHORIZATION];
        var oauthToken =
            _extractOauthTokenFromAuthorizationHeader(authorization);
        var isTokenValid = await verify(clientId, oauthToken);
        if (!isTokenValid) return RESPONSE_404;
      });
}

String _extractOauthTokenFromAuthorizationHeader(String authorizationHeader) =>
    authorizationHeader.replaceAll(BEARER, '');

Future<bool> verify(String clientId, String oauthToken) async {
  try {
    oauth.Tokeninfo tokenInfo = await info.load(oauthToken);
    bool isTokenValid = false;
    if (tokenInfo != null) {
      isTokenValid = tokenInfo.expiresIn > 0 && tokenInfo.issuedTo == clientId;
    } else
      print('token is null from $oauthToken');

    if (!isTokenValid) {
      print('$oauthToken is not valid');
      if (tokenInfo != null) print(tokenInfo.toJson());
    }

    return isTokenValid;
  } catch (e) {
    print(e);
    return false;
  }
}
