import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profissional.dart';
import '../providers/profissional_provider.dart';

class ProfissionaisPage extends StatefulWidget {
  const ProfissionaisPage({super.key});

  @override
  State<ProfissionaisPage> createState() => _ProfissionaisPageState();
}

class _ProfissionaisPageState extends State<ProfissionaisPage> {
  String _filtroBusca = '';

  @override
  Widget build(BuildContext context) {
    final profissionalProvider = Provider.of<ProfissionalProvider>(context);
    final profissionais = profissionalProvider.profissionais
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final profissionaisFiltrados = profissionais.where((prof) {
      final filtro = _filtroBusca.toLowerCase();
      return prof.nome.toLowerCase().contains(filtro) ||
          prof.especialidade.toLowerCase().contains(filtro);
    }).toList();

    final larguraTela = MediaQuery.of(context).size.width;
    final bool isWideScreen = larguraTela >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Profissionais da Saúde')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou especialidade',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (valor) {
                setState(() {
                  _filtroBusca = valor;
                });
              },
            ),
          ),
          Expanded(
            child: profissionaisFiltrados.isEmpty
                ? const Center(child: Text('Nenhum profissional encontrado.'))
                : ListView.builder(
              itemCount: profissionaisFiltrados.length,
              itemBuilder: (context, index) {
                final profissional = profissionaisFiltrados[index];
                final indexOriginal = profissionais.indexOf(profissional);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(profissional.nome),
                    subtitle: Text('${profissional.especialidade} | ${profissional.crm}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _mostrarDialogProfissional(
                              context,
                              profissionalProvider,
                              profissional: profissional,
                              index: indexOriginal,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            profissionalProvider.removerProfissional(indexOriginal);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: isWideScreen
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
      floatingActionButton: isWideScreen
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ElevatedButton.icon(
          onPressed: () {
            _mostrarDialogProfissional(context, profissionalProvider);
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Profissional'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 6,
          ),
        ),
      )
          : FloatingActionButton(
        onPressed: () {
          _mostrarDialogProfissional(context, profissionalProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogProfissional(
      BuildContext context,
      ProfissionalProvider profissionalProvider, {
        Profissional? profissional,
        int? index,
      }) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: profissional?.nome ?? '');
    final especialidadeController = TextEditingController(text: profissional?.especialidade ?? '');
    final crmController = TextEditingController(text: profissional?.crm ?? '');
    final telefoneController = TextEditingController(text: profissional?.telefone ?? '');
    final emailController = TextEditingController(text: profissional?.email ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(profissional == null ? 'Novo Profissional' : 'Editar Profissional'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: especialidadeController,
                  decoration: const InputDecoration(labelText: 'Especialidade'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: crmController,
                  decoration: const InputDecoration(labelText: 'CRM'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final novoProfissional = Profissional(
                  nome: nomeController.text.trim(),
                  especialidade: especialidadeController.text.trim(),
                  crm: crmController.text.trim(),
                  telefone: telefoneController.text.trim(),
                  email: emailController.text.trim(),
                );

                if (profissional == null) {
                  profissionalProvider.adicionarProfissional(novoProfissional);
                } else if (index != null) {
                  profissionalProvider.editarProfissional(index, novoProfissional);
                }

                Navigator.of(context).pop();
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
