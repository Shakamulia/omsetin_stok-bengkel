import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/model/pelanggan.dart';
import 'package:omsetin_stok/model/service.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/services/db_helper.dart';
import 'package:omsetin_stok/utils/colors.dart';
import 'package:omsetin_stok/view/page/transaction/checkout_page.dart';
import 'package:omsetin_stok/view/widget/antrian.dart';
import 'package:omsetin_stok/view/widget/back_button.dart';
import 'package:omsetin_stok/view/widget/expensiveFloatingButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductWithQuantity {
  final Product product;
  int quantity;

  ProductWithQuantity(this.product, this.quantity);
}

class ServiceWithQuantity {
  final Service service;
  int quantity;

  ServiceWithQuantity(this.service, this.quantity);
}

class TransaksiPage extends StatefulWidget {
  final List<Product> selectedProducts;
  final Map<int, int> initialQuantities;
  final int? transactionId;
  final bool isUpdate;

  const TransaksiPage({
    super.key,
    this.selectedProducts = const [],
    this.initialQuantities = const {},
    this.transactionId,
    this.isUpdate = false,
  });

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  Pelanggan? selectedPelanggan;
  // Ganti selectedItems dengan ValueNotifier
  final ValueNotifier<List<dynamic>> selectedItemsNotifier = ValueNotifier([]);
  List<Pelanggan> pelangganList = [];
  List<Service> serviceList = [];
  List<Product> productList = [];
  bool isLoading = true;
  int queueNumber = 1;
  bool isAutoReset = false;
  bool nonActivateQueue = false;
  final DatabaseService databaseService = DatabaseService.instance;

  Future<void> _loadQueueAndisAutoResetValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      queueNumber = prefs.getInt('queueNumber') ?? 1;
      isAutoReset = prefs.getBool('isAutoReset') ?? false;
      nonActivateQueue = prefs.getBool('nonActivateQueue') ?? false;

