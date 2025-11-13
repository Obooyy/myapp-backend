const { body, validationResult } = require('express-validator');

// Validation pour l'inscription
const validateRegister = [
  body('nom').notEmpty().withMessage('Le nom est requis'),
  body('prenom').notEmpty().withMessage('Le prénom est requis'),
  body('email').isEmail().withMessage('Email invalide'),
  body('password').isLength({ min: 6 }).withMessage('Le mot de passe doit contenir au moins 6 caractères'),
  body('telephone').optional().isLength({ min: 8 }).withMessage('Numéro de téléphone invalide')
];

// Validation pour la connexion
const validateLogin = [
  body('email').isEmail().withMessage('Email invalide'),
  body('password').notEmpty().withMessage('Le mot de passe est requis')
];

// Validation pour les catégories
const validateCategory = [
  body('title').notEmpty().withMessage('Le titre est requis'),
  body('description').notEmpty().withMessage('La description est requise')
];

// Validation pour les produits
const validateProduct = [
  body('title').notEmpty().withMessage('Le titre est requis'),
  body('description').notEmpty().withMessage('La description est requise'),
  body('category_id').optional().isInt().withMessage('ID de catégorie invalide')
];

// Middleware de vérification des erreurs
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ 
      error: 'Données invalides', 
      details: errors.array() 
    });
  }
  next();
};

module.exports = {
  validateRegister,
  validateLogin,
  validateCategory,
  validateProduct,
  handleValidationErrors
};