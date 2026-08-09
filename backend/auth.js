import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { query } from './db.js'

const JWT_SECRET = process.env.JWT_SECRET || 'change-me-in-production'
const JWT_EXPIRES_IN = '7d'
const SALT_ROUNDS = 10

export const createAuthToken = (user) => {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      full_name: user.full_name,
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN },
  )
}

export const registerUser = async ({ email, password, full_name }) => {
  const normalizedEmail = email.trim().toLowerCase()
  const existing = await query('SELECT id FROM auth_users WHERE email = $1', [normalizedEmail])
  if (existing.rows.length) {
    const error = new Error('Email already registered')
    error.status = 409
    throw error
  }

  const password_hash = await bcrypt.hash(password, SALT_ROUNDS)
  const result = await query(
    `INSERT INTO auth_users (email, password_hash, full_name)
     VALUES ($1, $2, $3)
     RETURNING id, email, full_name, created_at, updated_at, last_login_at, is_active`,
    [normalizedEmail, password_hash, full_name.trim()],
  )

  const user = result.rows[0]
  return {
    user,
    token: createAuthToken(user),
  }
}

export const authenticateUser = async ({ email, password }) => {
  const normalizedEmail = email.trim().toLowerCase()
  const result = await query(
    'SELECT id, email, full_name, password_hash, is_active, created_at, updated_at, last_login_at FROM auth_users WHERE email = $1',
    [normalizedEmail],
  )

  const user = result.rows[0]
  if (!user || !user.is_active) {
    const error = new Error('Invalid email or password')
    error.status = 401
    throw error
  }

  const passwordMatches = await bcrypt.compare(password, user.password_hash)
  if (!passwordMatches) {
    const error = new Error('Invalid email or password')
    error.status = 401
    throw error
  }

  await query('UPDATE auth_users SET last_login_at = now(), updated_at = now() WHERE id = $1', [user.id])

  return {
    user: {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
      created_at: user.created_at,
      updated_at: user.updated_at,
      last_login_at: new Date().toISOString(),
      is_active: user.is_active,
    },
    token: createAuthToken(user),
  }
}

export const verifyToken = (token) => {
  return jwt.verify(token, JWT_SECRET)
}

export const getUserById = async (id) => {
  const result = await query(
    'SELECT id, email, full_name, created_at, updated_at, last_login_at, is_active FROM auth_users WHERE id = $1',
    [id],
  )
  return result.rows[0] || null
}
