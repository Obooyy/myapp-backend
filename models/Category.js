class Category {
  constructor(pool) {
    this.pool = pool;
  }

  async findAll() {
    const result = await this.pool.query(
      'SELECT * FROM categories ORDER BY created_at DESC'
    );
    return result.rows;
  }

  async findById(id) {
    const result = await this.pool.query(
      'SELECT * FROM categories WHERE id = $1',
      [id]
    );
    return result.rows[0];
  }

  async create(categoryData) {
    const { title, description } = categoryData;
    const result = await this.pool.query(
      'INSERT INTO categories (title, description) VALUES ($1, $2) RETURNING *',
      [title, description]
    );
    return result.rows[0];
  }

  async update(id, categoryData) {
    const { title, description } = categoryData;
    const result = await this.pool.query(
      'UPDATE categories SET title = $1, description = $2 WHERE id = $3 RETURNING *',
      [title, description, id]
    );
    return result.rows[0];
  }

  async delete(id) {
    // Vérifier si la catégorie est utilisée par des produits
    const productsCount = await this.pool.query(
      'SELECT COUNT(*) FROM products WHERE category_id = $1',
      [id]
    );
    
    if (parseInt(productsCount.rows[0].count) > 0) {
      throw new Error('Impossible de supprimer : des produits utilisent cette catégorie');
    }

    const result = await this.pool.query(
      'DELETE FROM categories WHERE id = $1 RETURNING *',
      [id]
    );
    return result.rows[0];
  }

  async count() {
    const result = await this.pool.query('SELECT COUNT(*) FROM categories');
    return parseInt(result.rows[0].count);
  }
}

module.exports = Category;