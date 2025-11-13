const User = require('../models/User');

const authController = (pool) => {
  const userModel = new User(pool);

  const register = async (req, res) => {
    try {
      const { nom, prenom, email, telephone, password } = req.body;

      // Vérifier si l'email existe déjà
      const emailExists = await userModel.emailExists(email);
      if (emailExists) {
        return res.status(400).json({ error: 'Cet email est déjà utilisé' });
      }

      // Créer l'utilisateur
      const user = await userModel.create({
        nom,
        prenom,
        email,
        telephone,
        password
      });

      // Générer le token JWT
      const token = userModel.generateToken(user.id);

      res.status(201).json({
        message: 'Utilisateur créé avec succès',
        token,
        user: {
          id: user.id,
          nom: user.nom,
          prenom: user.prenom,
          email: user.email,
          telephone: user.telephone,
          created_at: user.created_at
        }
      });
    } catch (error) {
      console.error('Erreur inscription:', error);
      res.status(500).json({ error: 'Erreur lors de l inscription' });
    }
  };

  const login = async (req, res) => {
    try {
      const { email, password } = req.body;

      // Trouver l'utilisateur par email
      const user = await userModel.findByEmail(email);
      if (!user) {
        return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
      }

      // Vérifier le mot de passe
      const isPasswordValid = await userModel.checkPassword(password, user.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
      }

      // Générer le token JWT
      const token = userModel.generateToken(user.id);

      res.json({
        message: 'Connexion réussie',
        token,
        user: {
          id: user.id,
          nom: user.nom,
          prenom: user.prenom,
          email: user.email,
          telephone: user.telephone,
          created_at: user.created_at
        }
      });
    } catch (error) {
      console.error('Erreur connexion:', error);
      res.status(500).json({ error: 'Erreur lors de la connexion' });
    }
  };

  const checkEmail = async (req, res) => {
    try {
      const { email } = req.body;
      const exists = await userModel.emailExists(email);
      res.json({ exists });
    } catch (error) {
      console.error('Erreur vérification email:', error);
      res.status(500).json({ error: 'Erreur lors de la vérification' });
    }
  };

  const getProfile = async (req, res) => {
    try {
      const user = await userModel.findById(req.user.userId);
      if (!user) {
        return res.status(404).json({ error: 'Utilisateur non trouvé' });
      }
      res.json({ user });
    } catch (error) {
      console.error('Erreur profil:', error);
      res.status(500).json({ error: 'Erreur lors de la récupération du profil' });
    }
  };

  return {
    register,
    login,
    checkEmail,
    getProfile
  };
};

module.exports = authController;