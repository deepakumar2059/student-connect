import axios from 'axios'

const client = axios.create({
  baseURL: '/api/auth',
  headers: {
    'Content-Type': 'application/json',
  },
})

export function register(payload) {
  return client.post('/register', payload).then((response) => response.data)
}

export function login(payload) {
  return client.post('/login', payload).then((response) => response.data)
}

export default client
