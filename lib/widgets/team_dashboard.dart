// lib/widgets/team_dashboard.dart

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';


// Dashboard équipe
class TeamDashboard extends StatelessWidget {

  final String documentIdForSelectedUser;
  const TeamDashboard({
    super.key,
    required this.documentIdForSelectedUser
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Text('Dashboard team'));
  }
}