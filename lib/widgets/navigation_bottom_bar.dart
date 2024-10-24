// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// Import widgets for BottomNavigationBar
import 'main_dashboard.dart';
import 'idea_view.dart';
import 'survey.dart';
import 'profile.dart';

// NAVIGATION BAR
class NavigationBottomNavBar extends StatefulWidget {

  final String documentIdForSelectedUser;

  const NavigationBottomNavBar({super.key, required this.documentIdForSelectedUser});


  @override
  State<NavigationBottomNavBar> createState() =>
      _NavigationBottomNavBarState();
}

class _NavigationBottomNavBarState
    extends State<NavigationBottomNavBar> {

      
  int _selectedIndex = 0;
  // ignore: unused_field
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> widgetOptions = <Widget>[

    // Toutes les pages à inclure dans le widget
    MainDashboard(documentIdForSelectedUser: widget.documentIdForSelectedUser,),
    IdeaView(documentIdForSelectedUser: widget.documentIdForSelectedUser,),
    RSESurvey(documentIdForSelectedUser: widget.documentIdForSelectedUser,),
    Profil(documentIdForSelectedUser: widget.documentIdForSelectedUser,),
    
  ];

    return Scaffold(
      
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            backgroundColor:Color(0xFF2A5F54),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Idée',
            backgroundColor:Color(0xFF2A5F54)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.where_to_vote),
            label: 'Sondages',
            backgroundColor:Color(0xFF2A5F54)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profil', 
            backgroundColor:Color(0xFF2A5F54)
          )
          
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}












