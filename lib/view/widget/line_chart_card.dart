import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_stok/model/transaction.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/widget/custom_card_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartCard extends StatelessWidget {
  final List<TransactionData> transactionData;
  const LineChartCard({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return CustomCard(
      child: Container(
        height: screenSize.height * 0.3,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: _buildInfoText(
                          'Jumlah Penghasilan',
                          'Rp${_calculateTotal(transactionData, 'total')}',
                          blueColor)),
                  Expanded(
                      child: _buildInfoText(
                          'Jumlah Keuntungan',
                          'Rp${_calculateTotal(transactionData, 'profit')}',
                          secondaryColor)),
                ],
              ),
            ),
            Gap(screenSize.height * 0.01),
            Expanded(
              child: ChartScreen(transactionData: transactionData),
            ),
          ],
        ),
      ),
    );
  }

  static String _calculateTotal(List<TransactionData> data, String type) {
    int total = 0;
    for (var trx in data) {
      if (type == 'total') {
        total += trx.transactionTotal;
      } else if (type == 'profit') {
        total += trx.transactionProfit;
      }
    }
    return total.toString();
  }
}

Widget _buildInfoText(String title, String value, Color valueColor) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
      const Text("Hari ini",
          style: TextStyle(fontSize: 12, color: Colors.black54)),
      Text(value,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: valueColor)),
    ],
  );
}

class ChartScreen extends StatelessWidget {
  final List<TransactionData> transactionData;
  const ChartScreen({super.key, required this.transactionData});

  @override
  Widget build(BuildContext context) {
    List<ChartData> omsetData =
        _generateChartData(transactionData, isProfit: false);
    List<ChartData> profitData =
        _generateChartData(transactionData, isProfit: true);

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(fontSize: 10),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 100000,
        interval:
            20000, // Sesuaikan nilai ini biar lebih pas sama skala data kamu
        labelFormat: 'Rp{value}', // Biar ada prefix "Rp"
        labelStyle: TextStyle(fontSize: 10),
      ),
      series: <CartesianSeries>[
        AreaSeries<ChartData, String>(
          color: primaryColor.withOpacity(0.1),
          borderColor: primaryColor,
          borderWidth: 2,
          dataSource: omsetData,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
        ),
        AreaSeries<ChartData, String>(
          color: Colors.transparent,
          borderColor: blueColor,
          borderWidth: 2,
          dataSource: profitData,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
        ),
      ],
    );
  }

  List<ChartData> _generateChartData(List<TransactionData> data,
      {required bool isProfit}) {
    Map<String, double> monthlySums = {
      for (var i = 1; i <= 12; i++) _getMonthName(i): 0,
    };

    for (var trx in data) {
      final date = DateTime.tryParse(trx.transactionDate);
      if (date != null) {
        final month = _getMonthName(date.month);
        monthlySums[month] = (monthlySums[month] ?? 0) +
            (isProfit ? trx.transactionProfit : trx.transactionTotal)
                .toDouble();
      }
    }

    return monthlySums.entries
        .map((entry) => ChartData(entry.key, entry.value))
        .toList();
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }
}

class ChartData {
  final String label;
  final double value;

  ChartData(this.label, this.value);
}
