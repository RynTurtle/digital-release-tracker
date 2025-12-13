import 'package:flutter/material.dart';
import 'api.dart';


class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

// builds the movie list by listview building each element 
class MovieList extends StatelessWidget {
  final List<dynamic> items;
  const MovieList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
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
  List<Map<String, dynamic>>  movie_data =  [];

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
                child: MovieList(items:movie_data),
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
                    onSubmitted: (value) async {
                        // add the searched movies response to the list builder
                        final results = await search_movie(value);

                       setState(() {
                        // reload the page
                        movie_data = results;
                       });
                    }
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
