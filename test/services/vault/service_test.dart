import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:n_pass/core/models/vault_entry.dart';
import 'package:n_pass/core/services/vault/service.dart';
import 'package:n_pass/core/services/vault/store.dart';

import 'crypto_test.dart' show fastKdf;

VaultEntry entry(String title, {String password = 'hunter2'}) {
  final now = DateTime.utc(2026, 10, 5);
  return VaultEntry(id: VaultService.newEntryId(), title: title, password: password, createdAt: now, updatedAt: now);
}

void main() {
  late Directory dir;
  late VaultStore store;
  late VaultService vault;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('npass_vault_test');
    Hive.init(dir.path);
    store = await VaultStore.open();
    vault = VaultService(store, newKdfParams: fastKdf);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('a new vault is not created, then unlocked once created', () async {
    expect(vault.isCreated, isFalse);
    expect(vault.isUnlocked, isFalse);

    await vault.create('master');

    expect(vault.isCreated, isTrue);
    expect(vault.isUnlocked, isTrue);
    await expectLater(vault.create('other'), throwsStateError);
  });

  test('unlock checks the master password', () async {
    await vault.create('master');
    vault.lock();

    expect(vault.isUnlocked, isFalse);
    expect(await vault.unlock('wrong'), isFalse);
    expect(vault.isUnlocked, isFalse);
    expect(await vault.unlock('master'), isTrue);
    expect(vault.isUnlocked, isTrue);
  });

  test('entries can only be read or written while unlocked', () async {
    await vault.create('master');
    vault.lock();

    await expectLater(vault.readEntries(), throwsStateError);
    await expectLater(vault.saveEntry(entry('Mail')), throwsStateError);
    expect(() => vault.deleteEntry('x'), throwsStateError);
  });

  test('saved entries are encrypted at rest and read back after a restart', () async {
    await vault.create('master');
    final mail = entry('Mail', password: 'p4ssw0rd-mail');
    await vault.saveEntries([mail, entry('Bank')]);

    for (final blob in store.readEntries().values) {
      expect(utf8.decode(blob, allowMalformed: true), isNot(contains('p4ssw0rd-mail')));
    }

    final reopened = VaultService(store, newKdfParams: fastKdf);
    expect(await reopened.unlock('master'), isTrue);
    final entries = await reopened.readEntries();

    expect(entries.map((e) => e.title), unorderedEquals(['Mail', 'Bank']));
    expect(entries.firstWhere((e) => e.id == mail.id).password, 'p4ssw0rd-mail');
  });

  test('updating and deleting entries', () async {
    await vault.create('master');
    final mail = entry('Mail');
    await vault.saveEntry(mail);
    await vault.saveEntry(mail.copyWith(title: 'Personal mail'));

    expect((await vault.readEntries()).single.title, 'Personal mail');

    await vault.deleteEntry(mail.id);

    expect(await vault.readEntries(), isEmpty);
  });

  test('an entry blob moved under another id fails to decrypt', () async {
    await vault.create('master');
    final a = entry('A');
    await vault.saveEntry(a);
    await store.putEntry('other-id', store.readEntries()[a.id]!);

    await expectLater(vault.readEntries(), throwsA(anything));
  });

  test('changePassword keeps the entries and swaps the password', () async {
    await vault.create('old');
    await vault.saveEntry(entry('Mail'));

    expect(await vault.changePassword('wrong', 'new'), isFalse);
    expect(await vault.changePassword('old', 'new'), isTrue);

    vault.lock();
    expect(await vault.unlock('old'), isFalse);
    expect(await vault.unlock('new'), isTrue);
    expect((await vault.readEntries()).single.title, 'Mail');
  });

  test('an exported key unlocks the vault, another key does not', () async {
    await vault.create('master');
    final key = await vault.exportKey();
    vault.lock();

    expect(await vault.unlockWithKey(List.filled(32, 0)), isFalse);
    expect(vault.isUnlocked, isFalse);
    expect(await vault.unlockWithKey(key), isTrue);
    expect(vault.isUnlocked, isTrue);
  });

  test('the exported key still works after a password change', () async {
    await vault.create('old');
    final key = await vault.exportKey();
    await vault.changePassword('old', 'new');
    vault.lock();

    expect(await vault.unlockWithKey(key), isTrue);
  });

  test('destroy erases the vault', () async {
    await vault.create('master');
    await vault.saveEntry(entry('Mail'));
    await vault.destroy();

    expect(vault.isCreated, isFalse);
    expect(vault.isUnlocked, isFalse);
    expect(store.readEntries(), isEmpty);
  });

  test('unlockedListenable follows the lock state', () async {
    final states = <bool>[];
    vault.unlockedListenable.addListener(() => states.add(vault.unlockedListenable.value));

    await vault.create('master');
    vault.lock();
    await vault.unlock('master');
    await vault.destroy();

    expect(states, [true, false, true, false]);
  });

  test('newEntryId returns distinct 32-char hex ids', () {
    final ids = List.generate(100, (_) => VaultService.newEntryId());

    expect(ids.toSet(), hasLength(100));
    expect(ids.every(RegExp(r'^[0-9a-f]{32}$').hasMatch), isTrue);
  });
}
