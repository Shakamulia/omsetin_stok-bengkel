// Database Helper Class
import 'package:omsetin_stok/model/mekanik.dart';
import 'package:omsetin_stok/model/pelanggan.dart';
import 'package:omsetin_stok/model/product.dart';
import 'package:omsetin_stok/model/service.dart';
import 'package:omsetin_stok/model/spare_part.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:omsetin_stok/services/database_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  final DatabaseService dbService = DatabaseService.instance;

  // Add this getter to expose the instance
  static DatabaseHelper get instance => _instance;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();
  
// Spare Part Table
final String _sparePartTable = 'spare_part';
final String _sparePartId = 'id';
final String _sparePartImage = 'image';
final String _sparePartName = 'name';
final String _sparePartBarcode = 'barcode';
final String _sparePartBarcodeType = 'barcodeType';
final String _sparePartStock = 'stock';
final String _sparePartUnit = 'unit';
final String _sparePartSold = 'sold';
final String _sparePartPurchasePrice = 'purchasePrice';
final String _sparePartSellPrice = 'sellPrice';
final String _sparePartDateAdded = 'dateAdded';


// Untuk Service
Future<int> insertService(Service service) async {
  final db = await dbService.database;
  return await db.insert('services', service.toMap());
}

Future<List<Service>> getAllServices() async {
  final db = await dbService.database;
  final List<Map<String, dynamic>> maps = await db.query('services');
  return List.generate(maps.length, (i) {
    return Service.fromMap(maps[i]);
  });
}

// Untuk SparePart
Future<int> insertSparePart(Product product) async {
  final db = await dbService.database;
  return await db.insert('products', product.toMap());
}

Future<List<SparePart>> getAllSpareParts() async {
  final db = await dbService.database;
  final List<Map<String, dynamic>> maps = await db.query('products');
  return List.generate(maps.length, (i) {
    return SparePart.fromJson(maps[i]);
  });
}

  Future<int> createService(Pelanggan pelanggan) async {
    final db = await DatabaseService.instance.database;
    return await db.insert('pelanggan', pelanggan.toMap());
  }

  // Tabel Pelanggan

  // CRUD Operations untuk Pelanggan
  Future<int> insertPelanggan(Pelanggan pelanggan) async {
    final db = await DatabaseService.instance.database;
    return await db.insert('pelanggan', pelanggan.toMap());
  }

  Future<List<Pelanggan>> getAllPelanggan() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('pelanggan');

    return List.generate(maps.length, (i) {
      return Pelanggan.fromMap(maps[i]);
    });
  }

  Future<Pelanggan?> getPelangganById(int id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Pelanggan.fromMap(maps.first);
    }
    return null;
  }

  Future<Pelanggan?> getPelangganByKode(String kode) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pelanggan',
      where: 'kode = ?',
      whereArgs: [kode],
    );

    if (maps.isNotEmpty) {
      return Pelanggan.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePelanggan(Pelanggan pelanggan) async {
    final db = await DatabaseService.instance.database;
    return await db.update(
      'pelanggan',
      pelanggan.toMap(),
      where: 'id = ?',
      whereArgs: [pelanggan.id],
    );
  }

  Future<int> deletePelanggan(int id) async {
    final db = await DatabaseService.instance.database;
    return await db.delete(
      'pelanggan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations untuk Mekanik
  Future<int> insertMekanik(Mekanik mekanik) async {
    final db = await DatabaseService.instance.database;
    return await db.insert('mekanik', mekanik.toMap());
  }

  Future<List<Mekanik>> getAllMekanik() async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('mekanik');

    return List.generate(maps.length, (i) {
      return Mekanik.fromMap(maps[i]);
    });
  }

  Future<Mekanik?> getMekanikById(int id) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mekanik',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Mekanik.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Mekanik>> getMekanikBySpesialis(String spesialis) async {
    final db = await DatabaseService.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mekanik',
      where: 'spesialis = ?',
      whereArgs: [spesialis],
    );

    return List.generate(maps.length, (i) {
      return Mekanik.fromMap(maps[i]);
    });
  }

  Future<int> updateMekanik(Mekanik mekanik) async {
    final db = await DatabaseService.instance.database;
    return await db.update(
      'mekanik',
      mekanik.toMap(),
      where: 'id = ?',
      whereArgs: [mekanik.id],
    );
  }

  Future<int> deleteMekanik(int id) async {
    final db = await DatabaseService.instance.database;
    return await db.delete(
      'mekanik',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //* SPARE PART SECTION
Future<void> addSparePart(
  String image,
  String name,
  String barcode,
  String barcodeType,
  int stock,
  String unit,
  int sold,
  int purchasePrice,
  int sellPrice,
  String dateAdded,
) async {
  final db = await DatabaseService.instance.database;
  await db.insert(_sparePartTable, {
    _sparePartName: name,
    _sparePartImage: image,
    _sparePartBarcode: barcode,
    _sparePartBarcodeType: barcodeType,
    _sparePartStock: stock,
    _sparePartUnit: unit,
    _sparePartSold: sold,
    _sparePartPurchasePrice: purchasePrice,
    _sparePartSellPrice: sellPrice,
    _sparePartDateAdded: dateAdded,
  });
}

Future<List<SparePart>> getSpareParts() async {
  final db = await DatabaseService.instance.database;
  final data = await db.query(_sparePartTable);
  return data.map((e) => SparePart.fromJson(e)).toList();
}

Future<void> updateSparePart(SparePart sparePart) async {
  final db = await DatabaseService.instance.database;
  if (sparePart.sparePartId == null) {
    throw Exception('SparePart ID cannot be null for update');
  }
  await db.update(
    _sparePartTable,
    sparePart.toJson(),
    where: '$_sparePartId = ?',
    whereArgs: [sparePart.sparePartId],
  );
}

Future<void> deleteSparePart(int sparePartId) async {
  final db = await DatabaseService.instance.database;
  await db.delete(
    _sparePartTable,
    where: '$_sparePartId = ?',
    whereArgs: [sparePartId],
  );
}

  // Close database
  Future<void> close() async {
    final db = await DatabaseService.instance.database;
    db.close();
  }
}