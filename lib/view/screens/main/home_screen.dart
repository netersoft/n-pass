import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/i18n/translations.g.dart';
import '../../components/misc/status.dart';
import '../../layouts/main_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const HomeScreenContent();
}

class HomeScreenContent extends ConsumerStatefulWidget {
  const HomeScreenContent({super.key});

  @override
  ConsumerState<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends ConsumerState<HomeScreenContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MainLayout(
    checkServer: true,
    checkDatabase: true,
    child: Status(
      icon: Icons.check_circle,
      text: context.t.serverAndDatabaseAvailable,
    ),
  );
}
