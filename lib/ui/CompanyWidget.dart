import 'package:flutter/material.dart';
import 'package:trymethods/bloc/CompanyBloc.dart';

import 'package:trymethods/model/Company.dart';

class CompanyWidget extends StatefulWidget {
  CompanyWidget({Key key}) : super(key: key);
  static final route = "/companys";
  _CompanyWidgetState createState() => _CompanyWidgetState();
}

class _CompanyWidgetState extends State<CompanyWidget> {
  final CompanyBloc companybloc = CompanyBloc();
  @override
  Widget build(BuildContext context) {
    companybloc.getCompany(9).then((onValue) {
      debugPrint(onValue.toDatabaseJson().toString());
    });
    return Scaffold(
        appBar: AppBar(
          title: Text("الشركات"),
        ),
        body: getComapny(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: FloatingActionButton(
            elevation: 5.0,
            onPressed: () {
              showAddSheet(context);
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.indigoAccent,
            ),
          ),
        ));
  }

  Widget getComapny(BuildContext context) {
    return StreamBuilder(
      stream: companybloc.companys,
      initialData: new List<Company>(),
      builder: (BuildContext context, AsyncSnapshot<List<Company>> snapshot) {
        return buildWidget(context, snapshot);
      },
    );
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<List<Company>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? buildContent(context, snapshot.data)
          : Center(child: noCompanyFound());
    } else
      return loadingData();
  }

  Widget loadingData() {
    companybloc.getCompanys();
    return Center(child: CircularProgressIndicator());
  }

  Widget buildContent(BuildContext context, List<Company> companys) {
    return ListView.builder(
      itemCount: companys.length,
      itemBuilder: (context, ind) {
        Company cmp = companys[ind];
        return Padding(
          padding: EdgeInsets.fromLTRB(5, 2.5, 5, 2.5),
          child: GestureDetector(
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[200], width: 0.5),
                  borderRadius: BorderRadius.circular(5),
                ),
                color: Colors.white,
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(cmp.name,
                                style: TextStyle(
                                    color: Colors.indigoAccent,
                                    fontSize: 16.5,
                                    fontFamily: 'RobotoMono',
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          radius: 18,
                          child: IconButton(
                            icon: Center(
                              child: Icon(
                                Icons.clear,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              deleteCompany(cmp);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => setState(() {
                    showeditSheet(context, cmp);
                  })),
        );
      },
    );
  }

  GlobalKey<FormState> formkey = new GlobalKey();
  TextEditingController companyname = new TextEditingController();
  void showAddSheet(BuildContext context) {
    companyname.text = "";
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 15),
                    child: TextFormField(
                      controller: companyname,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: AsiaCell',
                          labelText: 'New Company',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.w500)),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Empty cadNumber!';
                        } else if (value.length < 3 || value.length > 50) {
                          return "Enter betweem 3 to 50 character Only";
                        } else
                          return null;
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            radius: 18,
                            child: IconButton(
                              icon: Icon(
                                Icons.save,
                                size: 22,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (formkey.currentState.validate()) {
                                  companybloc.addCompany(
                                      Company(name: companyname.text));
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  void showeditSheet(BuildContext context, Company cmp) {
    formkey = new GlobalKey();
    companyname.text = cmp.name;
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Form(
              key: formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 15),
                    child: TextFormField(
                      controller: companyname,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: AsiaCell',
                          labelText: 'New Company',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.w500)),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Empty cadNumber!';
                        } else if (value.length < 3 || value.length > 50) {
                          return "Enter betweem 3 to 50 character Only";
                        } else
                          return null;
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            radius: 18,
                            child: IconButton(
                              icon: Icon(
                                Icons.save,
                                size: 22,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (formkey.currentState.validate()) {
                                  cmp.name = companyname.text;
                                  companybloc.updateCompany(cmp);
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        });
  }

  void deleteCompany(Company cmp) async {
    companybloc.deleteCompanyById(cmp.id);
  }

  Widget noCompanyFound() {
    return Text("add Company First.");
  }
}
