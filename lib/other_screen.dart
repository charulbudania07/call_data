import 'package:call_management/custom_drawer.dart';
import 'package:flutter/material.dart';

class OthersScreen extends StatelessWidget {
  final String username;

  const OthersScreen({required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Others')),
      drawer: CustomDrawer(username: username,),
      body: Center(child: Text('Others Screen')),
    );
  }
}