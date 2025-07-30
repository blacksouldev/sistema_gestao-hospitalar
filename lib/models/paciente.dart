class Paciente {
  final String id;
  final String nome;
  final String cpf;
  final String telefone;
  final String email;
  final DateTime dataNascimento;
  final DateTime dataCadastro; // novo campo obrigatório

  Paciente({
    required this.id,
    required this.nome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.dataNascimento,
    required this.dataCadastro, // novo campo no construtor
  });
}
