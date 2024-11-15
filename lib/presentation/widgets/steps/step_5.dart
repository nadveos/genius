import 'package:flutter/material.dart';

class Step5 extends StatelessWidget {
  const Step5({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: const BoxDecoration(color: Colors.purple),
      child: const Center(
        child: Text('Aqui pon tu direccion'),
      ),
    );
  }
}