import pkg from 'pg'
const { Pool } = pkg

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl:
    process.env.NODE_ENV === 'production'
      ? { rejectUnauthorized: false }
      : false,
})

export const query = (text, params) => pool.query(text, params)

export const testConnection = async () => {
  await query('SELECT 1')
}

export const ensureAuthTables = async () => {
  await query('CREATE EXTENSION IF NOT EXISTS pgcrypto;')
  await query(`
    CREATE TABLE IF NOT EXISTS auth_users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email TEXT NOT NULL UNIQUE,
      password_hash TEXT NOT NULL,
      full_name TEXT NOT NULL,
      is_active BOOLEAN NOT NULL DEFAULT TRUE,
      created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
      updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
      last_login_at TIMESTAMP WITH TIME ZONE
    );
  `)
}
