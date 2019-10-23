import 'dart:async';
import 'package:trymethods/model/User.dart';
import 'package:trymethods/repository/AppRepository.dart';

class UsersBloc {
  //Get instance of the Repository
  final apprepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _userController = StreamController<List<User>>.broadcast();

  get users => _userController.stream;

  UsersBloc() {
    getUsers();
  }

  getUsers() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _userController.sink.add(await apprepo.getAllUsers());
  }

  Future<List<User>> getUsersAsync() async {
    return await apprepo.getAllUsers();
  }

  Future<User> getUser(String id) async {
    return await apprepo.getUser(id);
  }

  Future addUser(User user) async {
    await apprepo.insertUser(user);
    await getUsers();
  }

  updateUser(User user) async {
    await apprepo.updateUser(user);
    await getUsers();
  }

  deleteUserById(int id) async {
    await apprepo.deleteUserById(id);
    await getUsers();
  }

  dispose() {
    _userController.close();
  }
}
