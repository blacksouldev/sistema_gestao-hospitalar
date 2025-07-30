import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usuario.dart';
import '../providers/usuario_provider.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  String _filtroBusca = '';

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final usuarios = usuarioProvider.usuarios
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final usuariosFiltrados = usuarios.where((usuario) {
      final filtro = _filtroBusca.toLowerCase();
      return usuario.nome.toLowerCase().contains(filtro) ||
          usuario.email.toLowerCase().contains(filtro);
    }).toList();

    final larguraTela = MediaQuery.of(context).size.width;
    final bool isWideScreen = larguraTela >= 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou email',
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
            child: usuariosFiltrados.isEmpty
                ? const Center(child: Text('Nenhum usuário encontrado.'))
                : ListView.builder(
              itemCount: usuariosFiltrados.length,
              itemBuilder: (context, index) {
                final usuario = usuariosFiltrados[index];
                final indexOriginal = usuarios.indexOf(usuario);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(usuario.nome),
                    subtitle: Text(usuario.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _mostrarDialogUsuario(
                              context,
                              usuarioProvider,
                              usuario: usuario,
                              index: indexOriginal,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirmar exclusão'),
                                content: Text(
                                    'Tem certeza que deseja excluir o usuário "${usuario.nome}"?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Não')),
                                  TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Sim')),
                                ],
                              ),
                            );
                            if (confirmar == true) {
                              usuarioProvider.removerUsuario(usuario.id);
                            }
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
            _mostrarDialogUsuario(context, usuarioProvider);
          },
          icon: const Icon(Icons.add),
          label: const Text('Novo Usuário'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 6,
          ),
        ),
      )
          : FloatingActionButton(
        onPressed: () {
          _mostrarDialogUsuario(context, usuarioProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogUsuario(
      BuildContext context,
      UsuarioProvider usuarioProvider, {
        Usuario? usuario,
        int? index,
      }) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: usuario?.nome ?? '');
    final emailController = TextEditingController(text: usuario?.email ?? '');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(usuario == null ? 'Novo Usuário' : 'Editar Usuário'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nomeController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Campo obrigatório'
                          : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  nomeController.dispose();
                  emailController.dispose();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              if (usuario != null)
                TextButton(
                  onPressed: () async {
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: Text(
                            'Tem certeza que deseja excluir o usuário "${usuario.nome}"?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Não')),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Sim')),
                        ],
                      ),
                    );
                    if (confirmar == true) {
                      usuarioProvider.removerUsuario(usuario.id);
                      nomeController.dispose();
                      emailController.dispose();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final novoUsuario = Usuario(
                      id: usuario?.id ?? 'u${DateTime.now().millisecondsSinceEpoch}',
                      nome: nomeController.text.trim(),
                      email: emailController.text.trim(),
                    );

                    if (usuario == null) {
                      usuarioProvider.adicionarUsuario(novoUsuario);
                    } else if (index != null) {
                      usuarioProvider.atualizarUsuario(novoUsuario);
                    }

                    nomeController.dispose();
                    emailController.dispose();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
