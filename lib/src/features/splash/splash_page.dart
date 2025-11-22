import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          height: 48,
          width: 48,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

