import 'package:club_fitness/core/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePhoneAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;

  /// Step 1: sends the OTP SMS to [phoneNumber] (E.164 format, e.g. "+919876543210").
  ///
  /// [onCodeSent] fires once the SMS has been dispatched — use it to move
  /// your UI to the "enter OTP" screen.
  /// [onAutoVerified] fires only on Android devices that auto-detect the SMS
  /// without the user typing anything — if you implement it, complete the
  /// sign-in flow immediately instead of waiting for [verifyOtp].
  /// [onError] fires on invalid phone number, quota exceeded, etc.
  static Future<void> sendOtp({
    required String phoneNumber,
    required void Function() onCodeSent,
    required Future<UserEntity?> Function(PhoneAuthCredential credential)
    signInAndExchange,
    required void Function(UserEntity result) onAutoVerified,
    required void Function(String message) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final result = await signInAndExchange(credential);
          if (result != null) onAutoVerified(result);
        } catch (e) {
          onError(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Step 2: call once the user types in the 6-digit SMS code.
  /// Returns the backend response { user, accessToken, refreshToken, rotationToken }.
  static Future<UserEntity> verifyOtp(
    String smsCode, {
    required Future<UserEntity?> Function(PhoneAuthCredential credential)
    signInAndExchange,
  }) async {
    if (_verificationId == null) {
      throw Exception('No OTP was requested yet — call sendOtp first');
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );

    final result = await signInAndExchange(credential);
    if (result == null) {
      throw Exception('Sign-in failed');
    }
    return result;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
