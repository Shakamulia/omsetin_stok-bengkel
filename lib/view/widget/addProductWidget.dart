import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:omsetin_stok/services/database_service.dart';

class AddCategoryWidget extends StatefulWidget {
  final Function onCategoryAdded;

  const AddCategoryWidget({super.key, required this.onCategoryAdded});

  @override
  _AddCategoryWidgetState createState() => _AddCategoryWidgetState();
}

class _AddCategoryWidgetState extends State<AddCategoryWidget> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();
  late bool success = false;

  Future<void> _addCategory() async {
    final categoryName = _categoryController.text;
    if (categoryName.isNotEmpty) {
      await _databaseService.addCategory(
          categoryName, DateTime.now().toIso8601String());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Kategori berhasil ditambahkan! $categoryName")));
      success = true;
      print("Berhasil menambahkan kategori $categoryName");

      // Fetch categories again to update the list
      widget.onCategoryAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Nama Kategori Tidak Boleh Kosong")));
      success = false;
    }

    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _categoryController,
          focusNode: _categoryFocusNode,
          decoration: InputDecoration(
            labelText: 'Kategori',
            hintText: 'Nama Kategori',
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const Gap(5),
        ElevatedButton(
          onPressed: _addCategory,
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white),
          child: const Center(
            child: Text("SIMPAN"),
          ),
        ),
      ],
    );
  }
}
