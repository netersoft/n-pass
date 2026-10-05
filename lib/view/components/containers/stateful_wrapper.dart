import 'package:flutter/material.dart';

class StatefulWrapper extends StatefulWidget {
  final VoidCallback onInit;
  final Widget child;

  const StatefulWrapper({
    required this.onInit,
    required this.child,
    super.key,
  });

  @override
  State<StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
