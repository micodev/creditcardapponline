import 'dart:async';
import 'package:trymethods/model/Company.dart';
import 'package:trymethods/repository/AppRepository.dart';

class CompanyBloc {
  //Get instance of the Repository
  final apprepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _companyController = StreamController<List<Company>>.broadcast();

  get companys => _companyController.stream;

  CompanyBloc() {
    getCompanys();
  }

  getCompanys() async {
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _companyController.sink.add(await apprepo.getAllCompanys());
  }

  getCompanysAsync() async {
    return await apprepo.getAllCompanys();
  }

  addCompany(Company company) async {
    await apprepo.insertCompany(company);
    await getCompanys();
  }

  updateCompany(Company company) async {
    await apprepo.updateCompany(company);
    await getCompanys();
  }

  Future<Company> getCompany(int id) async {
    return await apprepo.getCompany(id);
  }

  deleteCompanyById(int id) async {
    await apprepo.deleteCompanyById(id);
    await getCompanys();
  }

  dispose() {
    _companyController.close();
  }
}
