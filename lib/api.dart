
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
    debugPrint("test");
    debugPrint(search_results.toString());
    // convert the json into a list containing dictionary's
    final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(search_results);

    return results;
  }else{
    throw Exception("TMDB request failed, status code: ${response.statusCode}");
  }
}  

