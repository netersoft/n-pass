import 'package:flutter/material.dart';

import '../../../core/tools/functions/entry_functions.dart';

/// Colored circle with the entry initials, the color being stable for a title.
class EntryAvatar extends StatelessWidget {
  static const List<Color> _palette = [
    Color(0xFF1565C0),
    Color(0xFF00838F),
    Color(0xFF2E7D32),
    Color(0xFF6A1B9A),
    Color(0xFFAD1457),
    Color(0xFFC62828),
    Color(0xFFEF6C00),
    Color(0xFF4E342E),
    Color(0xFF37474F),
    Color(0xFF283593),
  ];

  final String title;
  final double radius;

  const EntryAvatar({required this.title, super.key, this.radius = 22});

  static Color colorFor(String title) {
    final hash = title.trim().toLowerCase().codeUnits.fold<int>(0, (h, c) => (h * 31 + c) & 0x7fffffff);
    return _palette[hash % _palette.length];
  }

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: colorFor(title),
    child: Text(
      entryInitials(title),
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: radius * 0.75),
    ),
  );
}
