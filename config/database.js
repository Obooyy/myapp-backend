const { Pool } = require('pg');

// Script SQL pour créer les tables
const initDatabase = async (pool) => {
  try {
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

    // Table categories
    await pool.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

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

    // Insérer des données de test
    const userCount = await pool.query('SELECT COUNT(*) FROM users');
    if (parseInt(userCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO users (nom, prenom, email, telephone, password) 
        VALUES ('Admin', 'User', 'admin@myapp.com', '+2250102030405', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi') -- password
      `);
    }

    const categoryCount = await pool.query('SELECT COUNT(*) FROM categories');
    if (parseInt(categoryCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO categories (title, description) VALUES 
        ('Électronique', 'Smartphones, ordinateurs, accessoires tech'),
        ('Vêtements', 'Habits pour hommes, femmes et enfants')
      `);
    }

    const productCount = await pool.query('SELECT COUNT(*) FROM products');
    if (parseInt(productCount.rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO products (title, description, category_id) VALUES 
        ('iPhone 14 Pro', 'Smartphone Apple 128GB avec écran Dynamic Island', 1),
        ('T-shirt Blanc', 'T-shirt coton 100% qualité premium, toutes tailles', 2)
      `);
    }

    console.log('✅ Base de données initialisée avec succès');
  } catch (error) {
    console.error('❌ Erreur lors de l initialisation de la base de données:', error);
    throw error;
  }
};

module.exports = { initDatabase };