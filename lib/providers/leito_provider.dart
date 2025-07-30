import 'package:flutter/material.dart';

class Leito {
  final int id;
  final String descricao;
  final bool ocupado;

  Leito({
    required this.id,
    required this.descricao,
    required this.ocupado,
  });
}

class LeitoProvider extends ChangeNotifier {
  final List<Leito> _leitos = [
    Leito(id: 1, descricao: 'Leito 101', ocupado: true),
    Leito(id: 2, descricao: 'Leito 102', ocupado: false),
    Leito(id: 3, descricao: 'Leito 103', ocupado: true),
    Leito(id: 4, descricao: 'Leito 104', ocupado: false),
  ];

  List<Leito> get leitos => _leitos;
}
