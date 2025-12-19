import 'package:flutter/material.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit'),
      ),
      body: const Center(
        child: Text('Habit Page'),
      ),
    );
  }
}

