import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'api.dart';
import 'package:auto_size_text/auto_size_text.dart';


class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

// builds the movie list by listview building each element 
class MovieList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  MovieList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // build each widget item in the list 
      itemBuilder: (context, index) {
        double container_height = 200;

        String movie_title = items[index]["original_title"]; 
        String theatrical_release = items[index]["release_date"]; 
        String poster_path = items[index]["poster_path"] ?? ""; 
        String poster_url = "https://image.tmdb.org/t/p/w300$poster_path";

        int movie_id = items[index]["id"];

        final TextStyle release_style = const TextStyle(
          fontSize: 14,
          color: Colors.black54,
        );

        //debugPrint(movie_id.toString());
        //String digital_release = get_digital_date(movie_id) 
        return Padding(
          //main box which holds movie info 
          padding: const EdgeInsets.all(1.0),
          child: Container(
            height: container_height,
            //color: Colors.amber,
          
          // inside the box
          child:Row(
            children: [
              // movie image 
              Image.network(
                poster_url,
                // ensures 
                height: container_height,
                fit: BoxFit.cover,
                
                errorBuilder: (context, error, stackTrace) {
                  // replaces image with the broken image icon if the 
                  return const Icon(Icons.broken_image, size: 150);
               },
              ),
            
              // movie text (movie title, movie date top to bottom)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AutoSizeText(
                  movie_title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                AutoSizeText(
                  "Theatrical release: $theatrical_release",
                  style: release_style
                    ),


                FutureBuilder<String?>(
                  future: get_digital_date(movie_id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Digital release: Loading...",style: release_style);
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text("Digital release: N/A",style: release_style);
                    }

                    return Text("Digital release: ${snapshot.data}",style: release_style);
                  },
                ),
                    ],
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
