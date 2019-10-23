import 'dart:async';
import 'dart:convert';
//import 'package:trymethods/database/database.dart';
import 'package:trymethods/model/Company.dart';
import 'package:http/http.dart' as http;

class CompanyAccess {
  final apiUrl = "https://radiant-anchorage-08266.herokuapp.com/api";
  //final dbProvider = DatabaseProvider.dbProvider;
  Future<int> createCompany(Company company) async {
    // final db = await dbProvider.database;
    //debugPrint(company.toDatabaseJson().toString());
    // var result = db.insert(companyTABLE, company.toDatabaseJson());
    // return result;
    var body = json.encode(company.toDatabaseJson());
    var response = await http.post('$apiUrl/company',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<Company> getCompany(int id) async {
    // final db = await dbProvider.database;
    // var res = await db.query(companyTABLE, where: "id = ?", whereArgs: [id]);
    // return res.isNotEmpty ? Company.fromDatabaseJson(res.first) : Null;
    var response = await http.get('$apiUrl/company/$id');
    return response.statusCode == 200
        ? Company.fromDatabaseJson(json.decode(response.body))
        : Null;
  }

  Future<List<Company>> getCompanys() async {
    // final db = await dbProvider.database;
    // List<Map<String, dynamic>> result;
    // result = await db.query(companyTABLE);
    // List<Company> companys = result.isNotEmpty
    //     ? result.map((item) => Company.fromDatabaseJson(item)).toList()
    //     : [];
    // return companys;
    var response = await http.get('$apiUrl/company');
    List<dynamic> result = json.decode(response.body);
    return response.statusCode == 200
        ? result.map((item) => Company.fromDatabaseJson(item)).toList()
        : [];
  }

  Future<int> updateCompany(Company company) async {
    var body = json.encode(company.toDatabaseJson());
    var response = await http.put('$apiUrl/company/${company.id}',
        body: body, headers: {"Content-Type": "application/json"});
    return response.statusCode == 200 ? 1 : 0;
  }

  Future<int> deleteCompany(int id) async {
    var response = await http.delete('$apiUrl/company/$id');
    return response.statusCode == 200 ? 1 : 0;
  }

  Future deleteAllCompanys() async {
    var response = await http.delete('$apiUrl/company');
    return response.statusCode == 200 ? 1 : 0;
  }
}
