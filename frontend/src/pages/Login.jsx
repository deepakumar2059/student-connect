import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { login } from '../api/authApi'
import { useAuth } from '../contexts/AuthContext'

export default function Login() {
  const [form, setForm] = useState({ email: '', password: '' })
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

    try {
      const payload = await login({ email: form.email, password: form.password })
      signIn(payload)
      navigate('/')
    } catch (err) {
      setError(err.response?.data?.error || 'Unable to login. Please check your credentials.')
      setStatus(null)
    }
  }

  return (
    <main className="page page-form">
      <div className="page-header">
        <div>
          <p className="eyebrow">Sign in</p>
          <h1>Login to your account.</h1>
          <p className="lead">Use your email and password to access Student Connect.</p>
        </div>
      </div>

      <form className="profile-form" onSubmit={handleSubmit}>
        <label>
          Email address
          <input name="email" type="email" value={form.email} onChange={handleChange} required />
        </label>

        <label>
          Password
          <input name="password" type="password" value={form.password} onChange={handleChange} required />
        </label>

        <button type="submit" className="button button-primary">
          {status === 'saving' ? 'Signing in...' : 'Login'}
        </button>

        {error && <p className="status-error">{error}</p>}
      </form>
    </main>
  )
}
