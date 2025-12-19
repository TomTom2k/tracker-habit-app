import 'package:flutter/material.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
      ),
      body: const Center(
        child: Text('Routines Page'),
      ),
    );
  }
}

