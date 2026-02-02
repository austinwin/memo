import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/app/providers.dart';
import 'package:intl/intl.dart';

class JournalStats extends ConsumerWidget {
  const JournalStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entryRepositoryProvider).watchAll();

    return StreamBuilder<List<Entry>>(
      stream: entriesAsync,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? [];
        final stats = _calculateStats(entries);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: '🔥',
                    label: '${stats.streak} days',
                    subLabel: 'streak',
                    color: Colors.orange.shade50,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: '📅',
                    label: '${stats.entriesThisWeek} entry',
                    subLabel: 'wk',
                    labelSuffix: stats.entriesThisWeek != 1 ? 'wk' : 'wk',
                    color: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: '📝',
                    label: '${stats.wordsToday} words',
                    subLabel: 'today',
                    color: Colors.purple.shade50,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: '📊',
                    label: '${stats.wordsTotal} word',
                    subLabel: 'total',
                    labelSuffix: stats.wordsTotal != 1 ? 'total' : 'total',
                    color: Colors.green.shade50,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _Stats _calculateStats(List<Entry> entries) {
    if (entries.isEmpty) {
      return _Stats(0, 0, 0, 0);
    }
    
    // Sort logic is not needed for raw loops, but helpful for streak
    final sorted = List<Entry>.from(entries);
    sorted.sort((a,b) => b.createdAt.compareTo(a.createdAt));
    
    final dayKeys = <String>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int wordsToday = 0;
    int wordsTotal = 0;
    int entriesThisWeek = 0;
    
    for (final e in entries) {
       final dayKey = DateFormat('yyyy-MM-dd').format(e.createdAt);
       dayKeys.add(dayKey);
       
       final wordCount = _countWords(e.body);
       wordsTotal += wordCount;
       
       final entryDate = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
       
       if (entryDate.isAtSameMomentAs(today)) {
          wordsToday += wordCount;
       }
       
       final diff = now.difference(e.createdAt).inDays;
       if (diff >= 0 && diff < 7) {
          entriesThisWeek++;
       }
    }
    
    // Streak
    int streak = 0;
    var cursor = today;
    // Safety limit
    for (int i = 0; i < 3650; i++) {
        final key = DateFormat('yyyy-MM-dd').format(cursor);
        if (dayKeys.contains(key)) {
            streak++;
        } else {
             // If we haven't posted today yet, don't break the streak from yesterday immediately?
             // PWA logic says: if (!dayKeys.has(key)) break;
             // But if today is missing, the streak might be from yesterday. 
             // Logic in JS loops 3650 times starting from now. If today is invalid, streak is 0? 
             // Let's assume strict streak for now.
             if (i == 0 && !dayKeys.contains(key)) {
                // Check yesterday
             } else {
                 break;
             }
        }
        cursor = cursor.subtract(const Duration(days: 1));
    }
    
    // Re-check strict streak similar to simple JS logic
    // JS: starts cursor at now. if (!has(key)) break.
    // So if I didn't write today, streak is 0. 
    // Let's make it lenient: if today is missing, check yesterday.
    
    if (!dayKeys.contains(DateFormat('yyyy-MM-dd').format(today))) {
       // Reset and try from yesterday
       streak = 0;
       cursor = today.subtract(const Duration(days: 1));
           for (int i = 0; i < 3650; i++) {
            final key = DateFormat('yyyy-MM-dd').format(cursor);
            if (!dayKeys.contains(key)) break;
            streak++;
            cursor = cursor.subtract(const Duration(days: 1));
        }
    }

    return _Stats(streak, entriesThisWeek, wordsToday, wordsTotal);
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}

class _Stats {
  final int streak;
  final int entriesThisWeek;
  final int wordsToday;
  final int wordsTotal;
  
  _Stats(this.streak, this.entriesThisWeek, this.wordsToday, this.wordsTotal);
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String subLabel;
  final String? labelSuffix;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.subLabel,
    this.labelSuffix,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6), 
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            RichText(
                text: TextSpan(
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
                    children: [
                        TextSpan(text: label),
                        if (labelSuffix != null) TextSpan(text: ' $labelSuffix', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.grey)),
                    ]
                )
            ),
             if (labelSuffix == null) ...[
                 const SizedBox(width: 4),
                 Text(subLabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
             ]
        ],
      ),
    );
  }
}
