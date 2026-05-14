import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'watchlist.dart'; // uses WatchlistStorage.loadWatchlist()

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // need to change when making it for real
  final DateTime _firstDay = DateTime.utc(2000, 1, 1);
  final DateTime _lastDay = DateTime.utc(2100, 12, 31);

  // stores all saved movies/shows
  List<Map<String, dynamic>> watchlist = [];

  // stores events mapped to a specific day
  Map<DateTime, List<Map<String, dynamic>>> watchlistEvents = {};

  // remove time part so days match correctly
  DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // load saved watchlist from storage
  Future<void> loadWatchlist() async {
    final loaded = await WatchlistStorage.loadWatchlist();

    setState(() {
      watchlist = loaded;
    });

    // rebuild event map
    loadEvents();
  }

  // build calendar events map from watchlist
  void loadEvents() {
    watchlistEvents.clear();

    for (var item in watchlist) {
      // tv uses first_air_date, movie uses release_date
      final dateString = item["release_date"] ?? item["first_air_date"];
      if (dateString == null || dateString == "") continue;

      final date = normalize(DateTime.parse(dateString));

      watchlistEvents.putIfAbsent(date, () => []);
      watchlistEvents[date]!.add(item);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadWatchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TableCalendar(
        firstDay: _firstDay,
        lastDay: _lastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,

        // loads events for each day
        eventLoader: (day) {
          final d = normalize(day);
          return watchlistEvents[d] ?? [];
        },

        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(_selectedDay, day);
        },

        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },

        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },

        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },

        // show watchlist items inside the day boxes
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            final first = events[0] as Map<String, dynamic>;

            // tv uses original_name, movie uses original_title
            final title = first["original_title"] ??
                first["original_name"] ??
                "Unknown";

            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}