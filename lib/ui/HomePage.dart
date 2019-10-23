import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trymethods/bloc/CardAvails.dart';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/model/User.dart';
import 'package:trymethods/ui/CardsListWidget.dart';
import 'package:trymethods/ui/CompanyWidget.dart';
import 'package:trymethods/ui/LogWidget.dart';
import 'package:trymethods/ui/TypesWidget.dart';
import 'package:trymethods/ui/UserListPage.dart';
import 'package:trymethods/ui/comp/DropDownTypes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  static const String route = '/';

  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  static bool noCard = true;

  final int cardCount = 0;
  final CardAvails cardsAvail = CardAvails();
  TypesList dropDownSelected;
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();
  bool isloading = true;
  List<CardType> types = new List();
  List<User> users = new List();

  @override
  void initState() {
    super.initState();
  }

  Widget getCardsWidget() {
    /*The StreamBuilder widget,
    basically this widget will take stream of data (cards)
    and construct the UI (with state) based on the stream
    */
    return StreamBuilder(
      stream: cardsAvail.cardAvail,
      builder:
          (BuildContext context, AsyncSnapshot<List<PrintWidget>> snapshot) {
        return getCardWidget(snapshot);
      },
    );
  }

  Widget getCardWidget(AsyncSnapshot<List<PrintWidget>> snapshot) {
    /*Since most of our operations are asynchronous
    at initial state of the operation there will be no stream
    so we need to handle it if this was the case
    by showing users a processing/loading indicator*/

    if (snapshot.hasData) {
      /*Also handles whenever there's stream
      but returned returned 0 records of Todo from DB.
      If that the case show user that you have empty Todos
      */
      if (snapshot.data.length != 0) {
        noCard = false;
      } else
        noCard = true;
      return snapshot.data.length != 0
          ? ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, itemPosition) {
                PrintWidget card = snapshot.data[itemPosition];
                final Widget clickableItem = InkWell(
                  child: Container(
                      child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.grey[200], width: 0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: Colors.white,
                              child: ListTile(
                                  title: Center(
                                child: Text(
                                  "${card.print.replaceFirst(".0", " IQD")}   ${card.count}",
                                  style: TextStyle(
                                    color: Colors.indigoAccent,
                                    fontSize: 16.5,
                                    fontFamily: 'RobotoMono',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))))),
                  onTap: () {
                    if (card.count > 0) {
                      navigate(card);
                    } else {
                      final snackBar = SnackBar(
                        content: Text('No cards Found'),
                        duration: Duration(milliseconds: 500),
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    }
                  },
                );
                return clickableItem;
              },
            )
          : Container(
              child: Center(
              //this is used whenever there 0 Todo
              //in the data base
              child: noCardMessageWidget(),
            ));
    } else {
      return Center(
        /*since most of our I/O operations are done
                              outside the main thread asynchronously
                              we may want to display a loading indicator
                              to let the use know the app is currently
                              processing*/
        child: loadingData(),
      );
    }
  }

  Widget loadingData() {
    cardsAvail.getAvailableCards();
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text("Loading...",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget noCardMessageWidget() {
    return Container(
      child: Text(
        "Start adding card...",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
      ),
    );
  }

  void showAddCardSheet(BuildContext context) {
    TypesList dropdownselect;
    final cardNumberFormController = TextEditingController();

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
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
                      controller: cardNumberFormController,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: 1010102930912',
                          labelText: 'New Card',
                          labelStyle: TextStyle(
                              color: Colors.indigoAccent,
                              fontWeight: FontWeight.w500)),
                      validator: (String value) {
                        Pattern pattern = "^[0-9]+\$";
                        RegExp regex = new RegExp(pattern);
                        if (value.isEmpty) {
                          return 'Empty cadNumber!';
                        } else if (value.length < 13 || value.length > 13) {
                          return "Enter 13 Number Only";
                        } else if (!regex.hasMatch(value))
                          return "Enter Numbers Only";
                        else
                          return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 5, bottom: 15),
                    child: DropDownTypes(
                        initialValue: dropdownselect,
                        onValueChange: onValueChange),
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
                                if (formkey.currentState.validate() &&
                                    (dropDownSelected != null &&
                                        dropDownSelected.typeId != null)) {
                                  CreditCard card = CreditCard(
                                      cardNumber: cardNumberFormController.text,
                                      typeId: dropDownSelected.typeId);
                                  cardsAvail.addCard(card);
                                  dropDownSelected = null;
                                  Navigator.of(context).pop();
                                } else {
                                  if (dropDownSelected == null) {
                                    Navigator.of(context).pop();
                                    Flushbar(
                                      title: 'Validate Error',
                                      message: 'select type first',
                                      icon: Icon(
                                        Icons.info_outline,
                                        size: 28,
                                        color: Colors.indigoAccent,
                                      ),
                                      leftBarIndicatorColor:
                                          Colors.indigoAccent,
                                      duration: Duration(seconds: 3),
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
            )));
  }

  void onValueChange(TypesList value) {
    setState(() {
      dropDownSelected = value;
    });
  }

  Future navigate(PrintWidget card) async {
    final res = await Navigator.of(context)
        .pushNamed(CardsListWidget.route, arguments: card);
    cardsAvail.getAvailableCards();
    if (res == null) {
      return;
    }
    if (res == "sent") {
      Flushbar(
        title: "Info Message",
        message: "Card Sent",
        icon: Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.indigoAccent,
        ),
        leftBarIndicatorColor: Colors.indigoAccent,
        duration: Duration(seconds: 2),
      ).show(context);
    }
    cardsAvail.getAvailableCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("الرئيسية"),
        ),
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
            child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 2.0, right: 2.0, bottom: 2.0, top: 2.0),
                child: Container(
                    //This is where the magic starts
                    child: getCardsWidget()))),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
                border: Border(
              top: BorderSide(color: Colors.grey, width: 0.3),
            )),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Wrap(children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.people,
                      size: 28,
                      color: Colors.indigoAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(UserListPage.route);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_view_day,
                      size: 28,
                      color: Colors.indigoAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(TypesWidget.route)
                          .whenComplete(() {
                        cardsAvail.getAvailableCards();
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.insert_chart,
                      size: 28,
                      color: Colors.indigoAccent,
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(CompanyWidget.route)
                          .whenComplete(() {
                        cardsAvail.getAvailableCards();
                      });
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                  )
                ]),
                Expanded(
                  child: Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.listAlt,
                          size: 28,
                          color: Colors.indigoAccent,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(LogWidget.route);
                        },
                      ),
                    ],
                  )),
                )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 25),
          child: FloatingActionButton(
            elevation: 5.0,
            onPressed: () {
              if (!noCard) {
                showAddCardSheet(context);
              } else {
                Flushbar(
                  title: 'Error',
                  message: 'add Company or Types first',
                  icon: Icon(
                    Icons.info_outline,
                    size: 28,
                    color: Colors.redAccent,
                  ),
                  leftBarIndicatorColor: Colors.redAccent,
                  duration: Duration(seconds: 2),
                ).show(context);
              }
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
}
