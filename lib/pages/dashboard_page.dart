import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final Function(String pageKey) onCardTap;

  const DashboardPage({super.key, required this.onCardTap});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<bool> _visibleCards = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    _animateCards();
  }

  void _animateCards() async {
    for (int i = 0; i < _visibleCards.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (mounted) {
        setState(() {
          _visibleCards[i] = true;
        });
      }
    }
  }

  final List<_CardData> cards = [
    _CardData('Consultas', Icons.event_note, Colors.blue, 'consultas'),
    _CardData('Relatórios', Icons.assessment, Colors.green, 'relatorios'),
    _CardData('Pacientes', Icons.people, Colors.orange, 'pacientes'),
    _CardData('Profissionais', Icons.person, Colors.purple, 'profissionais'),
    _CardData('Leitos', Icons.local_hospital, Colors.red, 'leitos'),
    _CardData('Prontuários', Icons.folder_open, Colors.teal, 'prontuarios'),
    _CardData('Usuários', Icons.admin_panel_settings, Colors.brown, 'usuarios'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: LayoutBuilder(builder: (context, constraints) {
        // Mantém no máximo 7 colunas, mas adapta pra menos se tela menor
        int maxColumns = 7;
        // largura mínima aproximada do card pra respeitar proporção e tamanho visual:
        // Aqui vamos assumir aproximadamente 130 de largura para o cálculo,
        // mesmo que o seu código original não tenha tamanho fixo explícito,
        // mas o aspecto 1.8 garante proporção correta.
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
              ),
            );
          },
        );
      }),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final _CardData card;
  final Function(String) onTap;

  const _HoverCard({required this.card, required this.onTap, Key? key}) : super(key: key);

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

    final scale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
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
