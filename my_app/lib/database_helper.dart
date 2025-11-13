import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    // Initialiser sqflite si nécessaire
    await _initializeSqflite();
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> _initializeSqflite() async {
    // Force l'initialisation de sqflite
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'myapp_database.db');
    
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        // Activer les clés étrangères
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        telephone TEXT,
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    await db.insert('categories', {
      'title': 'Électronique',
      'description': 'Smartphones, ordinateurs, accessoires tech'
    });
    await db.insert('categories', {
      'title': 'Vêtements', 
      'description': 'Habits pour hommes, femmes et enfants'
    });

    await db.insert('users', {
      'nom': 'Admin',
      'prenom': 'User',
      'email': 'admin@example.com',
      'telephone': '0102030405',
      'password': 'password123'
    });

    await db.insert('products', {
      'title': 'iPhone 14 Pro',
      'description': 'Smartphone Apple 128GB avec écran Dynamic Island',
      'category_id': 1
    });
    await db.insert('products', {
      'title': 'T-shirt Blanc',
      'description': 'T-shirt coton 100% qualité premium, toutes tailles',
      'category_id': 2
    });
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL,
          prenom TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          telephone TEXT,
          password TEXT NOT NULL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      await db.insert('users', {
        'nom': 'Admin',
        'prenom': 'User',
        'email': 'admin@example.com',
        'telephone': '0102030405',
        'password': 'password123'
      });
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS products_new(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category_id INTEGER,
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
        )
      ''');
      
      final oldProducts = await db.query('products');
      for (var product in oldProducts) {
        await db.insert('products_new', product);
      }
      
      await db.execute('DROP TABLE products');
      await db.execute('ALTER TABLE products_new RENAME TO products');
    }
  }

  // === OPERATIONS UTILISATEURS ===
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await database;
    if (user['telephone'] != null) {
      user['telephone'] = (user['telephone'] as String).replaceAll(RegExp(r'[^0-9]'), '');
    }
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // === OPERATIONS CATEGORIES ===
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories', orderBy: 'id');
  }

  Future<int> getCategoriesCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM categories')
    ) ?? 0;
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update(
      'categories', 
      category, 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    final productsCount = await db.rawQuery(
      'SELECT COUNT(*) FROM products WHERE category_id = ?',
      [id]
    );
    final count = Sqflite.firstIntValue(productsCount) ?? 0;
    if (count > 0) {
      throw Exception('Impossible de supprimer : $count produit(s) utilisent cette catégorie');
    }
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // === OPERATIONS PRODUITS ===
  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, c.title as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      ORDER BY p.id DESC
    ''');
  }

  Future<int> getProductsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products')
    ) ?? 0;
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return await db.insert('products', product);
  }

  Future<int> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    return await db.update('products', product, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getCategoriesForDropdown() async {
    final db = await database;
    return await db.query('categories', columns: ['id', 'title']);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}