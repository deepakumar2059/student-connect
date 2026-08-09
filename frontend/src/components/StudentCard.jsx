import './StudentCard.css'

export default function StudentCard({ student }) {
  return (
    <article className="student-card">
      <div className="student-card-header">
        <div>
          <h3>{student.name}</h3>
          <p className="student-subtitle">{student.college} · {student.major}</p>
        </div>
      </div>
      <p className="student-bio">{student.bio}</p>
      <div className="student-tags">
        {student.interests.map((interest) => (
          <span key={interest} className="student-tag">
            {interest}
          </span>
        ))}
      </div>
    </article>
  )
}
