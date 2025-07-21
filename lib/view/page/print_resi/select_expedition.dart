import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/expeditions.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';

class SelectExpedition extends StatefulWidget {
  const SelectExpedition({super.key});

  @override
  State<SelectExpedition> createState() => _SelectExpeditionState();
}

class _SelectExpeditionState extends State<SelectExpedition> {
  final TextEditingController _searchController = TextEditingController();
  List<Expeditions> _filteredExpeditions = [];

  @override
  void initState() {
    super.initState();
    _filteredExpeditions = itemExpedition;
    _searchController.addListener(_filterExpeditions);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterExpeditions);
    _searchController.dispose();
    super.dispose();
  }

  void _filterExpeditions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExpeditions = itemExpedition.where((category) {
        return category.expedition.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                secondaryColor,
                primaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
            child: AppBar(
              title: Text(
                "Pilih Ekspedisi",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              leading: CustomBackButton(),
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
            const Gap(20),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      const Gap(8),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text(_filteredExpeditions[index].expedition),
                          onTap: () {
                            Navigator.pop(context,
                                _filteredExpeditions[index].expedition);
                          },
                        ),
                      ),
                      const Gap(5),
                    ],
                  );
                },
                itemCount: _filteredExpeditions.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
