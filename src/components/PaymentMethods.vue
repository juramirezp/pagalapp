<template>
  <div class="bg-white p-0 rounded-xl">
    <h2 class="text-xl font-semibold text-gray-800 mb-6">Métodos de Pago</h2>
    <div class="grid grid-cols-2 gap-x-4">

      <!-- Formulario para agregar nuevo método de pago -->
      <form @submit.prevent="addPaymentMethod" class="mb-6 space-y-4">
        <div>
          <label for="paymentMethodName" class="block text-sm font-medium text-gray-700 mb-1">Nombre del Método</label>
          <input type="text" id="paymentMethodName" v-model="newPaymentMethod.name" required
            class="w-full px-4 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow"
            placeholder="Ej: Tarjeta Principal" />
        </div>
        <div>
          <label for="paymentMethodType" class="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
          <select id="paymentMethodType" v-model="newPaymentMethod.type" required
            class="w-full px-4 py-2.5 border border-gray-300 bg-white rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm transition-shadow">
            <option value="" disabled>Selecciona un tipo</option>
            <option value="credit_card">Tarjeta de Crédito</option>
            <option value="debit_card">Tarjeta de Débito</option>
            <option value="bank_transfer">Transferencia Bancaria</option>
            <option value="crypto">Criptomoneda</option>
            <option value="cash">Efectivo</option>
            <option value="other">Otro</option>
          </select>
        </div>
        <button type="submit"
          class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 px-4 rounded-lg shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all ease-in-out duration-150 transform hover:scale-105">
          Agregar Método
        </button>
        <p v-if="errorMessage" class="text-red-600 text-sm text-center pt-1">{{ errorMessage }}</p>
      </form>

      <!-- Lista de métodos de pago -->
      <div class="space-y-3 max-h-80 overflow-y-auto pr-2">
        <div v-for="method in paymentMethods" :key="method.id"
          class="p-4 border border-gray-200 rounded-lg hover:shadow-lg transition-shadow duration-200 flex justify-between items-center bg-gray-50 hover:bg-white">
          <div>
            <h3 class="text-md font-medium text-gray-800">{{ method.name }}</h3>
            <p class="text-xs text-gray-500">{{ method.type_display }}</p>
          </div>
          <button @click="removePaymentMethod(method.id)"
            class="text-red-500 hover:text-red-700 font-medium py-1 px-2.5 rounded-md hover:bg-red-100 transition-colors text-sm">
            <!-- Icono Basura (ejemplo) -->
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
              </path>
            </svg>
          </button>
        </div>
        <div v-if="paymentMethods.length === 0" class="text-center text-gray-500 py-6">
          <p class="mb-1">No hay métodos de pago.</p>
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
const paymentMethods = ref([]);
const newPaymentMethod = ref({
  name: '',
  type: ''
});
const errorMessage = ref('');

const typeDisplayMap = {
  credit_card: 'Tarjeta de Crédito',
  debit_card: 'Tarjeta de Débito',
  bank_transfer: 'Transferencia Bancaria',
  crypto: 'Criptomoneda',
  cash: 'Efectivo',
  other: 'Otro'
};

async function fetchPaymentMethods() {
  if (!user.value) return;
  try {
    errorMessage.value = '';
    const { data, error } = await supabase
      .from('payment_methods')
      .select('*')
      .eq('user_id', user.value.id)
      .order('created_at', { ascending: false });

    if (error) throw error;
    paymentMethods.value = data.map(method => ({
      ...method,
      type_display: typeDisplayMap[method.type] || method.type
    }));
  } catch (error) {
    errorMessage.value = `Error al cargar métodos de pago: ${error.message}`;
    console.error('Error fetching payment methods:', error);
  }
}

async function addPaymentMethod() {
  if (!user.value || !newPaymentMethod.value.name || !newPaymentMethod.value.type) {
    errorMessage.value = 'Por favor, completa todos los campos.';
    return;
  }
  try {
    errorMessage.value = '';
    const { data, error } = await supabase
      .from('payment_methods')
      .insert([
        {
          user_id: user.value.id,
          name: newPaymentMethod.value.name,
          type: newPaymentMethod.value.type
        }
      ])
      .select();

    if (error) throw error;
    if (data && data.length > 0) {
      // Actualizar la lista localmente para reflejar el cambio inmediatamente
      paymentMethods.value.unshift({ ...data[0], type_display: typeDisplayMap[data[0].type] || data[0].type });
    }
    newPaymentMethod.value.name = '';
    newPaymentMethod.value.type = '';
    // Opcional: recargar desde la base de datos para asegurar consistencia
    // await fetchPaymentMethods(); 
  } catch (error) {
    errorMessage.value = `Error al agregar método de pago: ${error.message}`;
    console.error('Error adding payment method:', error);
  }
}

async function removePaymentMethod(methodId) {
  try {
    errorMessage.value = '';
    const { error } = await supabase
      .from('payment_methods')
      .delete()
      .match({ id: methodId });

    if (error) throw error;
    paymentMethods.value = paymentMethods.value.filter(method => method.id !== methodId);
  } catch (error) {
    errorMessage.value = `Error al eliminar método de pago: ${error.message}`;
    console.error('Error removing payment method:', error);
  }
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession();
  user.value = session?.user;

  if (user.value) {
    await fetchPaymentMethods();
  }

  supabase.auth.onAuthStateChange((_event, session) => {
    user.value = session?.user ?? null;
    if (user.value) {
      fetchPaymentMethods();
    } else {
      paymentMethods.value = []; // Limpiar métodos si el usuario cierra sesión
    }
  });
});

</script>

<style scoped>
/* Estilos específicos si son necesarios */
</style>