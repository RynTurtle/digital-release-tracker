import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

// builds the movie list by listview building each element 
class MovieList extends StatelessWidget {
  final List<int> _test = [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _test.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 200,
            color: Colors.amber,
          ),
        );
      },
    );
  }
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              // movie list which takes up the rest of the space 
              Expanded(
                child: MovieList(),
              ),

              const SizedBox(height: 20),

              //search bar at bottom of page
              SearchAnchor(
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    leading: const Icon(Icons.search),
                    hintText: 'search movie...',
                    onSubmitted: (value) => debugPrint(value),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return const <Widget>[];
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
