import 'dart:async';
import 'package:trymethods/model/CardType.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trymethods/model/PrintWidget.dart';

class CardTypeAccess {
  final apiUrl = "https://radiant-anchorage-08266.herokuapp.com/api";

  Future<int> createCardType(CardType type) async {
    var body = json.encode(type.toDatabaseJson());
    var response = await http.post('$apiUrl/type',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<CardType>> getCardTypes() async {
    var response = await http.get('$apiUrl/type');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => CardType.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<int> updateCardType(CardType type) async {
    var body = json.encode(type.toDatabaseJson());
    var response = await http.put('$apiUrl/type/${type.id}',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<int> deleteCardType(int id) async {
    var response = await http.delete('$apiUrl/type/$id');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future deleteAllCardTypes() async {
    var response = await http.delete('$apiUrl/type');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<List<TypeAndCompany>> getCardTypeAndCompany() async {
    // var cmpa = new CompanyAccess();
    // List<List<dynamic>> _final = new List();
    // List<CardType> types = await getCardTypes();
    // for (int i = 0; i < types.length; i++) {
    //   Company c = await cmpa.getCompany(types[i].companyId);
    //   _final.add([types[i], c]);
    // }

    // return _final;
    var response = await http.get('$apiUrl/getTypeAndCompany');
    List<dynamic> result = json.decode(response.body);

    var vsult = response.statusCode == 200
        ? result.map((item) => TypeAndCompany.fromDatabaseJson(item)).toList()
        : [];
    return vsult;
  }
}
