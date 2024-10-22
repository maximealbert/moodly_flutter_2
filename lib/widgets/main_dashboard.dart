// lib/widgets/main_dashboard.dart
// 

// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Since you're using DateFormat
import 'package:http/http.dart' as http;

// Dashboard principal
class MainDashboard extends StatefulWidget {
  final String documentIdForSelectedUser;
  const MainDashboard({
    super.key, 
    required this.documentIdForSelectedUser,
  });

  


  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {

  // Controllers for data (use setState to modify) - with default values when needed
  dynamic moods; // to get all mood history
  dynamic todaysMood; 
  
  dynamic selectedUserTeam; // to get all informations (isManager boolean, team, ...)
  String userName = '';
  String userFirstName = '';
  String teamName = '';
  Image userImage = Image(image: NetworkImage('https://petiteshistoiresdessciences.com/wp-content/uploads/2019/12/image-1.png'));
  String todaysDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // date config
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  



  // Fetch to get all datas concerning the user
  Future<void> getDatas(String documentId) async {

    print('get datas method called');

    final url = Uri.parse('http://localhost:1337/api/user-2s/' + documentId + '?populate=*');
    const String token = '01622abb9cee851ac33e52935f57327301e841ecbeb33d436ec8ca003d55c930416b0c19279b96027bb09d63a65cbd1e3b9149ff5b08151c8383b0831fe1cd22cbfc8f51105e37d0d6b3a4d87cfc9ac33bd66c4e7272eb6b88dd458de4bf753d11d90c37b65e3926c6ebfd86ed486f3c11ff3cc9bf91435b5f03538a8ed478ba'; // Replace with your actual token

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        setState(() {
          dynamic userDatas = data['data'];
          // set controllers to the good values
          moods = userDatas['moods'];
          selectedUserTeam = userDatas['team'];
          teamName = selectedUserTeam['Name'];
          print(selectedUserTeam);
          userFirstName = userDatas['firstname'];
          userName = userDatas['name'];
          final userProfilePictureLvlOne = userDatas['userProfilePicture'];
          final userPPLvlTwo = userProfilePictureLvlOne['formats'];
          final userPPMedium = userPPLvlTwo['medium'];
          final urlImage = 'http://localhost:1337' + userPPMedium['url'];
          userImage = Image(image: NetworkImage(urlImage,));

          moods = userDatas['moods'].toList();
          
          
         
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  
  
  // function to show the date picker and get back the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Show current date by default
      firstDate: DateTime(2023),  // Earliest date that can be selected
      lastDate: DateTime(2026),   // Latest date that can be selected
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Override the initState void to call a method everytime when the widget is loaded
  @override
  void  initState (){
    print('Init state method called');
    getDatas(widget.documentIdForSelectedUser);
  }


  @override
  Widget build(BuildContext context) {


    // call method to get datas and populate the view

    String documentId = widget.documentIdForSelectedUser;


    return  SafeArea(child: 
      Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ROW : Avatar, nom, button cloche
            Row(crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    
                    radius: 40,
                    backgroundImage: userImage.image,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenue', style: TextStyle(fontSize: 15)),
                      Text(userFirstName , style: TextStyle(fontSize: 25)),
                      Text(teamName , style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              
              
              IconButton(onPressed: (){
                print('Hello world');
              }, icon: Icon(Icons.notifications_active))
            ],),
            SizedBox(height: 30,),
            
            // BLOC 1 : mood du jour (selon si la variable todaysMood est cide )
            // todaysMood != null ? TodaysMoodFilled() : MoodNotFilled(),
            TodaysMoodFilled(),
            

            // BLOC 2 : historique des moods 
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
                
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
                      child: Text('Historique de vos moods', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: FilledButton(
                        
                        onPressed: (){
                          _selectDate(context);
                        }, 
                        child: Text(_selectedDate == null ? 'Select date' : 'Votre mood du jour : ' + _dateFormatter.format(_selectedDate!) )
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),

            // BLOC 3 : boite à idées
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
              
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
                    child: Text('Boîte à idées', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: FilledButton.icon(
                      
                      onPressed: (){
                        print('Add your mood for today');
                      }, 
                      icon: Icon(Icons.lightbulb), label: Text('Suggérer une idée')
                    ),
                  )
                ],
              ),
            ),
           
        ],),
      ));
  }
  
 
}

class TodaysMoodFilled extends StatefulWidget {


  const TodaysMoodFilled({
    super.key,
    
  });

  @override
  State<TodaysMoodFilled> createState() => _TodaysMoodFilledState();
}

class _TodaysMoodFilledState extends State<TodaysMoodFilled> {
  @override
  Widget build(BuildContext context) {



      return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
      
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
            child: Text('Votre mood du jour', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FilledButton.icon(
              
              onPressed: (){
                print('Add your mood for today');
              }, 
              icon: Icon(Icons.add), label: Text('Un mood existe déjà')
            ),
          )
        ],
      ),
    );
    

    
  }
}

class MoodNotFilled extends StatefulWidget {
  const MoodNotFilled({super.key});

  @override
  State<MoodNotFilled> createState() => _MoodNotFilledState();
}

class _MoodNotFilledState extends State<MoodNotFilled> {
  @override
  Widget build(BuildContext context) {
    
      // No mood filled, add mood button is shown
      return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
      
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
            child: Text('Votre mood du jour', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FilledButton.icon(
              
              onPressed: (){
                print('Add your mood for today');
              }, 
              icon: Icon(Icons.add), label: Text('Ajouter votre mood du jour')
            ),
          )
        ],
      ),
    );
  }
}