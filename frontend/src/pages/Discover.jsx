import { useEffect, useState } from 'react'
import { fetchStudents } from '../api/studentApi'
import StudentCard from '../components/StudentCard'

const majors = ['Computer Science', 'Business Analytics', 'Cinema Studies', 'Engineering', 'Psychology', 'Design']

export default function Discover() {
  const [students, setStudents] = useState([])
  const [isLoading, setIsLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [major, setMajor] = useState('')

  useEffect(() => {
    setIsLoading(true)
    fetchStudents({ q: search, major })
      .then(setStudents)
      .finally(() => setIsLoading(false))
  }, [search, major])

  return (
    <main className="page page-discover">
      <div className="page-header">
        <div>
          <p className="eyebrow">Discover students</p>
          <h1>Browse peer profiles by interests and major.</h1>
        </div>
      </div>

      <form className="search-panel" onSubmit={(event) => event.preventDefault()}>
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder="Search by name, interest, or college"
          aria-label="Search profiles"
        />
        <select value={major} onChange={(event) => setMajor(event.target.value)}>
          <option value="">All majors</option>
          {majors.map((option) => (
            <option key={option} value={option}>
              {option}
            </option>
          ))}
        </select>
      </form>

      {isLoading ? (
        <p className="status-message">Loading student profiles...</p>
      ) : students.length ? (
        <div className="student-grid">
          {students.map((student) => (
            <StudentCard key={student.id} student={student} />
          ))}
        </div>
      ) : (
        <p className="status-message">No profiles match your search. Try a broader filter.</p>
      )}
    </main>
  )
}
