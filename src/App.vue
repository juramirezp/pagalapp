<script setup>
import { ref, onMounted } from 'vue'
import PaymentMethods from './components/PaymentMethods.vue'
import ExpenseTypes from './components/ExpenseTypes.vue'
import ExpenseTemplates from './components/ExpenseTemplates.vue'; // Nueva importación
import HelpModal from './components/HelpModal.vue'; // Importar el modal de ayuda
import MonthlyRecords from './components/MonthlyRecords.vue';
import ReportView from './components/ReportView.vue';
import { supabase } from './supabase'

const user = ref(null)
const email = ref('')
const password = ref('')
const loading = ref(false)
const errorMessage = ref('')
const activeView = ref('dashboard'); // Vista por defecto
const showHelpModal = ref(false); // Estado para controlar el modal de ayuda
const theme = ref('dark'); // Estado para controlar el tema, por defecto oscuro
const isRegistering = ref(false);
const registrationSuccess = ref(false); // Nueva variable para el mensaje de éxito

function toggleTheme() {
  theme.value = theme.value === 'dark' ? 'light' : 'dark';
  document.documentElement.classList.toggle('dark', theme.value === 'dark');
  localStorage.setItem('theme', theme.value);
}

async function handleLogin() {
  try {
    loading.value = true
    errorMessage.value = ''
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })
    if (error) throw error
    user.value = data.user
    activeView.value = 'dashboard'; // Restablecer vista al iniciar sesión
  } catch (error) {
    errorMessage.value = error.error_description || error.message
  } finally {
    loading.value = false
  }
}

async function handleGitHubLogin() {
  try {
    loading.value = true;
    errorMessage.value = '';
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'github',
    });
    if (error) throw error;
  } catch (error) {
    errorMessage.value = error.error_description || error.message;
  } finally {
    loading.value = false;
  }
}

async function handleGoogleLogin() {
  try {
    loading.value = true;
    errorMessage.value = '';
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
    });
    if (error) throw error;
  } catch (error) {
    errorMessage.value = error.error_description || error.message;
  } finally {
    loading.value = false;
  }
}

async function handleLogout() {
  try {
    loading.value = true
    errorMessage.value = ''
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    user.value = null
    activeView.value = 'login'; // O redirigir a la vista de login si es necesario
  } catch (error) {
    errorMessage.value = error.error_description || error.message
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  // Inicializar tema desde localStorage (persistencia del usuario)
  const savedTheme = localStorage.getItem('theme');
  if (savedTheme) {
    theme.value = savedTheme;
    document.documentElement.classList.toggle('dark', theme.value === 'dark');
  } else {
    theme.value = 'dark';
    document.documentElement.classList.add('dark');
    localStorage.setItem('theme', 'dark');
  }
  const { data } = await supabase.auth.getUser()
  user.value = data.user
  if (user.value) {
    activeView.value = 'dashboard';
  } else {
    activeView.value = 'login';
  }
  supabase.auth.onAuthStateChange((_, session) => {
    user.value = session?.user ?? null
    if (user.value) {
      activeView.value = 'dashboard';
    } else {
      activeView.value = 'login';
    }
  })
})

