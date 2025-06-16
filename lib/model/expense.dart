class Expense {
  final int? expenseId;
  final String expenseName;
  final String expenseDateAdded;
  final String expenseDate;
  final int expenseAmount;
  final String expenseNote;

  Expense(
      {this.expenseId,
      required this.expenseName,
      required this.expenseDate,
      required this.expenseAmount,
      required this.expenseDateAdded,
      required this.expenseNote});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
        expenseId: json['expense_id'] as int,
        expenseName: json['expense_name'] as String,
        expenseDateAdded: json['expense_date_added'] as String,
        expenseDate: json['expense_date'] as String,
        expenseAmount: json['amount'] as int,
        expenseNote: json['expense_note'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'expense_id': expenseId,
      'expense_name': expenseName,
      'expense_date_added': expenseDateAdded,
      'expense_note': expenseNote,
      'expense_date': expenseDate,
      'expense_amount': expenseAmount,
    };
  }
}
