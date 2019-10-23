import 'package:flutter/material.dart';
import 'package:trymethods/databaseaccess/CardTypeAccess.dart';
import 'package:trymethods/databaseaccess/CompanyAccess.dart';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/Company.dart';

class DropDownTypes extends StatefulWidget {
  final TypesList initialValue;
  final void Function(TypesList) onValueChange;
  const DropDownTypes({this.onValueChange, this.initialValue});
  @override
  State createState() => new DropDownState();
}

class DropDownState extends State<DropDownTypes> {
  TypesList typeValue;
  @override
  void initState() {
    super.initState();
    typeValue = widget.initialValue;
  }

  List<DropdownMenuItem<TypesList>> cardtypes;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder:
          (context, AsyncSnapshot<List<DropdownMenuItem<TypesList>>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            else if (snapshot.data.length == 0) {
              dropDownItems();
              return CircularProgressIndicator();
            }
            cardtypes = cardtypes == null || cardtypes.length == 0
                ? snapshot.data
                : cardtypes;
            return new Theme(
              child: new DropdownButton<TypesList>(
                hint: const Text("pick type"),
                value: typeValue,
                onChanged: (TypesList value) {
                  setState(() {
                    typeValue = value;
                  });
                  widget.onValueChange(value);
                },
                items: cardtypes,
              ),
              data: Theme.of(context).copyWith(
                canvasColor: Colors.grey.shade50,
              ),
            );
        }
        return null;
      },
      future: dropDownItems(),
    );
  }

  Future<List<DropdownMenuItem<TypesList>>> dropDownItems() async {
    CardTypeAccess ctacc = CardTypeAccess();
    CompanyAccess ccacc = CompanyAccess();
    List<TypesList> tplist = new List<TypesList>();
    List<CardType> tp = await ctacc.getCardTypes();
    for (CardType t in tp) {
      Company c = await ccacc.getCompany(t.companyId);
      tplist.add(TypesList(
          c.name, t.brandPrice.toString().replaceFirst(".0", ""), t.id));
    }
    return tplist.map<DropdownMenuItem<TypesList>>((TypesList value) {
      return DropdownMenuItem<TypesList>(
        value: value,
        child: Text(value.company + " " + value.price + " الاف"),
      ); //DropMenuItem
    }).toList();
  }
}

class TypesList {
  String company;
  String price;
  int typeId;
  TypesList(this.company, this.price, this.typeId);
}
