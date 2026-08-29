class AuthService {
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // TODO: वास्तविक authentication logic यहाँ राख्नुहोस्
    // (जस्तै Firebase Auth: FirebaseAuth.instance.signInWithEmailAndPassword)
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> sendPasswordReset(String email) async {
    // TODO: वास्तविक password reset logic यहाँ राख्नुहोस्
    await Future.delayed(const Duration(seconds: 1));
  }
}
