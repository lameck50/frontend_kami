
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Thème 2: Moderne et Énergique
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF00897B), // Bleu Sarcelle
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF00897B),
    secondary: Color(0xFFE91E63), // Rose Vif
    background: Color(0xFFFFFFFF), // Blanc
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF00897B),
    foregroundColor: Color(0xFFFFFFFF), // Couleur du texte et des icônes de l'AppBar
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.red, // Couleur pour l'icône et le texte sélectionnés
    unselectedLabelColor: Colors.white70, // Couleur pour les non-sélectionnés
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF424242)),
    bodyMedium: TextStyle(color: Color(0xFF424242)),
  ),
);

// Thème 3: Élégant et Sombre
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF212121), // Gris Anthracite
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF303030), // Gris un peu plus clair
    secondary: Color(0xFF00E5FF), // Cyan Lumineux
    background: Color(0xFF212121),
  ),
  scaffoldBackgroundColor: const Color(0xFF212121),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF303030),
    foregroundColor: Color(0xFFE0E0E0), // Couleur du texte et des icônes de l'AppBar
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: Colors.red, // Couleur pour l'icône et le texte sélectionnés
    unselectedLabelColor: Colors.white70, // Couleur pour les non-sélectionnés
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
    bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
  ),
);
