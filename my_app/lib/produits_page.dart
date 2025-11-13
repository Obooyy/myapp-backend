import 'package:flutter/material.dart';
import 'database_helper.dart';

class ProduitsPage extends StatefulWidget {
  const ProduitsPage({super.key});

  @override
  State<ProduitsPage> createState() => _ProduitsPageState();
}

class _ProduitsPageState extends State<ProduitsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> produits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _databaseHelper.getProducts();
      setState(() {
        produits = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteProduct(int index) async {
    final product = produits[index];
    final productId = product['id'] as int;

    if (produits.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez avoir au moins 1 produit'), backgroundColor: Colors.red));
      return;
    }

    try {
      await _databaseHelper.deleteProduct(productId);
      await _loadProducts();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit supprimé avec succès'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  void _editProduct(int index) {
    _showAddEditProductDialog(product: produits[index], index: index);
  }

  Future<void> _addProduct() async {
    final count = await _databaseHelper.getProductsCount();
    if (count >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 10 produits atteint'), backgroundColor: Colors.red));
      return;
    }
    _showAddEditProductDialog();
  }

  Future<void> _showAddEditProductDialog({Map<String, dynamic>? product, int? index}) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final categories = await _databaseHelper.getCategoriesForDropdown();
    String? selectedCategoryId;

    if (product != null) {
      titleController.text = product['title'];
      descController.text = product['description'];
      selectedCategoryId = product['category_id']?.toString();
    } else {
      selectedCategoryId = categories.isNotEmpty ? categories.first['id'].toString() : null;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Ajouter un produit' : 'Modifier le produit', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre du produit', labelStyle: TextStyle(color: Color(0xFF718096)),
                border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4299E1))),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descController, maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description', labelStyle: TextStyle(color: Color(0xFF718096)),
                border: OutlineInputBorder(), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4299E1))),
              ),
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 15), const Text('Catégorie:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(5)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategoryId, isExpanded: true,
                    items: categories.map((category) => DropdownMenuItem<String>(
                      value: category['id'].toString(), child: Text(category['title']),
                    )).toList(),
                    onChanged: (String? newValue) { selectedCategoryId = newValue; },
                  ),
                ),
              ),
            ],
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: const Color(0xFF718096)), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                  try {
                    if (product == null) {
                      await _databaseHelper.insertProduct({
                        'title': titleController.text,
                        'description': descController.text,
                        'category_id': selectedCategoryId != null ? int.parse(selectedCategoryId!) : null,
                      });
                    } else {
                      await _databaseHelper.updateProduct(product['id'], {
                        'title': titleController.text,
                        'description': descController.text,
                        'category_id': selectedCategoryId != null ? int.parse(selectedCategoryId!) : null,
                      });
                    }
                    Navigator.of(context).pop();
                    await _loadProducts();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(product == null ? 'Produit ajouté avec succès' : 'Produit modifié avec succès'),
                      backgroundColor: Colors.green,
                    ));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4299E1)),
              child: Text(product == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)), onPressed: () => Navigator.pop(context)),
        title: const Text('Produits', style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Mes produits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF4299E1).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${produits.length}/10 produits', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4299E1))),
            ),
          ]),
          const SizedBox(height: 20),
          _isLoading 
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(child: ListView.builder(
                  itemCount: produits.length,
                  itemBuilder: (context, index) => _buildProductCard(produits[index], index),
                )),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct, backgroundColor: const Color(0xFF4299E1),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(product['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF718096)),
                onSelected: (String value) {
                  if (value == 'edit') _editProduct(index);
                  else if (value == 'delete') _deleteProduct(index);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Color(0xFF4299E1), size: 20), SizedBox(width: 8), Text('Modifier')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Supprimer')])),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            Text(product['description'], style: const TextStyle(fontSize: 14, color: Color(0xFF718096)), maxLines: 2, overflow: TextOverflow.ellipsis),
            if (product['category_name'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF4299E1).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('Catégorie: ${product['category_name']}', style: const TextStyle(fontSize: 12, color: Color(0xFF4299E1))),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}