import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedPage = 'dashboard';

  void _onSelectItem(String page) {
    setState(() {
      _selectedPage = page;
    });
    Navigator.of(context).pop(); // Fecha o Drawer
  }

  Widget _getPage() {
    switch (_selectedPage) {
      case 'dashboard':
        return DashboardPage(
          onCardTap: (pageKey) {
            setState(() {
              _selectedPage = pageKey;
            });
          },
        );
      case 'consultas':
        return const Center(child: Text('Página: Consultas'));
      case 'relatorios':
        return const Center(child: Text('Página: Relatórios'));
      case 'pacientes':
        return const Center(child: Text('Página: Pacientes'));
      case 'profissionais':
        return const Center(child: Text('Página: Profissionais'));
      case 'leitos':
        return const Center(child: Text('Página: Leitos'));
      case 'prontuarios':
        return const Center(child: Text('Página: Prontuários'));
      case 'usuarios':
        return const Center(child: Text('Página: Usuários'));
      default:
        return const Center(child: Text('Página não encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistema Hospitalar - ${_selectedPage[0].toUpperCase()}${_selectedPage.substring(1)}'),
      ),
      drawer: AppDrawer(onSelectItem: _onSelectItem),
      body: _getPage(),
    );
  }
}
