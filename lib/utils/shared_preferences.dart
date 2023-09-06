import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  saveLogin(
      {required String id,
      required String email,
      required String name,
      required String privilage,
      required String token}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString('id', id);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('privilege', privilage);
    await prefs.setString('token', token);
  }

  Future<bool> removeLoginData() async {
    final SharedPreferences prefs = await _prefs;
    bool success;
    try {
      await prefs.remove('id');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.remove('privilege');
      await prefs.remove('token');
      success = true;
    } catch (e) {
      success = false;
    }
    return success;
  }

  Future<dynamic> showID() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('id');
  }

  Future<dynamic> showName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('name');
  }

  Future<dynamic> showEmail() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('email');
  }

  Future<dynamic> showPrivilege() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('privilege');
  }

  Future<dynamic> showToken() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('token');
  }
}
