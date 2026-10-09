// Writes a demo vault as an NPass backup, to import before taking the store
// screenshots: `dart run tool/store_screenshots/make_demo_backup.dart <lang> <out.npass>`.
// Made-up accounts only; the backup password is [demoPassword].
import 'dart:io';
import 'dart:math';

import 'package:n_pass/core/models/totp_config.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/services/backup/service.dart';

// No punctuation: `adb shell input text` can reorder characters around it.
const demoPassword = 'TresorPyramide2026';

const _categories = {
  'en': {'personal': 'Personal', 'work': 'Work', 'finance': 'Finance', 'leisure': 'Entertainment', 'shopping': 'Shopping'},
  'fr': {'personal': 'Perso', 'work': 'Travail', 'finance': 'Banque', 'leisure': 'Loisirs', 'shopping': 'Achats'},
};

const _notes = {
  'en': 'Recovery codes in the safe at home.',
  'fr': 'Codes de secours dans le coffre à la maison.',
};

/// A random password like the app's generator would make.
String _password(Random random, int length) {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#%&*?';
  return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
}

Future<void> main(List<String> args) async {
  final lang = args[0];
  final category = _categories[lang]!;
  final random = Random(42);
  final now = DateTime.utc(2026, 10, 8, 9);
  var n = 0;
  VaultEntry entry(
    String title,
    String cat, {
    String username = '',
    String email = '',
    String url = '',
    bool favorite = false,
    String? totp,
    String notes = '',
  }) {
    n++;
    return VaultEntry(
      id: 'demo-$n',
      title: title,
      username: username,
      email: email,
      password: _password(random, 18),
      url: url,
      notes: notes,
      category: category[cat]!,
      favorite: favorite,
      totp: totp == null ? null : TotpConfig(secret: totp),
      createdAt: now.subtract(Duration(days: 30 - n)),
      updatedAt: now.subtract(Duration(days: 10 - n)),
    );
  }

  final entries = [
    entry(
      'Gmail',
      'personal',
      username: 'Claire Martin',
      email: 'claire.martin@gmail.com',
      url: 'https://mail.google.com',
      favorite: true,
      totp: 'JBSWY3DPEHPK3PXP',
      notes: _notes[lang]!,
    ),
    entry('GitHub', 'work', username: 'cmartin', email: 'claire.martin@gmail.com', url: 'https://github.com', totp: 'KRSXG5CTMVRXEZLU'),
    entry('Netflix', 'leisure', email: 'claire.martin@gmail.com', url: 'https://netflix.com'),
    entry('Spotify', 'leisure', username: 'claire.m', url: 'https://spotify.com'),
    entry('Amazon', 'shopping', email: 'claire.martin@gmail.com', url: 'https://amazon.com', favorite: true),
    entry('PayPal', 'finance', email: 'claire.martin@gmail.com', url: 'https://paypal.com', totp: 'GEZDGNBVGY3TQOJQ'),
    entry('LinkedIn', 'work', email: 'claire.martin@gmail.com', url: 'https://linkedin.com'),
    entry('Dropbox', 'work', email: 'claire.martin@gmail.com', url: 'https://dropbox.com'),
    entry('Instagram', 'personal', username: 'claire.voyage', url: 'https://instagram.com'),
    entry('Wi-Fi', 'personal', username: 'Livebox-4F2A'),
  ];
  final bytes = await BackupService().encode(entries, demoPassword);
  File(args[1]).writeAsBytesSync(bytes);
  stdout.writeln('${entries.length} entries -> ${args[1]}');
}
