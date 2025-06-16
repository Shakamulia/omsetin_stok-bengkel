class settingProfitType {
  final String profit;
  final String profitText;

  settingProfitType({
    required this.profit,
    required this.profitText,
  });
}

List<settingProfitType> itemProfit = [
  settingProfitType(
    profit: "omzetModal",
    profitText: 'Profit = Omzet - Modal',
  ),
  settingProfitType(
      profit: "omzetModalPengeluaran",
      profitText: 'Profit = Omzet - Modal - Pengeluaran'),
];
