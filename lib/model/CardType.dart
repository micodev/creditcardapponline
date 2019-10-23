class CardType {
  int id;
  double price;
  int companyId;
  double brandPrice;
  CardType({this.id, this.price, this.brandPrice, this.companyId});

  factory CardType.fromDatabaseJson(Map<String, dynamic> json) => CardType(
        id: json["id"],
        price: json["price"].toDouble(),
        companyId: json["company_id"], //companyId
        brandPrice: json["brandPrice"].toDouble(),
      );

  Map<String, dynamic> toDatabaseJson() => {
        'id': id,
        'price': price,
        'company_id': companyId,
        'brandPrice': brandPrice
      };
}
