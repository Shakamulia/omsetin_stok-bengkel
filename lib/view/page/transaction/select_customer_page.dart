import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/model/pelanggan.dart';
import 'package:omzetin_bengkel/providers/pelangganProvider.dart';
import 'package:omzetin_bengkel/utils/alert.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';
import 'package:omzetin_bengkel/view/page/pelanggan/add_pelanggan.dart';
import 'package:omzetin_bengkel/view/widget/Notfound.dart';
import 'package:omzetin_bengkel/view/widget/back_button.dart';
import 'package:omzetin_bengkel/view/widget/expensiveFloatingButton.dart';
import 'package:omzetin_bengkel/view/widget/search.dart';
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
        child: Stack(
          children: [
            Column(
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
                  child: _buildPelangganGridView(),
                ),
              ],
            ),
            // Replace FloatingActionButton with Positioned widget
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ExpensiveFloatingButton(
                text:
                    "TAMBAH PELANGGAN", // Changed from "TAMBAH PEGAWAI" to match your navigation function
                onPressed: () => _navigateToAddPelangganPage(),
              ),
            ),
          ],
        ),
      ),
    );
// Remove the floatingActionButton property completely
  }

  Widget _buildPelangganGridView() {
    return Consumer<Pelangganprovider>(
      builder: (context, pelangganProvider, child) {
        return FutureBuilder<List<Pelanggan>>(
          future: pelangganProvider.getPelangganList(
              query: _searchController.text, sortOrder: _sortOrder),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: NotFoundPage(
                title: _searchController.text == ""
                    ? "Tidak ada pelanggan yang ditemukan"
                    : 'Tidak ada pelanggan dengan nama "${_searchController.text}"',
              ));
            } else {
              final pelangganList = snapshot.data!;
              return GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: pelangganList.length,
                itemBuilder: (context, index) {
                  final pelanggan = pelangganList[index];
                  return _buildPelangganCard(pelanggan);
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildPelangganCard(Pelanggan pelanggan) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, pelanggan),
      child: Card(
        elevation: 0,
        color: cardColor,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 221, 227, 224),
                    image: _buildImageDecoration(pelanggan),
                  ),
                  child: _buildImageDecoration(pelanggan) == null
                      ? Icon(Icons.person, size: 40, color: Colors.blueGrey)
                      : null,
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        pelanggan.namaPelanggan,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 14, color: primaryColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      pelanggan.noHandphone ?? '-',
                      style:
                          GoogleFonts.poppins(fontSize: 15, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (widget.selectedCustomer?.id == pelanggan.id)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage? _buildImageDecoration(Pelanggan pelanggan) {
    try {
      if (pelanggan.profileImage == null || pelanggan.profileImage!.isEmpty) {
        return null;
      }

      if (pelanggan.profileImage!.startsWith('http') ||
          pelanggan.profileImage!.startsWith('https')) {
        return DecorationImage(
          image: NetworkImage(pelanggan.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      } else {
        return DecorationImage(
          image: AssetImage(pelanggan.profileImage!),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => null,
        );
      }
    } catch (e) {
      return null;
    }
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

  void _navigateToAddPelangganPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddPelangganPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween<Offset>(begin: begin, end: end)
              .chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    ).then((_) => setState(() {}));
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
