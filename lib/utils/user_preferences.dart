import 'package:payuung_pribadi/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _userKey = 'user';

  static Future<void> saveUserModel(UserModel user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = user.toRawJson();
    await prefs.setString(_userKey, userJson);
  }

  static Future<UserModel> getUserModel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      return UserModel.fromRawJson(userJson);
    } else {
      return UserModel.initial();
    }
  }
}
