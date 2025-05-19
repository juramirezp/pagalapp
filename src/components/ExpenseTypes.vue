<template>
  <div class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-md">
    <h2 class="text-xl font-semibold text-gray-800 dark:text-gray-100 mb-6">Tipos de Gasto</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-x-4">

      <!-- Formulario para agregar nuevo tipo de gasto -->
      <form @submit.prevent="addExpenseType" class="mb-6 space-y-4">
        <div>
          <label for="expenseTypeName" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Nombre
            del Tipo</label>
          <input type="text" id="expenseTypeName" v-model="newExpenseType.name" required
            class="w-full px-4 py-2.5 border border-gray-300 dark:border-slate-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow bg-white dark:bg-slate-700 text-gray-900 dark:text-gray-100 placeholder-gray-400 dark:placeholder-gray-500"
            placeholder="Ej: Alimentación, Transporte" />
        </div>
        <button type="submit"
          class="w-full bg-purple-600 hover:bg-purple-700 text-white font-semibold py-2.5 px-4 rounded-lg shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-all ease-in-out duration-150 transform hover:scale-105">
          Agregar Tipo
        </button>
        <p v-if="errorMessage" class="text-red-600 dark:text-red-400 text-sm text-center pt-1">{{ errorMessage }}</p>
      </form>

      <!-- Lista de tipos de gasto -->
      <div class="space-y-3 max-h-80 overflow-y-auto pr-2 grid grid-cols-1 gap-2">
        <div v-for="type in expenseTypes" :key="type.id"
          class="p-4 border border-gray-200 dark:border-slate-600 rounded-lg hover:shadow-lg transition-shadow duration-200 flex justify-between items-center bg-gray-50 dark:bg-slate-700 hover:bg-white dark:hover:bg-slate-600 max-h-[50px]">
          <span class="text-md font-medium text-gray-800 dark:text-gray-100">{{ type.name }}</span>
          <button @click="removeExpenseType(type.id)"
            class="text-red-500 hover:text-red-700 dark:text-red-400 dark:hover:text-red-500 font-medium py-1 px-2.5 rounded-md hover:bg-red-100 dark:hover:bg-slate-600 transition-colors text-sm">
            <!-- Icono Basura (ejemplo) -->
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
              </path>
            </svg>
          </button>
        </div>
        <div v-if="expenseTypes.length === 0" class="text-center text-gray-500 dark:text-gray-400 py-6">
          <p class="mb-1">No hay tipos de gasto.</p>
          <p class="text-sm">Agrega uno usando el formulario.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { supabase } from '../supabase'; // Asegúrate que la ruta sea correcta

const user = ref(null);
const expenseTypes = ref([]);
const newExpenseType = ref({
  name: ''
});
const errorMessage = ref('');

async function fetchExpenseTypes() {
  if (!user.value) return;
  try {
    errorMessage.value = '';
    const { data, error } = await supabase
      .from('expense_types') // Tabla para tipos de gasto
      .select('*')
      .eq('user_id', user.value.id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    expenseTypes.value = data;
  } catch (error) {
    errorMessage.value = `Error al cargar tipos de gasto: ${error.message}`;
    console.error('Error fetching expense types:', error);
  }
}

async function addExpenseType() {
  if (!user.value || !newExpenseType.value.name) {
    errorMessage.value = 'Por favor, ingresa un nombre para el tipo de gasto.';
    return;
  }
  try {
    errorMessage.value = '';
    const { data, error } = await supabase
      .from('expense_types')
      .insert([
        {
          user_id: user.value.id,
          name: newExpenseType.value.name
        }
      ])
      .select();

    if (error) throw error;
    if (data && data.length > 0) {
      expenseTypes.value.unshift(data[0]);
    }
    newExpenseType.value.name = '';
  } catch (error) {
    errorMessage.value = `Error al agregar tipo de gasto: ${error.message}`;
    console.error('Error adding expense type:', error);
  }
}

async function removeExpenseType(typeId) {
  try {
    errorMessage.value = '';
    const { error } = await supabase
      .from('expense_types')
      .delete()
      .match({ id: typeId });

    if (error) throw error;
    expenseTypes.value = expenseTypes.value.filter(type => type.id !== typeId);
  } catch (error) {
    errorMessage.value = `Error al eliminar tipo de gasto: ${error.message}`;
    console.error('Error removing expense type:', error);
  }
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession();
  user.value = session?.user;

  if (user.value) {
    await fetchExpenseTypes();
  } else {
    expenseTypes.value = []; // Limpiar tipos si el usuario cierra sesión
  }

  supabase.auth.onAuthStateChange((_event, session) => {
    user.value = session?.user ?? null;
    if (user.value) {
      fetchExpenseTypes();
    } else {
      expenseTypes.value = []; // Limpiar tipos si el usuario cierra sesión
    }
  });
});

</script>

<style scoped>
/* Estilos específicos si son necesarios */
</style>