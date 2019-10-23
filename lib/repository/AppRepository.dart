import 'package:trymethods/databaseaccess/CompanyAccess.dart';
import 'package:trymethods/databaseaccess/CreditCardAccess.dart';
import 'package:trymethods/databaseaccess/LogAccess.dart';
import 'package:trymethods/databaseaccess/CardTypeAccess.dart';
import 'package:trymethods/databaseaccess/UserAccess.dart';
import 'package:trymethods/model/CardType.dart';
import 'package:trymethods/model/Company.dart';
import 'package:trymethods/model/CreditCard.dart';
import 'package:trymethods/model/Log.dart';
import 'package:trymethods/model/PrintWidget.dart';
import 'package:trymethods/model/User.dart';

class AppRepository {
  final cardaccess = CreditCardAccess();
  final companyaccess = CompanyAccess();
  final useraccess = UserAccess();
  final typeaccess = CardTypeAccess();
  final logaccess = LogAccess();
  // ! cardaccess
  Future getAllCreditCards() => cardaccess.getCreditCards();
  Future insertCreditCard(CreditCard card) => cardaccess.createCreditCard(card);
  Future updateCreditCard(CreditCard card) => cardaccess.updateCreditCard(card);
  Future deleteCreditCardById(int id) => cardaccess.deleteCreditCard(id);
  Future deleteAllCreditCard() => cardaccess.deleteAllCreditCards();
  Future<List<PrintWidget>> getAvailableCardCount() =>
      cardaccess.getAvailableCreditCardsCounts();
  Future<List<CreditCard>> getCreditCardsByType(int id) =>
      cardaccess.getCreditCardsByType(id);

  // ! useraccess
  Future getAllUsers() => useraccess.getUsers();
  Future insertUser(User user) => useraccess.createUser(user);
  Future updateUser(User user) => useraccess.updateUser(user);
  Future deleteUserById(int id) => useraccess.deleteUser(id);
  Future deleteAllUser() => useraccess.deleteAllUsers();
  Future<User> getUser(String id) => useraccess.getUser(id);
  // ! logaccess
  Future getAllLogs() => logaccess.getLogs();
  Future<List<Log>> getLogsByDate(Duration time) =>
      logaccess.getLogsByDate(time: time);
  Future insertLog(Log log) => logaccess.createLog(log);
  Future deleteLogById(int id) => logaccess.deleteLog(id);
  Future deleteAllLog() => logaccess.deleteAllLogs();
  Future deleteLogbyDate(Duration dur) => logaccess.deleteLogByDate(dur);
  // ! companyaccess
  Future getAllCompanys() => companyaccess.getCompanys();
  Future insertCompany(Company company) => companyaccess.createCompany(company);
  Future updateCompany(Company company) => companyaccess.updateCompany(company);
  Future deleteCompanyById(int id) => companyaccess.deleteCompany(id);
  Future deleteAllCompany() => companyaccess.deleteAllCompanys();
  Future getCompany(int id) => companyaccess.getCompany(id);
  // ! typeaccess
  Future getAllTypes() => typeaccess.getCardTypes();
  Future insertType(CardType cardtype) => typeaccess.createCardType(cardtype);
  Future updateType(CardType cardtype) => typeaccess.updateCardType(cardtype);
  Future deleteTypeById(int id) => typeaccess.deleteCardType(id);
  Future deleteAllType() => typeaccess.deleteAllCardTypes();
  Future getCardTypeAndCompany() => typeaccess.getCardTypeAndCompany();
}
