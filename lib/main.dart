import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trymethods/ui/CardsListWidget.dart';
import 'package:trymethods/ui/CompanyWidget.dart';
import 'package:trymethods/ui/ContractsWidget.dart';
import 'package:trymethods/ui/EditUserInfo.dart';
import 'package:trymethods/ui/HomePage.dart';
import 'package:trymethods/ui/LogWidget.dart';
import 'package:trymethods/ui/TypesWidget.dart';
import 'package:trymethods/ui/UserListPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.indigoAccent,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark));
    return MaterialApp(
      initialRoute: HomePage.route,
      routes: {
        HomePage.route: (_) => HomePage(),
        ContractsWidget.route: (context) => ContractsWidget(
            arguments: ModalRoute.of(context).settings.arguments),
        UserListPage.route: (_) => UserListPage(),
        EditUserInfo.route: (context) =>
            EditUserInfo(user: ModalRoute.of(context).settings.arguments),
        CardsListWidget.route: (context) => CardsListWidget(
            printWidget: ModalRoute.of(context).settings.arguments),
        TypesWidget.route: (context) => TypesWidget(),
        CompanyWidget.route: (context) => CompanyWidget(),
        LogWidget.route: (context) => LogWidget()
        //EditUserInfo.route: (_) => EditUserInfo(),
        //'/contract': (context) => ContractsWidget(),
      },
      title: 'Reactive Flutter',
      theme: ThemeData(primarySwatch: Colors.indigo, canvasColor: Colors.white),
      //Our only screen/page we have
      //home: HomePage(),
    );
  }
}
