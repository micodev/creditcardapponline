import 'dart:async';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/repository/AppRepository.dart';

class CreditCardBloc {
  //Get instance of the Repository
  final _cardRepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _cardController = StreamController<List<CreditCard>>.broadcast();

  get cards => _cardController.stream;

  CreditCardBloc() {
    getCreditCards();
  }

  getCreditCards() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _cardController.sink.add(await _cardRepo.getAllCreditCards());
  }

  addCard(CreditCard card) async {
    await _cardRepo.insertCreditCard(card);
    await getCreditCards();
  }

  updateCard(CreditCard card) async {
    await _cardRepo.updateCreditCard(card);
    await getCreditCards();
  }

  deleteCardById(int id) async {
    await _cardRepo.deleteCreditCardById(id);
    await getCreditCards();
  }

  // deleteCardByTypeId(int id) async {
  //   await _cardRepo.deleteCardByCardType(id);
  //   await getCreditCards();
  // }

  dispose() {
    _cardController.close();
  }
}
