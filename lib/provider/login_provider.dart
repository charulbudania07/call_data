import 'package:call_management/model/login_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api.dart';

class LoginProvider extends ChangeNotifier {
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String? _error;
  User? _user;

  String get username => _username;
  String get password => _password;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Construct URL with query parameters
      String endpoint = "login?username=$_username&password=$_password";
      print("endpoint$endpoint");
      final response = await Api().post(endpoint, {});

      if (response.statusCode == 200 && response.data['success'] == true) {
        final userData = response.data['user'];
        _user = User.fromJson(userData);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _user!.token); // Save token
        await prefs.setString('FirstName', _user!.fname); // Save token
        await prefs.setString('LastName', _user!.lname); // Save token
        await prefs.setString('id', _user!.id.toString());
        await prefs.setString('name', _user!.username);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

}
