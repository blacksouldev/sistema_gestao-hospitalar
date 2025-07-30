import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_page.dart';
import 'consultas_page.dart';
import 'pacientes_page.dart';
import 'profissionais_page.dart';
import 'relatorios_page.dart';
import 'leitos_page.dart';
import 'prontuarios_page.dart'; // ✅ importação correta da tela
import 'usuarios_page.dart';    // ✅ importação da página de usuários

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
    Navigator.of(context).pop();
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
        return const ConsultasPage();
      case 'pacientes':
        return const PacientesPage();
      case 'relatorios':
        return const RelatoriosPage();
      case 'profissionais':
        return const ProfissionaisPage();
      case 'leitos':
        return const LeitosPage();
      case 'prontuarios':
        return const ProntuariosPage(); // ✅ página real conectada
      case 'usuarios':
        return const UsuariosPage();    // ✅ página real conectada
      default:
        return const Center(child: Text('Página não encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sistema Hospitalar - ${_selectedPage[0].toUpperCase()}${_selectedPage.substring(1)}',
        ),
      ),
      drawer: AppDrawer(onSelectItem: _onSelectItem),
      body: _getPage(),
    );
  }
}
