import 'package:flutter/material.dart';
import 'package:trymethods/bloc/CompanyBloc.dart';
import 'package:trymethods/model/Company.dart';

class DropDownCompany extends StatefulWidget {
  final Company initialValue;
  final void Function(Company) onValueChange;
  const DropDownCompany({this.onValueChange, this.initialValue});
  @override
  State createState() => new DropDownCompanyState();
}

class DropDownCompanyState extends State<DropDownCompany> {
  CompanyBloc companyBloc = new CompanyBloc();
  Company companyValue;
  @override
  void initState() {
    super.initState();
    companyValue = widget.initialValue;
  }

  List<Company> cardCompanys;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, AsyncSnapshot<List<Company>> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        else if (snapshot.hasData) if (snapshot.data.length == 0)
          return loadingData();
        else {
          cardCompanys = snapshot.data;
          return builderDropDown();
        }
        else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
      stream: companyBloc.companys,
    );
  }

  List<DropdownMenuItem<Company>> dropDownItemsBuilder(List<Company> companys) {
    return companys.map<DropdownMenuItem<Company>>((Company value) {
      return DropdownMenuItem<Company>(
        value: value,
        child: Text(value.name),
      ); //DropMenuItem
    }).toList();
  }

  Widget builderDropDown() {
    return new Theme(
      child: new DropdownButton<Company>(
        hint: const Text("pick company"),
        value: companyValue,
        onChanged: (Company value) {
          setState(() {
            companyValue = value;
          });
          widget.onValueChange(value);
        },
        items: dropDownItemsBuilder(cardCompanys),
      ),
      data: Theme.of(context).copyWith(
        canvasColor: Colors.grey.shade50,
      ),
    );
  }

  loadingData() {
    companyBloc.getCompanys();
    return Center(child: CircularProgressIndicator());
  }
}
