import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leito_provider.dart';

class LeitosPage extends StatelessWidget {
  const LeitosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final leitos = context.watch<LeitoProvider>().leitos;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: LayoutBuilder(builder: (context, constraints) {
        const approxCardWidth = 180.0;
        int crossAxisCount = (constraints.maxWidth / approxCardWidth).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;

        return GridView.builder(
          itemCount: leitos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            final leito = leitos[index];
            final color = leito.ocupado ? Colors.redAccent : Colors.green;
            final icon = leito.ocupado ? Icons.bed : Icons.bed_outlined;

            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(icon, size: 36, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      leito.descricao,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      leito.ocupado ? 'Ocupado' : 'Livre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
