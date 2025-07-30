import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consulta.dart';
import '../providers/consulta_provider.dart';
import '../components/nova_consulta.dart';

class ConsultasPage extends StatelessWidget {
  const ConsultasPage({super.key});

  Future<void> _abrirFormularioConsulta(BuildContext context, [Consulta? consulta]) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(consulta == null ? 'Nova Consulta' : 'Editar Consulta'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: NovaConsulta(consulta: consulta),
        ),
      ),
    );
  }

  void _mostrarConfirmacaoExclusao(BuildContext context, ConsultaProvider provider, String consultaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta consulta?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.excluirConsulta(consultaId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime dt) {
    String dia = dt.day.toString().padLeft(2, '0');
    String mes = dt.month.toString().padLeft(2, '0');
    String ano = dt.year.toString();
    String hora = dt.hour.toString().padLeft(2, '0');
    String minuto = dt.minute.toString().padLeft(2, '0');
    return '$dia-$mes-$ano às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final consultaProvider = context.watch<ConsultaProvider>();

    final larguraTela = MediaQuery.of(context).size.width;
    final bool isWideScreen = larguraTela >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
      ),
      body: consultaProvider.consultas.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma consulta cadastrada',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: consultaProvider.consultas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final consulta = consultaProvider.consultas[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const Icon(Icons.calendar_today, size: 30, color: Colors.blueAccent),
                title: Text(
                  consulta.pacienteNome,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Médico: ${consulta.medicoNome}'),
                    Text('Data: ${_formatarDataHora(consulta.dataHora.toLocal())}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar',
                      onPressed: () {
                        _abrirFormularioConsulta(context, consulta);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Excluir',
                      onPressed: () {
                        _mostrarConfirmacaoExclusao(context, consultaProvider, consulta.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: isWideScreen
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: isWideScreen
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: () => _abrirFormularioConsulta(context),
          icon: const Icon(Icons.add),
          label: const Text('Nova Consulta'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 6,
          ),
        ),
      )
          : FloatingActionButton(
        onPressed: () => _abrirFormularioConsulta(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