      if (nonActivateQueue == true) {
        queueNumber = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQueueAndisAutoResetValue();
      _loadData();
    });

    // Inisialisasi produk yang dipilih dari constructor
    if (widget.selectedProducts.isNotEmpty) {
      selectedItemsNotifier.value = [...widget.selectedProducts];
    }
  }

  Future<void> _loadData() async {
    try {
      final pelanggan = await DatabaseHelper.instance.getAllPelanggan();
      final services = await DatabaseHelper.instance.getAllServices();
      final products = await databaseService.getProducts();

      // Filter duplikat berdasarkan ID
      final uniquePelanggan = pelanggan
          .fold<Map<int, Pelanggan>>({}, (map, p) {
            if (p.id != null) map.putIfAbsent(p.id!, () => p);
            return map;
          })
          .values
          .toList();

      setState(() {
        pelangganList = uniquePelanggan;
        serviceList = services;
        productList = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  int _calculateTotal() {
    return selectedItemsNotifier.value.fold(0, (sum, item) {
      if (item is ProductWithQuantity) {
        return sum + (item.product.productSellPrice.toInt() * item.quantity);
      } else if (item is ServiceWithQuantity) {
        return sum + (item.service.price.toInt() * item.quantity);
      }
      return sum;
    });
  }

  void _showAddItemDialog() {
    String selectedType = 'service';
    dynamic selectedItem;
    int qty = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tambah Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(
                            value: 'service', child: Text('Layanan')),
                        DropdownMenuItem(
                            value: 'product', child: Text('Produk')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          selectedItem = null;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    if (selectedType == 'service')
                      DropdownButtonFormField<Service>(
                        value: selectedItem is Service ? selectedItem : null,
                        hint: Text('Pilih Layanan'),
                        items: serviceList.map((service) {
                          return DropdownMenuItem<Service>(
                            value: service,
                            child: Text(
                                '${service.name} - Rp.${service.price.toInt()}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedItem = value);
                        },
                      ),
                    if (selectedType == 'product')
                      Column(
                        children: [
                          DropdownButtonFormField<Product>(
                            value:
                                selectedItem is Product ? selectedItem : null,
                            hint: Text('Pilih Produk'),
                            items: productList.map((product) {
                              return DropdownMenuItem<Product>(
                                value: product,
                                child: Text(
                                    '${product.productName} - Rp.${product.productSellPrice}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedItem = value);
                            },
                          ),
                          SizedBox(height: 8),
                          if (selectedItem != null && selectedItem is Product)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    if (qty > 1) {
                                      setState(() => qty--);
                                    }
                                  },
                                ),
                                Text('$qty ${selectedItem.productUnit}'),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() => qty++);
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: selectedItem != null
                      ? () {
                          Navigator.pop(context);
                          // Perbarui ValueNotifier dengan list baru
                          final newList = [...selectedItemsNotifier.value];
                          // Cek apakah item sudah ada di list
                          final existingIndex = newList.indexWhere((item) {
                            if (selectedItem is Product && item is Product) {
                              return item.productId == selectedItem.productId;
                            } else if (selectedItem is Service &&
                                item is Service) {
                              return item.id == selectedItem.id;
                            }
                            return false;
                          });

                          if (existingIndex != -1) {
                            // Jika sudah ada, tambahkan jumlahnya
                            if (newList[existingIndex] is Product) {
                              newList[existingIndex] = ProductWithQuantity(
                                newList[existingIndex] as Product,
                                (newList[existingIndex] as ProductWithQuantity)
                                        .quantity +
                                    qty,
                              );
                            } else {
                              newList[existingIndex] = ServiceWithQuantity(
                                newList[existingIndex] as Service,
                                (newList[existingIndex] as ServiceWithQuantity)
                                        .quantity +
                                    qty,
                              );
                            }
                          } else {
                            // Jika belum ada, tambahkan item baru
                            if (selectedItem is Product) {
                              newList.add(ProductWithQuantity(
                                  selectedItem as Product, qty));
                            } else {
                              newList.add(ServiceWithQuantity(
                                  selectedItem as Service, qty));
                            }
                          }

                          selectedItemsNotifier.value = newList;
                        }
                      : null,
                  child: Text('Tambah'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToCheckout(BuildContext context) {
    if (selectedPelanggan == null || selectedItemsNotifier.value.isEmpty)
      return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          pelanggan: selectedPelanggan!,
          items: selectedItemsNotifier.value,
          total: _calculateTotal(),
          transactionId: widget.transactionId,
          isUpdate: widget.isUpdate,
          onTransactionSuccess: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [secondaryColor, primaryColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
            child: AppBar(
              backgroundColor: Colors.transparent,
              leading: const CustomBackButton(),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await showModalQueue(
                          context, queueNumber, isAutoReset, nonActivateQueue);
                      if (result != null) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setInt(
                            'queueNumber', result['queueNumber']);
                        await prefs.setBool(
                            'isAutoReset', result['isAutoReset']);
                        setState(() {
                          queueNumber = result['queueNumber'];
                        });
                        _loadQueueAndisAutoResetValue();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Text(
                              "Antrian",
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
              title: Text(
                'TRANSAKSI BENGKEL',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: bgColor,
                ),
              ),
              centerTitle: true,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pelanggan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<Pelanggan>(
                                value: pelangganList.contains(selectedPelanggan)
                                    ? selectedPelanggan
                                    : null,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                items: pelangganList.map((pelanggan) {
                                  return DropdownMenuItem<Pelanggan>(
                                    value: pelanggan,
                                    child: Text(
                                      '${pelanggan.namaPelanggan} - ${pelanggan.noHandphone}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedPelanggan = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Detail Order',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Gunakan ValueListenableBuilder untuk daftar item
                              ValueListenableBuilder(
                                valueListenable: selectedItemsNotifier,
                                builder: (context, List<dynamic> items, _) {
                                  if (items.isEmpty) {
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'List Layanan kosong\nSilahkan tambahkan layanan terlebih dahulu',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        return Card(
                                          margin: EdgeInsets.only(bottom: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        item is ProductWithQuantity
                                                            ? item.product
                                                                .productName
                                                            : item.service.name,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        final newList = [
                                                          ...items
                                                        ];
                                                        newList.removeAt(index);
                                                        selectedItemsNotifier
                                                            .value = newList;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      item is ProductWithQuantity
                                                          ? 'Rp.${NumberFormat("#,###").format(item.product.productSellPrice)} / ${item.product.productUnit}'
                                                          : 'Rp.${NumberFormat("#,###").format(item.service.price.toInt())}',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.remove,
                                                              size: 20),
                                                          onPressed: () {
                                                            final newList = [
                                                              ...items
                                                            ];
                                                            if (item
                                                                is ProductWithQuantity) {
                                                              if (item.quantity >
                                                                  1) {
                                                                newList[index] =
                                                                    ProductWithQuantity(
                                                                  item.product,
                                                                  item.quantity -
                                                                      1,
                                                                );
                                                                selectedItemsNotifier
                                                                        .value =
                                                                    newList;
                                                              } else {
                                                                newList
                                                                    .removeAt(
                                                                        index);
                                                                selectedItemsNotifier
                                                                        .value =
                                                                    newList;
                                                              }
                                                            } else if (item
                                                                is ServiceWithQuantity) {
                                                              if (item.quantity >
                                                                  1) {
                                                                newList[index] =
                                                                    ServiceWithQuantity(
                                                                  item.service,
                                                                  item.quantity -
                                                                      1,
                                                                );
                                                                selectedItemsNotifier
                                                                        .value =
                                                                    newList;
                                                              } else {
                                                                newList
                                                                    .removeAt(
                                                                        index);
                                                                selectedItemsNotifier
                                                                        .value =
                                                                    newList;
                                                              }
                                                            }
                                                          },
                                                        ),
                                                        Text(
                                                          '${item is ProductWithQuantity ? item.quantity : item.quantity}',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.add,
                                                              size: 20),
                                                          onPressed: () {
                                                            final newList = [
                                                              ...items
                                                            ];
                                                            if (item
                                                                is ProductWithQuantity) {
                                                              newList[index] =
                                                                  ProductWithQuantity(
                                                                item.product,
                                                                item.quantity +
                                                                    1,
                                                              );
                                                            } else if (item
                                                                is ServiceWithQuantity) {
                                                              newList[index] =
                                                                  ServiceWithQuantity(
                                                                item.service,
                                                                item.quantity +
                                                                    1,
                                                              );
                                                            }
                                                            selectedItemsNotifier
                                                                    .value =
                                                                newList;
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Subtotal: Rp.${NumberFormat("#,###").format(item is ProductWithQuantity ? item.product.productSellPrice * item.quantity : item.service.price.toInt() * item.quantity)}',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(18),
                      // Gunakan ValueListenableBuilder untuk total transaksi
                      ValueListenableBuilder(
                        valueListenable: selectedItemsNotifier,
                        builder: (context, List<dynamic> items, _) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor],
                                begin: Alignment(0, 2),
                                end: Alignment(-0, -2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL TRANSAKSI',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'id_ID',
                                              symbol: 'Rp. ',
                                              decimalDigits: 0)
                                          .format(_calculateTotal()),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: selectedPelanggan != null &&
                                          items.isNotEmpty
                                      ? () => _navigateToCheckout(context)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                      'BAYAR',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ExpensiveFloatingButton(
                    onPressed: _showAddItemDialog,
                    text: 'TAMBAH ITEM',
                    right: 12,
                    left: 12,
                    bottom: 100,
                  ),
                ],
              ),
            ),
    );
  }
}
