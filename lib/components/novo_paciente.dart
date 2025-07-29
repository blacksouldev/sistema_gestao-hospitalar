import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../providers/paciente_provider.dart';

class NovoPaciente extends StatefulWidget {
  final Paciente? paciente;

  const NovoPaciente({super.key, this.paciente});

  @override
  State<NovoPaciente> createState() => _NovoPacienteState();
}

class _NovoPacienteState extends State<NovoPaciente> {
  final _formKey = GlobalKey<FormState>();
  late String _nome, _cpf, _telefone, _email;
  DateTime _dataNascimento = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.paciente != null) {
      _nome = widget.paciente!.nome;
      _cpf = widget.paciente!.cpf;
      _telefone = widget.paciente!.telefone;
      _email = widget.paciente!.email;
      _dataNascimento = widget.paciente!.dataNascimento;
    } else {
      _nome = '';
      _cpf = '';
      _telefone = '';
      _email = '';
    }
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = context.read<PacienteProvider>();
      final novoPaciente = Paciente(
        id: widget.paciente?.id ?? provider.gerarId(),
        nome: _nome,
        cpf: _cpf,
        telefone: _telefone,
        email: _email,
        dataNascimento: _dataNascimento,
      );
      provider.adicionarOuEditarPaciente(novoPaciente);
      Navigator.of(context).pop();
    }
  }

  Future<void> _selecionarDataNascimento() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataNascimento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (dataSelecionada != null) {
      setState(() => _dataNascimento = dataSelecionada);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _nome,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
            onSaved: (value) => _nome = value!,
          ),
          TextFormField(
            initialValue: _cpf,
            decoration: const InputDecoration(labelText: 'CPF'),
            validator: (value) => value!.isEmpty ? 'Informe o CPF' : null,
            onSaved: (value) => _cpf = value!,
          ),
          TextFormField(
            initialValue: _telefone,
            decoration: const InputDecoration(labelText: 'Telefone'),
            onSaved: (value) => _telefone = value!,
          ),
          TextFormField(
            initialValue: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            onSaved: (value) => _email = value!,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Nascimento: ${_dataNascimento.toLocal().toString().split(' ')[0]}'),
              TextButton(
                onPressed: _selecionarDataNascimento,
                child: const Text('Selecionar Data'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _salvar,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
