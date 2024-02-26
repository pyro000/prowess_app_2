import 'package:bcrypt/bcrypt.dart';

class Hasher {
  Hasher();

  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  bool checkPassword(String password, String hash){
    return BCrypt.checkpw(password, hash);
  }
}