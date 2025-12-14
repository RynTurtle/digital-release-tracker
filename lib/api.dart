
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

Future<List<Map<String, dynamic>>> search_movie(String search_query) async {
  final uri = Uri.https(
    'api.themoviedb.org',
    '/3/search/movie',
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



Future<String> get_digital_date(int movie_id) async {
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
    throw Exception("digital release not found");
}  

