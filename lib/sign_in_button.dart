import 'package:earth_online_map/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_button/sign_in_button.dart';

class MySignInButton extends ConsumerWidget {
  const MySignInButton({super.key});

  Future<UserCredential> signInWithGoogle() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var user = ref.watch(authProvider);
    if (user.isLoading) {
      return Container();
    }
    User? data = user.value;
    return data == null
        ? SignInButton(
            Buttons.google,
            onPressed: () {
              signInWithGoogle();
            },
          )
        : data.displayName != null
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Welcome to Earth, ${data.displayName}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ))
            : Container();
  }
}
