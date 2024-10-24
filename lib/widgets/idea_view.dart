// lib/widgets/team_dashboard.dart

// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// Dashboard équipe
class IdeaView extends StatefulWidget {

  final String documentIdForSelectedUser;
  const IdeaView({
    super.key,
    required this.documentIdForSelectedUser
  });

  @override
  State<IdeaView> createState() => _IdeaViewState();
}

class _IdeaViewState extends State<IdeaView> {



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IdeasPage()
    );
  }
}


class IdeasPage extends StatefulWidget {
  @override
  _IdeasPageState createState() => _IdeasPageState();
}

class _IdeasPageState extends State<IdeasPage> {
  List ideas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchIdeas();
  }

  // Function to fetch ideas from Strapi
  Future<void> fetchIdeas() async {
        try {
            final responseIdea = await http.get(Uri.parse('http://localhost:1337/api/ideas'), headers: {
          'Authorization': 'Bearer 01622abb9cee851ac33e52935f57327301e841ecbeb33d436ec8ca003d55c930416b0c19279b96027bb09d63a65cbd1e3b9149ff5b08151c8383b0831fe1cd22cbfc8f51105e37d0d6b3a4d87cfc9ac33bd66c4e7272eb6b88dd458de4bf753d11d90c37b65e3926c6ebfd86ed486f3c11ff3cc9bf91435b5f03538a8ed478ba',
            },);

            if (responseIdea.statusCode == 200 || responseIdea.statusCode == 201){
                setState(() {
                  print('get datas');
                  ideas = json.decode(responseIdea.body)['data'];
                  isLoading = false;
                });
            }

          }catch (error) {
              print('Error fetching teams : $error');
          }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
          : ListView.builder(
              itemCount: ideas.length,
              itemBuilder: (context, index) {
                var idea = ideas[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Color(0xFFD4DFDD),),
                  
                   width: double.infinity,
                    child: ListTile(
                      title: Text(idea['idea']), // Display idea title
                    ),
                  ),
                );
              },
            ),
    );
  }
}