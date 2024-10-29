import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  // Lấy userId của người dùng hiện tại
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
