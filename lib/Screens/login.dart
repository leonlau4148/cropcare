import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcare/Utility/show_error_dialog.dart';
import 'package:cropcare/Routes/constants/routes.dart';


class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            color: Colors.brown,
            fontSize: 32.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
        ),

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Email',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      )
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 20),
                      ),
                    ),
                  ),
                ],
              ),
        
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text('Password',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      )
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
        
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        landingPageRoute,
                            (_) => false,
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-email') {
                      await showErrorDialog(
                        context,
                        "Invalid Email",
                      );
                    } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
                      await showErrorDialog(
                        context,
                        "Wrong Credentials",
                      );
                    } else if (e.code == 'too-many-requests') {
                      await showErrorDialog(
                        context,
                        "Too many requests, try again later",
                      );
                    } else {
                      await showErrorDialog(
                        context,
                        "Erorr: ${e.code}",
                      );
                    }
                  } catch (e) {
                    await showErrorDialog(
                      context,
                      "Erorr: ${e.toString()}",
                    );
                  }
                },
                child: const Text('Login',
                  style: TextStyle(
                  color: Colors.brown,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                )
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text("Not registered yet? Register here",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
