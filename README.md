# Student Connect

Student Connect is a full-stack web application designed to help students discover like-minded peers in colleges and universities. The platform allows users to browse student profiles, filter by major or interest, create a profile, and register/login to personalize the experience.

## Overview

The project is split into two main parts:

- Frontend: React + Vite single-page application
- Backend: Express server with PostgreSQL and JWT-based authentication

This app matches the project idea of connecting students based on academic focus, interests, and campus community involvement.

## Features

- Browse and search student profiles
- Filter students by major and interest keywords
- Create a profile with name, college, major, interests, and bio
- User registration and login using email/password
- JWT-based authentication and user session persistence
- Backend API for students and auth flows
- Frontend served through the backend in production builds

## Tech Stack

### Frontend
- React 19
- Vite
- React Router DOM
- Axios

### Backend
- Node.js
- Express
- PostgreSQL
- pg (PostgreSQL client)
- JWT (jsonwebtoken)
- bcrypt
- dotenv
- cors
- morgan

## Project Structure

```text
student-connect/
├── Problem Description_ Connecting Like-minded Students In Colleges And Universities(1).docx
├── backend/
│   ├── .env.example
│   ├── .env
│   ├── auth.js
│   ├── db.js
│   ├── index.js
│   ├── package.json
│   ├── routes/
│   │   └── auth.js
│   └── node_modules/
├── frontend/
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   ├── src/
│   │   ├── api/
│   │   │   ├── authApi.js
│   │   │   └── studentApi.js
│   │   ├── components/
│   │   ├── contexts/
│   │   │   └── AuthContext.jsx
│   │   ├── pages/
│   │   │   ├── Home.jsx
│   │   │   ├── Discover.jsx
│   │   │   ├── CreateProfile.jsx
│   │   │   ├── Register.jsx
│   │   │   └── Login.jsx
│   │   ├── App.jsx
│   │   ├── App.css
│   │   ├── index.css
│   │   ├── main.jsx
│   │   └── assets/
│   └── dist/
└── README.md
```

## How the App Works

### Frontend
The frontend uses React Router to navigate between pages:

- `/` — landing page / home
- `/discover` — browse student profiles and filter results
- `/create-profile` — create a student profile
- `/register` — register a new account
- `/login` — login to the application

The `AuthContext` stores the JWT and user data in localStorage, allowing the app to maintain a signed-in session across page loads.

### Backend
The backend exposes API routes under `/api` and `/api/auth`:

- `GET /api` — health check
- `GET /api/students` — fetch students with optional search and major filtering
- `GET /api/students/:id` — fetch one student by ID
- `POST /api/students` — create a new student profile
- `POST /api/auth/register` — register a user
- `POST /api/auth/login` — authenticate and issue a JWT
- `GET /api/auth/me` — get current logged-in user from token

The server also serves the built frontend bundle from `frontend/dist` when the application is running in production mode.

## Authentication and Database

The backend uses PostgreSQL and creates the `auth_users` table if it does not already exist.

- `auth_users` stores:
  - `id`
  - `email`
  - `password_hash`
  - `full_name`
  - `is_active`
  - `created_at`
  - `updated_at`
  - `last_login_at`

Passwords are hashed with `bcrypt`, and login sessions are protected by JWTs.

## Getting Started

### Prerequisites

- Node.js (v18+ recommended)
- npm or yarn
- PostgreSQL database

### 1. Clone the repository

```bash
git clone https://github.com/deepakumar2059/student-connect.git
cd student-connect
```

### 2. Setup the backend environment

From the `backend` folder:

```bash
cp .env.example .env
```

Update `.env` with your database connection and app settings:

```env
DATABASE_URL=postgres://user:password@localhost:5432/student_connect
PORT=5000
JWT_SECRET=replace-with-a-secure-random-value
```

### 3. Install backend dependencies

```bash
cd backend
npm install
```

### 4. Install frontend dependencies

```bash
cd ../frontend
npm install
```

### 5. Run the app in development mode

Start the backend:

```bash
cd backend
npm run dev
```

Start the frontend:

```bash
cd frontend
npm run dev
```

The Vite frontend will run on its own development server, while the backend will run separately on `http://localhost:5000`.

### 6. Production build

To build the frontend for deployment:

```bash
cd frontend
npm run build
```

Then start the backend:

```bash
cd backend
npm start
```

The backend serves the generated frontend build from `frontend/dist` automatically.

## Example API Usage

### Register a new user

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Aisha Khan",
    "email": "aisha@example.com",
    "password": "password123"
  }'
```

### Login

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "aisha@example.com",
    "password": "password123"
  }'
```

### Fetch students

```bash
curl "http://localhost:5000/api/students?q=AI&major=Computer%20Science"
```

## Notes

- The project currently includes sample student data in the backend for demonstration purposes.
- The frontend uses a search and filter flow to browse students by name, interest, college, and major.
- The backend is designed to be extended for real database-backed student profiles and richer social networking features.

## License

This project is currently provided as a development/demo project without a formal license file.

## Project Goal

The main goal of Student Connect is to create a simple and practical way for students to discover peers who share their academic interests, goals, and campus communities.

## Authors

This project is maintained as part of the Student Connect application repository by the project contributors.

---

Student Connect is a practical student networking platform that combines a React frontend with an Express/PostgreSQL backend to help people form meaningful academic and social connections.
