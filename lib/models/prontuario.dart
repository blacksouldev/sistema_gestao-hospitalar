class Prontuario {
  final String id;
  final String paciente;
  final String descricao;
  final DateTime data;

  Prontuario({
    required this.id,
    required this.paciente,
    required this.descricao,
    required this.data,
  });

  Prontuario copiarCom({
    String? id,
    String? paciente,
    String? descricao,
    DateTime? data,
  }) {
    return Prontuario(
      id: id ?? this.id,
      paciente: paciente ?? this.paciente,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
    );
  }
}
