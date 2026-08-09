import 'dotenv/config'
import express from 'express'
import cors from 'cors'
import morgan from 'morgan'
import path from 'path'
import { fileURLToPath } from 'url'
import authRouter from './routes/auth.js'
import { testConnection, ensureAuthTables } from './db.js'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 5000

app.use(cors())
app.use(morgan('dev'))
app.use(express.json())
app.use(express.static(path.join(__dirname, '../frontend/dist')))

app.use('/api/auth', authRouter)

const students = [
  {
    id: '1',
    name: 'Aisha Khan',
    college: 'Northview University',
    major: 'Computer Science',
    interests: ['AI', 'web development', 'study groups'],
    bio: 'Building code, joining hackathons, and helping peers improve their projects.',
  },
  {
    id: '2',
    name: 'Ravi Patel',
    college: 'Metro College',
    major: 'Business Analytics',
    interests: ['data science', 'student events', 'case competitions'],
    bio: 'Looking for classmates who love analytics and campus activities.',
  },
  {
    id: '3',
    name: 'Maya Smith',
    college: 'Eastside Institute',
    major: 'Cinema Studies',
    interests: ['film clubs', 'creative writing', 'networking'],
    bio: 'Interested in collaborative study groups and creative peer networks.',
  },
]

app.get('/api', (req, res) => {
  res.json({ message: 'Student Connect API is running' })
})

app.get('/api/students', (req, res) => {
  const { q = '', major = '' } = req.query
  const normalizedQuery = q.toLowerCase()
  const normalizedMajor = major.toLowerCase()

  const filtered = students.filter((student) => {
    const matchesSearch =
      student.name.toLowerCase().includes(normalizedQuery) ||
      student.college.toLowerCase().includes(normalizedQuery) ||
      student.bio.toLowerCase().includes(normalizedQuery) ||
      student.interests.some((interest) =>
        interest.toLowerCase().includes(normalizedQuery),
      )

    const matchesMajor =
      !normalizedMajor || student.major.toLowerCase().includes(normalizedMajor)

    return matchesSearch && matchesMajor
  })

  res.json(filtered)
})

app.get('/api/students/:id', (req, res) => {
  const student = students.find((item) => item.id === req.params.id)
  if (!student) {
    return res.status(404).json({ error: 'Student profile not found' })
  }
  res.json(student)
})

app.post('/api/students', (req, res) => {
  const { name, college, major, interests = [], bio = '' } = req.body

  if (!name || !college || !major) {
    return res.status(400).json({
      error: 'Name, college, and major are required fields.',
    })
  }

  const newStudent = {
    id: Date.now().toString(),
    name,
    college,
    major,
    interests: Array.isArray(interests)
      ? interests.filter((interest) => interest.trim()).map((interest) => interest.trim())
      : [],
    bio,
  }

  students.push(newStudent)
  res.status(201).json(newStudent)
})

app.use((req, res) => {
  if (req.header('Accept')?.includes('application/json')) {
    return res.status(404).json({ error: 'Route not found' })
  }
  res.sendFile(path.join(__dirname, '../frontend/dist/index.html'))
})

const startServer = async () => {
  try {
    await testConnection()
    await ensureAuthTables()
    console.log('Connected to PostgreSQL database')
  } catch (error) {
    console.error('Backend startup failed:', error.message)
    process.exit(1)
  }

  app.listen(PORT, () => {
    console.log(`Student Connect backend running on http://localhost:${PORT}`)
  })
}

startServer()
