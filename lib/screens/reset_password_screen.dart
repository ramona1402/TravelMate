import 'package:firebase_auth/firebase_auth.dart';
import 'package:TravelMate/reusable_widgets/reusable_widget.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
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
                if (errorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 211, 19, 5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                firebaseUIButton(context, "Reset Password", () async {
                  setState(() {
                    errorMessage = '';
                  });

                  if (_emailTextController.text.trim().isEmpty) {
                    setState(() {
                      errorMessage = 'Please enter your email.';
                    });
                    return;
                  }

                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: _emailTextController.text.trim(),
                    );
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Check your email'),
                            content: const Text(
                              'If an account exists for this email, you will receive a password reset link.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                    );
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      if (e.code == 'invalid-email') {
                        errorMessage = 'The email address is badly formatted.';
                      } else {
                        errorMessage =
                            e.message ?? 'An unexpected error occurred.';
                      }
                    });
                  } catch (e) {
                    setState(() {
                      errorMessage = 'An unexpected error occurred.';
                    });
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
