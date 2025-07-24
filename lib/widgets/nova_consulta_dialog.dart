import 'package:flutter/material.dart';
import '../models/consulta.dart';

class NovaConsultaDialog extends StatefulWidget {
  final Consulta? consulta;
  final Function(Consulta) onSalvar;

  const NovaConsultaDialog({super.key, this.consulta, required this.onSalvar});

  @override
  State<NovaConsultaDialog> createState() => _NovaConsultaDialogState();
}

class _NovaConsultaDialogState extends State<NovaConsultaDialog> {
  late TextEditingController pacienteController;
  late TextEditingController medicoController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    pacienteController = TextEditingController(text: widget.consulta?.pacienteNome ?? '');
    medicoController = TextEditingController(text: widget.consulta?.medicoNome ?? '');
    selectedDate = widget.consulta?.data;
  }

  @override
  void dispose() {
    pacienteController.dispose();
    medicoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _salvar() {
    if (pacienteController.text.isEmpty || medicoController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }
    final novaConsulta = Consulta(
      id: widget.consulta?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      pacienteNome: pacienteController.text,
      medicoNome: medicoController.text,
      data: selectedDate!,
    );
    widget.onSalvar(novaConsulta);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.consulta == null ? 'Nova Consulta' : 'Editar Consulta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pacienteController,
              decoration: const InputDecoration(labelText: 'Paciente'),
            ),
            TextField(
              controller: medicoController,
              decoration: const InputDecoration(labelText: 'Médico'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(selectedDate == null
                      ? 'Data não selecionada'
                      : 'Data: ${selectedDate!.toLocal()}'.split(' ')[0]),
                ),
                TextButton(
                  onPressed: () => _selecionarData(context),
                  child: const Text('Selecionar Data'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
