import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class MySignInButton extends StatefulWidget {
  const MySignInButton({super.key});

  @override
  State<MySignInButton> createState() => _MySignInButtonState();
}

class _MySignInButtonState extends State<MySignInButton> {
  bool showButton = false;
  String? userName;

  Future<void> checkSignIn(User? user) async {
    setState(() {
      showButton = user == null;
      userName = user?.displayName;
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    // Create a new provider
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      checkSignIn(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: showButton
          ? SignInButton(
              Buttons.google,
              onPressed: () {
                signInWithGoogle();
              },
            )
          : userName != null
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Welcome to Earth, $userName',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ))
              : Container(),
    );
  }
}
