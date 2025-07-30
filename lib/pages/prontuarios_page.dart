import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/prontuario.dart';
import '../models/paciente.dart';
import '../providers/prontuario_provider.dart';
import '../providers/paciente_provider.dart';

class ProntuariosPage extends StatelessWidget {
  const ProntuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProntuarioProvider, PacienteProvider>(
      builder: (context, prontuarioProvider, pacienteProvider, _) {
        final prontuarios = prontuarioProvider.prontuarios;
        final pacientes = pacienteProvider.pacientes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prontuários'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Novo Prontuário',
                onPressed: () {
                  if (pacientes.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Nenhum Paciente Cadastrado'),
                        content: const Text('Cadastre um paciente antes de adicionar um prontuário.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (_) => ProntuarioForm(pacientes: pacientes),
                  );
                },
              ),
            ],
          ),
          body: prontuarios.isEmpty
              ? const Center(child: Text('Nenhum prontuário cadastrado.'))
              : ListView.builder(
            itemCount: prontuarios.length,
            itemBuilder: (context, index) {
              final prontuario = prontuarios[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(prontuario.paciente),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy – HH:mm').format(prontuario.data)}\n${prontuario.descricao}',
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ProntuarioForm(
                              prontuario: prontuario,
                              pacientes: pacientes,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          prontuarioProvider.removerProntuario(prontuario.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProntuarioForm extends StatefulWidget {
  final Prontuario? prontuario;
  final List<Paciente> pacientes;

  const ProntuarioForm({super.key, this.prontuario, required this.pacientes});

  @override
  State<ProntuarioForm> createState() => _ProntuarioFormState();
}

class _ProntuarioFormState extends State<ProntuarioForm> {
  final _formKey = GlobalKey<FormState>();
  String? _paciente;
  String? _descricao;

  @override
  void initState() {
    super.initState();
    _paciente = widget.prontuario?.paciente;
    _descricao = widget.prontuario?.descricao;
  }

  @override
  Widget build(BuildContext context) {
    final isEditando = widget.prontuario != null;

    return AlertDialog(
      title: Text(isEditando ? 'Editar Prontuário' : 'Novo Prontuário'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _paciente,
                hint: const Text('Selecione o paciente'),
                items: widget.pacientes.map((paciente) {
                  return DropdownMenuItem<String>(
                    value: paciente.nome,
                    child: Text(paciente.nome),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _paciente = value),
                validator: (value) => value == null ? 'Selecione um paciente' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _descricao,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _descricao = value,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Descrição obrigatória' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Salvar'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final novo = Prontuario(
                id: widget.prontuario?.id ?? '',
                paciente: _paciente!,
                descricao: _descricao!,
                data: DateTime.now(),
              );

              final provider = Provider.of<ProntuarioProvider>(context, listen: false);
              if (isEditando) {
                provider.atualizarProntuario(novo);
              } else {
                provider.adicionarProntuario(novo);
              }

              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
