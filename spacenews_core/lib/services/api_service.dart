import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String _baseUrl =
      'https://api.spaceflightnewsapi.net/v4/articles/';

  static Future<List<Article>> fetchArticles({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        return results.map((e) => Article.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
