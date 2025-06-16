class Income {
  final int? incomeId;
  final String incomeName;
  final String incomeDateAdded;
  final String incomeDate;
  final int incomeAmount;
  final String incomeNote;

  Income(
      {this.incomeId,
      required this.incomeName,
      required this.incomeDateAdded,
      required this.incomeDate,
      required this.incomeAmount,
      required this.incomeNote});

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
        incomeId: json['income_id'] as int,
        incomeName: json['income_name'] as String,
        incomeDateAdded: json['income_date_added'] as String,
        incomeDate: json['income_date'] as String,
        incomeAmount: json['amount'] as int,
        incomeNote: json['income_note'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'income_id': incomeId,
      'income_name': incomeName,
      'income_date_added': incomeDateAdded,
      'income_date': incomeDate,
      'income_amount': incomeAmount,
      'income_note': incomeNote,
    };
  }
}
