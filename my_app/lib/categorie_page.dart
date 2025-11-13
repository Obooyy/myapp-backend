import 'package:flutter/material.dart';
import 'database_helper.dart';

class CategoriePage extends StatefulWidget {
  const CategoriePage({super.key});

  @override
  State<CategoriePage> createState() => _CategoriePageState();
}

class _CategoriePageState extends State<CategoriePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _databaseHelper.getCategories();
      setState(() {
        categories = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  Future<void> _deleteCategory(int index) async {
    final category = categories[index];
    final categoryId = category['id'] as int;

    if (categories.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous devez avoir au moins 1 catégorie'), backgroundColor: Colors.red));
      return;
    }

    try {
      await _databaseHelper.deleteCategory(categoryId);
      await _loadCategories();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Catégorie supprimée avec succès'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  void _editCategory(int index) {
    _showAddEditCategoryDialog(category: categories[index], index: index);
  }

  Future<void> _addCategory() async {
    final count = await _databaseHelper.getCategoriesCount();
    if (count >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 2 catégories atteint'), backgroundColor: Colors.red));
      return;
    }
    _showAddEditCategoryDialog();
  }

  Future<void> _showAddEditCategoryDialog({Map<String, dynamic>? category, int? index}) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    if (category != null) {
      titleController.text = category['title'];
      descController.text = category['description'];
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category == null ? 'Ajouter une catégorie' : 'Modifier la catégorie', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre de la catégorie', labelStyle: TextStyle(color: Color(0xFF718096)),
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
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), style: TextButton.styleFrom(foregroundColor: const Color(0xFF718096)), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                  try {
                    if (category == null) {
                      await _databaseHelper.insertCategory({
                        'title': titleController.text,
                        'description': descController.text,
                      });
                    } else {
                      await _databaseHelper.updateCategory(category['id'], {
                        'title': titleController.text,
                        'description': descController.text,
                      });
                    }
                    Navigator.of(context).pop();
                    await _loadCategories();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(category == null ? 'Catégorie ajoutée avec succès' : 'Catégorie modifiée avec succès'),
                      backgroundColor: Colors.green,
                    ));
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4299E1)),
              child: Text(category == null ? 'Ajouter' : 'Modifier'),
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
        title: const Text('Catégories', style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Mes catégories', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF4299E1).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('${categories.length}/2 catégories', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4299E1))),
            ),
          ]),
          const SizedBox(height: 20),
          _isLoading 
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) => _buildCategoryCard(categories[index], index),
                )),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory, backgroundColor: const Color(0xFF4299E1),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(category['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF718096)),
                onSelected: (String value) {
                  if (value == 'edit') _editCategory(index);
                  else if (value == 'delete') _deleteCategory(index);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Color(0xFF4299E1), size: 20), SizedBox(width: 8), Text('Modifier')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Supprimer')])),
                ],
              ),
            ]),
            const SizedBox(height: 8),
            Text(category['description'], style: const TextStyle(fontSize: 14, color: Color(0xFF718096)), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}