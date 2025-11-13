const express = require('express');
const { 
  validateCategory, 
  handleValidationErrors 
} = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

const categoryRoutes = (pool) => {
  const router = express.Router();
  const categoryController = require('../controllers/categoryController')(pool);

  // Toutes les routes sont protégées
  router.use(authenticateToken);

  router.get('/', categoryController.getAllCategories);
  router.get('/count', categoryController.getCategoriesCount);
  router.get('/:id', categoryController.getCategory);
  router.post('/', validateCategory, handleValidationErrors, categoryController.createCategory);
  router.put('/:id', validateCategory, handleValidationErrors, categoryController.updateCategory);
  router.delete('/:id', categoryController.deleteCategory);

  return router;
};

module.exports = categoryRoutes;