import { createClient } from '@supabase/supabase-js'

// Lee las variables de entorno de forma segura
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// Valida que las variables de entorno estén presentes
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error("Supabase URL and Anon Key must be provided in .env file")
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)