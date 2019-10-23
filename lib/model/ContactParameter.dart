import 'package:trymethods/bloc/CreditCardBloc.dart';

class ContactParameter {
  final String cardNumber;
  final CreditCardBloc creditcardBloc;
  final int cardId;
  ContactParameter({this.cardNumber, this.creditcardBloc, this.cardId});
}