async function handleRegister() {
  try {
    loading.value = true;
    errorMessage.value = '';
    registrationSuccess.value = false;
    const { data, error } = await supabase.auth.signUp({
      email: email.value,
      password: password.value,
    });
    if (error) throw error;
    // Opcional: podrías querer asignar data.user a user.value aquí si Supabase lo devuelve en signUp y quieres un auto - login
    // user.value = data.user;
    registrationSuccess.value = true;
    isRegistering.value = false; // Volver al formulario de login
    email.value = ''; // Limpiar campos
    password.value = ''; // Limpiar campos
    // No es necesario cambiar activeView aquí, ya que onAuthStateChange lo manejará o el usuario iniciará sesión manualmente.
  } catch (error) {
    errorMessage.value = error.error_description || error.message;
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="h-screen bg-gray-50 flex overflow-hidden">
    <HelpModal :show="showHelpModal" @close="showHelpModal = false" />
    <!-- Sidebar -->
    <aside v-if="user" class="w-64 bg-white dark:bg-slate-800 p-6 shadow-lg flex flex-col h-screen overflow-y-auto">
      <div class="mb-8">
        <div class="flex items-center mb-2">
          <img :src="user.user_metadata?.avatar_url || 'https://via.placeholder.com/40'" alt="User Avatar"
            class="w-10 h-10 rounded-full mr-3">
          <div>
            <p class="font-semibold text-gray-800 dark:text-gray-200">{{ user.user_metadata?.full_name || user.email }}
            </p>
            <p class="text-xs text-gray-500 dark:text-gray-400">{{ user.email }}</p>
          </div>
        </div>
        <!-- <input type="text" placeholder="Q Search..." class="w-full p-2 border border-gray-300 rounded-md text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"> -->
      </div>

      <nav class="flex-grow">
        <ul>
          <li class="mb-2">
            <a href="#" @click.prevent="activeView = 'dashboard'"
              class="flex items-center p-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors"
              :class="{ 'bg-gray-100 dark:bg-slate-700 text-blue-600 dark:text-blue-400': activeView === 'dashboard' }">
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6">
                </path>
              </svg>
              Dashboard
            </a>
          </li>
          <li class="mb-2">
            <a href="#" @click.prevent="activeView = 'monthlyRecords'"
              class="flex items-center p-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors"
              :class="{ 'bg-gray-100 dark:bg-slate-700 text-blue-600 dark:text-blue-400': activeView === 'monthlyRecords' }">
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
              </svg>
              Registros Mensuales
            </a>
          </li>
          <li class="mb-2">
            <a href="#" @click.prevent="activeView = 'expenseTemplates'"
              class="flex items-center p-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors"
              :class="{ 'bg-gray-100 dark:bg-slate-700 text-blue-600 dark:text-blue-400': activeView === 'expenseTemplates' }">
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M4 6h16M4 10h16M4 14h16M4 18h16"></path>
              </svg> <!-- Icono genérico, puedes cambiarlo -->
              Plantillas de Gastos
            </a>
          </li>
          <li class="mb-2">
            <a href="#" @click.prevent="activeView = 'expenseTypes'"
              class="flex items-center p-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors"
              :class="{ 'bg-gray-100 dark:bg-slate-700 text-blue-600 dark:text-blue-400': activeView === 'expenseTypes' }">
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10">
                </path>
              </svg>
              Tipos de Gasto
            </a>
          </li>
          <li class="mb-2">
            <a href="#" @click.prevent="activeView = 'paymentMethods'"
              class="flex items-center p-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors"
              :class="{ 'bg-gray-100 dark:bg-slate-700 text-blue-600 dark:text-blue-400': activeView === 'paymentMethods' }">
              <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"></path>
              </svg>
              Métodos de Pago
            </a>
          </li>
        </ul>
      </nav>

      <div class="mt-auto">
        <button @click.prevent="showHelpModal = true"
          class="w-full flex items-center justify-center p-2 mb-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors">
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.79 4 4s-1.79 4-4 4c-1.742 0-3.223-.835-3.772-2M12 18C7.582 18 4 14.418 4 10s3.582-8 8-8 8 3.582 8 8-3.582 8-8 8z">
            </path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 13.5a1.5 1.5 0 100-3 1.5 1.5 0 000 3z"></path>
            <line x1="12" y1="17" x2="12" y2="17.01"></line>
          </svg>
          Ayuda
        </button>
        <button @click="toggleTheme"
          class="w-full flex items-center justify-center p-2 mb-2 text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-slate-700 rounded-md transition-colors">
          <svg v-if="theme === 'dark'" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
            stroke="currentColor" class="w-5 h-5 mr-3">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 3v1m0 16v1m8.36-7.36l-.71.7m-12.02 0l-.71-.7m15.03-4.95l-.7.71M7.05 6.34l-.7-.71M21 12h-1M4 12H3m16.95 4.95l-.7-.71M6.34 17.66l-.7.71" />
          </svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor"
            class="w-5 h-5 mr-3">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M17.293 14.707A8 8 0 1112 4v0a8 8 0 005.293 10.707z" />
          </svg>
          {{ theme === 'dark' ? 'Tema Claro' : 'Tema Oscuro' }}
        </button>
        <button @click="handleLogout" :disabled="loading"
          class="w-full bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-md focus:outline-none focus:shadow-outline disabled:opacity-50 transition-colors">
          {{ loading ? 'Cerrando sesión...' : 'Cerrar Sesión' }}
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <main class="flex-1 overflow-y-auto">
      <div v-if="user" class=" mx-auto">
        <header
          class="mb-8 flex justify-between items-center sticky top-0 bg-gray-50 dark:bg-slate-900 z-10 py-4 shadow-sm  p-8 ">
          <div>
            <h1 class="text-2xl font-semibold text-gray-800 dark:text-gray-100">Gestor de Gastos</h1>
            <p class="text-sm text-gray-500 dark:text-gray-400">Administra tus finanzas de forma sencilla.</p>
          </div>
          <div class="flex items-center">
            <!-- Icono Notificación (ejemplo) -->
            <svg
              class="w-6 h-6 text-gray-600 dark:text-gray-300 mr-4 cursor-pointer hover:text-blue-500 dark:hover:text-blue-400"
              fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9">
              </path>
            </svg>
            <div class="flex items-center">
              <img :src="user.user_metadata?.avatar_url || 'https://via.placeholder.com/32'" alt="User Avatar"
                class="w-8 h-8 rounded-full mr-2">
              <span class="text-sm font-medium text-gray-700 dark:text-gray-200">{{ user.user_metadata?.full_name ||
                user.email }}</span>
            </div>
          </div>
        </header>

        <div class=" p-8 ">
          <!-- Contenido dinámico basado en activeView -->
          <div v-if="activeView === 'dashboard'" class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <ReportView />
          </div>

          <div v-else-if="activeView === 'paymentMethods'" class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <PaymentMethods />
          </div>

          <div v-else-if="activeView === 'expenseTypes'" class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <ExpenseTypes />
          </div>

          <div v-else-if="activeView === 'expenseTemplates'"
            class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <ExpenseTemplates />
          </div>

          <div v-else-if="activeView === 'monthlyRecords'" class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <MonthlyRecords />

          </div>

          <div v-else class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
            <h2 class="text-xl font-semibold text-gray-700 dark:text-gray-200 mb-4">Vista no encontrada</h2>
            <p class="text-gray-700 dark:text-gray-200">La sección solicitada no existe o está en construcción.</p>
          </div>
        </div>
      </div>

      <!-- Login Form (centrado si no hay usuario) -->
      <div v-else class="min-h-full flex flex-col justify-center items-center bg-gray-50 dark:bg-slate-900">
        <div class="bg-white dark:bg-slate-800 p-10 rounded-xl shadow-xl w-full max-w-md">
          <h1 class="text-3xl font-bold text-center text-blue-600 dark:text-blue-400 mb-8">Gestor de Gastos</h1>
          <form v-if="!isRegistering" @submit.prevent="handleLogin" class="space-y-6">
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Email</label>
              <input type="email" id="email" v-model="email" required
                class="mt-1 block w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow bg-white dark:bg-slate-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="tu@email.com" />
            </div>
            <div>
              <label for="password"
                class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Contraseña</label>
              <input type="password" id="password" v-model="password" required
                class="mt-1 block w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow bg-white dark:bg-slate-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="tu contraseña" />
            </div>
            <button type="submit" :disabled="loading"
              class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-60 transition-colors">
              {{ loading ? 'Iniciando sesión...' : 'Iniciar Sesión' }}
            </button>
            <button type="button" class="w-full text-sm text-center text-gray-600 dark:text-gray-300 underline mt-4"
              @click="isRegistering = true">¿No tienes cuenta? Regístrate</button>
            <p v-if="errorMessage" class="text-red-500 dark:text-red-400 text-sm text-center pt-2">{{ errorMessage }}
            </p>
            <div class="relative my-5">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-gray-300 dark:border-slate-600"></div>
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-3 bg-white dark:bg-slate-800 text-gray-500 dark:text-gray-400">O continuar con</span>
              </div>
            </div>
            <button type="button" @click="handleGoogleLogin" :disabled="loading"
              class="w-full flex items-center justify-center bg-white dark:bg-slate-700 hover:bg-gray-100 dark:hover:bg-slate-600 border border-gray-300 dark:border-slate-600 text-gray-700 dark:text-gray-200 font-semibold py-3 px-4 rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-blue-500 disabled:opacity-60 transition-colors mb-3">
              <img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google logo"
                class="h-5 w-5 mr-3">
              {{ loading ? 'Conectando...' : 'Iniciar sesión con Google' }}
            </button>
          </form>
          <!-- Register Form -->
          <form v-else @submit.prevent="handleRegister" class="space-y-6">
            <div>
              <label for="email-reg"
                class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Email</label>
              <input type="email" id="email-reg" v-model="email" required
                class="mt-1 block w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow bg-white dark:bg-slate-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="tu@email.com" />
            </div>
            <div>
              <label for="password-reg"
                class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Contraseña</label>
              <input type="password" id="password-reg" v-model="password" required
                class="mt-1 block w-full px-4 py-3 border border-gray-300 dark:border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow bg-white dark:bg-slate-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
                placeholder="tu contraseña" />
            </div>
            <button type="submit" :disabled="loading"
              class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-4 rounded-lg focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-60 transition-colors">
              {{ loading ? 'Registrando...' : 'Registrarse' }}
            </button>
            <button type="button" class="w-full text-sm text-center text-gray-600 dark:text-gray-300 underline mt-4"
              @click="isRegistering = false">¿Ya tienes cuenta? Inicia sesión</button>
            <p v-if="registrationSuccess" class="text-green-500 dark:text-green-400 text-sm text-center pt-2">
              ¡Registro exitoso! Ya puedes iniciar sesión.</p>
            <p v-if="errorMessage && !registrationSuccess" class="
              text-red-500 dark:text-red-400 text-sm text-center pt-2">{{ errorMessage }}</p>
          </form>
        </div>
      </div>
    </main>
  </div>
</template>
