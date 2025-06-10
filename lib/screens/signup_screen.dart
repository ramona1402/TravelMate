import 'package:firebase_auth/firebase_auth.dart';
import 'package:TravelMate/reusable_widgets/reusable_widget.dart';
import 'package:TravelMate/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:TravelMate/screens/signin_screen.dart';
import 'package:email_validator/email_validator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  bool validateEmail(String email) {
    return EmailValidator.validate(email);
  }

  bool validatePassword(String password) {
    // Parola trebuie să aibă cel puțin 6 caractere, o literă mare, o literă mică și un caracter special
    RegExp passwordRegExp = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
    );
    return passwordRegExp.hasMatch(password);
  }

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
                        "Create an account",
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
                  "Name",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                reusableTextField(
                  "Name",
                  Icons.person_outline,
                  false,
                  _nameTextController,
                ),
                const SizedBox(height: 10),
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
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(height: 50),
                if (errorMessage != null)
                  Center(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 211, 19, 5),
                      ),
                    ),
                  ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                if (!isLoading)
                  firebaseUIButton(context, "Register", () async {
                    setState(() {
                      isLoading = true;
                    });
                    String email = _emailTextController.text;
                    String password = _passwordTextController.text;
                    String name = _nameTextController.text;
                    if (email.isEmpty || password.isEmpty || name.isEmpty) {
                      setState(() {
                        errorMessage = "Please fill in all fields.";
                        isLoading = false;
                      });
                      return;
                    }

                    if (!validateEmail(email)) {
                      setState(() {
                        errorMessage = "Please enter a valid email address.";
                        isLoading = false;
                      });
                      return;
                    }

                    if (!validatePassword(password)) {
                      setState(() {
                        errorMessage = "Password is too simple.";
                        isLoading = false;
                      });
                      return;
                    }

                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                      await userCredential.user?.updateDisplayName(name);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } on FirebaseAuthException catch (error) {
                      setState(() {
                        if (error.code == 'email-already-in-use') {
                          errorMessage = 'This email is already in use.';
                        } else {
                          errorMessage = 'An unexpected error occurred.';
                        }
                        isLoading = false;
                      });
                    }
                  }),
                const SizedBox(height: 50),
                signInOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            );
          },
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
