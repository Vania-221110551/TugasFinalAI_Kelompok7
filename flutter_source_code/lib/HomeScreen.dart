import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/DB/DatabaseHelper.dart';
import 'package:sqflite/sqflite.dart';

import 'RecognitionScreen.dart';
import 'RegistrationScreen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(margin: const EdgeInsets.only(top: 100),child: Image.asset("images/logo.png",width: screenWidth-40,height: screenWidth-40,)),
          Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // await _databaseHelper.dropTable();

                    // setState((){
                    // });
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const RegistrationScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth-30, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontFamily: "PlusJakartaSans")
                  ), 
                  child: const Text("Register"),),
                Container(height: 20,),
                ElevatedButton(
                  onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const RecognitionScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(screenWidth-30, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: TextStyle(fontFamily: "PlusJakartaSans")
                  ),
                  child: const Text("Recognize"),),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
