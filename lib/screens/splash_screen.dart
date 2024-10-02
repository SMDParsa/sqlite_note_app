import 'package:flutter/material.dart';
import 'package:note_app/screens/notes_screen.dart';
import 'package:note_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  Future<void> _loadThemePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.containsKey('is_darkmode')) {
        _isDarkMode = prefs.getBool('is_darkmode') ?? false;
      } else {
        _isDarkMode = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadThemePrefs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode == true ? ThemeData.dark() : ThemeData.light(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isLogin;

  Future<void> _getLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('is_login')) {
      setState(() {
        isLogin = prefs.getBool('is_login') ?? false;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _getLoginInfo();

    Future.delayed(const Duration(seconds: 3)).then(
      (value) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            if (isLogin == true && isLogin != null) {
              return const NoteApp();
            } else {
              return const LoginScreen();
            }
          },
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note,
              size: 50,
            ),
            Text(
              'SQLite Note App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('version 1.0.0')
          ],
        ),
      ),
    );
  }
}
