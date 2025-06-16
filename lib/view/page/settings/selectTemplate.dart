import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/category.dart';
import 'package:omsetin_stok/model/receiptTemplate.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/utils/failedAlert.dart';
import 'package:omsetin_stok/utils/responsif/fsize.dart';
import 'package:omsetin_stok/utils/search_utils.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/search.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:omsetin_stok/utils/sort.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SelectTemplate extends StatefulWidget {
  const SelectTemplate({super.key});

  @override
  _SelectTemplateState createState() => _SelectTemplateState();
}

class _SelectTemplateState extends State<SelectTemplate> {
  final DatabaseService _databaseService = DatabaseService.instance;

  final TextEditingController _searchController = TextEditingController();

  Future<void> _pullRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentTemplate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //  void _filterSearch() {
  //   setState(() {
  //     _filteredProduct = filterItems(itemProduk, _searchController.text,
  //         (itemProduk) => itemProduk.productName);
  //   });
  // }

  void _updateTemplateInDatabase(newTemplate, newSize) async {
    await _databaseService.updateSettingTemplate(newTemplate, newSize);
    print(newTemplate + newSize);
  }

  String? currentReceipt;
  String? currentReceiptSize;

  Future<void> _loadCurrentTemplate() async {
    try {
      final currentReceiptFromDB = await _databaseService.getSettingReceipt();
      setState(() {
        currentReceipt = currentReceiptFromDB['settingReceipt'];
        currentReceiptSize = currentReceiptFromDB['settingReceiptSize'];
      });
    } catch (e) {
      print('Failed to load current template: $e');
    }
  }

  bool? info1 = false;
  bool? info2 = false;
  bool? info3 = false;
  bool? info4 = false;

  void _selectTemplate(String type, String size) {
    switch (type) {
      case 'default':
        if (size == '58') {
          info1 = true;
          info2 = false;
          info3 = false;
          info4 = false;
        } else if (size == '80') {
          info1 = false;
          info2 = false;
          info3 = true;
          info4 = false;
        }
        break;
      case 'tanpaAntrian':
        if (size == '58') {
          info1 = false;
          info2 = true;
          info3 = false;
          info4 = false;
        } else if (size == '80') {
          info3 = false;
          info1 = false;
          info2 = false;
          info4 = true;
        }
        break;
      default:
        break;
    }
    _updateTemplateInDatabase(type, size);
    Navigator.pop(
        context, {"type": type, "typeText": type, "papperSize": size});
  }

