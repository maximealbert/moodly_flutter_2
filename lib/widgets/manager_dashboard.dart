// lib/widgets/main_dashboard.dart

// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings, unused_field, unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Since you're using DateFormat
import 'package:http/http.dart' as http;

// Dashboard principal
class ManagerDashboard extends StatefulWidget {
  final String documentIdForSelectedUser;
  const ManagerDashboard({
    super.key, 
    required this.documentIdForSelectedUser,
  });


  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {

  // Controllers for data (use setState to modify) - with default values when needed
  dynamic moods; // to get all mood history
  dynamic todaysMood; 
  dynamic dateMood;
  dynamic selectedUserInfos;
  dynamic selectedUserTeam; // to get all informations (isManager boolean, team, ...)
  String userName = '';
  String userFirstName = '';
  String teamName = '';
  int userStrapiId = 0; 
  Image userImage = Image(image: NetworkImage('https://petiteshistoiresdessciences.com/wp-content/uploads/2019/12/image-1.png'));
  String todaysDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String teamDocumentId = '';

  String percentageForDate = '';
  String tagForDate = '';

  // date config
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // boolean if a mood has been founded for today (first launch)
  bool moodFound = false;


  // Controllers for all users in team (including the manager)
  List usersInTeamDocumentId = [];
  List usersInTeamName = [];
  List usersInTeamPercentageForGivenDate = [];
  List usersInTeamTagsForGivenDate = [];

  



  // Fetch to get all datas concerning the user
  Future<void> getDatas(String documentId) async {

    // Reset value to be sure to get back the good view (MoodFilled or not)
    todaysMood = null;

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
        setState(()  {
          dynamic userDatas = data['data'];
          // set controllers to the good values
          moods = userDatas['moods'];
          selectedUserTeam = userDatas['team'][0];
          selectedUserInfos = userDatas;
          teamName = selectedUserTeam['Name'];
          teamDocumentId = selectedUserTeam['documentId'];
          print(selectedUserTeam);
          userFirstName = userDatas['firstname'];
          userName = userDatas['name'];
          final userProfilePictureLvlOne = userDatas['userProfilePicture'];
          final userPPLvlTwo = userProfilePictureLvlOne['formats'];
          final userPPMedium = userPPLvlTwo['medium'];
          final urlImage = 'http://localhost:1337' + userPPMedium['url'];
          userImage = Image(image: NetworkImage(urlImage,));
          userStrapiId = userDatas['id'];


          });
        

          // Get the list of all users Id in the team (including the manager)
          // make the request http://localhost:1337/api/teams/f38mv9wdew19j2v7fdi162t4?populate=* with the teamDOcu
          dynamic idUsersInTeam;

          final urlTeams = Uri.parse("http://localhost:1337/api/teams/" + teamDocumentId + '?populate=*');  
          try {
            final responseTeam = await http.get(urlTeams, headers: {
          'Authorization': 'Bearer $token',
            },);

            if (responseTeam.statusCode == 200 || responseTeam.statusCode == 201){
              print('No error fetching teams');
              dynamic dataTeam = jsonDecode(responseTeam.body);
              setState(()  {
                dynamic dataTeams = dataTeam['data'];
                dynamic usersInTeam = dataTeams['users'];
                print(usersInTeam);
                for (dynamic user in usersInTeam){
                  //TODO : recupere les données de la team. il faut récupérer les données des utilisateurs et du manager
                    //print(user['documentId']);
                    usersInTeamDocumentId.add(user['documentId']);
                    final userNameFirstName = user['name'] + ' ' + user['firstname'];
                    usersInTeamName.add(userNameFirstName);
                    
                }


                });


                // do the fetch request to get the mood for today for each user
                for (var index = 0; index <= usersInTeamDocumentId.length; index ++){
                    final url = Uri.parse('http://localhost:1337/api/user-2s/' + documentId + '?populate=*');
                
                    try {
                      final response = await http.get(
                        url,
                        headers: {
                          'Authorization': 'Bearer $token',
                        },
                      );



                    }catch (error){
                        print('Error getting the mood for each user $error');
                    }
                }

               

              
            }

          }catch (error) {
              print('Error fetching teams : $error');
          }


         
        
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }




  // Override the initState void to call a method everytime when the widget is loaded
  @override
  void  initState (){
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
                      Text('Profil manager', style: TextStyle(fontSize: 15)),
                      Text(userFirstName , style: TextStyle(fontSize: 25)),
                      Text(teamName , style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ],
              ),
              
              
              IconButton(onPressed: (){
                getDatas(widget.documentIdForSelectedUser);
              }, icon: Icon(Icons.notifications_active))
            ],),
            SizedBox(height: 30,),
            
            // BLOC 1 : mood du jour (selon si la variable todaysMood est vide )
            GlobalMoodToday(documentId: widget.documentIdForSelectedUser, userStrapiId: userStrapiId, userInfos: selectedUserInfos, teamName: teamName)

            
            
           
        ],),
      ));
  }
  
 
}

class TodaysMoodFilled extends StatefulWidget {

  final moodForToday;


  const TodaysMoodFilled({
    super.key,
    required this.moodForToday
    
  });

  @override
  State<TodaysMoodFilled> createState() => _TodaysMoodFilledState();
}

class _TodaysMoodFilledState extends State<TodaysMoodFilled> {


  // controllers
  String percentageToday = '';
  String tagToday = '';


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {

      if (widget.moodForToday.isEmpty){
        print('Null value founded');
      }else{
        percentageToday = widget.moodForToday.toList()[0]['percentage'].toString();
         tagToday = widget.moodForToday.toList()[0]['tag'].toString();
      }

     

    });
  }

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
            padding: const EdgeInsets.fromLTRB(15.0, 10, 15, 10),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A5F54),
                borderRadius: BorderRadius.circular(25)
               
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Pourcentage : '+percentageToday,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A5F54),
                borderRadius: BorderRadius.circular(20)
               
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Tag : '+tagToday,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    

    
  }
}

class GlobalMoodToday extends StatefulWidget {

  final documentId;
  final userStrapiId;
  final userInfos;
  final teamName;

  const GlobalMoodToday({super.key, required this.documentId, required this.userStrapiId, required this.userInfos, required this.teamName});

  @override
  State<GlobalMoodToday> createState() => _GlobalMoodTodayState();
}

class _GlobalMoodTodayState extends State<GlobalMoodToday> {

  
  // date config
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  String todaysDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
  // User data is transfer with the user's documentId

  

  @override
  Widget build(BuildContext context) {
    
      // No mood filled, add mood button is shown
      return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
      
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
            padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
            child: Text("Mood de l\'équipe " + widget.teamName.toString(), style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: FilledButton.icon(
              
              onPressed: (){
                  print('Button pressed');
                }, 
              icon: Icon(Icons.add), label: Text('Ajouter votre mood du jour')
            ),
          )
        ],
      ),
    );
  }
}