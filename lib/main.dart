import 'dart:math';

import 'package:circular_reveal_animation/circular_reveal_animation.dart';
import 'package:earth_online_map/add_new_city_input.dart';
import 'package:earth_online_map/map.dart';
import 'package:earth_online_map/sign_in_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimatedMapController animatedMapController;
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animatedMapController = AnimatedMapController(vsync: this);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
    Future.delayed(const Duration(seconds: 1), () {
      animationController.forward();
    });
  }

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
      home: CircularRevealAnimation(
        animation: animation,
        child: Material(
          child: Stack(
            children: [
              MyMap(
                animatedMapController: animatedMapController,
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddNewCityInput(
                      animatedMapController: animatedMapController,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const MySignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
