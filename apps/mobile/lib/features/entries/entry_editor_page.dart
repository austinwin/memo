import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/data/attachment_storage.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/features/entries/drawing_canvas_page.dart';
import 'package:mobile/util/attachment_image.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';

class EntryEditorPage extends ConsumerStatefulWidget {
  const EntryEditorPage({super.key, required this.entryId, this.dayKeyParam});

  final String? entryId;
  final String? dayKeyParam;

  @override
  ConsumerState<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends ConsumerState<EntryEditorPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _tagController = TextEditingController();
  final _taskController = TextEditingController();
  late quill.QuillController _quillController;

  bool _loading = true;
  Entry? _existing;

  int? _moodInt; // deprecated
  String? _mood; // 'bad', 'ok', 'great'
  bool _pinned = false;
  bool _isTodo = false;
  
  double? _lat;
  double? _lng;
  String? _locationLabel;
  String? _locationSymbol;
  String _editorMode = 'plain';
  bool _showMarkdownPreview = false;
  List<EntryAttachment> _attachments = <EntryAttachment>[];
  final _picker = ImagePicker();
  final _attachmentStorage = AttachmentStorage();
  
  List<String> _tags = <String>[];
  List<TaskItem> _tasks = <TaskItem>[];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(entryRepositoryProvider);

    if (widget.entryId != null) {
      _existing = await repo.getById(widget.entryId!);
      _titleController.text = _existing?.title ?? '';
      _bodyController.text = _existing?.body ?? '';
      _editorMode = _existing?.bodyFormat ?? 'plain';
      _attachments = List<EntryAttachment>.from(_existing?.attachments ?? const <EntryAttachment>[]);
      _mood = _existing?.mood;
      _pinned = _existing?.pinned ?? false;
      _isTodo = _existing?.isTodo ?? false;
      _lat = _existing?.lat;
      _lng = _existing?.lng;
      _locationLabel = _existing?.locationLabel;
      _locationSymbol = _existing?.locationSymbol;
      _tags = List<String>.from(_existing?.tags ?? const <String>[]);
      _tasks = List<TaskItem>.from(_existing?.tasks ?? const <TaskItem>[]);
    }

    if (_editorMode == 'rich' && (_existing?.bodyDelta?.isNotEmpty ?? false)) {
      try {
        final document = quill.Document.fromJson(jsonDecode(_existing!.bodyDelta!) as List);
        _quillController = quill.QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillController = quill.QuillController.basic();
      }
    }

