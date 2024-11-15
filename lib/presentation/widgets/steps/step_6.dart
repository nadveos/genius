import 'package:flutter/material.dart';

class Step6 extends StatelessWidget {
  const Step6({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: const BoxDecoration(
    color: Colors.yellow
    ),
      child: const Center(
        child: Text('Ciudad donde vives'),
      ),
    );
  }
}