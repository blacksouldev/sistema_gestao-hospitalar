import 'package:flutter/material.dart';
import '../models/prontuario.dart';
import 'dart:math';

class ProntuarioProvider with ChangeNotifier {
  final List<Prontuario> _prontuarios = [
    Prontuario(
      id: 'p1',
      paciente: 'Ana Paula',
      descricao: 'Paciente com sintomas gripais e febre leve.',
      data: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Prontuario(
      id: 'p2',
      paciente: 'Carlos Henrique',
      descricao: 'Retorno de consulta, quadro estável.',
      data: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<Prontuario> get prontuarios => [..._prontuarios];

  void adicionarProntuario(Prontuario prontuario) {
    final novo = prontuario.copiarCom(
      id: 'p${Random().nextInt(9999)}',
      data: DateTime.now(),
    );
    _prontuarios.add(novo);
    notifyListeners();
  }

  void atualizarProntuario(Prontuario prontuario) {
    final index = _prontuarios.indexWhere((p) => p.id == prontuario.id);
    if (index >= 0) {
      _prontuarios[index] = prontuario;
      notifyListeners();
    }
  }

  void removerProntuario(String id) {
    _prontuarios.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  Prontuario? buscarPorId(String id) {
    return _prontuarios.firstWhere((p) => p.id == id, orElse: () => Prontuario(id: '', paciente: '', descricao: '', data: DateTime.now()));
  }
}
