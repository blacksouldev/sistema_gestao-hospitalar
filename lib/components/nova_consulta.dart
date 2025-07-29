import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consulta.dart';
import '../models/medico.dart';
import '../models/paciente.dart';
import '../providers/consulta_provider.dart';
import '../providers/paciente_provider.dart';
import 'busca_paciente_widget.dart';

class NovaConsulta extends StatefulWidget {
  final Consulta? consulta;

  const NovaConsulta({Key? key, this.consulta}) : super(key: key);

  @override
  State<NovaConsulta> createState() => _NovaConsultaState();
}

class _NovaConsultaState extends State<NovaConsulta> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _pacienteController;
  Medico? _medicoSelecionado;

  // Data/hora da consulta selecionada pelo usuário
  DateTime _dataSelecionada = DateTime.now();

  // Data/hora fixa do momento do cadastro
  late final DateTime _dataHoraCadastro;

  final TextEditingController _motivoController = TextEditingController();
  String? _tipoSelecionado;
  String? _planoSelecionado;
  final TextEditingController _observacoesController = TextEditingController();

  List<Medico> _medicos = [];
  List<String> _planos = [
    'Unimed',
    'Bradesco Saúde',
    'Amil',
    'SulAmérica',
    'Notredame',
  ];

  Paciente? _pacienteSelecionado;

  @override
  void initState() {
    super.initState();

    _pacienteController = TextEditingController();

    _dataHoraCadastro = widget.consulta?.dataHoraCadastro ?? DateTime.now();

    final consultaProvider = context.read<ConsultaProvider>();
    _medicos = consultaProvider.medicos;

    if (_medicos.isEmpty) {
      consultaProvider.buscarMedicos().then((_) {
        setState(() {
          _medicos = consultaProvider.medicos;
          _inicializarCampos();
        });
      });
    } else {
      _inicializarCampos();
    }
  }

  void _inicializarCampos() {
    if (widget.consulta != null) {
      final c = widget.consulta!;
      _pacienteController.text = c.pacienteNome;
      _medicoSelecionado = _medicos.firstWhere(
            (m) => m.id == c.medicoId,
        orElse: () =>
        _medicos.isNotEmpty ? _medicos[0] : throw Exception('Nenhum médico disponível'),
      );
      _dataSelecionada = c.dataHora;
      _motivoController.text = c.motivo;
      _tipoSelecionado = c.tipo;
      if (!_planos.contains(_tipoSelecionado)) {
        _planoSelecionado = null;
      } else {
        _planoSelecionado = c.observacoes; // plano salvo em observações (ajuste conforme seu modelo)
      }
      _observacoesController.text = c.observacoes;
    }
  }

  void _onPacienteSelecionado(Paciente? paciente) {
    setState(() {
      _pacienteSelecionado = paciente;
      if (paciente != null) {
        _pacienteController.text = paciente.nome;
      } else {
        _pacienteController.clear();
      }
    });
  }

  @override
  void dispose() {
    _pacienteController.dispose();
    _motivoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataHora(BuildContext context) async {
    final novaData = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (novaData != null) {
      final novaHora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: _dataSelecionada.hour, minute: _dataSelecionada.minute),
      );
      if (novaHora != null) {
        setState(() {
          _dataSelecionada = DateTime(
            novaData.year,
            novaData.month,
            novaData.day,
            novaHora.hour,
            novaHora.minute,
          );
        });
      }
    }
  }

  void _salvarConsulta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medicoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um médico')),
      );
      return;
    }

    final consultaProvider = context.read<ConsultaProvider>();

    final novaConsulta = Consulta(
      id: widget.consulta?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      pacienteNome: _pacienteController.text.trim(),
      medicoNome: _medicoSelecionado!.nome,
      medicoId: _medicoSelecionado!.id,
      dataHora: _dataSelecionada,
      dataHoraCadastro: _dataHoraCadastro,
      motivo: _motivoController.text.trim(),
      tipo: _tipoSelecionado ?? '',
      observacoes: _observacoesController.text.trim(),
    );

    if (widget.consulta == null) {
      final sucesso = await consultaProvider.salvarConsultaAPI({
        'pacienteNome': novaConsulta.pacienteNome,
        'medicoId': novaConsulta.medicoId,
        'data': novaConsulta.dataHora.toIso8601String(),
        'dataHoraCadastro': novaConsulta.dataHoraCadastro.toIso8601String(),
        'motivo': novaConsulta.motivo,
        'tipo': novaConsulta.tipo,
        'observacoes': novaConsulta.observacoes,
      });
      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar consulta')),
        );
        return;
      }
    } else {
      consultaProvider.excluirConsulta(widget.consulta!.id);
      consultaProvider.adicionarConsulta(novaConsulta);
    }

    Navigator.of(context).pop();
  }

  String _formatarDataHora(DateTime dt) {
    String dia = dt.day.toString().padLeft(2, '0');
    String mes = dt.month.toString().padLeft(2, '0');
    String ano = dt.year.toString();
    String hora = dt.hour.toString().padLeft(2, '0');
    String minuto = dt.minute.toString().padLeft(2, '0');
    return '$dia-$mes-$ano às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final pacienteProvider = context.watch<PacienteProvider>();
    final pacientes = pacienteProvider.pacientes;

    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BuscaPacienteWidget(onPacienteSelecionado: _onPacienteSelecionado),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pacienteController,
                decoration: const InputDecoration(labelText: 'Nome do Paciente'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome do paciente' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<Medico>(
                value: _medicoSelecionado,
                decoration: const InputDecoration(labelText: 'Médico'),
                items: _medicos
                    .map(
                      (medico) => DropdownMenuItem(
                    value: medico,
                    child: Text(medico.nome),
                  ),
                )
                    .toList(),
                onChanged: (medico) {
                  setState(() {
                    _medicoSelecionado = medico;
                  });
                },
                validator: (value) => value == null ? 'Selecione um médico' : null,
              ),

              const SizedBox(height: 12),

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Data/Hora do Cadastro (fixa)'),
                child: Text(
                  _formatarDataHora(_dataHoraCadastro),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => _selecionarDataHora(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Data e Hora da Consulta'),
                  child: Text(
                    _formatarDataHora(_dataSelecionada),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                maxLines: 1,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'Particular', child: Text('Particular')),
                  DropdownMenuItem(value: 'Plano de Saúde', child: Text('Plano de Saúde')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value;
                    if (value != 'Plano de Saúde') {
                      _planoSelecionado = null;
                    }
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo' : null,
              ),

              if (_tipoSelecionado == 'Plano de Saúde') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _planoSelecionado,
                  decoration: const InputDecoration(labelText: 'Selecione o Plano'),
                  items: _planos
                      .map(
                        (plano) => DropdownMenuItem(
                      value: plano,
                      child: Text(plano),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _planoSelecionado = value;
                    });
                  },
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Selecione um plano' : null,
                ),
              ],

              const SizedBox(height: 12),

              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
                enabled: true, // sempre ativo agora
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _salvarConsulta,
                  child: Text(widget.consulta == null ? 'Cadastrar Consulta' : 'Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
