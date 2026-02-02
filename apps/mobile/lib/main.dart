import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/data/local/isar_entry.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    runApp(const ProviderScope(child: MobileApp()));
  } else {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [IsarEntrySchema],
      directory: dir.path,
    );

    runApp(
      ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
        ],
        child: const MobileApp(),
      ),
    );
  }
}
