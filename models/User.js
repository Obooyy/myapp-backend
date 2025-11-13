const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class User {
  constructor(pool) {
    this.pool = pool;
  }

  async create(userData) {
    const { nom, prenom, email, telephone, password } = userData;
    
    // Hacher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);
    
    const result = await this.pool.query(
      `INSERT INTO users (nom, prenom, email, telephone, password) 
       VALUES ($1, $2, $3, $4, $5) RETURNING id, nom, prenom, email, telephone, created_at`,
      [nom, prenom, email, telephone, hashedPassword]
    );
    
    return result.rows[0];
  }

  async findByEmail(email) {
    const result = await this.pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );
    return result.rows[0];
  }

  async findById(id) {
    const result = await this.pool.query(
      'SELECT id, nom, prenom, email, telephone, created_at FROM users WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  async checkPassword(plainPassword, hashedPassword) {
    return await bcrypt.compare(plainPassword, hashedPassword);
  }

  generateToken(userId) {
    return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
  }

  async emailExists(email) {
    const result = await this.pool.query(
      'SELECT COUNT(*) FROM users WHERE email = $1',
      [email]
    );
    return parseInt(result.rows[0].count) > 0;
  }
}

module.exports = User;