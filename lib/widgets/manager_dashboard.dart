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
  List usersInTeamStrapiId = [];
  List usersInTeamName = [];
  List usersInTeamPercentageForToday = [];
  List usersInTeamTagsForToday = [];
  double averagePercentageForToday = 0.0;
  List <Map<String, dynamic>> moodsThirtyDays = [];

  // list to show an average percentage by date
  Map<String, double> averageByDate = {};
  int numberOfDaysWithDate = 0;

  



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

                usersInTeamPercentageForToday.clear();
                usersInTeamTagsForToday.clear();
                
        

                for (dynamic user in usersInTeam){
                  //TODO : recupere les données de la team. il faut récupérer les données des utilisateurs et du manager
                    //print(user['documentId']);
                    usersInTeamDocumentId.add(user['documentId']);
                    final userNameFirstName = user['name'] + ' ' + user['firstname'];
                    usersInTeamName.add(userNameFirstName);
                    usersInTeamStrapiId.add(user['id']);
                }


                });
              
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




    //do the fetch request to get the mood for today for each user
    for (dynamic userDocId in usersInTeamDocumentId){
        final url = Uri.parse('http://localhost:1337/api/user-2s/' + userDocId + '?populate=*');
    
        try {
          final response = await http.get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          dynamic responseBody = jsonDecode(response.body);
          dynamic selectedUserData = responseBody['data'];
          dynamic selectedUserMoods = selectedUserData['moods'];

          print(selectedUserMoods);

          // if : check if there is a mood for today
          dynamic moodsList = selectedUserMoods.toList();

          // Check is there is a mood and change the value of the bool

          setState(() {
            if ((moodsList.where((item)=> item['mood_datetime'] == todaysDateFormatted)).isNotEmpty ){
           
            final percentageSelected = moodsList.where((item)=> item['mood_datetime'] == todaysDateFormatted).toList()[0]['percentage'];
            final tagSelected = moodsList.where((item) => item['mood_datetime'] == todaysDateFormatted).toList()[0]['tag'];
            usersInTeamPercentageForToday.add(percentageSelected);
            usersInTeamTagsForToday.add(tagSelected);
            }
          });
  
          



        }catch (error){
            print('Error getting the mood for each user $error');
        }
    }

    dynamic sum = 0;
    // Calculate the average percentage
    for (dynamic perc in usersInTeamPercentageForToday){
      sum += perc;
    }
    print(sum);
    averagePercentageForToday = (sum/usersInTeamPercentageForToday.length).toDouble();
    print(averagePercentageForToday);

    getDatasForThirtyDays(usersInTeamStrapiId);


     //print('All percentages for users mood : ' + usersInTeamPercentageForToday.toString());


  }

  Future<void> getDatasForThirtyDays(List usersId) async{


    // get the date of 30 days from now on
    final DateTime today = DateTime.now();
    final DateTime thirtyDaysAgo = today.subtract(Duration(days: 30));

    // Formater la date en "YYYY-MM-DD"
    String formattedDate = "${thirtyDaysAgo.year}-${thirtyDaysAgo.month.toString().padLeft(2, '0')}-${thirtyDaysAgo.day.toString().padLeft(2, '0')}";

    String userIdsFilter = usersId.map((id) => "filters[user][id][\$in]=$id").join('&');
     final String url = Uri.encodeFull("http://localhost:1337/api/moods"
      "?filters[mood_datetime][\$gte]=$formattedDate"
      "&populate=*"
      "&$userIdsFilter");
      
    const String token = '01622abb9cee851ac33e52935f57327301e841ecbeb33d436ec8ca003d55c930416b0c19279b96027bb09d63a65cbd1e3b9149ff5b08151c8383b0831fe1cd22cbfc8f51105e37d0d6b3a4d87cfc9ac33bd66c4e7272eb6b88dd458de4bf753d11d90c37b65e3926c6ebfd86ed486f3c11ff3cc9bf91435b5f03538a8ed478ba'; // Replace with your actual token

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          "Content-Type": "application/json; charset=UTF-8"
        },
      );

      // Check StatusCode
      if (response.statusCode == 200 || response.statusCode == 201){
        dynamic newData = jsonDecode(response.body);
        dynamic moods = newData['data'];

        for (dynamic mood in moods){
         
          final dataToAdd = {"percentage" : mood['percentage'], "date" : mood['mood_datetime']};
          moodsThirtyDays.add(dataToAdd);
        }

        Map<String, List<int>> percentageByDate = {};

        setState(() {
          for (var mood in moodsThirtyDays) {
          String date = mood['date'];
          int percentage = mood['percentage'];

          // Si la date existe déjà, ajoute le pourcentage à la liste
          if (percentageByDate.containsKey(date)) {
            percentageByDate[date]?.add(percentage);
          } else {
            // Sinon, crée une nouvelle entrée pour cette date
            percentageByDate[date] = [percentage];
          }
        }

        // Calculer la moyenne pour chaque date
        
        percentageByDate.forEach((date, percentages) {
          double average = percentages.reduce((a, b) => a + b) / percentages.length;
          averageByDate[date] = average;
        });

        // 
        numberOfDaysWithDate = averageByDate.length;

        // Afficher les moyennes par date
        averageByDate.forEach((date, avgPercentage) {
          print("Date: $date, Average Percentage: ${avgPercentage.toStringAsFixed(2)}");
        });
        });

        

      }else{
        print("no data founded");
      }

    }catch(err){
      print('Error in this fetch to get data from the 30 last days $err');
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
            GlobalMoodToday(documentId: widget.documentIdForSelectedUser, userStrapiId: userStrapiId, userInfos: selectedUserInfos, teamName: teamName, todaysMoodForUser: usersInTeamPercentageForToday, todaysTagsForUser: usersInTeamTagsForToday, averageMood: averagePercentageForToday,),
            MoodHistory(moodsByDate: averageByDate),
            
            
           
        ],),
      ));
  }
  
 
}

