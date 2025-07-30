import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/rendering.dart';
import '../providers/consulta_provider.dart';
import '../providers/paciente_provider.dart';
import '../providers/leito_provider.dart';

enum RelatorioTipo { todos, consultas, pacientes, leitos }

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  RelatorioTipo _tipoSelecionado = RelatorioTipo.todos;
  bool mostrarGraficoConsultas = false;
  bool mostrarGraficoPacientes = false;
  bool mostrarGraficoLeitos = false;

  final GlobalKey consultasChartKey = GlobalKey();
  final GlobalKey pacientesChartKey = GlobalKey();
  final GlobalKey leitosChartKey = GlobalKey();

  Future<Uint8List?> _capturePng(GlobalKey key) async {
    try {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erro ao capturar gráfico: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultas = context.watch<ConsultaProvider>().consultas;
    final pacientes = context.watch<PacienteProvider>().pacientes;
    final leitos = context.watch<LeitoProvider>().leitos;

    int totalConsultas = consultas.length;
    int totalPacientes = pacientes.length;
    int leitosOcupados = leitos.where((l) => l.ocupado).length;
    int leitosLivres = leitos.length - leitosOcupados;

    // Contar consultas por dia
    Map<String, int> contarConsultasPorDia() {
      final Map<String, int> contagem = {};
      for (var c in consultas) {
        final data = c.dataHora;
        final chave = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
        contagem[chave] = (contagem[chave] ?? 0) + 1;
      }
      return contagem;
    }

    final consultasPorDia = contarConsultasPorDia();

    // Contar pacientes por dia (campo dataCadastro)
    Map<String, int> contarPacientesPorDia() {
      final Map<String, int> contagem = {};
      for (var p in pacientes) {
        final data = p.dataCadastro;
        final chave = '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
        contagem[chave] = (contagem[chave] ?? 0) + 1;
      }
      return contagem;
    }

    final pacientesPorDia = contarPacientesPorDia();

    Widget graficoBarras(Map<String, int> dados, Color cor, GlobalKey key) {
      final labels = dados.keys.toList();
      final valores = dados.values.toList();

      return RepaintBoundary(
        key: key,
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      return SideTitleWidget(
                        axisSide: AxisSide.bottom,
                        child: Text(i < labels.length ? labels[i] : '', style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),

              barGroups: List.generate(
                valores.length,
                    (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: valores[i].toDouble(),
                      color: cor,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  showingTooltipIndicators: [0],
                ),
              ),

              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 4,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${valores[group.x]}',
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget graficoPizzaLeitos() {
      return RepaintBoundary(
        key: leitosChartKey,
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: leitosOcupados.toDouble(),
                  color: Colors.redAccent,
                  title: 'Ocupados',
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                PieChartSectionData(
                  value: leitosLivres.toDouble(),
                  color: Colors.green,
                  title: 'Livres',
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget cardExpandable({
      required IconData icon,
      required String titulo,
      required Widget valor,
      required Color cor,
      required bool mostrar,
      required VoidCallback aoExpandir,
      required Widget? grafico,
    }) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: cor, size: 32),
              title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: valor,
              trailing: IconButton(
                icon: AnimatedRotation(
                  turns: mostrar ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.expand_more),
                ),
                onPressed: aoExpandir,
              ),
            ),
            if (mostrar && grafico != null)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: grafico),
          ],
        ),
      );
    }

    Widget conteudoRelatorio() {
      return Column(
        children: [
          if (_tipoSelecionado == RelatorioTipo.consultas || _tipoSelecionado == RelatorioTipo.todos)
            cardExpandable(
              icon: Icons.event_note,
              titulo: 'Total de Consultas',
              valor: Text('$totalConsultas', style: const TextStyle(fontSize: 24, color: Colors.blue)),
              cor: Colors.blue,
              mostrar: mostrarGraficoConsultas,
              aoExpandir: () => setState(() => mostrarGraficoConsultas = !mostrarGraficoConsultas),
              grafico: graficoBarras(consultasPorDia, Colors.blueAccent, consultasChartKey),
            ),
          if (_tipoSelecionado == RelatorioTipo.pacientes || _tipoSelecionado == RelatorioTipo.todos)
            cardExpandable(
              icon: Icons.people,
              titulo: 'Total de Pacientes',
              valor: Text('$totalPacientes', style: const TextStyle(fontSize: 24, color: Colors.orange)),
              cor: Colors.orange,
              mostrar: mostrarGraficoPacientes,
              aoExpandir: () => setState(() => mostrarGraficoPacientes = !mostrarGraficoPacientes),
              grafico: graficoBarras(pacientesPorDia, Colors.orange, pacientesChartKey),
            ),
          if (_tipoSelecionado == RelatorioTipo.leitos || _tipoSelecionado == RelatorioTipo.todos)
            cardExpandable(
              icon: Icons.local_hospital,
              titulo: 'Leitos (Total: ${leitos.length})',
              valor: Row(
                children: [
                  Text('$leitosOcupados', style: const TextStyle(fontSize: 24, color: Colors.red)),
                  const Text(' / ', style: TextStyle(fontSize: 24)),
                  Text('$leitosLivres', style: const TextStyle(fontSize: 24, color: Colors.green)),
                ],
              ),
              cor: Colors.teal,
              mostrar: mostrarGraficoLeitos,
              aoExpandir: () => setState(() => mostrarGraficoLeitos = !mostrarGraficoLeitos),
              grafico: graficoPizzaLeitos(),
            ),
        ],
      );
    }

    Future<void> gerarPDF() async {
      final estadoAntesConsultas = mostrarGraficoConsultas;
      final estadoAntesPacientes = mostrarGraficoPacientes;
      final estadoAntesLeitos = mostrarGraficoLeitos;

      setState(() {
        if (_tipoSelecionado == RelatorioTipo.consultas || _tipoSelecionado == RelatorioTipo.todos) {
          mostrarGraficoConsultas = true;
        }
        if (_tipoSelecionado == RelatorioTipo.pacientes || _tipoSelecionado == RelatorioTipo.todos) {
          mostrarGraficoPacientes = true;
        }
        if (_tipoSelecionado == RelatorioTipo.leitos || _tipoSelecionado == RelatorioTipo.todos) {
          mostrarGraficoLeitos = true;
        }
      });

      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final imgConsultas = (_tipoSelecionado == RelatorioTipo.consultas || _tipoSelecionado == RelatorioTipo.todos)
          ? await _capturePng(consultasChartKey)
          : null;

      final imgPacientes = (_tipoSelecionado == RelatorioTipo.pacientes || _tipoSelecionado == RelatorioTipo.todos)
          ? await _capturePng(pacientesChartKey)
          : null;

      final imgLeitos = (_tipoSelecionado == RelatorioTipo.leitos || _tipoSelecionado == RelatorioTipo.todos)
          ? await _capturePng(leitosChartKey)
          : null;

      setState(() {
        mostrarGraficoConsultas = estadoAntesConsultas;
        mostrarGraficoPacientes = estadoAntesPacientes;
        mostrarGraficoLeitos = estadoAntesLeitos;
      });

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Header(level: 0, child: pw.Text('Relatório Hospitalar', style: pw.TextStyle(fontSize: 24))),
            pw.Paragraph(text: 'Tipo do relatório: ${_tipoSelecionado.name.toUpperCase()}'),
            pw.SizedBox(height: 12),
            if (_tipoSelecionado == RelatorioTipo.consultas || _tipoSelecionado == RelatorioTipo.todos) ...[
              pw.Text('Total de Consultas: $totalConsultas', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 6),
              if (imgConsultas != null) pw.Image(pw.MemoryImage(imgConsultas), height: 200),
              pw.SizedBox(height: 12),
            ],
            if (_tipoSelecionado == RelatorioTipo.pacientes || _tipoSelecionado == RelatorioTipo.todos) ...[
              pw.Text('Total de Pacientes: $totalPacientes', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 6),
              if (imgPacientes != null) pw.Image(pw.MemoryImage(imgPacientes), height: 200),
              pw.SizedBox(height: 12),
            ],
            if (_tipoSelecionado == RelatorioTipo.leitos || _tipoSelecionado == RelatorioTipo.todos) ...[
              pw.Text('Leitos Ocupados: $leitosOcupados', style: pw.TextStyle(fontSize: 18)),
              pw.Text('Leitos Livres: $leitosLivres', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 6),
              if (imgLeitos != null) pw.Image(pw.MemoryImage(imgLeitos), height: 200),
            ],
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Gerar PDF',
            onPressed: gerarPDF,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<RelatorioTipo>(
              value: _tipoSelecionado,
              items: RelatorioTipo.values
                  .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name.toUpperCase()),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: conteudoRelatorio(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
