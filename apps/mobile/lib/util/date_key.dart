import 'package:intl/intl.dart';

final _dayKeyFormat = DateFormat('yyyy-MM-dd');

String dayKey(DateTime dt) {
  final local = dt.toLocal();
  return _dayKeyFormat.format(DateTime(local.year, local.month, local.day));
}

DateTime dayStart(DateTime dt) {
  final local = dt.toLocal();
  return DateTime(local.year, local.month, local.day);
}
