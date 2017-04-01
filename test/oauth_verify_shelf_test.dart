// Copyright (c) 2017, Damon Douglas. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/*
 * Before running this test:
 * 1. Provide fresh token https://developers.google.com/oauthplayground to common.OAUTH_TOKEN
 * 2. Run `server.dart`
 */

import 'dart:async';
import 'package:test/test.dart';
import 'common.dart' as common;
import 'package:oauth_verify_shelf/oauth_verify_shelf.dart' as oauth
    show verify;
import 'package:http/http.dart' as http;

final AUTHORIZATION = 'authorization';
final BEARER = 'Bearer ';
final GET_AUTHORITY = '0.0.0.0:9999';
final PATH = 'foo';
final STATUS_200 = 200;
final STATUS_404 = 404;

void main() {
  group('verify', () {
    bool shouldBeVerified;
    bool shouldNotBeVerified;

    setUpAll(() async {
      shouldBeVerified =
          await oauth.verify(common.CLIENT_ID, common.OAUTH_TOKEN);
      shouldNotBeVerified =
          await oauth.verify(common.CLIENT_ID, common.EXPIRED_OAUTH_TOKEN);
    });

    test('${common.OAUTH_TOKEN} and ${common.CLIENT_ID} returns true', () {
      expect(shouldBeVerified, isTrue);
    });

    test('${common.EXPIRED_OAUTH_TOKEN} and ${common.CLIENT_ID} returns false',
        () {
      expect(shouldNotBeVerified, isFalse);
    });
  });

  group('OauthTokenVerifier', () {
    int validRequestStatus;
    int inValidRequestStatus;
    int emptyHeaderRequestStatus;

    setUpAll(() async {
      var requestUrl = new Uri.http(GET_AUTHORITY, PATH);

      var validRequest = await http.get(requestUrl,
          headers: {AUTHORIZATION: BEARER + common.OAUTH_TOKEN});

      var inValidRequest = await http.get(requestUrl,
          headers: {AUTHORIZATION: BEARER + common.EXPIRED_OAUTH_TOKEN});

      var emptyHeaderRequest = await http.get(requestUrl);

      validRequestStatus = validRequest.statusCode;
      inValidRequestStatus = inValidRequest.statusCode;
      emptyHeaderRequestStatus = emptyHeaderRequest.statusCode;
    });

    test(
        '${common.OAUTH_TOKEN} and ${common.CLIENT_ID} responds with status $STATUS_200',
        () {
      expect(validRequestStatus, STATUS_200);
    });

    test(
        '${common.EXPIRED_OAUTH_TOKEN} and ${common.CLIENT_ID} responds with status $STATUS_404',
        () {
      expect(inValidRequestStatus, STATUS_404);
    });

    test('empty header responds with status $STATUS_404', () {
      expect(emptyHeaderRequestStatus, STATUS_404);
    });
  });
}
