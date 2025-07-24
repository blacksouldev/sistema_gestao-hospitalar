class Consulta {
  final String id;
  final String pacienteNome;
  final String medicoNome;
  final String medicoId;
  final DateTime dataHora;
  final String motivo;
  final String tipo;
  final String observacoes;

  Consulta({
    required this.id,
    required this.pacienteNome,
    required this.medicoNome,
    required this.medicoId,
    required this.dataHora,
    required this.motivo,
    required this.tipo,
    required this.observacoes,
  });
}
