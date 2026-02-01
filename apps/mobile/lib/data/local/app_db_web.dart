import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openConnection() {
  // Persisted in IndexedDB in the browser.
  return WebDatabase('memo');
}
