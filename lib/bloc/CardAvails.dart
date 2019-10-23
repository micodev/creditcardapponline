import 'dart:async';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/repository/AppRepository.dart';

class CardAvails {
  //Get instance of the Repository
  final _cardRepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _availController = StreamController<List<PrintWidget>>.broadcast();

  get cardAvail => _availController.stream;

  CardAvails() {
    getAvailableCards();
  }

  getAvailableCards() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _availController.sink.add(await _cardRepo.getAvailableCardCount());
  }

  addCard(CreditCard card) async {
    await _cardRepo.insertCreditCard(card);
    await getAvailableCards();
  }

  // deleteCardByTypeId(int id) async {
  //  // await _cardRepo.deleteCardByCardType(id);
  //   await getAvailableCards();
  // }

  deleteCardById(int id) async {
    //debugPrint(id.toString());
    await _cardRepo.deleteCreditCardById(id);
    await getAvailableCards();
  }

  dispose() {
    _availController.close();
  }
}
