import 'package:flutter/material.dart';
import '../models/paciente.dart';
import 'package:uuid/uuid.dart';

class PacienteProvider extends ChangeNotifier {
  final List<Paciente> _pacientes = [];

  List<Paciente> get pacientes => List.unmodifiable(_pacientes);

  void adicionarOuEditarPaciente(Paciente paciente) {
    final index = _pacientes.indexWhere((p) => p.id == paciente.id);
    if (index >= 0) {
      _pacientes[index] = paciente;
    } else {
      _pacientes.add(paciente);
    }
    notifyListeners();
  }

  void excluirPaciente(String id) {
    _pacientes.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  String gerarId() => const Uuid().v4();
}
