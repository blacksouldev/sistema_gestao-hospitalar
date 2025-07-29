class Paciente {
  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final DateTime dataNascimento;

  Paciente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.dataNascimento,
  });
}
