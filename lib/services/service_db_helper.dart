// lib/services/service_database_helper.dart
import 'package:omzetin_bengkel/model/services.dart';
import 'package:omzetin_bengkel/services/database_service.dart';

class ServiceDatabaseHelper {
  static const String _tableName = 'services';

  Future<int> createService(Service service) async {
    final db = await DatabaseService.instance.database;
    return await db.insert(_tableName, service.toJson());
  }

  Future<List<Service>> getServices() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return maps.map((map) => Service.fromJson(map)).toList();
  }

  Future<int> updateService(Service service) async {
    final db = await DatabaseService.instance.database;
    return await db.update(
      _tableName,
      service.toJson(),
      where: 'service_id = ?',
      whereArgs: [service.serviceId],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await DatabaseService.instance.database;
    return await db.delete(
      _tableName,
      where: 'service_id = ?',
      whereArgs: [id],
    );
  }

  void testServices() async {
    final db = await DatabaseService.instance.database;
    await db.insert('services', {
      'service_name': 'Test Service',
      'service_price': 10000,
      'service_date_added': DateTime.now().toString(),
    });
    final services = await db.query('services');
    print(services); // Should show inserted service
  }
}
