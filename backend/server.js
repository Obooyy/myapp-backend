const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { Pool } = require('pg');

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

// Test de la connexion à la base de données
pool.connect((err, client, release) => {
  if (err) {
    console.error('Erreur de connexion à la base de données:', err.stack);
  } else {
    console.log('✅ Connexion à PostgreSQL réussie');
    release();
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