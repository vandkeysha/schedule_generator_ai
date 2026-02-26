import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:schedule_generator_ai/models/task.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';
  final String apiKey;

  GeminiService() : apiKey = dotenv.env["GEMINI_API_KEY"] ?? "please input your API KEY" {
    if (apiKey.isEmpty) {
      throw ArgumentError("API KEY is missing");
    }
  } 

   Future<String> generateSchedule(List<Task> tasks) async {
    _validateTasks(tasks);
    final prompt = _buildPrompt(tasks);
    try {
      // akan muncul di debug console, untuk memastikan prompt sudah benar sebelum dikirim ke API
      print("prompt: \n$prompt");
      // add request time out message to avoid indefinite hangs if the Api is not responding
      final response = await http
          .post(Uri.parse("$_baseUrl?key=$apiKey"), headers: {
            "content-type": "application/json"
          },
          body: jsonEncode({
            "contents": [
              {
                "role": "user",
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          })
          ).timeout(Duration(seconds: 10));
          return _handleResponse(response);
    } catch (e) {
      throw ArgumentError("Failed to generate Schedule: $e");
    }
   }

  String _handleResponse(http.Response responses) {
    final data = jsonDecode(responses.body); 
    if (responses.statusCode == 401) { // 200 success
      throw ArgumentError("InValid API KEY Or unauthorized Access");
    } else if (responses.statusCode == 429){
      throw ArgumentError("Rate limit exceeded, please try again later");
    } else if (responses.statusCode == 500){
      throw ArgumentError("INTERNAL SERVER ERROR, please try again later");
    } else if (responses.statusCode == 503){
      throw ArgumentError("Service unavailable, please try again later");
    } else if(responses.statusCode == 200){
      return data["candidates"][0]["content"]["parts"][0]["text"];
    } else{
      throw ArgumentError("Unexpected Error");
    }
  }

  String _buildPrompt(List<Task> tasks) {
    final taskList = tasks.map((task) => "${task.name} (Priority: ${task.priority}, Duration: ${task.duration} minute, Deadline: ${task.deadline})").join("\n");
    return "Buatkan jadwal harian yang optimal berdasarkan task berikut:\n$taskList";
  }

  void _validateTasks(List<Task> tasks)  {
    if(tasks.isEmpty) throw ArgumentError("Task list cannot be empty, please provide at least one task.");
  }
}