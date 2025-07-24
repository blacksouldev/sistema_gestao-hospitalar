import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final Function(String) onSelectItem;

  const AppDrawer({super.key, required this.onSelectItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', 'dashboard'),
          _buildDrawerItem(Icons.calendar_today, 'Consultas', 'consultas'),
          _buildDrawerItem(Icons.bar_chart, 'Relatórios', 'relatorios'),
          _buildDrawerItem(Icons.people, 'Pacientes', 'pacientes'),
          _buildDrawerItem(Icons.medical_services, 'Profissionais', 'profissionais'),
          _buildDrawerItem(Icons.bed, 'Leitos', 'leitos'),
          _buildDrawerItem(Icons.folder_shared, 'Prontuários', 'prontuarios'),
          _buildDrawerItem(Icons.person, 'Usuários', 'usuarios'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, String pageKey) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () => onSelectItem(pageKey),
    );
  }
}
