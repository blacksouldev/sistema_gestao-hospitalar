import 'package:flutter/material.dart';

class MedicosPage extends StatelessWidget {
  const MedicosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Médicos')),
      body: const Center(child: Text('Página de Médicos')),
    );
  }
}
