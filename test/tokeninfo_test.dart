library tokeninfo_test;

import 'dart:async';
import 'package:test/test.dart';
import 'package:oauth_verify_shelf/tokeninfo.dart' as info;
import 'package:googleapis/oauth2/v2.dart' as oauth;
import 'common.dart' as common;

main() {
  group('Tokeninfo', () {
    oauth.Tokeninfo tokenInfo;
    setUpAll(() async {
      tokenInfo = await info.load(common.OAUTH_TOKEN);
    });
    test('', () {
      expect(tokenInfo.expiresIn, isNonZero);
      expect(tokenInfo.email, common.EMAIL);
      expect(tokenInfo.issuedTo, common.CLIENT_ID);
    });
  });
}
