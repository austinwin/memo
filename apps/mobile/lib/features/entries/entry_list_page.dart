import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:mobile/app/providers.dart';
import 'package:mobile/data/entry_repository.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/features/entries/widgets/journal_stats.dart';

class EntryListPage extends ConsumerStatefulWidget {
  const EntryListPage({super.key});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  int _tabIndex = 0; 
  String _query = '';
  
  // Filters
  String _filter = 'All Entries'; 
  String _moodFilter = 'All'; 
  String _sort = 'Newest';

  // Map State
  bool _showMapTimeline = false;
  double _mapTimelineValue = 1.0; 
  bool _showHeatmap = false; 
  String _timelineMode = 'Up to';
  
  // Map Filters
  String _mapMoodFilter = 'All moods';
  String _mapPinFilter = 'All';

  IconData _getSymbolIcon(String? symbol) {
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

  @override
  Widget build(BuildContext context) {
    if (_tabIndex == 1) {
       return _buildMapTab();
    }
    return _buildJournalTab();
  }

  Widget _buildJournalTab() {
    final repo = ref.watch(entryRepositoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final now = DateTime.now();
    final df = DateFormat('MMM d, yyyy, h:mm a');

    final dailyGoal = ref.watch(dailyGoalProvider);
    final todaysFocus = ref.watch(todaysFocusProvider);

    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0, 
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
             // Header Area
             Container(
                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                 color: bgColor,
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                const Text('Journal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                Row(
                                    children: [
                                        // Upload/Download for Import/Export
                                        IconButton(onPressed: (){}, icon: const Icon(Icons.download_outlined, color: Colors.blue), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                        const SizedBox(width: 16),
                                        IconButton(onPressed: (){}, icon: const Icon(Icons.upload_outlined, color: Colors.blue), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                        const SizedBox(width: 16),
                                        // Calendar Button (Restored)
                                        IconButton(
                                            onPressed: () async {
                                                final picked = await showDatePicker(
                                                    context: context, 
                                                    firstDate: DateTime(2020), 
                                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                                    initialDate: now
                                                );
                                                if(picked != null) {
                                                    // Logic to jump to date or filter could go here
                                                }
                                            }, 
                                            icon: const Icon(Icons.calendar_month, color: Colors.blue), 
                                            padding: EdgeInsets.zero, 
                                            constraints: const BoxConstraints()
                                        ),
                                        const SizedBox(width: 16),
                                        // Theme Switch
                                        InkWell(
                                            onTap: () {
                                                final newMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                                                ref.read(themeModeProvider.notifier).setMode(newMode);
                                            },
                                            customBorder: const CircleBorder(),
                                            child: Container(
                                                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), shape: BoxShape.circle),
                                                padding: const EdgeInsets.all(8),
                                                child: Icon(
                                                    themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, 
                                                    size: 20, 
                                                    color: Colors.blueGrey
                                                ),
                                            ),
                                        ),
                                    ],
                                )
                            ],
                        ),
                        const SizedBox(height: 16),
                        // Removed subheader as per user request
                        Text(df.format(now), style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
                        const SizedBox(height: 16),
                        
                        // Collapsible Dashboard
                        ExpansionTile(
                            title: const Text("Dashboard", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            initiallyExpanded: false,
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            shape: const Border(),
                            children: [
                                // Stats
                                const JournalStats(),
                                const SizedBox(height: 12),
                                // Daily Goal & Focus
                                Row(
                                    children: [
                                        Expanded(
                                            child: InkWell(
                                                onTap: () => _editValue(context, "Daily Goal", dailyGoal.value, dailyGoalProvider),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    height: 70,
                                                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                                                    child: dailyGoal.when(
                                                        data: (val) => (val == null || val.isEmpty) 
                                                            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.track_changes, color: Colors.deepOrangeAccent, size: 20), SizedBox(width: 8), Text("Set a daily goal", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13))])
                                                            : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                const Text("Daily Goal", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                                                const SizedBox(height: 2),
                                                                Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                            ]),
                                                        loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                                                        error: (_,__) => const Text("Error"),
                                                    ),
                                                ),
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: InkWell(
                                                onTap: () => _editValue(context, "Today's Focus", todaysFocus.value, todaysFocusProvider),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                    padding: const EdgeInsets.all(12),
                                                    height: 70,
                                                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                                                    child: todaysFocus.when(
                                                        data: (val) => (val == null || val.isEmpty) 
                                                            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lightbulb, color: Colors.amber, size: 20), SizedBox(width: 8), Text("Set today's focus", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13))])
                                                            : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                const Text("Today's Focus", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                                                const SizedBox(height: 2),
                                                                Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                            ]),
                                                        loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                                                        error: (_,__) => const Text("Error"),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ],
                                )
                            ],
                        ),

                        const SizedBox(height: 16),
                        
                        ExpansionTile(
                            title: const Text("Search", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            initiallyExpanded: false,
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            shape: const Border(),
                            children: [
                                TextField(
                                    decoration: InputDecoration(
                                        filled: true,
                                        fillColor: isDark ? Colors.grey[800] : Colors.grey.withValues(alpha: 0.1),
                                        hintText: 'Search entries...',
                                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                    ),
                                    onChanged: (v) => setState(() => _query = v),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                    children: [
                                        Expanded(
                                            flex: 3,
                                            child: _Dropdown(label: _filter, value: _filter, 
                                                items: const ['All Entries', 'Pinned', 'Tasks'],
                                                onChanged: (v) => setState(() => _filter = v)
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            flex: 2,
                                            child: _Dropdown(label: _moodFilter == 'All' ? 'Mood' : _moodFilter, value: _moodFilter, 
                                                items: const ['All', 'Good 😊', 'Ok 😐', 'Bad 😞'],
                                                onChanged: (v) => setState(() => _moodFilter = v),
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            flex: 2,
                                            child: _Dropdown(
                                                label: _sort,
                                                value: _sort,
                                                items: const ['Newest', 'Oldest', 'Title'],
                                                onChanged: (v) => setState(() => _sort = v),
                                            ),
                                        ),
                                    ],
                                ),
                                const SizedBox(height: 8),
                            ],
                        ),
                    ],
                 ),
             ),
             
             // List
             Expanded(
                 child: StreamBuilder<List<Entry>>(
                    stream: repo.watchAll(query: _query),
                    builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        var entries = snap.data!;
                        
                        // Client filters
                        entries = entries.where((e) {
                             if (_filter == 'Pinned' && !e.pinned) return false;
                             if (_filter == 'Tasks' && !e.isTodo) return false;
                             
                             if (_moodFilter != 'All') {
                                 final moodVal = _moodFilter.split(' ').first.toLowerCase();
                                 final target = switch(moodVal) {
                                     'good' => 'great',
                                     'bad' => 'bad',
                                     'ok' => 'ok',
                                     _ => 'all'
                                 };
                                 if (target != 'all' && e.mood != target) return false;
                             }
                             
                             return true;
                        }).toList();
                        
                        // Sort
                        if (_sort == 'Oldest') {
                            entries.sort((a,b) => a.createdAt.compareTo(b.createdAt));
                        } else if (_sort == 'Title') {
                            entries.sort((a,b) => a.title.compareTo(b.title));
                        } else {
                            entries.sort((a,b) => b.createdAt.compareTo(a.createdAt));
                        }
                        
                         if (entries.isEmpty) {
                            return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No entries found')));
                         }

                          // Group by day
                          final groups = <String, List<Entry>>{};
                          final dayFormat = DateFormat('EEE, MMM d, yyyy');
                          
                          for (final e in entries) {
                            final k = dayFormat.format(e.createdAt);
                            groups.putIfAbsent(k, () => []).add(e);
                          }
                          
                          final dayKeys = groups.keys.toList();
                          
                          return ListView.builder(
                             padding: const EdgeInsets.only(bottom: 80),
                             itemCount: dayKeys.length,
                             itemBuilder: (context, idx) {
                                 final day = dayKeys[idx];
                                 final group = groups[day]!;
                                 return Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                         Padding(
                                             padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                             child: Row(
                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                 children: [
                                                     Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                     Text('${group.length} entry', style: const TextStyle(color: Colors.grey)),
                                                 ],
                                             ),
                                         ),
                                         ...group.map((e) => _EntryCard(e: e, repo: repo)),
                                     ],
                                 );
                             },
                          );
                    },
                 ),
             ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(Theme.of(context).bottomNavigationBarTheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new'),
        backgroundColor: const Color(0xFF3B82F6), 
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _editValue(BuildContext context, String title, String? currentValue, StateNotifierProvider<AsyncStringNotifier, AsyncValue<String?>> provider) async {
      final controller = TextEditingController(text: currentValue);
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Text(title),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter value...'),
              ),
              actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: () {
                      ref.read(provider.notifier).set(controller.text);
                      Navigator.pop(context);
                  }, child: const Text('Save')),
              ],
          )
      );
  }

  Widget _buildMapTab() {
     final repo = ref.watch(entryRepositoryProvider);
     return Scaffold(
        body: StreamBuilder<List<Entry>>(
            stream: repo.watchAll(),
            builder: (context, snap) {
                var entries = snap.data ?? [];
                
                // Sort by date (oldest first for timeline)
                entries.sort((a,b) => a.createdAt.compareTo(b.createdAt));
                
                // 1. Calculate Distinct Time Groups for Slider
                List<String> timeKeys = [];
                String Function(DateTime) keyGen;
                
                if (_timelineMode == 'Monthly') {
                    keyGen = (d) => '${d.year}-${d.month}';
                } else if (_timelineMode == 'Weekly') {
                    keyGen = (d) => '${d.year}-W${(d.day / 7).ceil()}'; // Simple week grouping
                } else if (_timelineMode == 'Daily') {
                    keyGen = (d) => '${d.year}-${d.month}-${d.day}';
                } else {
                    // Up to / All time
                    keyGen = (d) => 'all'; 
                }

                if (_timelineMode != 'Up to') {
                    timeKeys = entries.map((e) => keyGen(e.createdAt)).toSet().toList();
                }

                // 2. Filter Entries based on Slider
                if (_showMapTimeline && entries.isNotEmpty) {
                     if (_timelineMode == 'Up to') {
                         // Cumulative scrubbing
                         final int idx = ((entries.length - 1) * _mapTimelineValue).round().clamp(0, entries.length - 1);
                         final limitDate = entries[idx].createdAt;
                         entries = entries.where((e) => e.createdAt.isBefore(limitDate) || e.createdAt.isAtSameMomentAs(limitDate)).toList();
                     } else if (timeKeys.isNotEmpty) {
                         // Discrete scrubbing
                         final int keyIdx = ((timeKeys.length - 1) * _mapTimelineValue).round().clamp(0, timeKeys.length - 1);
                         final targetKey = timeKeys[keyIdx];
                         entries = entries.where((e) => keyGen(e.createdAt) == targetKey).toList();
                     }
                }

                // 3. Location & Map Filters
                final valid = entries.where((e) {
                    if (e.lat == null || e.lng == null) return false;
                    
                    // Mood Filter
                    if (_mapMoodFilter != 'All moods') {
                        final targetMood = _mapMoodFilter.toLowerCase(); // 'great', 'okay', 'bad'
                        if (e.mood != null && e.mood != targetMood) return false;
                        if (e.mood == null) return false; // Hide unset moods if filter is active
                    }
                    
                    // Pin/Symbol Filter
                    if (_mapPinFilter != 'All') { 
                         if (_mapPinFilter == 'Favorites' && !e.pinned) return false;
                         // If we filter by symbol type (Home, Office etc.)
                         if (['Home', 'Office', 'Cafe', 'Restaurant', 'Store', 'Heart', 'Star', 'Travel', 'Nature'].contains(_mapPinFilter)) {
                             if (e.locationSymbol != _mapPinFilter) return false;
                         }
                    }
                    
                    return true;
                }).toList();
                
                final LatLng center;
                if (valid.isNotEmpty) {
                    center = LatLng(valid.last.lat!, valid.last.lng!);
                } else {
                    center = const LatLng(0,0);
                }
                
                final placesCount = valid.map((e) => '${e.lat!.toStringAsFixed(3)},${e.lng!.toStringAsFixed(3)}').toSet().length;

                return Stack(
                    children: [
                        FlutterMap(
                            options: MapOptions(
                                initialCenter: center,
                                initialZoom: valid.isNotEmpty ? 13 : 2,
                            ),
                            children: [
                                TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.mobile',
                                ),
                                MarkerLayer(
                                    markers: valid.map((e) {
                                        if (_showHeatmap) {
                                            // Simulated Heatmap: Transparent Circles
                                            return Marker(
                                                point: LatLng(e.lat!, e.lng!),
                                                width: 80,
                                                height: 80,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.red.withOpacity(0.3),
                                                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)]
                                                    ),
                                                ),
                                            );
                                        } else {
                                            // Regular Labelled Marker with Symbol
                                            final symbolIcon = _getSymbolIcon(e.locationSymbol);

                                            return Marker(
                                                point: LatLng(e.lat!, e.lng!),
                                                width: 120, // Wider for label
                                                height: 80,
                                                child: GestureDetector(
                                                    onTap: () => context.go('/entry/${e.id}'),
                                                    child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                            // Label
                                                            Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white.withOpacity(0.95),
                                                                    borderRadius: BorderRadius.circular(6),
                                                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
                                                                    border: Border.all(color: Colors.grey.withOpacity(0.2))
                                                                ),
                                                                child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                        Text(e.locationLabel ?? (e.title.isEmpty ? 'Untitled' : e.title), 
                                                                            maxLines: 1, 
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)
                                                                        ),
                                                                        Text(DateFormat('MMM d').format(e.createdAt), 
                                                                            style: const TextStyle(fontSize: 9, color: Colors.grey)
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                            // Beak of the bubble
                                                            ClipPath(
                                                                clipper: _TriangleClipper(),
                                                                child: Container(color: Colors.white.withOpacity(0.95), width: 8, height: 6),
                                                            ),
                                                            // Symbol Icon
                                                            Icon(symbolIcon, color: e.locationSymbol == 'Heart' ? Colors.red : (e.locationSymbol == 'Nature' ? Colors.green : Colors.blueAccent), size: 32),
                                                        ],
                                                    ),
                                                ),
                                            );
                                        }
                                    }).toList(),
                                )
                            ],
                        ),
                        
                        // Controls Layer
                        SafeArea(
                             child: Column(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                     // Top Row
                                     Container(
                                         margin: const EdgeInsets.all(16),
                                         child: Row(
                                             children: [
                                                 // Back
                                                 Container(
                                                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                                                     child: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black), onPressed: () => setState(() => _tabIndex = 0)),
                                                 ),
                                                 const SizedBox(width: 12),
                                                 // Title 
                                                 const Text('Map', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                 const SizedBox(width: 8),
                                                 Container(
                                                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                     decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
                                                     child: Text('$placesCount place${placesCount==1?'':'s'} · ${valid.length} entry', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                                                 ),
                                                 const Spacer(),
                                                 // Icons
                                                 Row(
                                                     mainAxisSize: MainAxisSize.min,
                                                     children: [
                                                         _MapHeadBtn(icon: Icons.refresh, onTap: () => setState((){})),
                                                         const SizedBox(width: 8),
                                                         _MapHeadBtn(
                                                             icon: Icons.history, 
                                                             isActive: _showMapTimeline,
                                                             activeColor: Colors.blue.shade100,
                                                             iconColor: _showMapTimeline ? Colors.blue : null,
                                                             onTap: () => setState(() => _showMapTimeline = !_showMapTimeline)
                                                         ),
                                                         const SizedBox(width: 8),
                                                         _MapHeadBtn(
                                                             icon: Icons.local_fire_department, 
                                                             isActive: _showHeatmap,
                                                             activeColor: Colors.orange.shade100,
                                                             iconColor: _showHeatmap ? Colors.orange : null,
                                                             onTap: () => setState(() => _showHeatmap = !_showHeatmap)
                                                         ),
                                                     ],
                                                 )
                                             ],
                                         ),
                                     ),
                                     
                                     // Search
                                     Container(
                                         margin: const EdgeInsets.symmetric(horizontal: 16),
                                         child: TextField(
                                            decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: 'Search map entries',
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                                prefixIcon: const Icon(Icons.search),
                                            ),
                                         ),
                                     ),
                                     const SizedBox(height: 12),
                                     
                                     // Chips Row & Timeline
                                     Container(
                                         margin: const EdgeInsets.symmetric(horizontal: 16),
                                         decoration: _showMapTimeline ? BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.9),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                         ) : null,
                                         padding: _showMapTimeline ? const EdgeInsets.all(8) : null,
                                         child: Column(
                                             children: [
                                                 Row(
                                                     children: [
                                                          // Mood Filter Dropdown
                                                          PopupMenuButton<String>(
                                                              initialValue: _mapMoodFilter,
                                                              child: Container(
                                                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
                                                                 child: Row(children: [
                                                                     if(_mapMoodFilter == 'All moods') const Icon(Icons.check, size: 16),
                                                                     if(_mapMoodFilter != 'All moods') const SizedBox(width: 16), // space for check
                                                                     const SizedBox(width: 4),
                                                                     Text(_mapMoodFilter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                                     const SizedBox(width: 4),
                                                                     const Icon(Icons.keyboard_arrow_down, size: 16)
                                                                 ]),
                                                              ),
                                                              onSelected: (v) => setState(() => _mapMoodFilter = v),
                                                              itemBuilder: (context) => [
                                                                  const PopupMenuItem(value: 'All moods', child: Row(children: [Icon(Icons.check, size: 16), SizedBox(width: 8), Text('All moods')])),
                                                                  const PopupMenuItem(value: 'great', child: Row(children: [Text('😊 Great')])), // value matches domain logic
                                                                  const PopupMenuItem(value: 'ok', child: Row(children: [Text('😐 Okay')])),
                                                                  const PopupMenuItem(value: 'bad', child: Row(children: [Text('😞 Bad')])),
                                                              ],
                                                          ),
                                                          const SizedBox(width: 8),
                                                          // Pins/Symbol Filter Dropdown
                                                          PopupMenuButton<String>(
                                                              initialValue: _mapPinFilter,
                                                              child: Container(
                                                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
                                                                 child: Row(children: [
                                                                     Icon(_mapPinFilter == 'All' ? Icons.filter_alt : _getSymbolIcon(_mapPinFilter), size: 16, color: Colors.blueAccent),
                                                                     const SizedBox(width: 4),
                                                                     Text(_mapPinFilter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                                                     const SizedBox(width: 4),
                                                                     const Icon(Icons.keyboard_arrow_down, size: 16)
                                                                 ]),
                                                              ),
                                                              onSelected: (v) => setState(() => _mapPinFilter = v),
                                                              itemBuilder: (context) {
                                                                  final list = ['All', 'Home', 'Office', 'Cafe', 'Restaurant', 'Store', 'Heart', 'Star', 'Travel', 'Nature'];
                                                                  return list.map((s) {
                                                                     final icon = s == 'All' ? Icons.filter_alt : _getSymbolIcon(s);
                                                                     return PopupMenuItem(
                                                                         value: s, 
                                                                         child: Row(children: [
                                                                             Icon(icon, size: 18, color: Colors.grey[700]), 
                                                                             const SizedBox(width: 8), 
                                                                             Text(s)
                                                                         ])
                                                                     );
                                                                  }).toList();
                                                              },
                                                          ),
                                                     ],
                                                 ),
                                                 // Timeline Slider Custom
                                                 if (_showMapTimeline) ...[
                                                     const SizedBox(height: 8),
                                                     const Divider(height: 1, color: Colors.black12),
                                                     const SizedBox(height: 4),
                                                     Row(
                                                         children: [
                                                             const Text("All time", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                                             Expanded(
                                                                 child: SliderTheme(
                                                                     data: SliderTheme.of(context).copyWith(
                                                                         trackHeight: 2,
                                                                         activeTrackColor: Colors.blue.withOpacity(0.3),
                                                                         thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                                         overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                                                     ),
                                                                     child: Slider(
                                                                         value: _mapTimelineValue,
                                                                         min: 0,
                                                                         max: 1.0, 
                                                                         divisions: (_timelineMode != 'Up to' && timeKeys.isNotEmpty) ? timeKeys.length : null,
                                                                         activeColor: Colors.blue,
                                                                         inactiveColor: Colors.grey.withValues(alpha: 0.3),
                                                                         onChanged: (v) => setState(() => _mapTimelineValue = v),
                                                                     ),
                                                                 ),
                                                             ),
                                                             
                                                             PopupMenuButton<String>(
                                                                 child: Container(
                                                                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withValues(alpha: 0.3))),
                                                                     child: Row(children: [
                                                                         Text(_timelineMode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                                         const SizedBox(width: 4), 
                                                                         const Icon(Icons.keyboard_arrow_down, size: 16)
                                                                     ]),
                                                                 ),
                                                                 onSelected: (v) => setState(() => _timelineMode = v),
                                                                 itemBuilder: (context) => ['Up to', 'Daily', 'Weekly', 'Monthly']
                                                                    .map((m) => PopupMenuItem(value: m, child: Text(m))).toList()
                                                             ),
                                                         ],
                                                     )
                                                 ]
                                             ],
                                         ),
                                     )
                                 ],
                             ),
                         ),
                    ],
                );
            }
        ),
        bottomNavigationBar: _buildBottomBar(Theme.of(context).bottomNavigationBarTheme),
        floatingActionButton: _showMapTimeline ? null : FloatingActionButton(
            onPressed: () => context.go('/new'),
            backgroundColor: const Color(0xFF3B82F6),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
        ),
     );
  }

  // Helper widget for map header buttons
  Widget _MapHeadBtn({required IconData icon, VoidCallback? onTap, bool isActive = false, Color? activeColor, Color? iconColor}) {
      return Container(
         decoration: BoxDecoration(
             color: isActive ? (activeColor ?? Colors.blue.shade100) : Colors.white,
             borderRadius: BorderRadius.circular(8),
             boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2)]
         ),
         child: IconButton(
             icon: Icon(icon, color: isActive ? (iconColor ?? Colors.blue) : Colors.black87, size: 20),
             onPressed: onTap,
             constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
             padding: EdgeInsets.zero,
         ),
      );
  }

  Widget _buildBottomBar(BottomNavigationBarThemeData theme) {
      return BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
              BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), activeIcon: Icon(Icons.edit), label: 'Entries'),
              BottomNavigationBarItem(icon: Icon(Icons.map_outlined), activeIcon: Icon(Icons.map), label: 'Map'),
          ],
      );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _Dropdown extends StatelessWidget {
    final String label;
    final String value;
    final List<String> items;
    final ValueChanged<String> onChanged;
    
    const _Dropdown({
        super.key,
        required this.label, 
        required this.value, 
        required this.items, 
        required this.onChanged,
    });
    
    @override
    Widget build(BuildContext context) {
         return Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
             decoration: BoxDecoration(
                 color: Theme.of(context).cardColor,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey.withValues(alpha: 0.2))
             ),
             child: DropdownButtonHideUnderline(
                 child: DropdownButton<String>(
                     isExpanded: true,
                     value: items.contains(value) ? value : items.first,
                     hint: Text(label, style: const TextStyle(fontSize: 13)),
                     icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                     style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color),
                     items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                     onChanged: (v) {
                         if (v != null) onChanged(v);
                     },
                 ),
             ),
         );
    }
}

class _EntryCard extends StatelessWidget {
    final Entry e;
    final EntryRepository repo;
    const _EntryCard({required this.e, required this.repo});

    @override
    Widget build(BuildContext context) {
        final df = DateFormat('h:mm a');
        return InkWell(
            onTap: () => context.go('/entry/${e.id}'),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text(e.title.isEmpty ? 'Untitled' : e.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(df.format(e.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                        ),
                        if (e.body.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(e.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                        ],
                        if (e.tags.isNotEmpty || e.lat != null) ...[
                            const SizedBox(height: 12),
                            Row(
                                children: [
                                    if (e.lat != null) const Icon(Icons.location_on, size: 14, color: Colors.blueAccent),
                                    if (e.lat != null) const SizedBox(width: 4),
                                    ...e.tags.map((t) => Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text('#$t', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                    )),
                                ],
                            ),
                        ]
                    ],
                ),
            ),
        );
    }
}
