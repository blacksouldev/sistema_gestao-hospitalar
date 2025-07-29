import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../providers/paciente_provider.dart';
import 'novo_paciente.dart'; // ajuste o caminho conforme seu projeto

typedef OnPacienteSelecionado = void Function(Paciente? paciente);

class BuscaPacienteWidget extends StatefulWidget {
  final OnPacienteSelecionado onPacienteSelecionado;

  const BuscaPacienteWidget({Key? key, required this.onPacienteSelecionado}) : super(key: key);

  @override
  State<BuscaPacienteWidget> createState() => _BuscaPacienteWidgetState();
}

class _BuscaPacienteWidgetState extends State<BuscaPacienteWidget> {
  final TextEditingController _cpfController = TextEditingController();
  Paciente? _pacienteEncontrado;
  bool _buscando = false;
  String? _erro;

  void _buscarPaciente() {
    final cpf = _cpfController.text.trim();
    if (cpf.isEmpty) {
      setState(() {
        _erro = 'Informe um CPF válido para busca';
        _pacienteEncontrado = null;
      });
      widget.onPacienteSelecionado(null);
      return;
    }

    setState(() {
      _buscando = true;
      _erro = null;
      _pacienteEncontrado = null;
    });

    final provider = context.read<PacienteProvider>();

    // busca segura, retorna null se não achar
    final pacientesFiltrados = provider.pacientes.where((p) => p.cpf == cpf).toList();
    Paciente? paciente = pacientesFiltrados.isNotEmpty ? pacientesFiltrados.first : null;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _buscando = false;
        if (paciente == null) {
          _erro = 'Paciente não encontrado. Você pode cadastrar um novo paciente.';
          widget.onPacienteSelecionado(null);
        } else {
          _pacienteEncontrado = paciente;
          _erro = null;
          widget.onPacienteSelecionado(paciente);
        }
      });
    });
  }

  void _abrirCadastroPaciente() {
    Navigator.of(context).pop(); // fecha modal atual se houver
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Paciente'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: const NovoPaciente(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _cpfController,
          decoration: InputDecoration(
            labelText: 'Buscar Paciente pelo CPF',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _buscando ? null : _buscarPaciente,
            ),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        if (_buscando)
          const LinearProgressIndicator()
        else if (_pacienteEncontrado != null)
          Text(
            'Paciente encontrado: ${_pacienteEncontrado!.nome}\nData Nascimento: ${_pacienteEncontrado!.dataNascimento.day.toString().padLeft(2, '0')}/'
                '${_pacienteEncontrado!.dataNascimento.month.toString().padLeft(2, '0')}/'
                '${_pacienteEncontrado!.dataNascimento.year}',
            style: const TextStyle(color: Colors.green),
          )
        else if (_erro != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_erro!, style: const TextStyle(color: Colors.red)),
                TextButton(
                  onPressed: _abrirCadastroPaciente,
                  child: const Text('Cadastrar novo paciente'),
                ),
              ],
            ),
      ],
    );
  }
}