    setState(() => _loading = false);
  }

  DateTime _createdAtForNewEntry(DateTime now) {
    final k = widget.dayKeyParam;
    if (k == null || k.isEmpty) return now;

    final parts = k.split('-');
    if (parts.length != 3) return now;

    // Keep time-of-day as now, but lock date to the selected day.
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  Future<void> _save() async {
    final repo = ref.read(entryRepositoryProvider);
    final now = DateTime.now();

    final title = _titleController.text;
    String body = _bodyController.text;
    String? bodyDelta;

    if (_editorMode == 'rich') {
      body = _quillController.document.toPlainText().trimRight();
      bodyDelta = jsonEncode(_quillController.document.toDelta().toJson());
    }

    final entry = _existing == null
        ? Entry(
            id: const Uuid().v7(),
            title: title,
            body: body,
            createdAt: _createdAtForNewEntry(now),
            updatedAt: now,
            mood: _mood,
            pinned: _pinned,
            isTodo: _isTodo,
            lat: _lat,
            lng: _lng,
            locationLabel: _locationLabel,
            locationSymbol: _locationSymbol,
            bodyFormat: _editorMode,
            bodyDelta: bodyDelta,
            attachments: _attachments,
            tags: _tags,
            tasks: _tasks,
          )
        : _existing!.copyWith(
            title: title,
            body: body,
            updatedAt: now,
            mood: _mood,
            pinned: _pinned,
            isTodo: _isTodo,
            lat: _lat,
            lng: _lng,
            locationLabel: _locationLabel,
            locationSymbol: _locationSymbol,
            bodyFormat: _editorMode,
            bodyDelta: bodyDelta,
            attachments: _attachments,
            tags: _tags,
            tasks: _tasks,
          );

    await repo.save(entry);

    if (!mounted) return;
    context.go('/entry/${entry.id}');
  }

  void _addTag() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(RegExp(r'[ ,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() {
      for (final t in parts) {
        if (!_tags.contains(t)) _tags.add(t);
      }
      _tagController.clear();
    });
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _tasks = [..._tasks, TaskItem(text: text, done: false)];
      _taskController.clear();
    });
  }

  Future<void> _addAttachmentFromPath(String path, String type, {String? name}) async {
    final stored = await _attachmentStorage.savePath(path, name ?? type);
    final attachment = EntryAttachment(
      id: const Uuid().v7(),
      type: type,
      path: stored,
      name: name,
      createdAt: DateTime.now(),
    );
    setState(() => _attachments = [..._attachments, attachment]);
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final stored = await _attachmentStorage.saveXFile(picked, picked.name);
    final attachment = EntryAttachment(
      id: const Uuid().v7(),
      type: 'image',
      path: stored,
      name: picked.name,
      createdAt: DateTime.now(),
    );
    setState(() => _attachments = [..._attachments, attachment]);
  }

  Future<void> _pickVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    final stored = await _attachmentStorage.saveXFile(picked, picked.name);
    final attachment = EntryAttachment(
      id: const Uuid().v7(),
      type: 'video',
      path: stored,
      name: picked.name,
      createdAt: DateTime.now(),
    );
    setState(() => _attachments = [..._attachments, attachment]);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path != null) {
      await _addAttachmentFromPath(file.path!, 'file', name: file.name);
      return;
    }
    if (file.bytes != null) {
      final ext = file.extension != null ? '.${file.extension}' : '.bin';
      final stored = await _attachmentStorage.saveBytes(file.bytes!, file.name, ext: ext);
      final attachment = EntryAttachment(
        id: const Uuid().v7(),
        type: 'file',
        path: stored,
        name: file.name,
        createdAt: DateTime.now(),
      );
      setState(() => _attachments = [..._attachments, attachment]);
    }
  }

  Future<void> _addDrawing() async {
    final bytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(builder: (_) => const DrawingCanvasPage()),
    );
    if (bytes == null) return;
    final saved = await _attachmentStorage.saveBytes(bytes, 'drawing');
    final attachment = EntryAttachment(
      id: const Uuid().v7(),
      type: 'drawing',
      path: saved,
      name: 'Drawing',
      createdAt: DateTime.now(),
    );
    setState(() => _attachments = [..._attachments, attachment]);
  }

  void _removeAttachment(String id) {
    setState(() => _attachments = _attachments.where((a) => a.id != id).toList());
  }

  Future<void> _useCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    } 

    // setState(() => _loading = true); // Don't block whole UI
    try {
        final position = await Geolocator.getCurrentPosition();
        setState(() {
            _lat = position.latitude;
            _lng = position.longitude;
        });
    } catch(e) {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
        // setState(() => _loading = false);
    }
  }

  void _showLocationPicker() {
    // Basic dialog state variables for editing within the dialog
    String? tempSymbol = _locationSymbol ?? 'Pin';
    String? tempLabel = _locationLabel;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
               width: double.infinity,
               // height: 500, // Dynamic height preferred
               child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                       // Header
                       Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           child: Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                   const Text('Add Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                   IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop())
                               ],
                           ),
                       ),
                       const Divider(height: 1),
                       // Map
                       SizedBox(
                           height: 250,
                           child: FlutterMap(
                              options: MapOptions(
                                initialCenter: (_lat != null && _lng != null) ? LatLng(_lat!, _lng!) : const LatLng(37.7749, -122.4194),
                                initialZoom: 13,
                                onTap: (_, point) {
                                  setStateDialog(() {
                                    _lat = point.latitude;
                                    _lng = point.longitude;
                                  });
                                  // Update parent state too if needed, but we usually commit on Save
                                  // For now, let's keep _lat/_lng live
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.mobile',
                                ),
                                if (_lat != null && _lng != null)
                                    MarkerLayer(
                                        markers: [
                                            Marker(
                                                point: LatLng(_lat!, _lng!),
                                                width: 40,
                                                height: 40,
                                        child: Icon(
                                          _getIconForSymbol(tempSymbol),
                                          color: _getColorForSymbol(tempSymbol),
                                          size: 40,
                                        ),
                                            )
                                        ],
                                    )
                              ],
                            ),
                       ),
                       // Controls
                       Padding(
                           padding: const EdgeInsets.all(16),
                           child: Column(
                               children: [
                                   SizedBox(
                                       width: double.infinity,
                                       height: 48,
                                       child: OutlinedButton.icon(
                                           onPressed: () async {
                                                try {
                                                    final pos = await Geolocator.getCurrentPosition();
                                                    setStateDialog(() {
                                                        _lat = pos.latitude;
                                                        _lng = pos.longitude;
                                                    });
                                                } catch(e) { /* ignore */ }
                                           }, 
                                           icon: const Icon(Icons.my_location, color: Colors.red), 
                                           label: const Text('Use Current Location', style: TextStyle(color: Colors.blue)),
                                           style: OutlinedButton.styleFrom(
                                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                               side: BorderSide(color: Colors.grey.withValues(alpha: 0.3))
                                           )
                                       ),
                                   ),
                                   const SizedBox(height: 12),
                                   Row(
                                       children: [
                                           // Label Input
                                           Expanded(
                                               flex: 2,
                                               child: TextField(
                                                   controller: TextEditingController(text: tempLabel),
                                                   onChanged: (v) => tempLabel = v,
                                                   decoration: InputDecoration(
                                                       hintText: 'Label (Home, Office, etc.)',
                                                       filled: true,
                                                       fillColor: Colors.grey.withValues(alpha: 0.1),
                                                       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                                   ),
                                               ),
                                           ),
                                           const SizedBox(width: 8),
                                           // Symbol Dropdown
                                           Expanded(
                                               flex: 1,
                                               child: PopupMenuButton<String>(
                                                   initialValue: tempSymbol,
                                                   child: Container(
                                                       height: 48,
                                                       padding: const EdgeInsets.symmetric(horizontal: 12),
                                                       decoration: BoxDecoration(
                                                           color: Colors.grey.withValues(alpha: 0.1),
                                                           borderRadius: BorderRadius.circular(12)
                                                       ),
                                                       child: Row(
                                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                           children: [
                                                               Icon(_getIconForSymbol(tempSymbol), size: 20, color: Colors.blueGrey),
                                                               const Icon(Icons.keyboard_arrow_down, size: 16)
                                                           ],
                                                       ),
                                                   ),
                                                   onSelected: (v) => setStateDialog(() => tempSymbol = v),
                                                   itemBuilder: (context) => [
                                                       'Pin', 'Home', 'Office', 'Cafe', 'Restaurant', 'Store', 'Heart', 'Star', 'Travel', 'Nature'
                                                   ].map((s) => PopupMenuItem(
                                                       value: s, 
                                                       child: Row(children: [
                                                           Icon(_getIconForSymbol(s), size: 18, color: Colors.blueGrey),
                                                           const SizedBox(width: 8),
                                                           Text(s)
                                                       ])
                                                   )).toList(),
                                               ),
                                           )
                                       ],
                                   ),
                                   const SizedBox(height: 16),
                                   Row(
                                       children: [
                                           Expanded(
                                               child: TextButton(
                                                   onPressed: () {
                                                       setState(() {
                                                           _lat = null;
                                                           _lng = null;
                                                           _locationLabel = null;
                                                           _locationSymbol = null;
                                                       });
                                                       context.pop();
                                                   },
                                                   child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                               ),
                                           ),
                                           const SizedBox(width: 8),
                                           Expanded(
                                               child: FilledButton(
                                                   onPressed: () {
                                                       setState(() {
                                                            // latlng already updated
                                                            _locationLabel = tempLabel;
                                                            _locationSymbol = tempSymbol;
                                                       });
                                                       context.pop();
                                                   },
                                                   style: FilledButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                                   child: const Text('Save Location'),
                                               ),
                                           )
                                       ],
                                   )
                               ],
                           ),
                       )
                   ],
               ),
            ),
          );
        }
      ),
    );
  }

  IconData _getIconForSymbol(String? symbol) {
      return switch(symbol) {
          'Home' => Icons.home,
          'Office' => Icons.business,
          'Cafe' => Icons.local_cafe,
          'Restaurant' => Icons.restaurant,
          'Store' => Icons.store,
          'Heart' => Icons.favorite,
          'Star' => Icons.star,
          'Travel' => Icons.flight,
          'Nature' => Icons.forest,
          _ => Icons.location_on
      };
  }

    Color _getColorForSymbol(String? symbol) {
      return switch (symbol) {
        'Heart' => Colors.red,
        'Nature' => Colors.green,
        _ => Colors.blueAccent,
      };
    }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    _taskController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entryId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            tooltip: _pinned ? 'Unpin' : 'Pin',
            onPressed: _loading ? null : () => setState(() => _pinned = !_pinned),
            icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Editor Mode
                  Text('Editor', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'plain', label: Text('Plain')),
                      ButtonSegment(value: 'markdown', label: Text('Markdown')),
                      ButtonSegment(value: 'rich', label: Text('Rich')),
                    ],
                    selected: <String>{_editorMode},
                    onSelectionChanged: (s) {
                      if (s.isEmpty) return;
                      setState(() => _editorMode = s.first);
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_editorMode == 'markdown')
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Preview Markdown'),
                      value: _showMarkdownPreview,
                      onChanged: (v) => setState(() => _showMarkdownPreview = v),
                    ),
                  if (_editorMode == 'plain')
                    TextField(
                      controller: _bodyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      minLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Write…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  if (_editorMode == 'markdown') ...[
                    TextField(
                      controller: _bodyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      minLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Write in Markdown…',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (_showMarkdownPreview) setState(() {});
                      },
                    ),
                    if (_showMarkdownPreview) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: MarkdownBody(data: _bodyController.text),
                      ),
                    ],
                  ],
                  if (_editorMode == 'rich') ...[
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                      ),
                    ),
                    const SizedBox(height: 8),
                    quill.QuillSimpleToolbar(
                      controller: _quillController,
                      config: const quill.QuillSimpleToolbarConfig(
                        showAlignmentButtons: false,
                        showCodeBlock: false,
                        showHeaderStyle: true,
                        showColorButton: false,
                        showBackgroundColorButton: false,
                        showStrikeThrough: true,
                        showIndent: false,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Mood (3-level)
                  Text('Mood', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'bad', label: Text('😞')),
                      ButtonSegment(value: 'ok', label: Text('😐')),
                      ButtonSegment(value: 'great', label: Text('😊')),
                    ],
                    selected: _mood == null ? <String>{} : <String>{_mood!},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (s) {
                      setState(() {
                        _mood = s.isEmpty ? null : s.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Todo Mode
                  SwitchListTile(
                    title: const Text('Is Todo?'),
                    subtitle: const Text('Mark this entry as a task'),
                    value: _isTodo,
                    onChanged: (v) => setState(() => _isTodo = v),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        Text('Location', style: Theme.of(context).textTheme.titleMedium),
                        Row(
                            children: [
                                TextButton.icon(
                                    onPressed: _useCurrentLocation,
                                    icon: const Icon(Icons.my_location),
                                    label: const Text('Current'),
                                ),
                                IconButton(onPressed: _showLocationPicker, icon: const Icon(Icons.map)),
                            ],
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_lat != null && _lng != null) ...[
                    Row(children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 4),
                      Text(
                          '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'),
                      const Spacer(),
                      TextButton(
                          onPressed: () =>
                              setState(() {
                                _lat = null;
                                _lng = null;
                              }),
                          child: const Text('Remove'))
                    ]),
                    SizedBox(
                        height: 150,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(_lat!, _lng!),
                                  initialZoom: 14,
                                  interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.none),
                                ),
                                children: [
                                  TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.mobile'),
                                  MarkerLayer(markers: [
                                    Marker(
                                        point: LatLng(_lat!, _lng!),
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          _getIconForSymbol(_locationSymbol),
                                          color: _getColorForSymbol(_locationSymbol),
                                          size: 40,
                                        ))
                                  ])
                                ]))),
                  ] else
                    OutlinedButton.icon(
                        onPressed: _showLocationPicker,
                        icon: const Icon(Icons.map),
                        label: const Text('Add Location')),

                  const SizedBox(height: 16),

                  // Attachments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.add),
                        onSelected: (v) async {
                          if (v == 'image') await _pickImage();
                          if (v == 'video') await _pickVideo();
                          if (v == 'file') await _pickFile();
                          if (v == 'drawing') await _addDrawing();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'image', child: Text('Add Image')),
                          PopupMenuItem(value: 'video', child: Text('Add Video')),
                          PopupMenuItem(value: 'file', child: Text('Add File')),
                          PopupMenuItem(value: 'drawing', child: Text('Draw')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_attachments.isEmpty)
                    Text('No attachments yet.', style: TextStyle(color: Theme.of(context).hintColor)),
                  if (_attachments.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _attachments.map((a) {
                        final thumb = (a.type == 'image' || a.type == 'drawing')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: buildAttachmentImage(a.path, width: 80, height: 80, fit: BoxFit.cover),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(a.type == 'video' ? Icons.videocam : Icons.insert_drive_file),
                              );
                        return Stack(
                          children: [
                            thumb,
                            Positioned(
                              top: -6,
                              right: -6,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () => _removeAttachment(a.id),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                  // Tags
                  Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in _tags)
                        InputChip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTag,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tasks
                  Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final task in _tasks)
                    CheckboxListTile(
                      value: task.done,
                      title: Text(task.text),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(
                        tooltip: 'Remove',
                        onPressed: () {
                          setState(() {
                            _tasks = _tasks.where((t) => t != task).toList();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _tasks = _tasks
                              .map(
                                (t) => t == task
                                    ? t.copyWith(done: v ?? false)
                                    : t,
                              )
                              .toList();
                        });
                      },
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            hintText: 'Add task',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTask,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
