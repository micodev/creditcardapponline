import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trymethods/database/database.dart';
import 'package:trymethods/model/User.dart';

class UserAccess {
  final dbProvider = DatabaseProvider.dbProvider;
  final apiUrl = "https://radiant-anchorage-08266.herokuapp.com/api";
  Future<int> createUser(User user) async {
    var body = json.encode(user.toDatabaseJson());
    var response = await http.post('$apiUrl/user',
        body: body, headers: {"Content-Type": "application/json"});
    response.body;
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<User>> getUsers() async {
    var response = await http.get('$apiUrl/user');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => User.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<User> getUser(String id) async {
    var response = await http.get('$apiUrl/user/$id');
    response.body;
    return response.statusCode == 200
        ? User.fromDatabaseJson(json.decode(response.body))
        : Null;
  }

  Future<int> updateUser(User user) async {
    var body = json.encode(user.toDatabaseJson());
    var response = await http.put('$apiUrl/user/${user.id}',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<int> deleteUser(int id) async {
    var response = await http.delete('$apiUrl/user/$id');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future deleteAllUsers() async {
    var response = await http.delete('$apiUrl/user');
    return response.statusCode == 200 ? 1 : 0;
  }
}
