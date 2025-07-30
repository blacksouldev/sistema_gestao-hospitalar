import 'package:flutter/material.dart';
import '../models/usuario.dart'; // importe o modelo aqui

class UsuarioProvider with ChangeNotifier {
  final List<Usuario> _usuarios = [
    Usuario(id: 'u1', nome: 'Admin', email: 'admin@hospital.com'),
    Usuario(id: 'u2', nome: 'João Silva', email: 'joao@hospital.com'),
  ];

  List<Usuario> get usuarios => [..._usuarios];

  void adicionarUsuario(Usuario usuario) {
    _usuarios.add(usuario);
    notifyListeners();
  }

  void atualizarUsuario(Usuario usuario) {
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index >= 0) {
      _usuarios[index] = usuario;
      notifyListeners();
    }
  }

  void removerUsuario(String id) {
    _usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  Usuario? buscarPorId(String id) {
    return _usuarios.firstWhere(
          (u) => u.id == id,
      orElse: () => Usuario(id: '', nome: '', email: ''),
    );
  }
}
