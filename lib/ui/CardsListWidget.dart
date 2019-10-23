import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:trymethods/bloc/CardsByTypeBloc.dart';
import 'package:trymethods/bloc/CreditCardBloc.dart';
import 'package:trymethods/bloc/LogBloc.dart';
import 'package:trymethods/bloc/TypeBloc.dart';
import 'package:http/http.dart' as http;
import 'package:trymethods/bloc/UsersBloc.dart';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/ContactParameter.dart';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/model/Log.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/model/User.dart';
import 'package:trymethods/ui/ContractsWidget.dart';

class CardsListWidget extends StatefulWidget {
  static final String route = "/cardslist";
  final PrintWidget printWidget;
  CardsListWidget({Key key, this.printWidget}) : super(key: key);
  _CardsListWidgetState createState() => _CardsListWidgetState();
}

class _CardsListWidgetState extends State<CardsListWidget> {
  PrintWidget printWidget;
  CardsByTypeBloc cardbloc;
  @override
  void initState() {
    super.initState();
    printWidget = widget.printWidget;
    cardbloc = CardsByTypeBloc(printWidget.typeId);
    cardbloc.getCreditCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("أرقام الكارتات"),
      ),
      body: Container(
          child: StreamBuilder(
        stream: cardbloc.cards,
        builder: (context, AsyncSnapshot<List<CreditCard>> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  cardbloc.getCreditCards();
                  return Center(child: CircularProgressIndicator());
                }
                var cards = snapshot.data;
                return buildListView(cards);
              } else {
                cardbloc.getCreditCards();
                return Center(child: CircularProgressIndicator());
              }
              break;
            case ConnectionState.done:
              return Text('\$d${snapshot.data} (closed)');
          }
          return null; // unreachable
        },
      )),
    );
  }

  Widget buildListView(List<CreditCard> cards) {
    return ListView.builder(
      itemCount: cards == null ? 0 : cards.length,
      itemBuilder: (context, ind) {
        var card = cards[ind];
        return Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
            child: Slidable(
              child: InkWell(
                  child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey[200], width: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.white,
                      child: ListTile(
                          title: Center(
                        child: Text(
                          "${card.cardNumber}",
                          style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 16.5,
                            fontFamily: 'RobotoMono',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))),
                  onTap: () => setState(() {
                        makeEditSheet(card);
                      })),
              actionPane: SlidableDrawerActionPane(),
              actions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.redAccent,
                  icon: Icons.delete,
                  onTap: () {
                    cardbloc.deleteCardById(card.id).whenComplete(() {
                      if (cards.length == 1) {
                        Navigator.pop(context, true);
                      }
                    });
                  },
                ),
                IconSlideAction(
                  caption: 'Send',
                  color: Colors.green,
                  icon: Icons.send,
                  onTap: () {
                    navigate(card).then((onValue) {
                      if (onValue == null) {
                        return;
                      }
                      String result = "";
                      if (onValue)
                        result = "Card has been sent.";
                      else
                        result = "Error happened";

                      if (cards.length == 1 ||
                          result == "Card has been sent.") {
                        Navigator.pop(context, "sent");
                      }
                    });
                  },
                ),
              ],
            ));
      },
    );
  }

  List<User> users = new List();
  bool isloading = true;
  List<CardType> types = new List();
  final TypeBloc typebloc = TypeBloc();
  final UsersBloc userBloc = UsersBloc();
  final LogBloc logBloc = LogBloc();
  final CreditCardBloc creditcardBloc = CreditCardBloc();
  Future navigate(CreditCard card) async {
    users = await userBloc.getUsersAsync();
    types = await typebloc.getCardTypesAsync();

    var type = types.where((i) => i.id == card.typeId).first;
    var parms = ContactParameter(
        creditcardBloc: creditcardBloc,
        cardNumber: card.cardNumber,
        cardId: card.id);
    final result = await Navigator.pushNamed(context, ContractsWidget.route,
        arguments: parms);
    if (result != null && result.toString() != "error") {
      List<String> args = result;
      if (args == null || args.length == 0) {
        return false;
      }
      double balance = type.price;
      if (users.where((i) => i.number == args[1]).length == 0)
        await userBloc
            .addUser(User(name: args[0], number: args[1], balance: balance));
      else {
        User user = users.where((i) => i.number == args[1]).first;
        user.balance = user.balance + balance;
        await userBloc.updateUser(user);
      }
      var now = new DateTime.now();
      User user = await userBloc.getUser(args[1]);

      await logBloc.addLog(Log(
          userId: user.id,
          amount: balance,
          label: "دين",
          date: now.millisecondsSinceEpoch));
      await creditcardBloc.deleteCardById(int.parse(args[2]));
      await cardbloc.getCreditCards();
      if (user.username != null)
        await fetchPost(user.username.replaceFirst("@", ""), args[3]);
      return true;
    }
  }

  Future fetchPost(String username, String text) async {
    try {
      var response = await http.get(
          'https://api.telegram.org/bot884953090:AAFqr3gveF8L-R9uaajKp0NxStcSDTDkqn0/'
                  'sendMessage?chat_id=' +
              username +
              "&message=" +
              text.replaceAll(" ", "%20"));
      response.body;
    } catch (e) {
      e.toString();
    }
  }

  final formKey = GlobalKey<FormState>();
  TextEditingController cardNumber = TextEditingController();
  void makeEditSheet(CreditCard card) {
    setState(() {
      cardNumber.text = card.cardNumber;
    });
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Form(
              key: formKey,
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
                      controller: cardNumber,
                      textInputAction: TextInputAction.newline,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                      autofocus: true,
                      decoration: const InputDecoration(
                          hintText: 'eg: 101010293901',
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
                                if (formKey.currentState.validate()) {
                                  card.cardNumber = cardNumber.text;
                                  cardbloc.updateCard(card);
                                } else {
                                  Flushbar(
                                    title: 'Validate Error',
                                    message: 'check the fields',
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 28,
                                      color: Colors.indigoAccent,
                                    ),
                                    leftBarIndicatorColor: Colors.indigoAccent,
                                    duration: Duration(seconds: 3),
                                  ).show(context);
                                }
                                Navigator.of(context).pop();
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
}
