import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/util/attachment_image.dart';
import 'package:video_player/video_player.dart';

class EntryDetailPage extends ConsumerStatefulWidget {
  const EntryDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends ConsumerState<EntryDetailPage> {
  Future<Entry?>? _future;

  IconData _getSymbolIcon(String? symbol) {
    return switch (symbol) {
      'Home' => Icons.home,
      'Office' => Icons.business,
      'Cafe' => Icons.local_cafe,
      'Restaurant' => Icons.restaurant,
      'Store' => Icons.store,
      'Heart' => Icons.favorite,
      'Star' => Icons.star,
      'Travel' => Icons.flight,
      'Nature' => Icons.forest,
      _ => Icons.location_on,
    };
  }

  Color _getSymbolColor(String? symbol) {
    return switch (symbol) {
      'Heart' => Colors.red,
      'Nature' => Colors.green,
      _ => Colors.blueAccent,
    };
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = ref.read(entryRepositoryProvider);
    _future = repo.getById(widget.entryId);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(entryRepositoryProvider);
    final df = DateFormat('EEE, MMM d • h:mm a');

    return FutureBuilder<Entry?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final entry = snap.data;
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Entry not found')),
          );
        }

        final title = entry.title.trim().isEmpty ? 'Untitled' : entry.title.trim();
        final body = entry.body.trim().isEmpty ? '(empty)' : entry.body.trim();

        final moodLabel = switch (entry.mood) {
          'great' => 'Mood: 😊 Great',
          'ok' => 'Mood: 😐 OK',
          'bad' => 'Mood: 😞 Bad',
          _ => null,
        };

        return Scaffold(
          appBar: AppBar(
            title: const Text('Entry'),
            actions: [
              IconButton(
                tooltip: entry.pinned ? 'Unpin' : 'Pin',
                onPressed: () async {
                  await repo.save(
                    entry.copyWith(
                      pinned: !entry.pinned,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  setState(_reload);
                },
                icon: Icon(entry.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: () => context.go('/entry/${entry.id}/edit'),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  final deleted = entry;
                  await repo.delete(entry.id);
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Entry deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await repo.save(deleted);
                        },
                      ),
                    ),
                  );

                  context.pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      df.format(entry.updatedAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    if (moodLabel != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Mood: $moodLabel',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (entry.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in entry.tags) Chip(label: Text(t)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (entry.lat != null && entry.lng != null) ...[
                  SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(entry.lat!, entry.lng!),
                          initialZoom: 15,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mobile',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(entry.lat!, entry.lng!),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  _getSymbolIcon(entry.locationSymbol),
                                  color: _getSymbolColor(entry.locationSymbol),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EntryBody(entry: entry, fallbackText: body),
                        if (entry.attachments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.attachments.map((a) {
                              final thumb = (a.type == 'image' || a.type == 'drawing')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: buildAttachmentImage(a.path, width: 100, height: 100, fit: BoxFit.cover),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(a.type == 'video' ? Icons.videocam : Icons.insert_drive_file),
                                    );
                              return InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AttachmentViewerPage(attachment: a)),
                                ),
                                child: thumb,
                              );
                            }).toList(),
                          ),
                        ],
                        if (entry.tasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final task in entry.tasks)
                            Row(
                              children: [
                                Icon(
                                  task.done
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: task.done
                                      ? Colors.teal
                                      : Theme.of(context).hintColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(task.text)),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntryBody extends StatelessWidget {
  const _EntryBody({required this.entry, required this.fallbackText});

  final Entry entry;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    if (entry.bodyFormat == 'markdown') {
      return MarkdownBody(data: entry.body);
    }
    if (entry.bodyFormat == 'rich' && entry.bodyDelta != null) {
      try {
        final document = quill.Document.fromJson(jsonDecode(entry.bodyDelta!) as List);
        final controller = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
        return quill.QuillEditor.basic(controller: controller);
      } catch (_) {
        return Text(fallbackText, style: Theme.of(context).textTheme.bodyLarge);
      }
    }
    return Text(fallbackText, style: Theme.of(context).textTheme.bodyLarge);
  }
}

class AttachmentViewerPage extends StatefulWidget {
  const AttachmentViewerPage({super.key, required this.attachment});

  final EntryAttachment attachment;

  @override
  State<AttachmentViewerPage> createState() => _AttachmentViewerPageState();
}

class _AttachmentViewerPageState extends State<AttachmentViewerPage> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.attachment.type == 'video') {
        _controller = kIsWeb
          ? VideoPlayerController.networkUrl(Uri.parse(widget.attachment.path))
          : VideoPlayerController.networkUrl(Uri.file(widget.attachment.path));
      _controller!.initialize().then((_) {
        if (mounted) setState(() {});
        _controller?.play();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.attachment;
    return Scaffold(
      appBar: AppBar(title: Text(a.name ?? 'Attachment')),
      body: Center(
        child: switch (a.type) {
          'image' || 'drawing' => buildAttachmentImage(a.path),
          'video' => (_controller == null || !_controller!.value.isInitialized)
              ? const CircularProgressIndicator()
              : AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
          _ => Text(a.path),
        },
      ),
    );
  }
}
