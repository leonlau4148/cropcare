import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Routes/generated_routes.dart';
import 'package:cropcare/Routes/constants/routes.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp (
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.white,
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.brown),
              hintStyle: TextStyle(color: Colors.brown),
            )),
        debugShowCheckedModeBanner: false,
        initialRoute: loginRoute,
        onGenerateRoute: RouteGenerator().generateRoute,
      ),

  );
}


