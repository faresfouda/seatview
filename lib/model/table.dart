class Table {
  final int id;
  final int seats;
  final String position;
  final bool isBooked;

  Table({
    required this.id,
    required this.seats,
    required this.position,
    required this.isBooked,
  });

  factory Table.fromJson(Map<String, dynamic> json) {
    return Table(
      id: json['id'],
      seats: json['seats'],
      position: json['position'],
      isBooked: json['isBooked'],
    );
  }
}
