import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/consulta.dart';
import '../models/medico.dart';
import '../providers/consulta_provider.dart';

class NovaConsulta extends StatefulWidget {
  final Consulta? consulta;

  const NovaConsulta({Key? key, this.consulta}) : super(key: key);

  @override
  State<NovaConsulta> createState() => _NovaConsultaState();
}

class _NovaConsultaState extends State<NovaConsulta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pacienteController = TextEditingController();
  Medico? _medicoSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  List<Medico> _medicos = [];

  @override
  void initState() {
    super.initState();

    final consultaProvider = context.read<ConsultaProvider>();
    _medicos = consultaProvider.medicos;

    if (_medicos.isEmpty) {
      consultaProvider.buscarMedicos().then((_) {
        setState(() {
          _medicos = consultaProvider.medicos;
          if (widget.consulta != null) {
            _medicoSelecionado = _medicos.firstWhere(
                  (m) => m.id == widget.consulta!.medicoId,
              orElse: () => _medicos.isNotEmpty ? _medicos[0] : throw Exception('Nenhum médico disponível'),
            );
          }
        });
      });
    } else {
      if (widget.consulta != null) {
        final c = widget.consulta!;
        _pacienteController.text = c.pacienteNome;
        _medicoSelecionado = _medicos.firstWhere(
              (m) => m.id == c.medicoId,
          orElse: () => _medicos.isNotEmpty ? _medicos[0] : throw Exception('Nenhum médico disponível'),
        );
        _dataSelecionada = c.dataHora;
        _motivoController.text = c.motivo;
        _tipoController.text = c.tipo;
        _observacoesController.text = c.observacoes;
      }
    }
  }

  @override
  void dispose() {
    _pacienteController.dispose();
    _motivoController.dispose();
    _tipoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final novaData = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (novaData != null) {
      setState(() {
        _dataSelecionada = DateTime(
          novaData.year,
          novaData.month,
          novaData.day,
          _dataSelecionada.hour,
          _dataSelecionada.minute,
        );
      });
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
      motivo: _motivoController.text.trim(),
      tipo: _tipoController.text.trim(),
      observacoes: _observacoesController.text.trim(),
    );

    if (widget.consulta == null) {
      // Criar nova - usando método salvarConsultaAPI com Map (simula API)
      final sucesso = await consultaProvider.salvarConsultaAPI({
        'pacienteNome': novaConsulta.pacienteNome,
        'medicoId': novaConsulta.medicoId,
        'data': novaConsulta.dataHora.toIso8601String(),
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
      // Editar: remove antiga e adiciona nova localmente
      consultaProvider.excluirConsulta(widget.consulta!.id);
      consultaProvider.adicionarConsulta(novaConsulta);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _pacienteController,
                decoration: const InputDecoration(labelText: 'Nome do Paciente'),
                validator: (value) => value == null || value.isEmpty ? 'Informe o nome do paciente' : null,
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
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Data da Consulta'),
                      child: GestureDetector(
                        onTap: () => _selecionarData(context),
                        child: Text(
                          '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
                              '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
                              '${_dataSelecionada.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Hora'),
                      child: Text(
                        '${_dataSelecionada.hour.toString().padLeft(2, '0')}:'
                            '${_dataSelecionada.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo'),
                maxLines: 1,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
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
