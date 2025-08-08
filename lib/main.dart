import 'package:call_management/home_screen.dart';
import 'package:call_management/login_screen.dart';
import 'package:call_management/provider/comment_provider.dart';
import 'package:call_management/provider/connected_call_provider.dart';
import 'package:call_management/provider/follow_up_provider.dart';
import 'package:call_management/provider/home_provider.dart';
import 'package:call_management/provider/install_app_provider.dart';
import 'package:call_management/provider/login_provider.dart';
import 'package:call_management/provider/not_connected_call_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ConnectedCallProvider()),
        ChangeNotifierProvider(create: (_) => NotConnectedCallProvider()),
        ChangeNotifierProvider(create: (_) => FollowUpProvider()),
        ChangeNotifierProvider(create: (_) => InstallAppProvider()),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? fName = prefs.getString('FirstName');
    String? lName = prefs.getString('LastName');
    if (token != null && token.isNotEmpty) {
      return HomeScreen(username: "$fName $lName"); // Replace with your real home screen
    } else {
      return  LoginScreen();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ConnectedCallProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Call Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: FutureBuilder<Widget>(
          future: _getInitialScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}
