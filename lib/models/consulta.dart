class Consulta {
  final String id;
  final String pacienteNome;
  final String medicoNome;
  final String medicoId;
  final DateTime dataHora; // data/hora da consulta
  final DateTime dataHoraCadastro; // data/hora do momento do cadastro
  final String motivo;
  final String tipo;
  final String observacoes;

  Consulta({
    required this.id,
    required this.pacienteNome,
    required this.medicoNome,
    required this.medicoId,
    required this.dataHora,
    required this.dataHoraCadastro,
    required this.motivo,
    required this.tipo,
    required this.observacoes,
  });
}
