import 'package:flutter/material.dart';

class Step4 extends StatelessWidget {
  const Step4({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: const BoxDecoration(
    color: Colors.red
    ),
      child: const Center(
        child: Text('Aqui pon tu numero de telefono'),
      ),
    );
  }
}