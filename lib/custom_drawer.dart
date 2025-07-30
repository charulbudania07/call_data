import 'package:call_management/connected_call_screen.dart';
import 'package:call_management/follow_up_screen.dart';
import 'package:call_management/home_screen.dart';
import 'package:call_management/install_app_screen.dart';
import 'package:call_management/login_screen.dart';
import 'package:call_management/not_connected_screen.dart';
import 'package:call_management/other_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  final String username;

  const CustomDrawer({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          _buildHeader(username),
          _drawerItem(context, 'Home', Icons.home, HomeScreen(username: username,)),
          _drawerItem(context, 'Follow Up', Icons.assignment, FollowUpScreen(username: username,)),
          _drawerItem(context, 'Connected', Icons.check_circle, ConnectedScreen(username: username,)),
          _drawerItem(context, 'Not Connected', Icons.call_end, NotConnectedScreen(username: username,)),
          _drawerItem(context, 'Install App', Icons.install_mobile, InstallAppScreen(username: username,)),
          _drawerItem(context, 'Others', Icons.more_horiz, OthersScreen(username: username,)),
          _drawerItem(context, 'Logout', Icons.logout, LoginScreen(), isLogout: true),
        ],
      ),
    );
  }

  Widget _buildHeader(String username) {
    return UserAccountsDrawerHeader(
      accountName: Text(username),
      accountEmail: Text(''), // Optional: Add email
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 30),
      ),
      decoration: BoxDecoration(color: Colors.blue),
    );
  }

  Widget _drawerItem(BuildContext context, String title, IconData icon, Widget screen, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () async {
        Navigator.pop(context); // Close the drawer

        if (isLogout) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => screen),
                (route) => false,
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
    );
  }
}
