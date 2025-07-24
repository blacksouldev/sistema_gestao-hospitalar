import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../models/medico.dart';

class ConsultaProvider extends ChangeNotifier {
  final List<Consulta> _consultas = [];
  final List<Medico> _medicos = [];

  List<Consulta> get consultas => List.unmodifiable(_consultas);
  List<Medico> get medicos => List.unmodifiable(_medicos);

  // Simula buscar médicos (exemplo local, você pode trocar para API depois)
  Future<void> buscarMedicos() async {
    // Exemplo mockado
    _medicos.clear();
    _medicos.addAll([
      Medico(id: '1', nome: 'Dr. Marcos', especialidade: 'Cardiologista'),
      Medico(id: '2', nome: 'Dra. Ana', especialidade: 'Pediatra'),
      Medico(id: '3', nome: 'Dr. João', especialidade: 'Ortopedista'),
    ]);
    notifyListeners();
  }

  // Simula salvar consulta (exemplo local)
  Future<bool> salvarConsultaAPI(Map<String, dynamic> consultaMap) async {
    try {
      final novaConsulta = Consulta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pacienteNome: consultaMap['pacienteNome'] ?? '',
        medicoNome: _medicos.firstWhere(
                (m) => m.id == consultaMap['medicoId'],
            orElse: () => Medico(id: '', nome: 'Médico não encontrado', especialidade: '')
        ).nome,
        data: DateTime.parse(consultaMap['data']),
      );
      _consultas.add(novaConsulta);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Simula buscar consultas (exemplo local)
  Future<void> buscarConsultas() async {
    // Aqui você pode carregar de um backend ou banco local
    notifyListeners();
  }

  void adicionarConsulta(Consulta novaConsulta) {
    _consultas.add(novaConsulta);
    notifyListeners();
  }

  void excluirConsulta(String id) {
    _consultas.removeWhere((consulta) => consulta.id == id);
    notifyListeners();
  }
}
