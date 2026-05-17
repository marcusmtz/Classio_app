import 'package:flutter/material.dart';

/// Paleta de colores moderna y universitaria
class AppColors {
  // Colores Principales - Azul universitario moderno
  static const primary = Color(0xFF4F46E5); // Indigo vibrante
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF3730A3);
  static const primaryContainer = Color(0xFFEEF2FF);

  // Colores Secundarios - Verde éxito
  static const secondary = Color(0xFF10B981);
  static const secondaryLight = Color(0xFF34D399);
  static const secondaryDark = Color(0xFF059669);
  static const secondaryContainer = Color(0xFFD1FAE5);

  // Colores de Fondo
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F4F6);

  // Colores de Texto
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // Colores de Prioridad
  static const priorityCritical = Color(0xFFEF4444);
  static const priorityHigh = Color(0xFFF59E0B);
  static const priorityMedium = Color(0xFFFBBF24);
  static const priorityLow = Color(0xFF10B981);

  // Colores de Tipos de Evaluación
  static const examColor = Color(0xFFEF4444);
  static const taskColor = Color(0xFF3B82F6);
  static const projectColor = Color(0xFF10B981);

  // Colores para Cursos (Palette vibrante)
  static const List<Color> courseColors = [
    Color(0xFFEF4444), // Rojo
    Color(0xFFF59E0B), // Naranja
    Color(0xFFFBBF24), // Amarillo
    Color(0xFF10B981), // Verde
    Color(0xFF3B82F6), // Azul
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Púrpura
    Color(0xFFEC4899), // Rosa
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Naranja oscuro
  ];

  // Colores de Estado
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Sombras
  static const shadow = Color(0x1A000000);
  static const shadowLight = Color(0x0D000000);

  // Modo Oscuro
  static const darkBackground = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkSurfaceVariant = Color(0xFF374151);
  static const darkTextPrimary = Color(0xFFF9FAFB);
  static const darkTextSecondary = Color(0xFF9CA3AF);
  static const cardDark = Color(0xFF1F2937);
}
