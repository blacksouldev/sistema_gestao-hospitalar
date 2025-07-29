import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/consulta_provider.dart';
import 'providers/paciente_provider.dart'; // ✅ Adicionado aqui
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConsultaProvider()),
        ChangeNotifierProvider(create: (_) => PacienteProvider()), // ✅ Adicionado aqui
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema Hospitalar',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const HomePage() : const LoginPage();
          },
        ),
      ),
    );
  }
}
