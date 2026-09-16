import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onVerificationCompleted,
    required void Function(FirebaseAuthException) onVerificationFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // कतिपय firebase_auth plugin संस्करणमा एउटा known bug छ: OTP सही भई sign-in
  // वास्तवमा सफल भइसके पनि, plugin bridge ले नतिजा फर्काउँदा "PigeonUserDetails"
  // खालको हानिरहित type-cast त्रुटि फ्याँक्छ। यसले गर्दा UI मा verify बटन
  // थिचेपछि केही नभएजस्तो देखिन्छ, जबकि प्रयोगकर्ता वास्तवमा login भइसकेको
  // हुन्छ। यहाँ त्यो विशेष त्रुटिलाई चिनेर, currentUser साँच्चै login भएको
  // पुष्टि गरेपछि मात्र यसलाई बेवास्ता गर्छौं — अरू कुनै वास्तविक त्रुटि
  // (गलत OTP, नेटवर्क त्रुटि आदि) ज्यूँको त्यूँ माथि नै पठाइन्छ।
  Future<UserCredential?> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      final msg = e.toString();
      final isKnownPigeonBug = msg.contains('PigeonUserDetails') || msg.contains('List<Object?>');
      if (isKnownPigeonBug && _auth.currentUser != null) {
        return null;
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInWithPhoneCredential(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await signInWithCredential(credential);
  }
}
