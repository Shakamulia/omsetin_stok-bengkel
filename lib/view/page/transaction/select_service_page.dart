import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/services/database_service.dart';

class SelectServicePage extends StatefulWidget {
  final List<Service> selectedServices;

  const SelectServicePage({
    super.key,
    required this.selectedServices,
  });

  @override
  _SelectServicePageState createState() => _SelectServicePageState();
}

class _SelectServicePageState extends State<SelectServicePage> {
  List<Service> services = [];
  List<Service> filteredServices = [];
  final TextEditingController searchController = TextEditingController();
  final List<Service> _tempSelectedServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _tempSelectedServices.addAll(widget.selectedServices);
  }

  Future<void> _loadServices() async {
    final db = DatabaseService.instance;
    final result = await db.getServices();
    setState(() {
      services = result;
      filteredServices = result;
    });
  }

  void _filterServices(String query) {
    setState(() {
      filteredServices = services.where((service) {
        final nameLower = service.serviceName.toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    });
  }

  bool _isServiceSelected(int? serviceId) {
    if (serviceId == null) return false;
    return _tempSelectedServices.any((s) => s.serviceId == serviceId);
  }

  void _toggleServiceSelection(Service service) {
    setState(() {
      if (_isServiceSelected(service.serviceId)) {
        _tempSelectedServices
            .removeWhere((s) => s.serviceId == service.serviceId);
      } else {
        _tempSelectedServices.add(service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Layanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _tempSelectedServices);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari layanan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterServices,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return CheckboxListTile(
                  title: Text(service.serviceName),
                  subtitle: Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(service.servicePrice),
                  ),
                  value: _isServiceSelected(service.serviceId),
                  onChanged: (bool? value) {
                    _toggleServiceSelection(service);
                  },
                  secondary: const Icon(Icons.medical_services),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
