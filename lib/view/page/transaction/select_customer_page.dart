import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omsetin_bengkel/model/pelanggan.dart';
import 'package:omsetin_bengkel/providers/pelangganProvider.dart';
import 'package:omsetin_bengkel/utils/alert.dart';
import 'package:omsetin_bengkel/utils/colors.dart';
import 'package:omsetin_bengkel/utils/responsif/fsize.dart';
import 'package:omsetin_bengkel/view/widget/back_button.dart';
import 'package:omsetin_bengkel/view/widget/search.dart';
import 'package:provider/provider.dart';

class SelectCustomerPage extends StatefulWidget {
  final Pelanggan? selectedCustomer;

  const SelectCustomerPage({Key? key, this.selectedCustomer}) : super(key: key);

  @override
  _SelectCustomerPageState createState() => _SelectCustomerPageState();
}

class _SelectCustomerPageState extends State<SelectCustomerPage> {
  TextEditingController _searchController = TextEditingController();
  String _sortOrder = 'asc';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondaryColor, primaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: AppBar(
              title: Text(
                'PILIH PELANGGAN',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: SizeHelper.Fsize_normalTitle(context),
                  color: bgColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              leading: CustomBackButton(),
              elevation: 0,
              toolbarHeight: kToolbarHeight + 20,
              actions: [
                IconButton(
                  icon: Icon(Icons.sort, color: bgColor),
                  onPressed: _showSortOptions,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: SearchTextField(
                prefixIcon: const Icon(Icons.search, size: 24),
                obscureText: false,
                hintText: "Cari pelanggan...",
                controller: _searchController,
                maxLines: 1,
                suffixIcon: null,
                color: cardColor,
              ),
            ),
            Expanded(
              child: _buildCustomerList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCustomerDialog(context),
      ),
    );
  }

  Widget _buildCustomerList() {
    final pelangganProvider = Provider.of<Pelangganprovider>(context);

    return FutureBuilder<List<Pelanggan>>(
      future: pelangganProvider.getPelangganList(
        query: _searchController.text,
        sortOrder: _sortOrder,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading customers'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text(
                  _searchController.text.isEmpty
                      ? 'Tidak ada pelanggan'
                      : 'Tidak ditemukan pelanggan',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                if (_searchController.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _showAddCustomerDialog(context,
                          name: _searchController.text);
                    },
                    child: Text(
                      'Tambah "${_searchController.text}"',
                      style: GoogleFonts.poppins(color: primaryColor),
                    ),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final customer = snapshot.data![index];
            return Card(
              margin: EdgeInsets.only(bottom: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: primaryColor.withOpacity(0.2),
                  backgroundImage: customer.profileImage != null
                      ? AssetImage(customer.profileImage!)
                      : null,
                  child: customer.profileImage == null
                      ? Text(
                          customer.namaPelanggan[0],
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  customer.namaPelanggan,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.noHandphone),
                    if (customer.email != null && customer.email!.isNotEmpty)
                      Text(customer.email!),
                  ],
                ),
                trailing: widget.selectedCustomer?.id == customer.id
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () => Navigator.pop(context, customer),
              ),
            );
          },
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text("A-Z"),
                onTap: () {
                  setState(() => _sortOrder = 'asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.sort_by_alpha),
                title: Text("Z-A"),
                onTap: () {
                  setState(() => _sortOrder = 'desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.new_releases),
                title: Text("Terbaru"),
                onTap: () {
                  setState(() => _sortOrder = 'newest');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text("Terlama"),
                onTap: () {
                  setState(() => _sortOrder = 'oldest');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCustomerDialog(BuildContext context, {String? name}) async {
    final pelangganProvider =
        Provider.of<Pelangganprovider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    TextEditingController nameController =
        TextEditingController(text: name ?? '');
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController addressController = TextEditingController();
    String? gender;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Tambah Pelanggan Baru',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Pelanggan',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'No. HP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (value) => gender = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);

                  try {
                    final newCustomer = {
                      'pelanggan_name': nameController.text,
                      'pelanggan_no_hp': phoneController.text,
                      'pelanggan_email': emailController.text,
                      'pelanggan_alamat': addressController.text,
                      'pelanggan_gender': gender,
                    };

                    await pelangganProvider.addPelanggan(newCustomer);
                    Navigator.pop(context);
                    setState(() {});
                  } catch (e) {
                    showErrorDialog(context, 'Gagal menambah pelanggan: $e');
                  } finally {
                    setState(() => _isLoading = false);
                  }
                }
              },
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
