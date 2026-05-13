import 'package:flutter/material.dart';
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
    final Map<int, Future<String?>> _digitalDateCache = {};

  Future<String?> getCachedDigitalDate(int movieId) {
    return _digitalDateCache.putIfAbsent(
      movieId,
      () => get_digital_date(movieId),
    );
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      // build each widget item in the list 
      itemBuilder: (context, index) {
        double container_height = 200;


        String title = items[index]["original_title"] ?? items[index]["original_name"]; 
        String release_date = items[index]["release_date"] ?? items[index]["first_air_date"]; 
        String poster_path = items[index]["poster_path"] ?? ""; 
        String poster_url = "https://image.tmdb.org/t/p/w300$poster_path";
        String search_type = (items[index]["search_type"] ?? "a").toString();

        int id = items[index]["id"];

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
                  title,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                AutoSizeText(
                  search_type == "movie" ? "MOVIE" : "TV",
                  style: release_style
                    ),


                AutoSizeText(
                  "Release date: $release_date",
                  style: release_style
                    ),

                FutureBuilder<String?>(
                  future: getCachedDigitalDate(id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Digital release: Loading...",style: release_style);
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      // if theres no digital release date 
                      return Text("",style: release_style);
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
  List<Map<String, dynamic>>  search_results =  [];

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
                child: MovieList(items:search_results),
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
                    hintText: 'search for movie/show...',
                    onSubmitted: (value) async {
                        // add the searched movies and tv responses to the list builder
                        final r1 = await search("movie", value);
                        final r2 = await search("tv", value);
                        for (var item in r1) {item["search_type"] = "movie";}
                        for (var item in r2) {item["search_type"] = "tv";}
                        
                        r1.addAll(r2); // merge the two lists 
                       setState(() {
                        // reload the page
                        search_results = r1;
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
