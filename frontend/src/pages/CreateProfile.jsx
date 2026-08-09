import { useState } from 'react'
import { createStudent } from '../api/studentApi'

export default function CreateProfile() {
  const [form, setForm] = useState({
    name: '',
    college: '',
    major: '',
    interests: '',
    bio: '',
  })
  const [status, setStatus] = useState(null)
  const [error, setError] = useState(null)

  function handleChange(event) {
    const { name, value } = event.target
    setForm((current) => ({ ...current, [name]: value }))
  }

  function handleSubmit(event) {
    event.preventDefault()
    setStatus('saving')
    setError(null)

    const payload = {
      ...form,
      interests: form.interests
        .split(',')
        .map((item) => item.trim())
        .filter(Boolean),
    }

    createStudent(payload)
      .then(() => {
        setStatus('saved')
        setForm({ name: '', college: '', major: '', interests: '', bio: '' })
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Unable to save your profile.')
        setStatus(null)
      })
  }

  return (
    <main className="page page-form">
      <div className="page-header">
        <div>
          <p className="eyebrow">Create profile</p>
          <h1>Share your academic focus and interests.</h1>
          <p className="lead">
            Add a profile so other students can discover you for study groups, events, and mentorship.
          </p>
        </div>
      </div>

      <form className="profile-form" onSubmit={handleSubmit}>
        <label>
          Name
          <input name="name" value={form.name} onChange={handleChange} required />
        </label>
        <label>
          College
          <input name="college" value={form.college} onChange={handleChange} required />
        </label>
        <label>
          Major
          <input name="major" value={form.major} onChange={handleChange} required />
        </label>
        <label>
          Interests (comma separated)
          <input name="interests" value={form.interests} onChange={handleChange} placeholder="e.g. coding, study groups, events" />
        </label>
        <label>
          Bio
          <textarea name="bio" value={form.bio} onChange={handleChange} rows="4" />
        </label>

        <button type="submit" className="button button-primary">
          {status === 'saving' ? 'Saving...' : 'Create profile'}
        </button>

        {status === 'saved' && <p className="status-success">Profile created successfully.</p>}
        {error && <p className="status-error">{error}</p>}
      </form>
    </main>
  )
}
