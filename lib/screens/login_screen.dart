import 'package:flutter/material.dart';
import 'package:note_app/screens/notes_screen.dart';
import 'package:note_app/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  String? userNameEmpty;
  String? passwordEmpty;
  String? userName, userPass;

  bool showPassword = true;

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('user_name');
    userPass = prefs.getString('user_pass');
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(children: [
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(
                      labelText: "Enter your name!", errorText: userNameEmpty),
                ),
                TextField(
                  obscureText: showPassword,
                  decoration: InputDecoration(
                    suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            if (showPassword == false) {
                              showPassword = true;
                            } else {
                              showPassword = false;
                            }
                          });
                        },
                        icon: showPassword == false
                            ? const Icon(Icons.hide_source)
                            : const Icon(Icons.remove_red_eye)),
                    labelText: "Enter your Password!",
                    errorText: passwordEmpty,
                  ),
                  controller: userPasswordController,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    setState(() {
                      if (userNameController.text.isEmpty) {
                        userNameEmpty = "Name is required!";
                      } else if (userPasswordController.text.isEmpty) {
                        userNameEmpty = null;
                        passwordEmpty = "Password is required!";
                      } else {
                        prefs.setBool('is_login', true);
                        if (userNameController.text == userName &&
                            userPasswordController.text == userPass) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NoteApp(),
                              ));
                        } else if (userNameController.text != userName) {
                          userNameEmpty = "Wrong user name entered!";
                          passwordEmpty = null;
                        } else if (userPasswordController.text != userPass) {
                          passwordEmpty = "Wrong Password!";
                          userNameEmpty = null;
                        }
                      }
                    });
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              right: 0,
              left: 0,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ));
                      },
                      child: const Text('Create account'))
                ],
              ))
        ]),
      ),
    );
  }
}
