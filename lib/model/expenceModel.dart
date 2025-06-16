class Expensemodel {
  final int? id;
  final String? name;
  final String? dateAdded;
  final String? date;
  final String? note;
  final int? amount;
  Expensemodel({this.id, this.name, this.date, this.note, this.amount, this.dateAdded});

  factory Expensemodel.fromJson(Map<String, dynamic> json) => Expensemodel(
      id: json['expense_id'],
      name: json['expense_name'],
      dateAdded: json['expense_date_added'],
      date: json['expense_date'],
      note: json['expense_note'],
      amount: json['expense_amount'],
      );
}