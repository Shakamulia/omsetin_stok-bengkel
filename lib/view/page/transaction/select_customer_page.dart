import 'package:flutter/material.dart';
import 'package:omsetin_stok/model/pelanggan.dart';
import 'package:omsetin_stok/services/database_service.dart';
import 'package:omsetin_stok/view/widget/custom_textfield.dart';

class SelectCustomerPage extends StatefulWidget {
  const SelectCustomerPage({super.key});

  @override
  _SelectCustomerPageState createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  List<Pelanggan> customers = [];
  List<Pelanggan> filteredCustomers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    searchController.addListener(() {
      _filterCustomers(searchController.text);
    });
  }

  Future<void> _loadCustomers() async {
    final db = DatabaseService.instance;
    final result = await db.getAllPelanggan();
    setState(() {
      customers = result;
      filteredCustomers = result;
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        final nameLower = customer.namaPelanggan.toLowerCase();
        final phoneLower = customer.noHandphone.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) || 
               phoneLower.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Pelanggan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari pelanggan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterCustomers,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                return ListTile(
                  title: Text(customer.namaPelanggan),
                  subtitle: customer.noHandphone.isNotEmpty
                      ? Text(customer.noHandphone)
                      : null,
                  onTap: () => Navigator.pop(context, customer),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Pelanggan Baru'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pelanggan',
                    hintText: 'Masukkan nama pelanggan',
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: phoneController,
                  hintText: 'Masukkan nomor telepon', obscureText: false, prefixIcon: null, suffixIcon: null, maxLines: null,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    hintText: 'Masukkan alamat',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama pelanggan harus diisi'),
                    ),
                  );
                  return;
                }

                final newCustomer = Pelanggan(
                  id: DateTime.now().millisecondsSinceEpoch,
                  kode: 'CUST-${DateTime.now().millisecondsSinceEpoch}',
                  namaPelanggan: nameController.text,
                  noHandphone: phoneController.text,
                  alamat: addressController.text,
                  email: '',
                  gender: 'L',
                  profileImage: '',
                );

                await DatabaseService.instance.insertPelanggan(newCustomer);
                Navigator.pop(context);
                _loadCustomers();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}