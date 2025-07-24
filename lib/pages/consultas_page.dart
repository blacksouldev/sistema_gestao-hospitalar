import 'package:flutter/material.dart';

class ConsultasPage extends StatelessWidget {
  const ConsultasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui pode colocar a lista de consultas ou placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_note, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text('Página de Consultas', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
