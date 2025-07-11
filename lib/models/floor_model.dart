import 'package:flutter/material.dart';

class FloorModel {
  final String name;
  final int level;

  FloorModel({
    required this.name,
    required this.level,
  });
}

class Store {
  final String name;
  final String category;
  final double x;
  final double y;
  final Color color;

  Store({
    required this.name,
    required this.category,
    required this.x,
    required this.y,
    required this.color,
  });
}
