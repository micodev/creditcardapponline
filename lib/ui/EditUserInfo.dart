import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:trymethods/bloc/LogBloc.dart';
import 'package:trymethods/bloc/UsersBloc.dart';
import 'package:trymethods/model/Log.dart';
import 'package:trymethods/model/User.dart';

class EditUserInfo extends StatefulWidget {
  static final route = "/Users/edit";
  final User user;
  EditUserInfo({Key key, this.user}) : super(key: key);

  _EditUserInfoState createState() => _EditUserInfoState();
}

class _EditUserInfoState extends State<EditUserInfo> {
  User user;
  final LogBloc logBloc = LogBloc();
  final UsersBloc userBloc = UsersBloc();
  TextEditingController name = TextEditingController();
  TextEditingController paidAmount = TextEditingController();
  TextEditingController username = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    user = widget.user;
    name.text = widget.user.name;
    username.text = widget.user.username == null ? "" : widget.user.username;
    paidAmount.text = "0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تعديل بيانات المستخدم"),
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          height: MediaQuery.of(context).size.height,
          child: SafeArea(
            child: Form(
                key: formKey,
                child: ListView(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person),
                              hintText: 'Insert name here',
                              labelText: 'Name',
                            ),
                            onSaved: (String value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String value) {
                              if (value.length == 0)
                                return "Name should have value";
                              if (value.contains('@'))
                                return 'Do not use the @ char.';
                              return null;
                            },
                            maxLength: 100,
                            controller: name,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.person_add),
                              hintText: 'eg : @anime19',
                              labelText: 'Username',
                            ),
                            onSaved: (String value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String value) {
                              Pattern pattern = "^@[A-Za-z0-9_]+\$";
                              RegExp regex = new RegExp(pattern);
                              if (value.length == 0) {
                                return null;
                              }
                              if (!regex.hasMatch(value))
                                return "Enter valid username Only";
                              else if (!value.contains('@'))
                                return 'use the @ char.';
                              return null;
                            },
                            maxLength: 100,
                            controller: username,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.money_off),
                              hintText: 'Insert amount here',
                              labelText: 'money',
                            ),
                            onSaved: (String value) {
                              // This optional block of code can be used to run
                              // code when the user saves the form.
                            },
                            validator: (String value) {
                              Pattern pattern = "^[0-9]+\$";
                              RegExp regex = new RegExp(pattern);
                              if (value == "0") {
                                return null;
                              }
                              if (value.length == 0)
                                return "Amount should have value";
                              else if (!regex.hasMatch(value))
                                return "Enter Numbers Only";
                              else if (user.balance < double.parse(value))
                                return "value should be less than balance";
                              else if (value == "0")
                                return "please add more than 0 money";
                              return null;
                            },
                            maxLength: 7,
                            controller: paidAmount,
                          ),
                        )
                      ],
                    )
                  ],
                )),
          )),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: FloatingActionButton(
          elevation: 5.0,
          onPressed: () {
            if (formKey.currentState.validate()) {
              user.name = name.text;
              user.username = username.text == null ? "" : username.text;
              user.balance = user.balance - double.parse(paidAmount.text);
              var now = new DateTime.now();
              if (paidAmount.text != "0") {
                logBloc.addLog(Log(
                    userId: user.id,
                    amount: double.parse(paidAmount.text),
                    label: "دفع",
                    date: now.millisecondsSinceEpoch));
              }
              userBloc.updateUser(user);
              Navigator.of(context).pop();
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
          },
          backgroundColor: Colors.grey[50],
          child: Icon(
            Icons.check,
            size: 32,
            color: Colors.indigoAccent,
          ),
        ),
      ),
    );
  }
}
