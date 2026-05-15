import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'watchlist.dart'; // uses WatchlistStorage.loadWatchlist()
import 'api.dart';
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
    await loadEvents();
  }

  // build calendar events map from watchlist
  Future<void> loadEvents() async {
    watchlistEvents.clear();

    for (var item in watchlist) {
      final id = item["id"];
      final searchType = item["search_type"];

      if (id == null) continue;

      // =========================
      // TV SHOWS (latest season + episodes)
      // =========================
      if (searchType == "tv") {
        final seasonDateString =
            await get_latest_season_date(id);

        if (seasonDateString != null &&
            seasonDateString != "") {
          final seasonDate =
              normalize(DateTime.parse(seasonDateString));

          watchlistEvents.putIfAbsent(seasonDate, () => []);
          watchlistEvents[seasonDate]!.add({
            ...item,
            "event_type": "season",
          });
        }

        final episodes =
            await get_latest_season_episodes(id);

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var ep in episodes) {
          final airDateString = ep["air_date"];
          if (airDateString == null || airDateString == "") continue;

          final airDate = DateTime.parse(airDateString);

          if (airDate.isBefore(today)) continue;

          final date = normalize(airDate);

          watchlistEvents.putIfAbsent(date, () => []);
          watchlistEvents[date]!.add({
            ...item,
            "event_type": "episode",
            "episode_name": ep["name"],
            "episode_number": ep["episode_number"],
          });
        }
      }

      // =========================
      // MOVIES (release date only)
      // =========================
      else if (searchType == "movie") {
        final releaseDate = item["release_date"];

        if (releaseDate != null && releaseDate != "") {
          final date = normalize(DateTime.parse(releaseDate));

          watchlistEvents.putIfAbsent(date, () => []);
          watchlistEvents[date]!.add({
            ...item,
            "event_type": "movie",
          });
        }
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

      // keep calendar and list separate (no shared scroll)
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

                  final first =
                      events[0] as Map<String, dynamic>;

                  final title = first["episode_name"] ??
                      first["season_name"] ??
                      first["original_title"] ??
                      first["original_name"] ??
                      "Event";

                  final type = first["event_type"];

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: type == "episode"
                            ? Colors.purple
                            : type == "movie"
                                ? Colors.green
                                : Colors.blue,
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

                  final type = item["event_type"];

                  return Card(
                    child: ListTile(
                      leading: Icon(
                        type == "episode"
                            ? Icons.movie
                            : type == "movie"
                                ? Icons.local_movies
                                : Icons.calendar_month,
                        color: type == "episode"
                            ? Colors.purple
                            : type == "movie"
                                ? Colors.green
                                : Colors.blue,
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