import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/data/entry_repository.dart';
import 'package:mobile/data/local/app_db.dart';

final appDbProvider = Provider<AppDb>((ref) {
  final db = AppDb();
  ref.onDispose(db.close);
  return db;
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(ref.watch(appDbProvider));
});
