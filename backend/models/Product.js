class Product {
  constructor(pool) {
    this.pool = pool;
  }

  async findAll() {
    const result = await this.pool.query(`
      SELECT p.*, c.title as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      ORDER BY p.created_at DESC
    `);
    return result.rows;
  }

  async findById(id) {
    const result = await this.pool.query(`
      SELECT p.*, c.title as category_name 
      FROM products p 
      LEFT JOIN categories c ON p.category_id = c.id 
      WHERE p.id = $1
    `, [id]);
    return result.rows[0];
  }

  async create(productData) {
    const { title, description, category_id } = productData;
    const result = await this.pool.query(
      'INSERT INTO products (title, description, category_id) VALUES ($1, $2, $3) RETURNING *',
      [title, description, category_id]
    );
    return result.rows[0];
  }

  async update(id, productData) {
    const { title, description, category_id } = productData;
    const result = await this.pool.query(
      'UPDATE products SET title = $1, description = $2, category_id = $3 WHERE id = $4 RETURNING *',
      [title, description, category_id, id]
    );
    return result.rows[0];
  }

  async delete(id) {
    const result = await this.pool.query(
      'DELETE FROM products WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  async count() {
    const result = await this.pool.query('SELECT COUNT(*) FROM products');
    return parseInt(result.rows[0].count);
  }

  async getCategoriesForDropdown() {
    const result = await this.pool.query(
      'SELECT id, title FROM categories ORDER BY title'
    );
    return result.rows;
  }
}

module.exports = Product;