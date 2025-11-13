const express = require('express');
const { 
  validateProduct, 
  handleValidationErrors 
} = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

const productRoutes = (pool) => {
  const router = express.Router();
  const productController = require('../controllers/productController')(pool);

  // Toutes les routes sont protégées
  router.use(authenticateToken);

  router.get('/', productController.getAllProducts);
  router.get('/count', productController.getProductsCount);
  router.get('/categories-dropdown', productController.getCategoriesForDropdown);
  router.get('/:id', productController.getProduct);
  router.post('/', validateProduct, handleValidationErrors, productController.createProduct);
  router.put('/:id', validateProduct, handleValidationErrors, productController.updateProduct);
  router.delete('/:id', productController.deleteProduct);

  return router;
};

module.exports = productRoutes;