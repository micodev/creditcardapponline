import 'dart:async';
import 'dart:convert';
import 'package:trymethods/model/Log.dart';
import 'package:http/http.dart' as http;

class LogAccess {
  final apiUrl = "https://radiant-anchorage-08266.herokuapp.com/api";

  Future<int> createLog(Log log) async {
    var body = json.encode(log.toDatabaseJson());
    var response = await http.post('$apiUrl/log',
        body: body, headers: {"Content-Type": "application/json"});
    response.body;
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<Log>> getLogs() async {
    var response = await http.get('$apiUrl/log');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => Log.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<List<Log>> getLogsByDate({Duration time}) async {
    final date = DateTime.now();
    int now = date.millisecondsSinceEpoch;
    int day = date.add(time).millisecondsSinceEpoch;
    var response = await http.get('$apiUrl/log/$now/$day');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => Log.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<int> deleteLog(int id) async {
    var response = await http.delete('$apiUrl/log/$id');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<int> deleteLogByDate(Duration dur) async {
    int now = DateTime.now().add(dur).millisecondsSinceEpoch;
    var response = await http.delete('$apiUrl/logdate/$now');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future deleteAllLogs() async {
    var response = await http.delete('$apiUrl/log');
    response.body;
    return response.statusCode == 200 ? 1 : 0;
  }
}
