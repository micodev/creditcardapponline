import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:trymethods/bloc/TypeCompanyBloc.dart';
import 'package:trymethods/databaseaccess/CompanyAccess.dart';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/Company.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/ui/comp/DropDownCompany.dart';

class TypesWidget extends StatefulWidget {
  static final route = "/types";
  TypesWidget({Key key}) : super(key: key);

  _TypesWidgetState createState() => _TypesWidgetState();
}

class _TypesWidgetState extends State<TypesWidget> {
  final TypeCompanyBloc typebloc = TypeCompanyBloc();
  int noCompany;
  bool isloading = true;
  @override
  void initState() {
    super.initState();
    isthereCompany().then((val) {
      noCompany = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("فئات البطاقات"),
        ),
        body: isloading
            ? Center(
                child: Text("LOADING"),
              )
            : getTypes(context),
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

  Widget getTypes(BuildContext context) {
    return StreamBuilder(
      stream: typebloc.types,
      initialData: new List<TypeAndCompany>(),
      builder:
          (BuildContext context, AsyncSnapshot<List<TypeAndCompany>> snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loadingData();
          case ConnectionState.waiting:
            typebloc.getCardTypes();
            return loadingData();
          case ConnectionState.active:
            return buildWidget(context, snapshot);
          case ConnectionState.done:
            return buildWidget(context, snapshot);
        }
        return null;
      },
    );
  }

  Widget buildWidget(
      BuildContext context, AsyncSnapshot<List<TypeAndCompany>> snapshot) {
    if (snapshot.hasData) {
      return snapshot.data.length != 0
          ? buildContent(context, snapshot.data)
          : Center(child: noCompanyFound());
    } else
      return loadingData();
  }

  Widget loadingData() {
    return Center(child: CircularProgressIndicator());
  }

  Widget buildContent(BuildContext context, List<TypeAndCompany> types) {
    return ListView.builder(
      itemCount: types.length,
      itemBuilder: (context, ind) {
        Company company = types[ind].cm;
        CardType tp = types[ind].ct;
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
                            Text(
                              company.name,
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 16.5,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              tp.brandPrice
                                  .toString()
                                  .replaceFirst(".0", " IQD"),
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 16.5,
                                fontFamily: 'RobotoMono',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          radius: 18,
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              deleteType(tp);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onTap: () => setState(() {
                    showeditSheet(context, tp);
                  })),
        );
      },
    );
  }

