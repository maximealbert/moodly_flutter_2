// ignore_for_file: prefer_const_constructors, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets/navigation_bottom_bar.dart';
import 'widgets/navigation_bottom_bar_manager.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner : false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2A5F54)),
        useMaterial3: true,
      ),
      home: const MoodyLogin(title: 'Moody'),
    );
  }
}

class MoodyLogin extends StatefulWidget {
  const MoodyLogin({super.key, required this.title});


  final String title;

  @override
  State<MoodyLogin> createState() => _MoodyLoginState();
}

class _MoodyLoginState extends State<MoodyLogin> {

  dynamic connecteduser; 
  final mailAdressTextField = TextEditingController();
  final passwordTextField = TextEditingController();
  var textOnboardConnectionManager = 'L\'application qui suit votre mood au quotidien';

  // Fetch request 
  Future<void> connectUser(String email, String password) async {
    final url = Uri.parse('http://localhost:1337/api/user-2s/');
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
          var rawdatausers = data['data'];
          // print(rawdatausers); 

          dynamic connecteduser;

          for (var i = 0; i < rawdatausers.length; i ++){

            if (rawdatausers[i]['email'] == email.toLowerCase() && rawdatausers[i]['password'] == password){
              print('Result founded');
              connecteduser = rawdatausers[i];
              // TODO : add error handling if two users got the same mail 
            }
          }

          if (connecteduser != null){
            // User has been founded 
            print(connecteduser['documentId'] + ' is the document if for current user');

            // Check if user is manager to show the good NavigationBottomBar
            if (connecteduser['ismanager'] == true){
              // user is a manager so we show the dashboard for his team view
              Navigator.pushAndRemoveUntil(context , MaterialPageRoute(builder : (context) => NavigationBottomNavBarManager(documentIdForSelectedUser: connecteduser['documentId'].toString(),)), (Route<dynamic> route)=> false);
            }else{
              Navigator.pushAndRemoveUntil(context , MaterialPageRoute(builder : (context) => NavigationBottomNavBar(documentIdForSelectedUser: connecteduser['documentId'].toString(),)), (Route<dynamic> route)=> false);
            }
            
            
            // Change page and show user Name on the page
          }else{
            textOnboardConnectionManager = 'Email ou mot de passe incorrect, veuillez essayer à nouveau';
          }
        
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      
      body: Center(
        
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
           
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bienvenue sur Moodly',
              ),
              Text(
                textOnboardConnectionManager,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 30),
              TextField (
                controller: mailAdressTextField,
                decoration: InputDecoration(
                  labelText: 'Email'
                ),
              ),
              const SizedBox(height: 30),
              TextField (
                controller: passwordTextField,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password'
                ),
              ),
              const SizedBox(height: 50),
              FloatingActionButton.extended(onPressed: (){
                print("Mail : " + mailAdressTextField.text);
                print("Password : " + passwordTextField.text);
                connectUser(mailAdressTextField.text, passwordTextField.text);
                
               

              }, label: const Text('Se connecter'))
            ],
          ),
        ),
      ) 
    );
  }
}




