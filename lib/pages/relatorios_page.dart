import 'package:flutter/material.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Aqui pode colocar relatórios reais ou placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('Página de Relatórios', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}
