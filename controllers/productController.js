const Product = require('../models/Product');

const productController = (pool) => {
  const productModel = new Product(pool);

  const getAllProducts = async (req, res) => {
    try {
      const products = await productModel.findAll();
      res.json({ 
        success: true,
        data: products 
      });
    } catch (error) {
      console.error('Erreur récupération produits:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération des produits' });
    }
  };

  const getProduct = async (req, res) => {
    try {
      const { id } = req.params;
      const product = await productModel.findById(id);
      
      if (!product) {
        return res.status(404).json({ error: 'Produit non trouvé' });
      }
      
      res.json({ 
        success: true,
        data: product 
      });
    } catch (error) {
      console.error('Erreur récupération produit:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération du produit' });
    }
  };

  const createProduct = async (req, res) => {
    try {
      const product = await productModel.create(req.body);
      res.status(201).json({ 
        success: true,
        message: 'Produit créé avec succès',
        data: product 
      });
    } catch (error) {
      console.error('Erreur création produit:', error);
      res.status(500).json({ error: 'Erreur lors de la création du produit' });
    }
  };

  const updateProduct = async (req, res) => {
    try {
      const { id } = req.params;
      const product = await productModel.update(id, req.body);
      
      if (!product) {
        return res.status(404).json({ error: 'Produit non trouvé' });
      }
      
      res.json({ 
        success: true,
        message: 'Produit mis à jour avec succès',
        data: product 
      });
    } catch (error) {
      console.error('Erreur mise à jour produit:', error);
      res.status(500).json({ error: 'Erreur lors de la mise à jour du produit' });
    }
  };

  const deleteProduct = async (req, res) => {
    try {
      const { id } = req.params;
      
      // Vérifier s'il reste au moins 1 produit
      const count = await productModel.count();
      if (count <= 1) {
        return res.status(400).json({ 
          error: 'Impossible de supprimer : vous devez avoir au moins 1 produit' 
        });
      }

      const product = await productModel.delete(id);
      
      if (!product) {
        return res.status(404).json({ error: 'Produit non trouvé' });
      }
      
      res.json({ 
        success: true,
        message: 'Produit supprimé avec succès',
        data: product 
      });
    } catch (error) {
      console.error('Erreur suppression produit:', error);
      res.status(500).json({ error: 'Erreur lors de la suppression du produit' });
    }
  };

  const getProductsCount = async (req, res) => {
    try {
      const count = await productModel.count();
      res.json({ count });
    } catch (error) {
      console.error('Erreur comptage produits:', error);
      res.status(500).json({ error: 'Erreur lors du comptage des produits' });
    }
  };

  const getCategoriesForDropdown = async (req, res) => {
    try {
      const categories = await productModel.getCategoriesForDropdown();
      res.json({ 
        success: true,
        data: categories 
      });
    } catch (error) {
      console.error('Erreur récupération catégories dropdown:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération des catégories' });
    }
  };

  return {
    getAllProducts,
    getProduct,
    createProduct,
    updateProduct,
    deleteProduct,
    getProductsCount,
    getCategoriesForDropdown
  };
};

module.exports = productController;