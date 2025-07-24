import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consulta_provider.dart';
import '../models/medico.dart';

class NovaConsulta extends StatefulWidget {
  const NovaConsulta({super.key});

  @override
  State<NovaConsulta> createState() => _NovaConsultaState();
}

class _NovaConsultaState extends State<NovaConsulta> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController pacienteController = TextEditingController();
  final TextEditingController medicoController = TextEditingController();

  String? medicoSelecionadoId;
  String data = '';
  String hora = '';
  String motivo = '';
  String tipo = '';
  String observacoes = '';

  @override
  void initState() {
    super.initState();
    Provider.of<ConsultaProvider>(context, listen: false).buscarMedicos();
  }

  String? _converterDataParaIso(String dataBrasileira) {
    try {
      final partes = dataBrasileira.split('/');
      if (partes.length != 3) return null;
      final dia = int.parse(partes[0]);
      final mes = int.parse(partes[1]);
      final ano = int.parse(partes[2]);
      final data = DateTime(ano, mes, dia);
      return data.toIso8601String().split('T')[0];
    } catch (e) {
      return null;
    }
  }

  Future<void> salvarConsulta() async {
    if (medicoSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um médico válido')),
      );
      return;
    }

    final dataIso = _converterDataParaIso(data);
    if (dataIso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data inválida. Use o formato dd/MM/yyyy')),
      );
      return;
    }

    final provider = Provider.of<ConsultaProvider>(context, listen: false);

    final consulta = {
      'pacienteNome': pacienteController.text.trim(),
      'medicoId': medicoSelecionadoId!,
      'data': "${dataIso}T${hora}:00",
      'motivo': motivo,
      'tipo': tipo,
      'observacoes': observacoes,
    };

    try {
      final sucesso = await provider.salvarConsultaAPI(consulta);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consulta cadastrada com sucesso')),
        );
        await provider.buscarConsultas();
        if (mounted) Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao cadastrar consulta')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na comunicação: $e')),
      );
    }
  }

  @override
  void dispose() {
    pacienteController.dispose();
    medicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConsultaProvider>(context);
    final medicos = provider.medicos;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: pacienteController,
                decoration: const InputDecoration(labelText: 'Paciente (digite ou crie)'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome do paciente' : null,
              ),

              const SizedBox(height: 12),

              Autocomplete<Medico>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<Medico>.empty();
                  return medicos.where((m) =>
                      m.nome.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (medico) => "${medico.nome} (${medico.especialidade})",
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: 'Médico (selecione existente)'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Selecione um médico válido';
                      if (medicoSelecionadoId == null) return 'Selecione um médico válido';
                      return null;
                    },
                    onChanged: (val) {
                      final medicoEncontrado = medicos.firstWhere(
                            (m) => m.nome.toLowerCase() == val.toLowerCase(),
                        orElse: () => Medico(id: '', nome: '', especialidade: ''),
                      );
                      if (medicoEncontrado.id.isNotEmpty) {
                        medicoSelecionadoId = medicoEncontrado.id;
                      } else {
                        medicoSelecionadoId = null;
                      }
                    },
                  );
                },
                onSelected: (Medico medico) {
                  medicoSelecionadoId = medico.id;
                  medicoController.text = medico.nome;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Data (dd/MM/yyyy)'),
                keyboardType: TextInputType.datetime,
                onChanged: (val) => data = val,
                validator: (val) => val == null || val.isEmpty ? 'Informe a data' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Hora (HH:mm)'),
                keyboardType: TextInputType.datetime,
                onChanged: (val) => hora = val,
                validator: (val) => val == null || val.isEmpty ? 'Informe a hora' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Motivo'),
                onChanged: (val) => motivo = val,
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Tipo'),
                onChanged: (val) => tipo = val,
              ),

              const SizedBox(height: 12),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Observações'),
                onChanged: (val) => observacoes = val,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    salvarConsulta();
                  }
                },
                child: const Text('Cadastrar Consulta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
