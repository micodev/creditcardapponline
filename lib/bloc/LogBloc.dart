import 'dart:async';
import 'package:trymethods/model/Log.dart';
import 'package:trymethods/repository/AppRepository.dart';

class LogBloc {
  //Get instance of the Repository
  final apprepo = AppRepository();

  //Stream controller is the 'Admin' that manages
  //the state of our stream of data like adding
  //new data, change the state of the stream
  //and broadcast it to observers/subscribers
  final _logController = StreamController<List<Log>>.broadcast();

  get logs => _logController.stream;

  LogBloc() {
    getLogs(duration);
  }
  static Duration duration = new Duration(days: -1);
  getLogs(Duration dur) async {
    if (dur != null) duration = dur;
    //sink is a way of adding data reactively to the stream
    //by registering a new event
    _logController.sink.add(await apprepo.getLogsByDate(duration));
  }

  Future<List<Log>> getLogsByDateAsync(Duration time) async {
    return await apprepo.getLogsByDate(time);
  }

  getLogsAsync() async {
    return await apprepo.getAllLogs();
  }

  addLog(Log log) async {
    await apprepo.insertLog(log);
    await getLogs(duration);
  }

  deleteLogById(int id) async {
    await apprepo.deleteLogById(id);
    await getLogs(duration);
  }

  Future deleteAllLogs() async {
    await apprepo.deleteAllLog();
    await getLogs(duration);
  }

  Future deleteAllLogsByDate(Duration dur) async {
    await apprepo.deleteLogbyDate(dur);
    await getLogs(duration);
  }

  dispose() {
    _logController.close();
  }
}
