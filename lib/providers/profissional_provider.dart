import 'package:flutter/material.dart';
import '../models/profissional.dart';

class ProfissionalProvider with ChangeNotifier {
  final List<Profissional> _profissionais = [
    Profissional(
      nome: 'Dra. Carla Mendes',
      especialidade: 'Cardiologia',
      crm: 'CRM 12345',
      telefone: '(11) 99999-1234',
      email: 'carla.mendes@hospital.com',
    ),
    Profissional(
      nome: 'Dr. Lucas Silva',
      especialidade: 'Ortopedia',
      crm: 'CRM 67890',
      telefone: '(11) 98888-5678',
      email: 'lucas.silva@hospital.com',
    ),
  ];

  List<Profissional> get profissionais => [..._profissionais];

  void adicionarProfissional(Profissional profissional) {
    _profissionais.add(profissional);
    notifyListeners();
  }

  void editarProfissional(int index, Profissional profissionalAtualizado) {
    if (index >= 0 && index < _profissionais.length) {
      _profissionais[index] = profissionalAtualizado;
      notifyListeners();
    }
  }

  void removerProfissional(int index) {
    if (index >= 0 && index < _profissionais.length) {
      _profissionais.removeAt(index);
      notifyListeners();
    }
  }
}
