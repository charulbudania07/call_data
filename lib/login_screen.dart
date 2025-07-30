import 'package:call_management/home_screen.dart';
import 'package:call_management/provider/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LOGIN',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: provider.setUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              onChanged: provider.setPassword,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            if (provider.error != null) ...[
              SizedBox(height: 10),
              Text(provider.error!, style: TextStyle(color: Colors.red)),
            ],
            SizedBox(height: 20),
            provider.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      bool result = await provider.login();
                      if (result) {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String? fName = prefs.getString('FirstName');
                        String? lName = prefs.getString('LastName');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HomeScreen(username: "$fName $lName"),
                          ),
                        );
                      } else {
                       print("error");
                      }},
                    child: Text('LOG IN'),
                  ),
          ],
        ),
      ),
    );
  }
}
