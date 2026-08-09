import express from 'express'
import { authenticateUser, getUserById, registerUser, verifyToken } from '../auth.js'

const router = express.Router()

router.post('/register', async (req, res) => {
  try {
    const { email, password, full_name } = req.body
    if (!email || !password || !full_name) {
      return res.status(400).json({ error: 'Full name, email, and password are required.' })
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters.' })
    }

    const payload = await registerUser({ email, password, full_name })
    res.status(201).json(payload)
  } catch (error) {
    res.status(error.status || 500).json({ error: error.message || 'Registration failed.' })
  }
})

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' })
    }

    const payload = await authenticateUser({ email, password })
    res.json(payload)
  } catch (error) {
    res.status(error.status || 500).json({ error: error.message || 'Login failed.' })
  }
})

router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers.authorization
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing authorization token.' })
    }

    const token = authHeader.split(' ')[1]
    const payload = verifyToken(token)
    const user = await getUserById(payload.userId)
    if (!user) {
      return res.status(401).json({ error: 'Invalid token.' })
    }

    res.json({ user })
  } catch (error) {
    res.status(401).json({ error: 'Unauthorized.' })
  }
})

export default router
