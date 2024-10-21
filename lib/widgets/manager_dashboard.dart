import 'package:flutter/material.dart';

class ManagerDashboard extends StatefulWidget {
  final String documentIdForSelectedUser;
  const ManagerDashboard({super.key, required this.documentIdForSelectedUser});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}