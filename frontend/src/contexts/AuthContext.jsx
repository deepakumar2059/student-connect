import { createContext, useContext, useEffect, useMemo, useState } from 'react'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => localStorage.getItem('authToken'))
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('authUser')
    return stored ? JSON.parse(stored) : null
  })

  useEffect(() => {
    if (token) {
      localStorage.setItem('authToken', token)
    } else {
      localStorage.removeItem('authToken')
    }
  }, [token])

  useEffect(() => {
    if (user) {
      localStorage.setItem('authUser', JSON.stringify(user))
    } else {
      localStorage.removeItem('authUser')
    }
  }, [user])

  const signIn = (payload) => {
    setToken(payload.token)
    setUser(payload.user)
  }

  const signOut = () => {
    setToken(null)
    setUser(null)
  }

  const value = useMemo(
    () => ({ token, user, signIn, signOut }),
    [token, user],
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
