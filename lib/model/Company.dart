class Company {
  int id;
  String name;
  Company({this.id, this.name});

  factory Company.fromDatabaseJson(Map<String, dynamic> json) => Company(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toDatabaseJson() => {'id': id, 'name': name};
}
