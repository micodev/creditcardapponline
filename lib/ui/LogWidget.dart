import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trymethods/bloc/LogBloc.dart';
import 'package:trymethods/bloc/UsersBloc.dart';
import 'package:trymethods/model/Log.dart';
import 'package:trymethods/model/User.dart';
import 'package:fab_menu/fab_menu.dart';

class LogWidget extends StatefulWidget {
  static final String route = "/Log";
  LogWidget({Key key}) : super(key: key);

  _LogWidgetState createState() => _LogWidgetState();
}

class _LogWidgetState extends State<LogWidget> {
  LogBloc logBloc = LogBloc();
  UsersBloc usersBloc = UsersBloc();
  List<User> users = new List();
  bool loading = true;
  bool deleteloading = false;
  int _radioValue1 = 0;

  List<MenuData> menuDatas;
  @override
  void initState() {
    menuDatas = [
      MenuData(Icons.delete, deleteDependDate, labelText: 'حذف حسب التاريخ'),
      MenuData(Icons.delete_forever, deleteAll, labelText: 'حذف الكل')
    ];
    usersBloc.getUsersAsync().then((val) {
      users = val;
    }).whenComplete(() {
      setState(() {
        // logBloc.getLogsByDateAsync(Duration(hours: -1)).whenComplete(() {});
        loading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      appBar: AppBar(
        title: Text("السجل"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            buildLogDate(),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[logView()],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: new FabMenu(
        mainIcon: FontAwesomeIcons.trash,
        maskOpacity: 0,
        mainButtonBackgroundColor: Colors.indigo[300],
        menus: menuDatas,
        maskColor: Colors.black,
      ),
      floatingActionButtonLocation: fabMenuLocation,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red[300],
      //   elevation: 5,
      //   hoverColor: Colors.red,
      //   onPressed: () {},
      //   child: Center(
      //     child: Icon(FontAwesomeIcons.trash),
      //   ),
      // ),
    ));
  }

  void logbydate(int val) {
    switch (val) {
      case 0:
        return logBloc.getLogs(Duration(days: -1));
        break;
      case 1:
        return logBloc.getLogs(Duration(days: -91));
        break;
      case 2:
        return logBloc.getLogs(Duration(days: -365));
        break;
    }
  }

  void onChange(int val) {
    setState(() {
      logbydate(val);

      _radioValue1 = val;
    });
  }

  Widget buildLogDate() {
    return Container(
      height: 90,
      color: Colors.indigoAccent,
      child: Center(
        child: Wrap(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5.0),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    'أختر من الأوقات  أدناه ',
                    style: new TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Radio(
                      activeColor: Colors.white,
                      value: 0,
                      groupValue: _radioValue1,
                      onChanged: onChange,
                    ),
                    new Text(
                      'اليوم',
                      style: new TextStyle(
                          fontSize: 16.0,
                          color:
                              _radioValue1 == 0 ? Colors.white : Colors.black),
                    ),
                    new Radio(
                      activeColor: Colors.white,
                      value: 1,
                      groupValue: _radioValue1,
                      onChanged: onChange,
                    ),
                    new Text(
                      'أشهر 3',
                      style: new TextStyle(
                        color: _radioValue1 == 1 ? Colors.white : Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    new Radio(
                      activeColor: Colors.white,
                      value: 2,
                      groupValue: _radioValue1,
                      onChanged: onChange,
                    ),
                    new Text(
                      'سنه',
                      style: new TextStyle(
                          color:
                              _radioValue1 == 2 ? Colors.white : Colors.black,
                          fontSize: 16.0),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget logView() {
    return loading
        ? loadingData()
        : StreamBuilder(
            stream: logBloc.logs,
            builder: (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
              if (snapshot.hasError) return Text('Error: ${snapshot.error}');
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return loadingData();
                case ConnectionState.waiting:
                  logbydate(_radioValue1);
                  return loadingData();
                case ConnectionState.active:
                  return buildLogView(context, snapshot.data);
                case ConnectionState.done:
                  return buildLogView(context, snapshot.data);
              }
              return null; // unreachable
            },
          );
  }

  Widget loadingData() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget buildLogView(BuildContext context, List<Log> logs) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: logs.length == 0
            ? noLogs(context)
            : ListView.separated(
                itemCount: logs.length,
                itemBuilder: (context, ind) {
                  Log log = logs[ind];
                  User user = users.where((i) => i.id == log.userId).first;
                  bool dep = log.label == "دين";
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => setState(() {
                        onLogTap(context, log, user);
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            color: dep ? Colors.deepOrange : Colors.greenAccent,
                            child: Center(
                                child: Text(
                              log.label,
                              style: TextStyle(
                                  color: !dep ? Colors.black : Colors.white),
                            )),
                          ),
                          Expanded(
                            child: Container(
                                child: Center(
                                    child: Text(log.amount
                                        .toString()
                                        .replaceFirst(".0", " IQD"))),
                                height: 50,
                                color: Colors.white60),
                          ),
                          Container(
                              child: Center(child: Text(user.name)),
                              width: 200,
                              height: 50,
                              color: Colors.grey[50]),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (cont, ind) {
                  return Container(
                    height: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          color: Colors.black45,
                        )
                      ],
                    ),
                    color: Colors.white,
                  );
                }));
  }

  deleteDependDate(BuildContext context, MenuData menuData) {
    setState(() {
      loading = true;
    });
    Duration dur = new Duration();
    switch (_radioValue1) {
      case 0:
        dur = new Duration(days: -1);
        break;
      case 1:
        dur = new Duration(days: -91);
        break;
      case 2:
        dur = new Duration(days: -365);
        break;
    }
    logBloc.deleteAllLogsByDate(dur).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  deleteAll(BuildContext context, MenuData menuData) {
    setState(() {
      loading = true;
    });
    logBloc.deleteAllLogs().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  Widget noLogs(BuildContext context) {
    return Center(
      child: Text(
        "لا يوجد سجلات",
        style: TextStyle(color: Colors.indigoAccent, fontSize: 25),
      ),
    );
  }

  String flushTitle;
  String flushMessage;
  static Flushbar flush;
  void onLogTap(BuildContext context, Log log, User user) {
    setState(() {
      flushTitle = "${user.name} : ${user.number}";
      flushMessage = "${log.toDate()}";
    });

    if (flush != null) {
      if (flush.isShowing() == false) {
        flush = Flushbar(
          title: flushTitle,
          mainButton: FlatButton(
            child: CircleAvatar(
              radius: 15,
              child: Icon(
                Icons.close,
                size: 10,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          message: flushMessage,
          icon: Icon(
            Icons.info_outline,
            size: 28,
            color: Colors.indigoAccent,
          ),
          leftBarIndicatorColor: Colors.indigoAccent,
          //duration: Duration(seconds: 2),
        );
        flush.show(context);
      } else {
        flush.dismiss(context);
        flush = Flushbar(
          title: flushTitle,
          mainButton: FlatButton(
            child: CircleAvatar(
              radius: 15,
              child: Icon(
                Icons.close,
                size: 10,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          message: flushMessage,
          icon: Icon(
            Icons.info_outline,
            size: 28,
            color: Colors.indigoAccent,
          ),
          leftBarIndicatorColor: Colors.indigoAccent,
          //duration: Duration(seconds: 2),
        );
        flush.show(context);
      }
    } else {
      flush = Flushbar(
        title: flushTitle,
        mainButton: FlatButton(
          child: CircleAvatar(
            radius: 15,
            child: Icon(
              Icons.close,
              size: 10,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        message: flushMessage,
        icon: Icon(
          Icons.info_outline,
          size: 28,
          color: Colors.indigoAccent,
        ),
        leftBarIndicatorColor: Colors.indigoAccent,
        //duration: Duration(seconds: 2),
      );
      flush.show(context);
    }
  }
}
