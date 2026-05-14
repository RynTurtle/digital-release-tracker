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

      // add digital date as a duplicate event
      final digitalDateString = item["digital_date"];
      if (digitalDateString != null && digitalDateString != "") {
        final digitalDate = normalize(DateTime.parse(digitalDateString));

        // create a modified copy so you can tell it's digital
        final digitalItem = Map<String, dynamic>.from(item);
        digitalItem["event_type"] = "digital";

        watchlistEvents.putIfAbsent(digitalDate, () => []);
        watchlistEvents[digitalDate]!.add(digitalItem);
      }
    }

    setState(() {});
  }

  List<Map<String, dynamic>> _getUpcomingEvents() {
    final all = <Map<String, dynamic>>[];

    watchlistEvents.forEach((date, items) {
      for (var item in items) {
        final copy = Map<String, dynamic>.from(item);
        copy["event_date"] = date;
        all.add(copy);
      }
    });

    all.sort((a, b) {
      final da = a["event_date"] as DateTime;
      final db = b["event_date"] as DateTime;
      return da.compareTo(db);
    });

    return all;
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

      // ✅ FIX: keep calendar and list separate (no shared scroll)
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: TableCalendar(
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,

              eventLoader: (day) {
                final d = normalize(day);
                return watchlistEvents[d] ?? [];
              },

              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),

              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },

              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },

              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },

              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return null;

                  final first = events[0] as Map<String, dynamic>;

                  final title = first["original_title"] ??
                      first["original_name"] ??
                      "Unknown";

                  final isDigital = first["event_type"] == "digital";

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDigital ? Colors.blue : Colors.green,
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
          ),

          Expanded(
            flex: 2,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: _getUpcomingEvents().length,
                itemBuilder: (context, index) {
                  final item = _getUpcomingEvents()[index];

                  final title = item["original_title"] ??
                      item["original_name"] ??
                      "Unknown";

                  final date = item["event_date"] as DateTime;

                  final isDigital = item["event_type"] == "digital";

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isDigital ? Icons.download : Icons.movie,
                        color: isDigital ? Colors.blue : Colors.green,
                      ),
                      title: Text(title),
                      subtitle: Text(
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}