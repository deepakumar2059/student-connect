import { Link } from 'react-router-dom'

export default function Home() {
  return (
    <main className="page page-home">
      <section className="hero-panel">
        <div>
          <p className="eyebrow">Student Connect</p>
          <h1>Find peers who share your interests and majors.</h1>
          <p className="lead">
            Connect with like-minded students across colleges and universities.
            Build study groups, discover events, and grow your campus network.
          </p>
          <div className="hero-actions">
            <Link className="button button-primary" to="/discover">
              Discover profiles
            </Link>
            <Link className="button button-secondary" to="/create-profile">
              Create your profile
            </Link>
          </div>
        </div>
        <div className="hero-panel-image">
          <div className="stats-card">
            <strong>120+</strong>
            <p>student connections made</p>
          </div>
          <div className="hero-panel-box">
            <p className="box-title">Join project teams, study clubs, and mentorship matches.</p>
          </div>
        </div>
      </section>
      <section className="feature-grid">
        <article>
          <h2>Search by major</h2>
          <p>Filter students by their major and discover the right people for your campus goals.</p>
        </article>
        <article>
          <h2>Share interests</h2>
          <p>Connect through shared hobbies, events, and academic focus areas.</p>
        </article>
        <article>
          <h2>Easy profile creation</h2>
          <p>Create a profile in seconds and let classmates find you.</p>
        </article>
      </section>
    </main>
  )
}