class GlobalMoodToday extends StatefulWidget {

  final documentId;
  final userStrapiId;
  final userInfos;
  final teamName;
  final todaysMoodForUser;
  final todaysTagsForUser ;
  final averageMood;

  const GlobalMoodToday({super.key, required this.documentId, required this.userStrapiId, required this.userInfos, required this.teamName, required this.todaysMoodForUser, required this.todaysTagsForUser, required this.averageMood});

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
            child: Text("Mood de l\'équipe " + widget.teamName.toString() + ' pour aujourd\'hui', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
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
                // child : widget.averageMood.toString != null ? Text('État général : ' + widget.averageMood.toString() + ' %', style: TextStyle(color: Colors.white),), : Text('Pas de moods renseignés pour aujourd\'hui' , style: TextStyle(color: Colors.white),),
                child: Text('État général : ' + widget.averageMood.toString() + ' %', style: TextStyle(color: Colors.white),),
              ),
            ),
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
                  'Pourcentages : ' + widget.todaysMoodForUser.join(', ') ,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Padding(
                      padding: const EdgeInsets.fromLTRB(15.0, 5, 15, 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A5F54),
                          borderRadius: BorderRadius.circular(25)
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Tags : ' + widget.todaysTagsForUser.join(', '),
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



class MoodHistory extends StatefulWidget {

  
  final moodsByDate;
  const MoodHistory({super.key, required this.moodsByDate});

  @override
  State<MoodHistory> createState() => _MoodHistoryState();
}

class _MoodHistoryState extends State<MoodHistory> {
  @override
  Widget build(BuildContext context) {

    print(widget.moodsByDate);
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 5, 10),
      child: Container(
        
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
        width: double.infinity,
        
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                padding: EdgeInsets.fromLTRB(15.0, 15, 15,0),
                child: Text("Mood sur 30 jours ", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              // LIST VIEW VUILDER
              widget.moodsByDate.isEmpty == true ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Pas de moods enregistrés sur les 30 derniers jours'),
              ) : Padding(
                padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
                child: Text(widget.moodsByDate.toString()),
              )
            ],
          ),
      ),
    );
  }
}