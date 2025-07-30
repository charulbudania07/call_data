import 'package:call_management/custom_drawer.dart';
import 'package:flutter/material.dart';

class FollowUpScreen extends StatelessWidget {
  final String username;

  const FollowUpScreen({required this.username});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Follow Up')),
      drawer: CustomDrawer(username: username,),
      body: Center(child: Text('Follow Up Screen')),
    );
  }
}