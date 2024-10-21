// lib/widgets/profil.dart

import 'package:flutter/material.dart';
import '../main.dart';

//CALENDAR page
class Profil extends StatefulWidget {
  final String documentIdForSelectedUser;
  const Profil({
    super.key,
    required this.documentIdForSelectedUser
  });

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FloatingActionButton(onPressed: (){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder : (context) => const MoodyLogin(title: 'Moodly',)), (Route<dynamic> route)=> false);
        
             
    }, child: const Icon(Icons.exit_to_app),));
  }
}