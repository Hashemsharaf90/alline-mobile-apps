import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInController with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? googleAccount;
  GoogleSignInClientAuthorization? auth;
  String errorMessage = '';
  late final Future<void> _initialization;

  GoogleSignInController() {
    _initialization = _initialize();
  }

  Future<void> _initialize() async {
    if (AppConstants.googleServerClientId.trim().isEmpty) {
      errorMessage = 'Google Sign-In is not configured for this build.';
      notifyListeners();
      return;
    }

    await _googleSignIn.initialize(
      serverClientId: AppConstants.googleServerClientId,
    );

    // Listen to authentication events like official example
    _googleSignIn.authenticationEvents.listen(_handleAuthenticationEvent);
  }

  Future<void> _handleAuthenticationEvent(
      GoogleSignInAuthenticationEvent event) async {
    googleAccount = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (googleAccount != null) {
      const List<String> scopes = <String>['email'];
      final existingAuthorization = await googleAccount?.authorizationClient
          .authorizationForScopes(scopes);
      if (existingAuthorization != null) {
        auth = existingAuthorization;
      }
    } else {
      auth = null;
    }

    notifyListeners();
  }

  Future<void> login() async {
    try {
      errorMessage = '';
      await _initialization;
      if (AppConstants.googleServerClientId.trim().isEmpty) {
        throw StateError('Google Sign-In is not configured for this build.');
      }

      const List<String> scopes = <String>['email'];
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: scopes,
      );
      googleAccount = account;

      // authorizationForScopes is intentionally non-interactive and can
      // return null on a first sign-in. This call originates from the Google
      // button, so authorizeScopes can safely request the required consent.
      auth = await account.authorizationClient.authorizationForScopes(scopes) ??
          await account.authorizationClient.authorizeScopes(scopes);

      if (auth?.accessToken.isEmpty ?? true) {
        throw StateError('Google did not return an access token.');
      }

      notifyListeners();
    } catch (e) {
      errorMessage = _errorMessageFromSignInException(e);
      notifyListeners();
      rethrow;
    }
  }

  String _errorMessageFromSignInException(dynamic e) {
    if (e is GoogleSignInException) {
      return switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Sign in canceled',
        _ => 'GoogleSignInException ${e.code}: ${e.description}',
      };
    }
    return 'Unknown error: $e';
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
  }
}
