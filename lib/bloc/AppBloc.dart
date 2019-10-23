
import 'package:trymethods/bloc/CreditCardBloc.dart';

class AppBloc {
  CreditCardBloc _creditCard;
  AppBloc()
      : _creditCard = CreditCardBloc();

  CreditCardBloc get creditCardBloc => _creditCard;
 
}