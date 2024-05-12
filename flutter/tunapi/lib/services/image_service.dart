import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/image_data.dart';

Future<List<ImageData>> loadImages() async {
  const String baseUrl = 'http://192.168.1.104:5000/api/';
  var response = await http.get(Uri.parse(baseUrl));
  var jsonData = json.decode(response.body) as List;
  return jsonData.map((data) => ImageData.fromJson(data)).toList();
}
