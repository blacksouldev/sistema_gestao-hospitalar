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

  @override
  Widget build(BuildContext context) {
    final consultaProvider = context.watch<ConsultaProvider>();

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
                    Text('Data: ${consulta.dataHora.toLocal().toString().split(' ')[0]}'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton.icon(
        onPressed: () => _abrirFormularioConsulta(context),
        icon: const Icon(Icons.add),
        label: const Text('Nova Consulta'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
      ),
    );
  }
}
