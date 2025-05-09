import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cropcare/Routes/constants/routes.dart';

import '../Utility/show_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email',
          style: TextStyle(
            color: Colors.brown,
            fontSize: 32.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Text(
              "We've send already an verification email. Please open it to verify your account.",
              style: TextStyle(
                  color: Colors.brown,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
                "If you haven't received a verification email yet, press the 'Send verification email'.",
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                )),
            const SizedBox(
              height: 50,
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();

                if (context.mounted) {
                  await showDialogPromt(context, "Verify Email",
                      "We've send already an verification email. Please open it to verify your account.");

                }
              },
              child: const Text('Send verification email',
                style: TextStyle(
                color: Colors.brown,
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                        (route) => false,
                  );
                }
              },
              child: const Text('Login' ,
                style: TextStyle(
                  color: Colors.brown,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
