import 'package:flutter/material.dart';

enum SizeType { w, h }

const w = SizeType.w;
const h = SizeType.h;

class MakeSpace extends StatelessWidget {
  final SizeType type;
  final double step;

  const MakeSpace(this.type, this.step, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: type == SizeType.w ? 10 * step : 0,
    height: type == SizeType.h ? 10 * step : 0,
  );
}
