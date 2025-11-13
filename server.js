const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');

// Charger les variables d'environnement
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Configuration de la base de données
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// === INITIALISATION BASE DE DONNÉES ===
const initDatabase = async () => {
  try {
    console.log('🔄 Initialisation des tables...');
    
    // Table users
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        nom VARCHAR(100) NOT NULL,
        prenom VARCHAR(100) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        telephone VARCHAR(20),
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Table users créée');

    // Table categories
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Table categories créée');

    // Table products
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Table products créée');

    // Données de test - Users
    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    if (parseInt(userCount.rows[0].count) === 0) {
      const hashedPassword = await bcrypt.hash('password123', 10);
      await pool.query(
        'INSERT INTO users (nom, prenom, email, telephone, password) VALUES ($1, $2, $3, $4, $5)',
        ['Admin', 'User', 'admin@myapp.com', '+2250102030405', hashedPassword]
      );
      console.log('✅ Utilisateur admin créé');
    }

    // Données de test - Categories
    const categoryCount = await pool.query('SELECT COUNT(*) FROM categories');
    if (parseInt(categoryCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO categories (title, description) VALUES 
        ('Électronique', 'Smartphones, ordinateurs, accessoires tech'),
        ('Vêtements', 'Habits pour hommes, femmes et enfants')
      `);
      console.log('✅ Catégories de test créées');
    }

    // Données de test - Products
    const productCount = await pool.query('SELECT COUNT(*) FROM products');
    if (parseInt(productCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO products (title, description, category_id) VALUES 
        ('iPhone 14 Pro', 'Smartphone Apple 128GB avec écran Dynamic Island', 1),
        ('T-shirt Blanc', 'T-shirt coton 100% qualité premium, toutes tailles', 2)
      `);
      console.log('✅ Produits de test créés');
    }

    console.log('🎉 Base de données initialisée avec succès!');
  } catch (error) {
    console.error('❌ Erreur initialisation BDD:', error);
  }
};

// Test de la connexion à la base de données
pool.connect((err, client, release) => {
  if (err) {
    console.error('Erreur de connexion à la base de données:', err.stack);
  } else {
    console.log('✅ Connexion à PostgreSQL réussie');
    release();
    
    // Lancer l'initialisation après la connexion
    initDatabase();
  }
});

// Routes
app.use('/api/auth', require('./routes/auth')(pool));
app.use('/api/categories', require('./routes/categories')(pool));
app.use('/api/products', require('./routes/products')(pool));

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ 
    message: '🚀 API My App est en ligne!', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Route 404
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion des erreurs globales
app.use((err, req, res, next) => {
  console.error('Erreur:', err.stack);
  res.status(500).json({ error: 'Erreur interne du serveur' });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log(`🎉 Serveur démarré sur le port ${PORT}`);
  console.log(`📍 Environnement: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 URL: http://localhost:${PORT}`);
});