class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // यो फंक्सनले फोन नम्बर वा इमेललाई सही रूपमा इमेलमा ढाल्छ
  String _formatEmail(String input) {
    String cleaned = input.trim();
    if (!cleaned.contains('@')) {
      // यदि `@` छैन भने यो फोन नम्बर हो, यसमा थलोको डोमेन थप्छौँ
      return '$cleaned@thalo.app';
    }
    return cleaned;
  }

  Future<User?> login({required String email, required String password}) async {
    try {
      String finalEmail = _formatEmail(email);
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: finalEmail,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unknown';
    }
  }

  Future<User?> register({
    required String firstName,
    required String middleName,
    required String lastName,
    required String gender,
    required String dob,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      String finalEmail = _formatEmail(emailOrPhone);

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: finalEmail,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        String fullName = '$firstName ${middleName.isNotEmpty ? '$middleName ' : ''}$lastName';
        await user.updateDisplayName(fullName.trim());
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'firstName': firstName.trim(),
          'middleName': middleName.trim(),
          'lastName': lastName.trim(),
          'fullName': fullName.trim(),
          'gender': gender,
          'dob': dob,
          'emailOrPhone': emailOrPhone.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'unknown';
    }
  }
}
