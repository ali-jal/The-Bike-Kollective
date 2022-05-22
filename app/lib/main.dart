import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_bike_kollective/get-photo.dart';
import 'add_bike_page.dart';
import 'package:the_bike_kollective/bike_list_view.dart';
import 'home_view.dart';
import 'models.dart';
import 'mock_data.dart';
import 'profile_view.dart';
import 'bike_list_view.dart';
import 'Login/user_agreement.dart';
import 'Login/spash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

Future<void> main() async {
  fillMockList();
  print(mockList.bikes[0].name);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MainPage());
}

// information/instructions: Flutter Widget, renders the MainScreen
// widget. This widget is the root of the application. The class
// also contains ThemeData(), which will hold a lot of the style info.
// @params: no params
// @return: nothing returned
// bugs: no known bugs
// TODO: Fill in themeData info.

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  App createState() => App();
}

class App extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'The Bike Kollective',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const HomeView(),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const HomeView(),
        ProfileView.routeName: (context) => const ProfileView(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/bike-list': (context) => const BikeListView(),
        // TODO: We will need to change the user to the current user at some point.
        '/add-bike': (context) => const AddBikePage(),
        // When google redirects user to splash screen
        '/spash-screen': (context) => const SplashScreen(),
        // user is directed to agreement page if first time making account
        '/user-agreement': (context) => AgreementPage(),
        GetPhoto.routeName: (context) => const GetPhoto(),
        AddBikePage.routeName: (context) => const AddBikePage(),
      },
    );
  }
}