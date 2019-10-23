import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:sms/sms.dart';
import 'package:trymethods/model/ContactParameter.dart';

class ContractsWidget extends StatefulWidget {
  static const route = '/contract';
  final ContactParameter arguments;
  // final int typeId;
  // final CreditCardBloc creditcardBloc;
  // final void Function() refreshUi;
  // ContractsWidget({Key key, this.typeId, this.creditcardBloc, this.refreshUi})
  //     : super(key: key);
  ContractsWidget({Key key, this.arguments}) : super(key: key);
  @override
  _ContractsWidgetState createState() => _ContractsWidgetState();
}

class _ContractsWidgetState extends State<ContractsWidget> {
  final searchContact = TextEditingController();
  @override
  void initState() {
    contacts = ContactsService.getContacts(query: "<>");
    searchContact.addListener(searchContactcontent);
    super.initState();
  }

  @override
  void dispose() {
    searchContact.dispose();
    super.dispose();
  }

  Future<Iterable<Contact>> contacts;
  String prevcon;
  searchContactcontent() {
    setState(() {
      if (prevcon != searchContact.text) {
        prevcon = searchContact.text;
        if (prevcon == "") {
          contacts = ContactsService.getContacts(query: "<>");
        } else {
          contacts = ContactsService.getContacts(query: prevcon);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جهات الأتصال"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          textFieldSearch(),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                      builder:
                          (context, AsyncSnapshot<Iterable<Contact>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            return loadingData();
                          case ConnectionState.active:
                            return loadingData();
                          case ConnectionState.done:
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }
                            if (snapshot.hasData) {
                              return buildContacts(snapshot);
                            } else
                              return loadingData();
                        }
                        return null;
                      },
                      future: contacts),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContacts(AsyncSnapshot<Iterable<Contact>> value) {
    List<Contact> contlist = value.data.toList();
    contlist = contlist.where((c) => c.phones.toList().length != 0).toList();
    if (contlist.length == 0) return noContacts();
    return SafeArea(
        bottom: true,
        child: Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: ListView.builder(
              itemCount: contlist == null ? 0 : contlist.length,
              itemBuilder: (context, item) {
                Contact ct = contlist[item];
                if (ct != null && ct.phones.length != 0)
                  return InkWell(
                    child: Card(
                      color: Colors.grey[100],
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          height: 50,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(ct.displayName,
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(ct.phones.toList()[0].value,
                                      style: TextStyle(
                                          fontSize: 19,
                                          letterSpacing: 4,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.indigoAccent)),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Contact ct = contlist[item];
                      SmsSender sender = new SmsSender();
                      String address = ct.phones.toList()[0].value;
                      String sms =
                          'تفضل رقم البطاقه : ' + widget.arguments.cardNumber;
                      var message = new SmsMessage(address, sms);
                      message.onStateChanged.listen((state) {
                        if (state == SmsMessageState.Sent) {
                          List<String> args = [
                            ct.displayName,
                            address,
                            widget.arguments.cardId.toString(),
                            sms
                          ];

                          Navigator.pop(context, args);
                        } else if (state == SmsMessageState.Fail)
                          Navigator.pop(context, "error");
                      });
                      sender.sendSms(message);
                    },
                  );
                else
                  return null;
              },
            )));
  }

  Widget textFieldSearch() {
    return Container(
        padding: EdgeInsets.all(10),
        height: 90,
        width: MediaQuery.of(context).size.width,
        color: Colors.indigoAccent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Card(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: TextField(
                  controller: searchContact,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 15, bottom: 11, top: 11, right: 15),
                      labelText: "Enter Contact Name",
                      hintText: "eg :- Ali muhammed"),
                ),
              )),
            )
          ],
        ));
  }

  Widget loadingData() {
    return Container(
        width: 100,
        height: 100,
        child: Center(child: CircularProgressIndicator()));
  }

  Widget noContacts() {
    return Container(
      child: Center(
        child: Text(
          "No contacts search about others...",
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
