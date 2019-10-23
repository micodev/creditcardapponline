class CreditCard {
  int id;
  String cardNumber;
  int typeId;

  CreditCard({this.id, this.cardNumber, this.typeId});

  factory CreditCard.fromDatabaseJson(Map<String, dynamic> data) => CreditCard(
        //Factory method will be used to convert JSON objects that
        //are coming from querying the database and converting
        //it into a Todo object

        id: data['id'],
        cardNumber: data['cardNumber'],
        typeId: data['type_id'],
      );

  Map<String, dynamic> toDatabaseJson() => {
        //A method will be used to convert Todo objects that
        //are to be stored into the datbase in a form of JSON

        "id": this.id,
        "cardNumber": this.cardNumber,
        "type_id": this.typeId
      };
}
