<template>
  <div class="space-y-6">
    <h2 class="text-xl font-semibold text-gray-700 mb-4">Resumen de Gastos</h2>
    
    <!-- Filtros -->
    <div class="bg-white p-4 rounded-lg shadow-md">
      <div class="flex space-x-4">
        <div class="w-1/2">
          <label for="startDate" class="block text-sm font-medium text-gray-700 mb-1">Desde</label>
          <input type="month" id="startDate" v-model="filters.startDate"
                 class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
        </div>
        <div class="w-1/2">
          <label for="endDate" class="block text-sm font-medium text-gray-700 mb-1">Hasta</label>
          <input type="month" id="endDate" v-model="filters.endDate"
                 class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
        </div>
      </div>
      <button @click="fetchData"
              class="mt-4 w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
        Aplicar Filtros
      </button>
    </div>
    
    <!-- Resumen general -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-white p-4 rounded-lg shadow-md">
        <h3 class="text-lg font-medium text-gray-800 mb-2">Gasto Total</h3>
        <p class="text-2xl font-bold text-blue-600">{{ formatCurrency(totalExpenses) }}</p>
      </div>
      
      <div class="bg-white p-4 rounded-lg shadow-md">
        <h3 class="text-lg font-medium text-gray-800 mb-2">Gasto Promedio</h3>
        <p class="text-2xl font-bold text-green-600">{{ formatCurrency(averageExpense) }}</p>
      </div>
      
      <div class="bg-white p-4 rounded-lg shadow-md">
        <h3 class="text-lg font-medium text-gray-800 mb-2">Categoría Principal</h3>
        <p class="text-2xl font-bold text-purple-600">{{ mainCategory || 'N/A' }}</p>
      </div>
    </div>
    
    <!-- Gráficos -->
    <div class="bg-white p-4 rounded-lg shadow-md">
      <h3 class="text-lg font-medium text-gray-800 mb-4">Distribución por Categoría</h3>
      <div class="h-64">
        <canvas ref="pieChart" class="h-full w-full"></canvas>
      </div>
    </div>
    
    <div class="bg-white p-4 rounded-lg shadow-md">
      <h3 class="text-lg font-medium text-gray-800 mb-4">Evolución Mensual</h3>
      <div class="h-64">
        <!-- Aquí iría el gráfico de líneas -->
        <div class="flex items-center justify-center h-full bg-gray-100 rounded-md">
          <p class="text-gray-500">Gráfico de evolución mensual</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../supabase';

const user = ref(null);
const monthlyRecords = ref([]);
const filters = ref({
  startDate: '',
  endDate: ''
});

// Datos calculados
const totalExpenses = computed(() => {
  return monthlyRecords.value.reduce((total, record) => {
    return total + (record.expenses?.reduce((sum, expense) => sum + (expense.amount || 0), 0) || 0);
}, 0);
});

const averageExpense = computed(() => {
  if (monthlyRecords.value.length === 0) return 0;
  return totalExpenses.value / monthlyRecords.value.length;
});

const mainCategory = ref('');
const pieChart = ref(null);

// Funciones
async function fetchData() {
  if (!user.value) return;
  
  try {
    let query = supabase
      .from('monthly_expenses')
      .select('*')
      .eq('user_id', user.value.id);
    
    if (filters.value.startDate) {
      query = query.gte('period', filters.value.startDate);
    }
    
    if (filters.value.endDate) {
      query = query.lte('period', filters.value.endDate);
    }
    
    const { data, error } = await query;
    
    if (error) throw error;
    
    // Procesar los gastos
    monthlyRecords.value = data.map(record => {
      try {
        if (record.expenses && typeof record.expenses === 'string') {
          record.expenses = JSON.parse(record.expenses);
        } else if (!record.expenses) {
          record.expenses = [];
        }
      } catch (e) {
        console.error('Error parsing expenses:', e);
        record.expenses = [];
      }
      return record;
    });
  } catch (error) {
    console.error('Error fetching monthly records:', error);
  }
}

function formatCurrency(amount) {
  if (amount === null || amount === undefined) return 'No especificado';
  return new Intl.NumberFormat('es-CL', { style: 'currency', currency: 'CLP' }).format(amount);
}

async function renderCharts() {
  Chart.register(...registerables);
  
  // Datos de ejemplo para el gráfico
  const data = {
    labels: ['Alimentación', 'Transporte', 'Servicios', 'Entretenimiento'],
    datasets: [{
      data: [300, 50, 100, 40],
      backgroundColor: [
        '#3B82F6',
        '#10B981',
        '#F59E0B',
        '#8B5CF6'
      ],
      borderWidth: 1
    }]
  };
  
  new Chart(pieChart.value, {
    type: 'pie',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false
    }
  });
}

onMounted(async () => {
  const { data: { session } } = await supabase.auth.getSession();
  user.value = session?.user;

  if (user.value) {
    await fetchData();
    await renderCharts();
  }

  supabase.auth.onAuthStateChange((_event, session) => {
    user.value = session?.user ?? null;
    if (user.value) {
      fetchData();
      renderCharts();
    } else {
      monthlyRecords.value = [];
      totalExpenses.value = 0;
      averageExpense.value = 0;
      mainCategory.value = '';
    }
  });
});
</script>

<style scoped>
/* Estilos específicos si son necesarios */
</style>