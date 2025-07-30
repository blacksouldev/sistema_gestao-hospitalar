import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paciente.dart';
import '../providers/paciente_provider.dart';
import 'novo_paciente.dart';

typedef OnPacienteSelecionado = void Function(Paciente? paciente);

class BuscaPacienteWidget extends StatefulWidget {
  final OnPacienteSelecionado onPacienteSelecionado;

  const BuscaPacienteWidget({Key? key, required this.onPacienteSelecionado}) : super(key: key);

  @override
  State<BuscaPacienteWidget> createState() => _BuscaPacienteWidgetState();
}

class _BuscaPacienteWidgetState extends State<BuscaPacienteWidget> {
  final TextEditingController _cpfController = TextEditingController();
  List<Paciente> _pacientesEncontrados = [];
  bool _buscando = false;
  String? _erro;

  void _buscarPaciente() {
    final cpf = _cpfController.text.trim();
    if (cpf.isEmpty) {
      setState(() {
        _erro = 'Informe ao menos parte do CPF para busca';
        _pacientesEncontrados.clear();
      });
      widget.onPacienteSelecionado(null);
      return;
    }

    setState(() {
      _buscando = true;
      _erro = null;
      _pacientesEncontrados.clear();
    });

    final provider = context.read<PacienteProvider>();
    final pacientesFiltrados = provider.pacientes.where((p) => p.cpf.startsWith(cpf)).toList();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      setState(() {
        _buscando = false;
        if (pacientesFiltrados.isEmpty) {
          _erro = 'Nenhum paciente encontrado. Você pode cadastrar um novo paciente.';
          widget.onPacienteSelecionado(null);
        } else {
          _pacientesEncontrados = pacientesFiltrados;
          if (_pacientesEncontrados.length == 1) {
            widget.onPacienteSelecionado(_pacientesEncontrados.first);
          } else {
            widget.onPacienteSelecionado(null);
          }
        }
      });
    });
  }

  void _abrirCadastroPaciente() {
    Navigator.of(context).pop();
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
            labelText: 'Buscar Paciente pelo CPF (parcial)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: _buscando ? null : _buscarPaciente,
            ),
          ),
          keyboardType: TextInputType.number,
          onFieldSubmitted: (_) => _buscarPaciente(), // permite buscar com ENTER
        ),
        const SizedBox(height: 8),
        if (_buscando)
          const LinearProgressIndicator()
        else if (_pacientesEncontrados.length == 1)
          Text(
            'Paciente encontrado: ${_pacientesEncontrados.first.nome}\nData Nascimento: '
                '${_pacientesEncontrados.first.dataNascimento.day.toString().padLeft(2, '0')}/'
                '${_pacientesEncontrados.first.dataNascimento.month.toString().padLeft(2, '0')}/'
                '${_pacientesEncontrados.first.dataNascimento.year}',
            style: const TextStyle(color: Colors.green),
          )
        else if (_pacientesEncontrados.length > 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vários pacientes encontrados:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._pacientesEncontrados.map(
                      (p) => ListTile(
                    title: Text(p.nome),
                    subtitle: Text('CPF: ${p.cpf}'),
                    onTap: () {
                      widget.onPacienteSelecionado(p);
                      setState(() => _pacientesEncontrados = [p]);
                    },
                  ),
                ),
              ],
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
