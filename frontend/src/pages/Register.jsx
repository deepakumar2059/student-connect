import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { register } from '../api/authApi'
import { useAuth } from '../contexts/AuthContext'

export default function Register() {
  const [form, setForm] = useState({ full_name: '', email: '', password: '', confirmPassword: '' })
  const [status, setStatus] = useState(null)
  const [error, setError] = useState(null)
  const navigate = useNavigate()
  const { signIn } = useAuth()

  function handleChange(event) {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  async function handleSubmit(event) {
    event.preventDefault()
    setStatus('saving')
    setError(null)

    if (form.password !== form.confirmPassword) {
      setError('Passwords do not match.')
      setStatus(null)
      return
    }

    try {
      const payload = await register({
        full_name: form.full_name,
        email: form.email,
        password: form.password,
      })
      signIn(payload)
      navigate('/')
    } catch (err) {
      setError(err.response?.data?.error || 'Unable to register. Please try again.')
      setStatus(null)
    }
  }

  return (
    <main className="page page-form">
      <div className="page-header">
        <div>
          <p className="eyebrow">Create account</p>
          <h1>Register to join Student Connect.</h1>
          <p className="lead">Sign up with email and password to start using the platform.</p>
        </div>
      </div>

      <form className="profile-form" onSubmit={handleSubmit}>
        <label>
          Full name
          <input name="full_name" value={form.full_name} onChange={handleChange} required />
        </label>

        <label>
          Email address
          <input name="email" type="email" value={form.email} onChange={handleChange} required />
        </label>

        <label>
          Password
          <input name="password" type="password" value={form.password} onChange={handleChange} required />
        </label>

        <label>
          Confirm password
          <input name="confirmPassword" type="password" value={form.confirmPassword} onChange={handleChange} required />
        </label>

        <button type="submit" className="button button-primary">
          {status === 'saving' ? 'Registering...' : 'Register'}
        </button>

        {error && <p className="status-error">{error}</p>}
      </form>
    </main>
  )
}
