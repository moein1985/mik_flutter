import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppModule extends Equatable {
  final String name;
  final String nameKey;
  final IconData icon;
  final String? route;
  final bool isEnabled;
  final String? description;
  final Color color;

  const AppModule({
    required this.name,
    required this.nameKey,
    required this.icon,
    this.route,
    required this.isEnabled,
    this.description,
    required this.color,
  });

  @override
  List<Object?> get props => [name, nameKey, icon, route, isEnabled, description, color];
}
