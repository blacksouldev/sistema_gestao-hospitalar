import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../providers/paciente_provider.dart';
import '../components/novo_paciente.dart';

class PacientesPage extends StatelessWidget {
  const PacientesPage({super.key});

  Future<void> _abrirFormularioPaciente(BuildContext context, [Paciente? paciente]) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(paciente == null ? 'Novo Paciente' : 'Editar Paciente'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: NovoPaciente(paciente: paciente),
        ),
      ),
    );
  }

  void _mostrarConfirmacaoExclusao(BuildContext context, PacienteProvider provider, String pacienteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir este paciente?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.excluirPaciente(pacienteId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pacienteProvider = context.watch<PacienteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: pacienteProvider.pacientes.isEmpty
          ? const Center(
        child: Text(
          'Nenhum paciente cadastrado',
          style: TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          itemCount: pacienteProvider.pacientes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final paciente = pacienteProvider.pacientes[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const Icon(Icons.person, size: 30, color: Colors.blueAccent),
                title: Text(
                  paciente.nome,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Telefone: ${paciente.telefone}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      tooltip: 'Editar',
                      onPressed: () {
                        _abrirFormularioPaciente(context, paciente);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Excluir',
                      onPressed: () {
                        _mostrarConfirmacaoExclusao(context, pacienteProvider, paciente.id);
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
        onPressed: () => _abrirFormularioPaciente(context),
        icon: const Icon(Icons.add),
        label: const Text('Novo Paciente'),
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
