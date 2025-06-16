// // select_Pelanggan_page.dart
// import 'package:flutter/material.dart';

// class SelectPelangganPage extends StatefulWidget {
//   const SelectPelangganPage({super.key});

//   @override
//   _SelectPelangganPageState createState() => _SelectPelangganPageState();
// }

// class _SelectPelangganPageState extends State<SelectPelangganPage> {
//   List<Pelanggan> Pelanggans = [];
//   List<Pelanggan> filteredPelanggans = [];
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadPelanggans();
//   }

//   Future<void> _loadPelanggans() async {
//     // Implementasi pengambilan data pelanggan dari database
//     final result = await DatabaseService.instance.getAllPelanggans();
//     setState(() {
//       Pelanggans = result;
//       filteredPelanggans = result;
//     });
//   }

//   void _filterPelanggans(String query) {
//     setState(() {
//       filteredPelanggans = Pelanggans.where((Pelanggan) {
//         final nameLower = Pelanggan_nama.toLowerCase();
//         final phoneLower = Pelanggan.phoneNumber?.toLowerCase() ?? '';
//         final searchLower = query.toLowerCase();
//         return nameLower.contains(searchLower) || 
//                phoneLower.contains(searchLower);
//       }).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pilih Pelanggan'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: 'Cari pelanggan...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onChanged: _filterPelanggans,
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: filteredPelanggans.length,
//               itemBuilder: (context, index) {
//                 final Pelanggan = filteredPelanggans[index];
//                 return ListTile(
//                   title: Text(Pelanggan.PelangganName),
//                   subtitle: Pelanggan.phoneNumber != null
//                       ? Text(Pelanggan.phoneNumber!)
//                       : null,
//                   onTap: () => Navigator.pop(context, Pelanggan),
//                   trailing: const Icon(Icons.chevron_right),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddPelangganDialog(),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   void _showAddPelangganDialog() {
//     final nameController = TextEditingController();
//     final phoneController = TextEditingController();
//     final addressController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Tambah Pelanggan Baru'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nama Pelanggan',
//                   hintText: 'Masukkan nama pelanggan'),
//                 ),
//               ),
//               icon: TextField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(
//                   labelText: 'Nomor Telepon',
//                   hintText: 'Masukkan nomor telepon'),
//                 ),
//               ),
//               TextField(
//                 controller: addressController,
//                 decoration: const InputDecoration(
//                   labelText: 'Alamat',
//                   hintText: 'Masukkan alamat'),
//                 ),
//                 maxLines: 2,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Batal'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (nameController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Nama pelanggan harus diisi'),
//                     ),
//                   );
//                   return;
//                 }

//                 final newPelanggan = Pelanggan(
//                   PelangganId: DateTime.now().millisecondsSinceEpoch,
//                   PelangganName: nameController.text,
//                   phoneNumber: phoneController.text.isNotEmpty
//                       ? phoneController.text
//                       : null,
//                   address: addressController.text.isNotEmpty
//                       ? addressController.text
//                       : null,
//                 );

//                 // Simpan ke database
//                 await DatabaseService.instance.insertPelanggan(newPelanggan);

//                 Navigator.pop(context);
//                 _loadPelanggans();
//               },
//               child: const Text('Simpan'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }