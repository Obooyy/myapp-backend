const express = require('express');
const { 
  validateRegister, 
  validateLogin, 
  handleValidationErrors 
} = require('../middleware/validation');
const { authenticateToken } = require('../middleware/auth');

const authRoutes = (pool) => {
  const router = express.Router();
  const authController = require('../controllers/authController')(pool);

  // Public routes
  router.post('/register', validateRegister, handleValidationErrors, authController.register);
  router.post('/login', validateLogin, handleValidationErrors, authController.login);
  router.post('/check-email', authController.checkEmail);

  // Protected routes
  router.get('/profile', authenticateToken, authController.getProfile);

  return router;
};

module.exports = authRoutes;