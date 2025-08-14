import 'package:flutter/material.dart';

class GameModel {
  final String name;
  final String description;
  final String route;
  final Widget icon;

  GameModel({
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
  });
}
