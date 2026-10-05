import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/vault_entry.dart';
import '../../core/providers/vault/entries_provider.dart';
import '../../core/routes/app_route.dart';
import '../../core/services/di/locator.dart';
import '../../core/services/i18n/translations.g.dart';
import '../../core/services/vault/service.dart';
import '../../core/tools/functions/entry_functions.dart';
import '../components/misc/status.dart';
import '../components/vault/copy_feedback.dart';
import '../components/vault/entry_avatar.dart';
import '../themes/app_theme.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    AppTheme.setStatusBarColor();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchController.clear();
    ref.read(entriesFilterProvider.notifier).setQuery('');
    setState(() => _searching = false);
  }

  Future<void> _delete(VaultEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);
    final entries = ref.read(entriesProvider.notifier);
    await entries.delete(entry.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(t.entryDeleted(title: entry.title)),
          action: SnackBarAction(label: t.undo, onPressed: () => entries.save(entry)),
        ),
      );
  }

  PreferredSizeWidget _appBar(EntriesFilterState filter) {
    const white = IconThemeData(color: Colors.white);
    if (_searching) {
      return AppBar(
        backgroundColor: AppTheme.getAppbarBgColor(),
        iconTheme: white,
        leading: IconButton(tooltip: context.t.closeSearch, icon: const Icon(Icons.arrow_back), onPressed: _closeSearch),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          cursorColor: Colors.white,
          style: const TextStyle(fontSize: 18, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: context.t.search,
            hintStyle: const TextStyle(fontSize: 18, color: Colors.white54),
          ),
          onChanged: ref.read(entriesFilterProvider.notifier).setQuery,
        ),
      );
    }

    return AppBar(
      backgroundColor: AppTheme.getAppbarBgColor(),
      iconTheme: white,
      actionsIconTheme: white,
      title: Text(context.t.appName, style: const TextStyle(color: Colors.white)),
      actions: [
        IconButton(tooltip: context.t.search, icon: const Icon(Icons.search), onPressed: () => setState(() => _searching = true)),
        PopupMenuButton<EntrySort>(
          tooltip: context.t.sort,
          icon: const Icon(Icons.sort),
          initialValue: filter.sort,
          onSelected: ref.read(entriesFilterProvider.notifier).setSort,
          itemBuilder: (context) => [
            PopupMenuItem(value: EntrySort.title, child: Text(context.t.sortByTitle)),
            PopupMenuItem(value: EntrySort.recent, child: Text(context.t.sortByRecent)),
          ],
        ),
        IconButton(tooltip: context.t.lock, icon: const Icon(Icons.lock_outline), onPressed: () => locator<VaultService>().lock()),
        IconButton(tooltip: context.t.settings, icon: const Icon(Icons.settings), onPressed: () => const SettingsRoute().push<void>(context)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(entriesFilterProvider);
    final entries = ref.watch(visibleEntriesProvider);

    return KeyboardDismissOnTap(
      child: PopScope(
        canPop: !_searching,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _closeSearch();
        },
        child: Scaffold(
          appBar: _appBar(filter),
          floatingActionButton: FloatingActionButton(
            tooltip: context.t.addEntry,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            onPressed: () => const NewEntryRoute().push<void>(context),
            child: const Icon(Icons.add),
          ),
          body: entries.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Status(icon: Icons.error_outline, text: context.t.anErrorOccurred),
            data: (list) {
              if (list.isEmpty) {
                return filter.query.trim().isEmpty
                    ? Status(icon: Icons.lock_outline, title: context.t.noEntries, text: context.t.noEntriesHint)
                    : Status(
                        icon: Icons.search_off,
                        text: context.t.noSearchResults(query: filter.query.trim()),
                      );
              }
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) => _EntryTile(entry: list[index], onDelete: _delete),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final VaultEntry entry;
  final ValueChanged<VaultEntry> onDelete;

  const _EntryTile({required this.entry, required this.onDelete});

  String get _subtitle => [entry.username, entry.email, entry.url].firstWhere((s) => s.isNotEmpty, orElse: () => '');

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(entry.id),
    direction: DismissDirection.endToStart,
    background: Container(
      color: Theme.of(context).colorScheme.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    ),
    onDismissed: (_) => onDelete(entry),
    child: ListTile(
      leading: EntryAvatar(title: entry.title),
      title: Text(entry.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: _subtitle.isEmpty ? null : Text(_subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: entry.password.isEmpty
          ? null
          : IconButton(
              tooltip: context.t.copy,
              icon: const Icon(Icons.copy),
              onPressed: () => copyWithFeedback(context, field: context.t.password, value: entry.password, sensitive: true),
            ),
      onTap: () => EntryRoute(id: entry.id).push<void>(context),
    ),
  );
}
