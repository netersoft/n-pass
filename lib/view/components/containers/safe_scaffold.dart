import 'package:flutter/material.dart';

class SafeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const SafeScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
    ),
  );
}
