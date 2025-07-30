import 'package:call_management/custom_drawer.dart';
import 'package:flutter/material.dart';

class InstallAppScreen extends StatelessWidget {
  final String username;

  const InstallAppScreen({super.key, required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Install App')),
      drawer: CustomDrawer(username: username,),
      body: Center(child: Text('Install App Screen')),
    );
  }
}