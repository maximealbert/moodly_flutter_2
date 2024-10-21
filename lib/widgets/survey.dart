// lib/widgets/rse_survey.dart

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

//Sondages RSE 
class RSESurvey extends StatelessWidget {
  final String documentIdForSelectedUser;
  const RSESurvey({
    super.key,
    required this.documentIdForSelectedUser
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Text('Sondage RSE'));
  }
}