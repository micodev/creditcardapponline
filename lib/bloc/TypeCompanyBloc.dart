import 'dart:async';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/repository/AppRepository.dart';

class TypeCompanyBloc {
  //Get instance of the Repository
  final apprepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _typeController = StreamController<List<TypeAndCompany>>.broadcast();

  get types => _typeController.stream;

  TypeCompanyBloc() {
    getCardTypes();
  }

  getCardTypes() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _typeController.sink.add(await apprepo.getCardTypeAndCompany());
  }

  getCardTypesAsync() async {
    return await apprepo.getAllTypes();
  }

  addCardType(CardType type) async {
    await apprepo.insertType(type);
    await getCardTypes();
  }

  updateCardType(CardType type) async {
    await apprepo.updateType(type);
    await getCardTypes();
  }

  deleteCardTypeById(int id) async {
    await apprepo.deleteTypeById(id);
    await getCardTypes();
  }

  dispose() {
    _typeController.close();
  }
}
