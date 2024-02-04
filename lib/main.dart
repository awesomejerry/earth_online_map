import 'dart:math';

import 'package:earth_online_map/add_new_city_input.dart';
import 'package:earth_online_map/map.dart';
import 'package:earth_online_map/sign_in_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var generatedColor = Random().nextInt(Colors.primaries.length);
    return MaterialApp(
      title: 'Earth Online: Map',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.primaries[generatedColor]),
        useMaterial3: true,
      ),
      home: const Material(
        child: Stack(
          children: [
            MyMap(),
            Positioned(
              left: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddNewCityInput(),
                  SizedBox(
                    width: 10,
                  ),
                  MySignInButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