  bool isMatchingTemplate(
      String? currentReceipt,
      String? currentReceiptSize,
      String? type,
      String? paperSize,
      bool info1,
      bool info2,
      bool info3,
      bool info4) {
    return (currentReceipt == type && currentReceiptSize == paperSize) ||
        (info1 && paperSize == '58' && type == 'default') ||
        (info2 && paperSize == '58' && type == 'tanpaAntrian') ||
        (info3 && paperSize == '80' && type == 'default') ||
        (info4 && paperSize == '80' && type == 'tanpaAntrian');
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
                  secondaryColor,
                  primaryColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              title: Text(
                "BAGIKAN STRUK PEMBAYARAN",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              leading: CustomBackButton(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 35,
          right: 35,
        ),
        child: Column(
          children: MediaQuery.of(context).orientation == Orientation.landscape
              ? [
                  Gap(10),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: itemTemplate
                                .where((item) => item.papperSize == "58")
                                .length,
                            itemBuilder: (context, index) {
                              final filteredItems = itemTemplate
                                  .where((item) => item.papperSize == "58")
                                  .toList();
                              final item = filteredItems[index];
                              return ZoomTapAnimation(
                                onTap: () {
                                  _updateTemplateInDatabase(
                                      item.type, item.papperSize);
                                  Navigator.pop(
                                    context,
                                    {
                                      "type": item.type,
                                      "typeText": item.typeText,
                                      "papperSize": item.papperSize
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Image.asset(
                                                item.image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const Gap(5),
                                            Text(
                                              item.typeText.length > 15
                                                  ? '${item.typeText.substring(0, 15)}...'
                                                  : item.typeText,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.landscape
                                                  ? "(Ukuran Kertas 58 mm)"
                                                  : "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      ),
                                      if (isMatchingTemplate(
                                          currentReceipt,
                                          currentReceiptSize,
                                          item.type,
                                          item.papperSize,
                                          info1!,
                                          info2!,
                                          info3!,
                                          info4!))
                                        Positioned(
                                          top: 0,
                                          right: 12,
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                            ),
                            itemCount: itemTemplate
                                .where((item) => item.papperSize == "80")
                                .length,
                            itemBuilder: (context, index) {
                              final filteredItems = itemTemplate
                                  .where((item) => item.papperSize == "80")
                                  .toList();
                              final item = filteredItems[index];
                              return ZoomTapAnimation(
                                onTap: () {
                                  _updateTemplateInDatabase(
                                      item.type, item.papperSize);
                                  Navigator.pop(
                                    context,
                                    {
                                      "type": item.type,
                                      "typeText": item.typeText,
                                      "papperSize": item.papperSize
                                    },
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(),
                                      child: Center(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Image.asset(
                                                item.image,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const Gap(5),
                                            Text(
                                              item.typeText.length > 15
                                                  ? '${item.typeText.substring(0, 15)}...'
                                                  : item.typeText,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              MediaQuery.of(context)
                                                          .orientation ==
                                                      Orientation.landscape
                                                  ? "(Ukuran Kertas 80 mm)"
                                                  : "",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (isMatchingTemplate(
                                        currentReceipt,
                                        currentReceiptSize,
                                        item.type,
                                        item.papperSize,
                                        info1!,
                                        info2!,
                                        info3!,
                                        info4!))
                                      Positioned(
                                        top: 0,
                                        right: 12,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : [
                  const Gap(20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ukuran Kertas 58 mm",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const Gap(10),
                  SizedBox(
                    height: 250,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: itemTemplate
                          .where((item) => item.papperSize == "58")
                          .length,
                      itemBuilder: (context, index) {
                        final filteredItems = itemTemplate
                            .where((item) => item.papperSize == "58")
                            .toList();
                        final item = filteredItems[index];
                        return ZoomTapAnimation(
                          onTap: () {
                            _updateTemplateInDatabase(
                                item.type, item.papperSize);
                            Navigator.pop(
                              context,
                              {
                                "type": item.type,
                                "typeText": item.typeText,
                                "papperSize": item.papperSize
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          item.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const Gap(5),
                                      Text(
                                        item.typeText.length > 15
                                            ? '${item.typeText.substring(0, 15)}...'
                                            : item.typeText,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMatchingTemplate(
                                    currentReceipt,
                                    currentReceiptSize,
                                    item.type,
                                    item.papperSize,
                                    info1!,
                                    info2!,
                                    info3!,
                                    info4!))
                                  Positioned(
                                    top: 0,
                                    right: 40,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ukuran Kertas 80 mm",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: itemTemplate
                          .where((item) => item.papperSize == "80")
                          .length,
                      itemBuilder: (context, index) {
                        final filteredItems = itemTemplate
                            .where((item) => item.papperSize == "80")
                            .toList();
                        final item = filteredItems[index];
                        return ZoomTapAnimation(
                          onTap: () {
                            _updateTemplateInDatabase(
                                item.type, item.papperSize);
                            Navigator.pop(
                              context,
                              {
                                "type": item.type,
                                "typeText": item.typeText,
                                "papperSize": item.papperSize
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Image.asset(
                                          item.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const Gap(5),
                                      Text(
                                        item.typeText.length > 15
                                            ? '${item.typeText.substring(0, 15)}...'
                                            : item.typeText,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isMatchingTemplate(
                                    currentReceipt,
                                    currentReceiptSize,
                                    item.type,
                                    item.papperSize,
                                    info1!,
                                    info2!,
                                    info3!,
                                    info4!))
                                  Positioned(
                                    top: 0,
                                    right: 40,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
