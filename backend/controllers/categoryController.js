const Category = require('../models/Category');

const categoryController = (pool) => {
  const categoryModel = new Category(pool);

  const getAllCategories = async (req, res) => {
    try {
      const categories = await categoryModel.findAll();
      res.json({ 
        success: true,
        data: categories 
      });
    } catch (error) {
      console.error('Erreur récupération catégories:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération des catégories' });
    }
  };

  const getCategory = async (req, res) => {
    try {
      const { id } = req.params;
      const category = await categoryModel.findById(id);
      
      if (!category) {
        return res.status(404).json({ error: 'Catégorie non trouvée' });
      }
      
      res.json({ 
        success: true,
        data: category 
      });
    } catch (error) {
      console.error('Erreur récupération catégorie:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération de la catégorie' });
    }
  };

  const createCategory = async (req, res) => {
    try {
      const category = await categoryModel.create(req.body);
      res.status(201).json({ 
        success: true,
        message: 'Catégorie créée avec succès',
        data: category 
      });
    } catch (error) {
      console.error('Erreur création catégorie:', error);
      res.status(500).json({ error: 'Erreur lors de la création de la catégorie' });
    }
  };

  const updateCategory = async (req, res) => {
    try {
      const { id } = req.params;
      const category = await categoryModel.update(id, req.body);
      
      if (!category) {
        return res.status(404).json({ error: 'Catégorie non trouvée' });
      }
      
      res.json({ 
        success: true,
        message: 'Catégorie mise à jour avec succès',
        data: category 
      });
    } catch (error) {
      console.error('Erreur mise à jour catégorie:', error);
      res.status(500).json({ error: 'Erreur lors de la mise à jour de la catégorie' });
    }
  };

  const deleteCategory = async (req, res) => {
    try {
      const { id } = req.params;
      
      // Vérifier s'il reste au moins 1 catégorie
      const count = await categoryModel.count();
      if (count <= 1) {
        return res.status(400).json({ 
          error: 'Impossible de supprimer : vous devez avoir au moins 1 catégorie' 
        });
      }

      const category = await categoryModel.delete(id);
      
      if (!category) {
        return res.status(404).json({ error: 'Catégorie non trouvée' });
      }
      
      res.json({ 
        success: true,
        message: 'Catégorie supprimée avec succès',
        data: category 
      });
    } catch (error) {
      console.error('Erreur suppression catégorie:', error);
      
      if (error.message.includes('des produits utilisent cette catégorie')) {
        return res.status(400).json({ error: error.message });
      }
      
      res.status(500).json({ error: 'Erreur lors de la suppression de la catégorie' });
    }
  };

  const getCategoriesCount = async (req, res) => {
    try {
      const count = await categoryModel.count();
      res.json({ count });
    } catch (error) {
      console.error('Erreur comptage catégories:', error);
      res.status(500).json({ error: 'Erreur lors du comptage des catégories' });
    }
  };

  return {
    getAllCategories,
    getCategory,
    createCategory,
    updateCategory,
    deleteCategory,
    getCategoriesCount
  };
};

module.exports = categoryController;