import 'dart:io';

import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/Company.dart';

class PrintWidget {
  int typeId;
  String print;
  int count;
  PrintWidget({this.typeId, this.print, this.count});
  factory PrintWidget.fromDatabaseJson(Map<String, dynamic> json) =>
      PrintWidget(
        typeId: json["type_id"],
        print: json["print"],
        count: json["count"],
      );
  Map<String, dynamic> toDatabaseJson() => {
        'type_id': typeId,
        'print': print,
        'count': count,
      };
}

class TypeAndCompany {
  CardType ct;
  Company cm;
  TypeAndCompany({this.ct, this.cm});
  factory TypeAndCompany.fromDatabaseJson(List<dynamic> json) => TypeAndCompany(
      ct: CardType.fromDatabaseJson(json[0]),
      // CardType(
      //     id: json[0]["id"],
      //     price: json[0]["price"],
      //     companyId: json[0]["company_id"]),
      cm: Company.fromDatabaseJson(json[1]));
  //Company(id: json[1]["id"], name: json[0]["name"]));
}

class CheckConnection {
  Future<bool> checkConnect() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }
}
