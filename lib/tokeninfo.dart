library tokeninfo;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http show Client;
import 'package:googleapis/oauth2/v2.dart' as oauth;

Future<oauth.Tokeninfo> load(String token) async {
  var client = new http.Client();
  var api = new oauth.Oauth2Api(client);
  return api.tokeninfo(accessToken: token);
}
