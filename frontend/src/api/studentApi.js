import axios from 'axios'

const client = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

export function fetchStudents(filters = {}) {
  return client.get('/students', { params: filters }).then((response) => response.data)
}

export function createStudent(profile) {
  return client.post('/students', profile).then((response) => response.data)
}

export default client
