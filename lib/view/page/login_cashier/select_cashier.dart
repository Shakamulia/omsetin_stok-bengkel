import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/cashier.dart';
import 'package:omzetin_bengkel/providers/cashierProvider.dart';
import 'package:omzetin_bengkel/services/database_service.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/refresWidget.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
import 'package:provider/provider.dart';

class SelectCashier extends StatefulWidget {
  const SelectCashier({super.key});

  @override
  State<SelectCashier> createState() => _SelectCashierState();
}

class _SelectCashierState extends State<SelectCashier> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _searchController = TextEditingController();
  List<CashierData> _filteredCashier = [];

  @override
  void initState() {
    super.initState();
    _loadCashiers();
    _searchController.addListener(_filterCashiers);
  }

  Future _loadCashiers() async {
    final cashiers = await _databaseService.getCashiers();
    setState(() {
      _filteredCashier = cashiers;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCashiers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCashiers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _loadCashiers();
    } else {
      setState(() {
        _filteredCashier = _filteredCashier.where((cashier) {
          return cashier.cashierName.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  secondaryColor, // Warna akhir gradient
                  primaryColor, // Warna awal gradient
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                "PILIH KASIR",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Column(
          children: [
            const Gap(20),
            SearchTextField(
              prefixIcon: const Icon(Icons.search, size: 24),
              obscureText: false,
              hintText: "Search",
              controller: _searchController,
              maxLines: 1,
              suffixIcon: null,
              color: cardColor,
            ),
            const Gap(5),
            Expanded(
              child: _filteredCashier.isEmpty
                  ? CustomRefreshWidget(
                      onRefresh: null,
                      child: Center(
                          child: NotFoundPage(
                        title: _searchController.text == ""
                            ? "Tidak ada Kasir yang ditemukan"
                            : 'Tidak ada Kasir dengan nama "${_searchController.text}"',
                      )),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        final cashier = _filteredCashier[index];
                        var cashierProvider = Provider.of<CashierProvider>(
                            context,
                            listen: false);
                        return Column(
                          children: [
                            const Gap(18),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: cashierProvider
                                            .cashierData?['cashierName'] ==
                                        cashier.cashierName
                                    ? cardColor
                                    : cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    ClipOval(
                                      child: Image.asset(
                                        cashier.cashierImage,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Gap(10),
                                    Text(cashierProvider
                                                .cashierData?['cashierName'] ==
                                            cashier.cashierName
                                        ? "${cashier.cashierName} (Sedang digunakan)"
                                        : cashier.cashierName),
                                  ],
                                ),
                                onTap: cashierProvider
                                            .cashierData?['cashierName'] ==
                                        cashier.cashierName
                                    ? null
                                    : () {
                                        print(
                                            'cashir id: ${cashier.cashierId}');

                                        Navigator.pop(context, {
                                          'cashierName': cashier.cashierName,
                                          'cashierPin': cashier.cashierPin,
                                          'cashierId':
                                              cashier.cashierId.toString()
                                        });
                                      },
                              ),
                            ),
                            const Gap(5),
                          ],
                        );
                      },
                      itemCount: _filteredCashier.length,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
