import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consulta_provider.dart';
import '../providers/paciente_provider.dart';

class DashboardPage extends StatefulWidget {
  final Function(String pageKey) onCardTap;

  const DashboardPage({super.key, required this.onCardTap});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<bool> _visibleCards = List.filled(7, false);
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animateCards();
  }

  void _animateCards() async {
    final int center = (_visibleCards.length / 2).floor();

    List<int> order = [];
    order.add(center);

    for (int offset = 1; offset < _visibleCards.length; offset++) {
      if (center - offset >= 0) order.add(center - offset);
      if (center + offset < _visibleCards.length) order.add(center + offset);
    }

    for (int i in order) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _visibleCards[i] = true;
        });
      }
    }
  }

  final List<_CardData> baseCards = [
    _CardData('Consultas', Icons.event_note, Colors.blue, 'consultas'),
    _CardData('Relatórios', Icons.assessment, Colors.green, 'relatorios'),
    _CardData('Pacientes', Icons.people, Colors.orange, 'pacientes'),
    _CardData('Profissionais', Icons.person, Colors.purple, 'profissionais'),
    _CardData('Leitos', Icons.local_hospital, Colors.red, 'leitos'),
    _CardData('Prontuários', Icons.folder_open, Colors.teal, 'prontuarios'),
    _CardData('Usuários', Icons.admin_panel_settings, Colors.brown, 'usuarios'),
  ];

  String _getDescription(int index) {
    switch (baseCards[index].title) {
      case 'Consultas':
        return 'Gerencie e acompanhe os agendamentos de consultas médicas, visualizando horários, profissionais e status.';
      case 'Relatórios':
        return 'Visualize relatórios detalhados e gráficos para análise do desempenho, atendimentos e estatísticas do hospital.';
      case 'Pacientes':
        return 'Acesse informações completas e histórico clínico dos pacientes, facilitando o acompanhamento do tratamento.';
      case 'Profissionais':
        return 'Gerencie o cadastro e dados dos profissionais de saúde, incluindo especialidades e contatos.';
      case 'Leitos':
        return 'Controle o status dos leitos, verificando quais estão disponíveis, ocupados ou em manutenção.';
      case 'Prontuários':
        return 'Tenha acesso rápido e seguro aos prontuários médicos, com informações detalhadas sobre cada atendimento.';
      case 'Usuários':
        return 'Administre os usuários do sistema, definindo permissões e níveis de acesso para garantir a segurança.';
      default:
        return '';
    }
  }

  int _getContagemConsultas(BuildContext context) {
    final provider = Provider.of<ConsultaProvider>(context);
    return provider.consultas.length;
  }

  int _getContagemPacientes(BuildContext context) {
    final provider = Provider.of<PacienteProvider>(context);
    return provider.pacientes.length;
  }

  @override
  Widget build(BuildContext context) {
    int consultasCount = _getContagemConsultas(context);
    int pacientesCount = _getContagemPacientes(context);

    List<_CardData> cards = baseCards.map((card) {
      if (card.title == 'Consultas') {
        return _CardData(
          '${card.title} ($consultasCount)',
          card.icon,
          card.color,
          card.pageKey,
        );
      } else if (card.title == 'Pacientes') {
        return _CardData(
          '${card.title} ($pacientesCount)',
          card.icon,
          card.color,
          card.pageKey,
        );
      }
      return card;
    }).toList();

    String descriptionText;
    Color descriptionColor;

    if (_hoveredIndex != null) {
      descriptionText = _getDescription(_hoveredIndex!);
      descriptionColor = cards[_hoveredIndex!].color;
    } else {
      descriptionText = 'Passe o mouse sobre um card para ver a descrição aqui.';
      descriptionColor = Colors.grey.shade600;
    }

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              int maxColumns = 7;
              const approxCardWidth = 130.0;

              int crossAxisCount = (constraints.maxWidth / approxCardWidth).floor();
              if (crossAxisCount < 1) crossAxisCount = 1;
              if (crossAxisCount > maxColumns) crossAxisCount = maxColumns;

              return GridView.builder(
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 3,
                  childAspectRatio: 1.8,
                ),
                itemBuilder: (context, index) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: _visibleCards[index] ? 1 : 0,
                    child: _HoverCard(
                      card: cards[index],
                      onTap: widget.onCardTap,
                      onHover: (hovering) {
                        setState(() {
                          _hoveredIndex = hovering ? index : null;
                        });
                      },
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            descriptionText,
            style: TextStyle(
              fontSize: 15,
              color: descriptionColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final _CardData card;
  final Function(String) onTap;
  final Function(bool) onHover;

  const _HoverCard({
    required this.card,
    required this.onTap,
    required this.onHover,
    Key? key,
  }) : super(key: key);

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final boxShadow = _hovering
        ? [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ]
        : [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        widget.onHover(true);
      },
      onExit: (_) {
        setState(() => _hovering = false);
        widget.onHover(false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onTap(widget.card.pageKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.card.color,
            boxShadow: boxShadow,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.card.icon, size: 40, color: Colors.white),
              const SizedBox(height: 6),
              Text(
                widget.card.title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final String title;
  final IconData icon;
  final Color color;
  final String pageKey;

  _CardData(this.title, this.icon, this.color, this.pageKey);
}
