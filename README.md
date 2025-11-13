# My App Backend API

Backend Node.js/Express pour l'application Flutter My App.

## 🚀 Déploiement Rapide sur Railway

### 1. Prérequis
- Compte GitHub
- Compte Railway

### 2. Déploiement
1. **Pousser ce code sur GitHub**
2. **Aller sur [Railway.app](https://railway.app)**
3. **"New Project" → "Deploy from GitHub repo"**
4. **Sélectionner votre repository**
5. **Railway détectera automatiquement Node.js et déploiera**

### 3. Configuration
Railway créera automatiquement:
- ✅ **URL de déploiement** (ex: https://myapp.up.railway.app)
- ✅ **Base de données PostgreSQL**
- ✅ **Variables d'environnement**

### 4. Variables d'environnement
Railway ajoutera automatiquement:
- `DATABASE_URL` (PostgreSQL)
- `PORT` (géré automatiquement)

Vous devez ajouter manuellement:
- `JWT_SECRET` (une chaîne secrète complexe)

## 📚 API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion  
- `POST /api/auth/check-email` - Vérifier email
- `GET /api/auth/profile` - Profil utilisateur

### Catégories
- `GET /api/categories` - Liste catégories
- `POST /api/categories` - Créer catégorie
- `PUT /api/categories/:id` - Modifier catégorie
- `DELETE /api/categories/:id` - Supprimer catégorie

### Produits
- `GET /api/products` - Liste produits
- `POST /api/products` - Créer produit
- `PUT /api/products/:id` - Modifier produit
- `DELETE /api/products/:id` - Supprimer produit

## 🔧 Développement Local

```bash
# Installation
npm install

# Démarrage
npm run dev

# L'API sera sur http://localhost:5000