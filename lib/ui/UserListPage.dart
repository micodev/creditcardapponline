import 'package:flutter/material.dart';
import 'package:trymethods/bloc/UsersBloc.dart';
import 'package:trymethods/model/User.dart';
import 'package:trymethods/ui/EditUserInfo.dart';

class UserListPage extends StatefulWidget {
  static final String route = "/Users";
  UserListPage({Key key}) : super(key: key);

  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final UsersBloc usersBloc = UsersBloc();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المستخدمين"),
      ),
      body: StreamBuilder(
        stream: usersBloc.users,
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0)
              return Center(child: Text("No Users available"));
            return usersPageBuilder(snapshot.data);
          } else
            return loadingData();
        },
      ),
    );
  }

  Widget usersPageBuilder(List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        User user = users[index];
        return Container(
          padding: EdgeInsets.all(5),
          color: Colors.grey[100],
          height: 70,
          child: GestureDetector(
            child: Card(
                child: Padding(
              padding: EdgeInsets.all(7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: TextStyle(fontSize: 17, color: Colors.black54),
                        ),
                        Text(
                          user.number,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ]),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "${user.balance.toString().replaceFirst(".0", "")} IQD",
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.indigoAccent),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
            onTap: () {
              Navigator.pushNamed(context, EditUserInfo.route, arguments: user);
            },
          ),
        );
      },
    );
  }

  Widget loadingData() {
    usersBloc.getUsers();
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
