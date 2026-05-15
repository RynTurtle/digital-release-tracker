
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';


Map<String, String> getHeaders() {
  return {
    'Authorization': 'Bearer ${dotenv.env["API_KEY"] ?? ""}',
    'Content-Type': 'application/json',
  };
}

Future<List<Map<String, dynamic>>> search(String search_type, String search_query) async {
  final uri = Uri.https(
    'api.themoviedb.org',
    '/3/search/$search_type',
    {'query': search_query},
  );

  var response = await http.get(uri,headers: getHeaders());
  if (response.statusCode == 200) {
    var request = convert.jsonDecode(response.body) as Map<String, dynamic>;
    var search_results = request["results"]; 
    //debugPrint(search_results.toString());
    // convert the json into a list containing dictionary's
    final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(search_results);

    return results;
  }else{
    throw Exception("TMDB request failed, status code: ${response.statusCode}");
  }
}  




Future<String?> get_digital_date(int movie_id) async {
  final uri = Uri.https(
    'api.themoviedb.org',
    '/3/movie/$movie_id/release_dates',
  );

  var response = await http.get(uri,headers: getHeaders());
  if (response.statusCode != 200) {
    throw Exception("TMDB request failed, status code: ${response.statusCode}");
  }

  var request = convert.jsonDecode(response.body) as Map<String, dynamic>;
  debugPrint(response.statusCode.toString());

  final List<dynamic> results = request["results"];
    for (var country_release in results){
        // go based on US release

        if (country_release["iso_3166_1"] == "US"){
          // if there is a US release then find the digital release 
          for (var us_release  in country_release["release_dates"]){
              if (us_release["type"] == 4){
                // return the digital release 
                debugPrint("release_date value: ${us_release["release_date"]}");
                return us_release["release_date"].toString().split("T")[0];
              }
          }
        }
    }
  return null; // no date found  
}  

Future<List<Map<String, dynamic>>> get_latest_season_episodes(int series_id) async {
  // get full TV show details (to find latest season number)
  final detailsUri = Uri.https(
    'api.themoviedb.org',
    '/3/tv/$series_id',
  );

  var detailsResponse = await http.get(detailsUri, headers: getHeaders());

  if (detailsResponse.statusCode != 200) {
    throw Exception(
        "TMDB request failed, status code: ${detailsResponse.statusCode}");
  }

  var details =
      convert.jsonDecode(detailsResponse.body) as Map<String, dynamic>;

  final List seasons = details["seasons"] ?? [];

  // remove specials (season 0)
  final validSeasons =
      seasons.where((s) => s["season_number"] != 0).toList();

  if (validSeasons.isEmpty) return [];

  // latest season by number
  validSeasons.sort((a, b) => a["season_number"].compareTo(b["season_number"]));

  final latestSeason = validSeasons.last;
  final seasonNumber = latestSeason["season_number"];

  // fetch episodes for that season
  final seasonUri = Uri.https(
    'api.themoviedb.org',
    '/3/tv/$series_id/season/$seasonNumber',
  );

  var seasonResponse = await http.get(seasonUri, headers: getHeaders());

  if (seasonResponse.statusCode != 200) {
    throw Exception(
        "TMDB request failed, status code: ${seasonResponse.statusCode}");
  }

  var seasonData =
      convert.jsonDecode(seasonResponse.body) as Map<String, dynamic>;

  final List episodes = seasonData["episodes"] ?? [];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // ONLY return real upcoming episodes
  final upcomingEpisodes = <Map<String, dynamic>>[];

  for (var e in episodes) {
    final airDateString = e["air_date"];
    if (airDateString == null || airDateString == "") continue;

    final airDate = DateTime.parse(airDateString);

    // ONLY FUTURE EPISODES
    if (airDate.isBefore(today)) continue;

    upcomingEpisodes.add(e as Map<String, dynamic>);
  }

  return upcomingEpisodes;
}


Future<String?> get_latest_season_date(int series_id) async {
  final uri = Uri.https(
    'api.themoviedb.org',
    '/3/tv/$series_id',
  );

  final response = await http.get(uri, headers: getHeaders());

  if (response.statusCode != 200) {
    throw Exception(
      "TMDB request failed, status code: ${response.statusCode}",
    );
  }

  final data =
      convert.jsonDecode(response.body) as Map<String, dynamic>;

  final seasons = data["seasons"] as List<dynamic>? ?? [];

  // remove specials (season 0)
  final validSeasons =
      seasons.where((s) => s["season_number"] != 0).toList();

  if (validSeasons.isEmpty) return null;

  final latestSeason = validSeasons.last;

  final dateString = latestSeason["air_date"];

  if (dateString == null || dateString == "") return null;

  return dateString.toString().split("T")[0];
}