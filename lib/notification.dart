import 'package:flutter/material.dart';

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
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
      theme: themeData,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child:Column(
            children: [
              // push to bottom 
              const Spacer(),
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    leading: const Icon(Icons.search),
                    hintText: 'search movie...',
                    onSubmitted:(value) => debugPrint(value),
                  );
                },

                // expand on this if you want to suggest movies before entering 
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return const <Widget>[];
                },
            ),
            // 5% spacing 
            SizedBox(height: MediaQuery.of(context).size.height * 0.05,)
          ])
        ),
      ),
    );
  }
}