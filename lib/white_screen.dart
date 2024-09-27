import 'package:flutter/material.dart';

class WhiteScreen extends StatelessWidget {
  const WhiteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(

      home: Scaffold(
        backgroundColor: Colors.white,
      ),
    );
  }
}
