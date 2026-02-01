import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/util/date_key.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = dayStart(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(entryRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: StreamBuilder<Map<String, int>>(
        stream: repo.watchDayCountsForMonth(_focusedDay),
        builder: (context, snap) {
          final counts = snap.data ?? const <String, int>{};

          Color? heatColor(int count) {
            if (count <= 0) return null;
            if (count == 1) return Colors.teal.withValues(alpha: 0.15);
            if (count == 2) return Colors.teal.withValues(alpha: 0.25);
            if (count == 3) return Colors.teal.withValues(alpha: 0.35);
            return Colors.teal.withValues(alpha: 0.45);
          }

          return Column(
            children: [
              TableCalendar<void>(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = dayStart(selected);
                    _focusedDay = focused;
                  });
                  context.go('/calendar/day/${dayKey(selected)}');
                },
                onPageChanged: (focused) {
                  setState(() {
                    _focusedDay = focused;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focused) {
                    final k = dayKey(day);
                    final c = counts[k] ?? 0;
                    final bg = heatColor(c);
                    if (bg == null) return null;

                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('${day.day}'),
                    );
                  },
                  markerBuilder: (context, day, events) {
                    final k = dayKey(day);
                    final c = counts[k] ?? 0;
                    if (c <= 0) return null;

                    return Positioned(
                      bottom: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          c.clamp(1, 3),
                          (i) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Center(
                  child: Text(
                    'Tap a day to view entries',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
