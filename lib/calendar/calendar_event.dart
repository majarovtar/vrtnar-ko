import 'package:flutter/material.dart';

class GardenTask {
  final String id;
  final String title;
  final String plantName;
  final DateTime dueDate;
  final IconData icon;
  final String description;
  final bool isOverdue;
  final bool isCompleted;

  const GardenTask({
    required this.id,
    required this.title,
    required this.plantName,
    required this.dueDate,
    required this.icon,
    required this.description,
    this.isOverdue = false,
    this.isCompleted = false,
  });

  GardenTask copyWith({
    String? id,
    String? title,
    String? plantName,
    DateTime? dueDate,
    IconData? icon,
    String? description,
    bool? isOverdue,
    bool? isCompleted,
  }) {
    return GardenTask(
      id: id ?? this.id,
      title: title ?? this.title,
      plantName: plantName ?? this.plantName,
      dueDate: dueDate ?? this.dueDate,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      isOverdue: isOverdue ?? this.isOverdue,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}