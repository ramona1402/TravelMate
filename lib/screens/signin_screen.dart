import 'package:firebase_auth/firebase_auth.dart';
import 'package:TravelMate/reusable_widgets/reusable_widget.dart';
import 'package:TravelMate/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:TravelMate/screens/signup_screen.dart';
import 'package:TravelMate/screens/reset_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFCDD7F5),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).size.height * 0.1,
              20,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Hi, Welcome Back!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Email",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                reusableTextField(
                  "Email",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Password",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                reusableTextField(
                  "Password",
                  Icons.lock_outline,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 0),

                if (errorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 211, 19, 5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                forgetPassword(context),
                const SizedBox(height: 20),
                firebaseUIButton(context, "Login", () {
                  String email = _emailTextController.text;
                  String password = _passwordTextController.text;

                  if (email.isEmpty || password.isEmpty) {
                    setState(() {
                      errorMessage = "Please fill in both email and password.";
                    });
                    return;
                  }

                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      )
                      .then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      })
                      .catchError((error) {
                        setState(() {
                          errorMessage = 'Wrong email or password.';
                        });
                      });
                }),
                const SizedBox(height: 135),
                signUpOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          child: const Text(
            "Register",
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.black),
          textAlign: TextAlign.right,
        ),
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ResetPassword()),
            ),
      ),
    );
  }
}
