// lib/widgets/main_dashboard.dart

// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings, unused_field, unused_local_variable

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
  dynamic dateMood;
  
  dynamic selectedUserTeam; // to get all informations (isManager boolean, team, ...)
  String userName = '';
  String userFirstName = '';
  String teamName = '';
  int userStrapiId = 0; 
  Image userImage = Image(image: NetworkImage('https://petiteshistoiresdessciences.com/wp-content/uploads/2019/12/image-1.png'));
  String todaysDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());


  String percentageForDate = '';
  String tagForDate = '';

  // date config
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  // boolean if a mood has been founded for today (first launch)
  bool moodFound = false;
  



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
        setState(() {
          dynamic userDatas = data['data'];
          // set controllers to the good values
          moods = userDatas['moods'];
          selectedUserTeam = userDatas['team'][0];
          teamName = selectedUserTeam['Name'];
          print(selectedUserTeam);
          userFirstName = userDatas['firstname'];
          userName = userDatas['name'];
          final userProfilePictureLvlOne = userDatas['userProfilePicture'];
          final userPPLvlTwo = userProfilePictureLvlOne['formats'];
          final userPPMedium = userPPLvlTwo['medium'];
          final urlImage = 'http://localhost:1337' + userPPMedium['url'];
          userImage = Image(image: NetworkImage(urlImage,));
          userStrapiId = userDatas['id'];

          final moodsList = userDatas['moods'].toList();

          // Check is there is a mood and change the value of the bool
          moodsList.isEmpty ? moodFound = true : moodFound = false;
  
          if ((moodsList.where((item)=> item['mood_datetime'] == todaysDateFormatted)).isEmpty ){
            print('No mood found for this date');
            todaysMood = null;
            moodFound = false;
            
          }else{
            print('mood found for this date');
            todaysMood = moodsList.where((item)=> item['mood_datetime'] == todaysDateFormatted);
            moodFound = true;
          }

        
        
         
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> getDatasForDate(String documentId, String dateSelected) async {
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
          final moodsList = userDatas['moods'].toList();
          // print(moodsList);
          dateMood = moodsList.where((item)=> item['mood_datetime'] == dateSelected);
          print(dateMood.toList()[0]);

          if (dateMood != null){
            print(dateSelected);
            print('Mood has been found for this date');
            print(dateMood);
            tagForDate = dateMood.toList()[0]['tag'].toString();
            percentageForDate = dateMood.toList()[0]['percentage'].toString();
          }else{
            tagForDate = 'Pas de mood pour cette date';
            percentageForDate = 'Pas de mood pour cette date';
          }


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
        final formattedDateForFunc = _dateFormatter.format(pickedDate);
        
        // _dateFormatter.format(_selectedDate!)
        getDatasForDate(widget.documentIdForSelectedUser, formattedDateForFunc.toString());
      });
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
                      Text('Bienvenue', style: TextStyle(fontSize: 15)),
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
            moodFound == false ? MoodNotFilled(documentId: widget.documentIdForSelectedUser, userStrapiId: userStrapiId,) : TodaysMoodFilled(moodForToday: todaysMood,),

            // TODO: dev en cours - a changer
            //MoodNotFilled(documentId: widget.documentIdForSelectedUser, userStrapiId : userStrapiId),
            

            

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
                      padding: const EdgeInsets.fromLTRB(15.0, 10, 15, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF2A5F54),
                          borderRadius: BorderRadius.circular(25)
               
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Pourcentage : ' + percentageForDate,
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
                  'Tag : ' + tagForDate,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
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

class MoodNotFilled extends StatefulWidget {

  final documentId;
  final userStrapiId;

  const MoodNotFilled({super.key, required this.documentId, required this.userStrapiId});

  @override
  State<MoodNotFilled> createState() => _MoodNotFilledState();
}

class _MoodNotFilledState extends State<MoodNotFilled> {

  // Controllers
  double _sliderValue = 0.0;
  String? selectedTag;

  // TODO: définir les tags (dynamique depuis Strapi ?)
  final tagsList = <String>['Burn-out', 'Épuisé', 'Fatigué', 'Stressé', 'Débordé', 'Anxieux', 'Frustré', 'Irrité', 'Sous pression', 'Nerveux', 'Déconcentré', 'Distrait', 'Appréhensif', 'Indifférent', 'Fatigué mais motivé', 'Calme', 'Posé', 'Optimiste', 'Motivé', 'Serein', 'Confiant', 'Inspiré', 'Créatif', 'Energique', 'Enthousiaste', 'Heureux', 'Joyeux', 'Exalté', 'Rayonnant', 'Enjoué'];

  // date config
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
  String todaysDateFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
  // User data is transfer with the user's documentId

  String _feelingEmoji = '😁';

  String _getEmoji (int sliderValueVoid){
    if (sliderValueVoid >= 0 && sliderValueVoid <= 20){
      return '😩';
    }else if (sliderValueVoid > 20 && sliderValueVoid <= 40){
      return '😕';
    }else if (sliderValueVoid > 40 && sliderValueVoid <= 60){
      return '😐';
    }else if (sliderValueVoid > 60 && sliderValueVoid <= 80){
      return '🙂';
    }else{
      return '😃';
    }
  }



  Future<void> addMood() async {

    // Structure the data 
    final newMoodData = jsonEncode({
      "data" : {
         "percentage" : _sliderValue,
         "mood_datetime" : todaysDateFormatted,
         "tag" : selectedTag,
         "user" : [
          {
            "id" : widget.userStrapiId
          }
         ] 
      }
    });

    // Define the URL
    final url = Uri.parse('http://localhost:1337/api/moods');

    // Define the headers
    final headers = {
      "Content-type" : "application/json",
      "Authorization" : "Bearer 01622abb9cee851ac33e52935f57327301e841ecbeb33d436ec8ca003d55c930416b0c19279b96027bb09d63a65cbd1e3b9149ff5b08151c8383b0831fe1cd22cbfc8f51105e37d0d6b3a4d87cfc9ac33bd66c4e7272eb6b88dd458de4bf753d11d90c37b65e3926c6ebfd86ed486f3c11ff3cc9bf91435b5f03538a8ed478ba "
    };

    final response = await http.post(url, headers: headers, body: newMoodData);

    if (response.statusCode == 200 || response.statusCode == 201){
        // Response OK
        // perform actions here 

        final temp = jsonDecode(response.body);
        print(temp['data']);
        Navigator.of(context).pop();
    }else{
      print("Failed to add mood : ${response.body}");
    }





  }


  void _showModalAddMood(){
    showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          
          title: Text('Add your mood'),
          content: StatefulBuilder(
          
              builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
            children:  [

              Text('Comment vous sentez-vous aujourd\'hui ?'),
              Row(
                children: [
                  Text(_sliderValue.toDouble().toStringAsFixed(1)),
                  Slider(value: _sliderValue, min: 0, max: 100, divisions: 10, label: _getEmoji(_sliderValue.toInt()) ,onChanged: (double value)  {
                    setState(() {
                      _sliderValue = value;
                    });
                  })

                  ],
              ),
              SizedBox(height: 30,),
              Text('Comment définiriez-vous votre mood ?'),
              DropdownButton<String>(
                value: selectedTag,
                hint: Text('Option'),
                items: tagsList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTag = newValue; // Mettre à jour la sélection
                  });
                },
              ),

            ],
          );
              },

            ),
          actions: [
            TextButton.icon(onPressed: (){Navigator.of(context).pop();}, icon: Icon(Icons.close), label: Text('Annuler')),
            TextButton.icon(onPressed: (){
              // call method here to add the mood to Strapi
              addMood();
            }, icon: Icon(Icons.add), label: Text('Enregistrer')),
          ],
        );
    });
  }

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
                  _showModalAddMood();
                }, 
              icon: Icon(Icons.add), label: Text('Ajouter votre mood du jour')
            ),
          )
        ],
      ),
    );
  }
}