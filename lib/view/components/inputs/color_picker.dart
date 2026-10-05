import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

const List<Color> availableColors = [
  // Noir et blanc
  Colors.white,
  Colors.black,

  // Gris
  Colors.grey,
  Colors.blueGrey,
  Color(0xFF9E9E9E),
  Color(0xFF757575),
  Color(0xFF616161),
  Color(0xFF424242),
  Color(0xFF212121),
  Color(0xFFEEEEEE), // Gris clair
  Color(0xFFCFD8DC), // Gris moyen
  Color(0xFF90A4AE), // Gris moyen foncé
  Color(0xFF455A64), // Gris foncé
  // Brun
  Colors.brown,
  Color(0xFF8D6E63),
  Color(0xFF795548),
  Color(0xFF6D4C41),
  Color(0xFF5D4037),
  Color(0xFFBCAAA4), // Brun clair
  // Orange
  Colors.orange,
  Colors.deepOrange,
  Color(0xFFFFB74D),
  Color(0xFFFFA726),
  Color(0xFFFF9800),
  Color(0xFFFB8C00),
  Color(0xFFFFE0B2), // Orange clair
  // Jaune
  Colors.yellow,
  Colors.amber,
  Color(0xFFFFF176),
  Color(0xFFFFEE58),
  Color(0xFFFFEB3B),
  Color(0xFFFFD54F),
  Color(0xFFFFF59D), // Jaune clair
  // Vert
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Color(0xFF81C784),
  Color(0xFF66BB6A),
  Color(0xFF4CAF50),
  Color(0xFF43A047),
  Color(0xFF2E7D32),
  Color(0xFFC5E1A5), // Vert clair
  // Turquoise
  Colors.teal,
  Color(0xFF4DB6AC),
  Color(0xFF26A69A),
  Color(0xFF009688),
  Color(0xFFB2DFDB), // Turquoise clair
  // Cyan
  Colors.cyan,
  Color(0xFF4DD0E1),
  Color(0xFF26C6DA),
  Color(0xFF00BCD4),
  Color(0xFFB2EBF2), // Cyan clair
  // Indigo
  Colors.indigo,
  Color(0xFF64B5F6),
  Color(0xFF4FC3F7),
  Color(0xFF42A5F5),
  Color(0xFF2196F3),
  Color(0xFF1E88E5),
  Color(0xFFBBDEFB), // Bleu clair
  // Pourpre
  Colors.purple,
  Colors.deepPurple,
  Color(0xFFBA68C8),
  Color(0xFF9575CD),
  Color(0xFF7E57C2),
  Color(0xFF673AB7),
  Color(0xFFD1C4E9), // Violet clair
  // Rose
  Colors.pink,
  Color(0xFFF06292),
  Color(0xFFEC407A),
  Color(0xFFE91E63),
  Color(0xFFFFCCBC), // Rose clair
  // Rouge
  Colors.red,
  Color(0xFFE57373),
  Color(0xFFEF5350),
  Color(0xFFF44336),
  Color(0xFFFFCDD2), // Rouge clair
];

int _portraitCrossAxisCount = 4;
int _landscapeCrossAxisCount = 5;
double _borderRadius = 30;
double _blurRadius = 5;
double _iconSize = 24;

Widget pickerLayoutBuilder(
  BuildContext context,
  List<Color> colors,
  PickerItem child,
) {
  Orientation orientation = MediaQuery.of(context).orientation;

  return SizedBox(
    width: 300,
    height: orientation == Orientation.portrait ? 360 : 240,
    child: GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? _portraitCrossAxisCount : _landscapeCrossAxisCount,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      children: [for (final Color color in colors) child(color)],
    ),
  );
}

Widget pickerItemBuilder(
  Color color,
  bool isCurrentColor,
  void Function() changeColor,
) => Container(
  margin: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(_borderRadius),
    color: color,
    boxShadow: [
      BoxShadow(
        color: color.withValues(alpha: 0.8),
        offset: const Offset(1, 2),
        blurRadius: _blurRadius,
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: changeColor,
      borderRadius: BorderRadius.circular(_borderRadius),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isCurrentColor ? 1 : 0,
        child: Icon(
          Icons.done,
          size: _iconSize,
          color: useWhiteForeground(color) ? Colors.white : Colors.black,
        ),
      ),
    ),
  ),
);
