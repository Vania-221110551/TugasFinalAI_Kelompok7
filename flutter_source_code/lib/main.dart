
import 'package:flutter/material.dart';
import 'package:flutter_application_1/login.dart';
import 'package:sqflite/sqflite.dart';

import 'HomeScreen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DatabaseHelper().resetDatabase();
  runApp(const MaterialApp(home:Login(), debugShowCheckedModeBanner: false,));
}