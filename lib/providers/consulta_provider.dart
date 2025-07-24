import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../models/medico.dart';

class ConsultaProvider extends ChangeNotifier {
  final List<Consulta> _consultas = [];
  final List<Medico> _medicos = [];

  List<Consulta> get consultas => List.unmodifiable(_consultas);
  List<Medico> get medicos => List.unmodifiable(_medicos);

  Future<void> buscarMedicos() async {
    // Exemplo local mockado
    _medicos.clear();
    _medicos.addAll([
      Medico(
        id: '1',
        nome: 'Dr. Marcos',
        especialidade: 'Cardiologista',
        crm: '12345',
        telefone: '(11) 99999-9999',
        email: 'marcos@hospital.com',
      ),
      Medico(
        id: '2',
        nome: 'Dra. Ana',
        especialidade: 'Pediatra',
        crm: '23456',
        telefone: '(11) 98888-8888',
        email: 'ana@hospital.com',
      ),
      Medico(
        id: '3',
        nome: 'Dr. João',
        especialidade: 'Ortopedista',
        crm: '34567',
        telefone: '(11) 97777-7777',
        email: 'joao@hospital.com',
      ),
    ]);
    notifyListeners();
  }

  Future<bool> salvarConsultaAPI(Map<String, dynamic> consultaMap) async {
    try {
      final medicoEncontrado = _medicos.firstWhere(
            (m) => m.id == consultaMap['medicoId'],
        orElse: () => throw Exception('Médico não encontrado'),
      );
      final novaConsulta = Consulta(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        pacienteNome: consultaMap['pacienteNome'],
        medicoNome: medicoEncontrado.nome,
        medicoId: medicoEncontrado.id,
        dataHora: DateTime.parse(consultaMap['data']),
        motivo: consultaMap['motivo'] ?? '',
        tipo: consultaMap['tipo'] ?? '',
        observacoes: consultaMap['observacoes'] ?? '',
      );
      _consultas.add(novaConsulta);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> buscarConsultas() async {
    // No exemplo local, só notifica para atualizar a UI
    notifyListeners();
  }

  void adicionarConsulta(Consulta novaConsulta) {
    _consultas.add(novaConsulta);
    notifyListeners();
  }

  void excluirConsulta(String id) {
    _consultas.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
