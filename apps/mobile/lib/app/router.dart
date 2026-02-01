import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/entries/entry_detail_page.dart';
import 'package:mobile/features/entries/entry_editor_page.dart';
import 'package:mobile/features/entries/entry_list_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const EntryListPage(),
      routes: [
        GoRoute(
          path: 'entry/:id',
          builder:
              (context, state) => EntryDetailPage(entryId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              builder:
                  (context, state) => EntryEditorPage(entryId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'new',
          builder: (context, state) => const EntryEditorPage(entryId: null),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(
        child: Text(state.error?.toString() ?? 'Route error'),
      ),
    );
  },
);
