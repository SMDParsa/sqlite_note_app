import 'package:flutter/material.dart';
import 'package:note_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  String? userNameEmpty;
  String? passwordEmpty;

  bool showPassword = true;

  String? userName;
  String? userPass;

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
                  'Sign Up',
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
                    if (userNameController.text.isNotEmpty &&
                        userPasswordController.text.isNotEmpty) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString(
                          'user_name', userNameController.text);
                      await prefs.setString(
                          'user_pass', userPasswordController.text);

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Account created! Please login")));

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    }

                    setState(() {
                      if (userNameController.text.isEmpty) {
                        userNameEmpty = "Name is required!";
                      } else if (userPasswordController.text.isEmpty) {
                        userNameEmpty = null;
                        passwordEmpty = "Password is required!";
                      } else {
                        userNameEmpty = null;
                        passwordEmpty = null;
                      }
                    });
                  },
                  child: const Text(
                    "Create Account",
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
                  const Text('Already have an account?'),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Please Login'))
                ],
              ))
        ]),
      ),
    );
  }
}
