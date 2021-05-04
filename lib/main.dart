import 'package:bloc_form/bloc/provider.dart';
import 'package:bloc_form/pages/home_page.dart';
import 'package:bloc_form/pages/login_page.dart';
import 'package:bloc_form/pages/product_page.dart';
import 'package:bloc_form/pages/register_page.dart';
import 'package:bloc_form/shared_preferences/user_preferences.dart';
import 'package:flutter/material.dart';

void main() async {
  final prefs = new UserPreferences();
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.initPrefs();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
        child: MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (BuildContext context) => LoginPage(),
        'home': (BuildContext context) => HomePage(),
        'product': (BuildContext context) => ProductPage(),
        'register': (BuildContext context) => RegisterPage(),
      },
      theme: ThemeData(primaryColor: Colors.deepPurple),
    ));
  }
}
