class ProfitData {
  final int? omzet;
  final int? totalModal;
  final int? totalExpense;
  final int? profitKotor;
  final int? profitBersih;

  ProfitData({
    this.omzet,
    this.totalModal,
    this.totalExpense,
    this.profitKotor,
    this.profitBersih,
  });

  factory ProfitData.fromJson(Map<String, dynamic> json) => ProfitData(
        omzet: json['omzet'] as int?,
        totalModal: json['total_Modal'] as int?,
        totalExpense: json['total_Expense'] as int?,
        profitKotor: json['profit_Kotor'] as int?,
        profitBersih: json['profit_Bersih'] as int?,
      );


  Map<String, dynamic> toJson() {
    return {
      'omzet': omzet,
      'total_Modal': totalModal,
      'total_Expense': totalExpense,
      'profit_Kotor': profitKotor,
      'profit_Bersih': profitBersih,
    };
  }
}