  GlobalKey<FormState> formkey = new GlobalKey();
  TextEditingController brandprice = new TextEditingController();
  TextEditingController price = new TextEditingController();
  Company cmp;
  void showAddSheet(BuildContext context) {
    cmp = null;
    price.text = "";
    brandprice.text = "";
    if (noCompany == 0)
      Flushbar(
        title: 'Error',
        message: 'add Company first',
        icon: Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.redAccent,
        ),
        leftBarIndicatorColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ).show(context);
    else {
      cmp = null;
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
                        child: new DropDownCompany(
                          initialValue: cmp,
                          onValueChange: onCompantSelectChange,
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 5, bottom: 15),
                      child: TextFormField(
                        controller: brandprice,
                        textInputAction: TextInputAction.newline,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w400),
                        autofocus: true,
                        decoration: const InputDecoration(
                            hintText: 'eg: 5000',
                            labelText: 'Insert brand Price',
                            labelStyle: TextStyle(
                                color: Colors.indigoAccent,
                                fontWeight: FontWeight.w500)),
                        validator: (String value) {
                          Pattern pattern = "^[0-9]+\$";
                          RegExp regex = new RegExp(pattern);
                          if (value.isEmpty) {
                            return 'Empty cadNumber!';
                          } else if (value.length < 3 || value.length > 50) {
                            return "Enter betweem 3 to 50 character Only";
                          } else if (!regex.hasMatch(value))
                            return "Enter Numbers Only";
                          else
                            return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 5, bottom: 15),
                      child: TextFormField(
                        controller: price,
                        textInputAction: TextInputAction.newline,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w400),
                        autofocus: true,
                        decoration: const InputDecoration(
                            hintText: 'eg: 5000',
                            labelText: 'Insert Price',
                            labelStyle: TextStyle(
                                color: Colors.indigoAccent,
                                fontWeight: FontWeight.w500)),
                        validator: (String value) {
                          Pattern pattern = "^[0-9]+\$";
                          RegExp regex = new RegExp(pattern);
                          if (value.isEmpty) {
                            return 'Empty cadNumber!';
                          } else if (value.length < 3 || value.length > 50) {
                            return "Enter betweem 3 to 50 character Only";
                          } else if (!regex.hasMatch(value))
                            return "Enter Numbers Only";
                          else
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
                                    Navigator.of(context).pop();
                                    if (cmp != null) {
                                      typebloc.addCardType(CardType(
                                          price: double.parse(price.text),
                                          brandPrice:
                                              double.parse(brandprice.text),
                                          companyId: cmp.id));
                                    } else {
                                      Flushbar(
                                        title: 'Error',
                                        message: 'Select Company first',
                                        icon: Icon(
                                          Icons.info_outline,
                                          size: 28,
                                          color: Colors.redAccent,
                                        ),
                                        leftBarIndicatorColor: Colors.redAccent,
                                        duration: Duration(seconds: 2),
                                      ).show(context);
                                    }
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
  }

  void showeditSheet(BuildContext context, CardType tp) {
    cmp = null;
    formkey = new GlobalKey();
    price.text = tp.price.toString().replaceFirst(".0", "");
    brandprice.text = tp.brandPrice.toString().replaceFirst(".0", "");
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
                      child: new DropDownCompany(
                        initialValue: cmp,
                        onValueChange: onCompantSelectChange,
                      )),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 15),
                    child: TextFormField(
                      controller: brandprice,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: 5000',
                          labelText: 'Insert brand Price',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.w500)),
                      validator: (String value) {
                        Pattern pattern = "^[0-9]+\$";
                        RegExp regex = new RegExp(pattern);
                        if (value.isEmpty) {
                          return 'Empty cadNumber!';
                        } else if (value.length < 3 || value.length > 50) {
                          return "Enter betweem 3 to 50 character Only";
                        } else if (!regex.hasMatch(value))
                          return "Enter Numbers Only";
                        else
                          return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 15),
                    child: TextFormField(
                      controller: price,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: 5000',
                          labelText: 'Insert Price',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.w500)),
                      validator: (String value) {
                        Pattern pattern = "^[0-9]+\$";
                        RegExp regex = new RegExp(pattern);
                        if (value.isEmpty) {
                          return 'Empty cadNumber!';
                        } else if (value.length < 3 || value.length > 50) {
                          return "Enter betweem 3 to 50 character Only";
                        } else if (!regex.hasMatch(value))
                          return "Enter Numbers Only";
                        else
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
                                  Navigator.of(context).pop();
                                  if (tp.companyId > 0 &&
                                          tp.companyId != null ||
                                      cmp != null) {
                                    if (cmp != null) tp.companyId = cmp.id;
                                    tp.price = double.parse(price.text);
                                    tp.brandPrice =
                                        double.parse(brandprice.text);
                                    typebloc.updateCardType(tp);
                                  } else {
                                    Flushbar(
                                      title: 'Error',
                                      message: 'Select Company first',
                                      icon: Icon(
                                        Icons.info_outline,
                                        size: 28,
                                        color: Colors.redAccent,
                                      ),
                                      leftBarIndicatorColor: Colors.redAccent,
                                      duration: Duration(seconds: 2),
                                    ).show(context);
                                  }
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

  void deleteType(CardType tp) async {
    typebloc.deleteCardTypeById(tp.id);
  }

  Widget noCompanyFound() {
    return Text("add Type First.");
  }

  void onCompantSelectChange(Company cmpv) {
    setState(() {
      cmp = cmpv;
    });
  }

  Future<int> isthereCompany() async {
    CompanyAccess ca = new CompanyAccess();
    int no = (await ca.getCompanys()).length;

    setState(() {
      isloading = false;
    });
    return no;
  }
}
