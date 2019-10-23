import 'dart:async';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreditCardAccess {
  final apiUrl = "https://radiant-anchorage-08266.herokuapp.com/api";
  Future<int> createCreditCard(CreditCard card) async {
    var body = json.encode(card.toDatabaseJson());
    var response = await http.post('$apiUrl/card',
        body: body, headers: {"Content-Type": "application/json"});
    response.body;
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<CreditCard>> getCreditCards() async {
    var response = await http.get('$apiUrl/card');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => CreditCard.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<int> updateCreditCard(CreditCard card) async {
    var body = json.encode(card.toDatabaseJson());
    var response = await http.put('$apiUrl/card/${card.id}',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<int> deleteCreditCard(int id) async {
    var response = await http.delete('$apiUrl/card/$id');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future deleteAllCreditCards() async {
    var response = await http.delete('$apiUrl/card');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<PrintWidget>> getAvailableCreditCardsCounts() async {
    var response = await http.get('$apiUrl/cardAvailCount');
    response.body;
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => PrintWidget.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<List<CreditCard>> getCreditCardsByType(int id) async {
    var response = await http.get('$apiUrl/cardType/$id');
    response.body;
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => CreditCard.fromDatabaseJson(item)).toList()
        : [];
  }
}
