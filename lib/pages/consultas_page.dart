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

  @override
  Widget build(BuildContext context) {
    final consultaProvider = context.watch<ConsultaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nova Consulta',
            onPressed: () {
              _abrirFormularioConsulta(context);
            },
          ),
        ],
      ),
      body: consultaProvider.consultas.isEmpty
          ? const Center(child: Text('Nenhuma consulta cadastrada'))
          : ListView.builder(
        itemCount: consultaProvider.consultas.length,
        itemBuilder: (context, index) {
          final consulta = consultaProvider.consultas[index];
          return ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(consulta.pacienteNome),
            subtitle: Text(
              'Médico: ${consulta.medicoNome} \nData: ${consulta.dataHora.toLocal().toString().split(' ')[0]}',
            ),
            isThreeLine: true,
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
          );
        },
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
}
