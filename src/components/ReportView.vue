<template>
  <div class="space-y-8">
    <h2 class="text-2xl font-semibold text-gray-700 dark:text-gray-200 mb-4">Informes y Reportes</h2>
    <div class="bg-white dark:bg-slate-800 p-6 rounded-lg ">
      <h3 class="text-lg font-medium text-gray-800 dark:text-gray-100 mb-4">Resumen mensual</h3>
      <div class="flex justify-between items-center mb-6">
        <div>
          <label for="reportMonth" class="block text-sm font-medium text-gray-700 dark:text-gray-200 mb-1">Selecciona el
            mes:</label>
          <input type="month" id="reportMonth" v-model="selectedPeriod"
            class="border rounded px-3 py-1 dark:bg-slate-700 dark:border-slate-600 dark:text-gray-200" />
        </div>
      </div>
      <div v-if="loading" class="text-gray-500 dark:text-gray-400">Cargando datos...</div>
      <div v-else class="grid grid-cols-2 gap-x-8">
        <!-- Métricas principales -->
        <div class="grid grid-cols-1  gap-4 mb-8">
          <div class="grid grid-cols-3 gap-x-3">
            <div class="p-4 bg-gray-50 dark:bg-slate-700 rounded-md shadow border dark:border-slate-600">
              <div class="font-medium text-gray-500 dark:text-gray-400">Total Gastado</div>
              <div class="text-xl font-bold text-blue-600 dark:text-blue-400">
                {{ formatCurrency(metrics.totalSpent) }}
              </div>
            </div>
            <div class="p-4 bg-gray-50 dark:bg-slate-700 rounded-md shadow border dark:border-slate-600">
              <div class="font-medium text-gray-500 dark:text-gray-400">Gastos Pendientes de Pago</div>
              <div class="text-xl font-bold text-blue-600 dark:text-blue-400">
                {{ formatCurrency(metrics.pendingAmount) }}
              </div>
            </div>
            <div class="p-4 bg-gray-50 dark:bg-slate-700 rounded-md shadow border dark:border-slate-600">
              <div class="font-medium text-gray-500 dark:text-gray-400">N° de Gastos Registrados</div>
              <div class="text-xl font-bold text-blue-600 dark:text-blue-400">
                {{ metrics.expenseCount }}
              </div>
            </div>
          </div>
          <!-- Gráficos -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div>
              <h4 class="text-md font-medium text-gray-700 dark:text-gray-200 mb-2">Gastos por tipo</h4>
              <canvas ref="typeChart"></canvas>
            </div>
            <div>
              <h4 class="text-md font-medium text-gray-700 dark:text-gray-200 mb-2">Comparativo mensual</h4>
              <canvas ref="monthlyChart"></canvas>
            </div>
          </div>
        </div>

        <div>
          <!-- Tabla de Gastos Detallados -->
          <div class="mt-8">
            <h4 class="text-md font-medium text-gray-700 dark:text-gray-200 mb-2">Detalle de Gastos del Mes</h4>
            <div v-if="detailedExpenses.length > 0"
              class="overflow-x-auto bg-white dark:bg-slate-800 rounded-lg shadow">
              <table class="min-w-full divide-y divide-gray-200 dark:divide-slate-700">
                <thead class="bg-gray-50 dark:bg-slate-700">
                  <tr>
                    <th scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Descripción
                    </th>
                    <th scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Monto</th>
                    <th scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Fecha</th>
                    <th scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Tipo de
                      Gasto
                    </th>
                    <th scope="col"
                      class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Método de
                      Pago</th>
                  </tr>
                </thead>
                <tbody class="bg-white dark:bg-slate-800 divide-y divide-gray-200 dark:divide-slate-700">
                  <tr v-for="expense in detailedExpenses" :key="expense.id || expense.date + expense.description">
                    <!-- Asegurar una key única -->
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-gray-100">{{
                      expense.description || 'N/A' }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">{{
                      formatCurrency(expense.amount) }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">{{ expense.date }}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">{{
                      expenseTypes[expense.expense_type_id]
                      || 'Desconocido' }}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">{{
                      paymentMethods[expense.payment_method_id] || 'No especificado' }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-else class="text-center py-4 text-gray-500 dark:text-gray-400">
              No hay gastos detallados para este período.
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue';
import Chart from 'chart.js/auto';
import { supabase } from '../supabase';

const user = ref(null);
const selectedPeriod = ref(new Date().toISOString().slice(0, 7));
const metrics = ref({ totalSpent: 0, pendingAmount: 0, expenseCount: 0 });
const loading = ref(true);
const detailedExpenses = ref([]);
const paymentMethods = ref({}); // Para almacenar { id: name }
const expenseTypes = ref({}); // Para almacenar { id: name }

// Refs para los gráficos
const typeChart = ref(null);
const monthlyChart = ref(null);
let typeChartInstance = null;
let monthlyChartInstance = null;
let detailedExpensesTable = null; // Placeholder if needed for direct DOM manipulation, usually not for Vue.

function formatCurrency(amount) {
  return amount?.toLocaleString('es-CL', { style: 'currency', currency: 'CLP' }) || '-';
}

async function fetchExpenseTypes() {
  if (!user.value) return;
  const { data, error } = await supabase
    .from('expense_types')
    .select('id, name')
    .eq('user_id', user.value.id);

  if (error) {
    console.error('Error fetching expense types:', error);
    return;
  }
  if (data) {
    expenseTypes.value = data.reduce((acc, type) => {
      acc[type.id] = type.name;
      return acc;
    }, {});
  }
}

async function fetchPaymentMethods() {
  if (!user.value) return;
  const { data, error } = await supabase
    .from('payment_methods')
    .select('id, name')
    .eq('user_id', user.value.id);

  if (error) {
    console.error('Error fetching payment methods:', error);
    return;
  }
  if (data) {
    paymentMethods.value = data.reduce((acc, method) => {
      acc[method.id] = method.name;
      return acc;
    }, {});
  }
}

async function fetchMonthlyReport() {
  if (!user.value || !selectedPeriod.value) return;
  loading.value = true;
  // Obtener datos de gastos por periodo
  const { data, error } = await supabase
    .from('monthly_expenses')
    .select('*')
    .eq('user_id', user.value.id)
    .eq('period', selectedPeriod.value)
    .maybeSingle();
  if (error) { loading.value = false; return; }
  let expenses = [];
  if (data && data.expenses && typeof data.expenses === 'string') {
    try { expenses = JSON.parse(data.expenses); } catch { }
  } else if (data && Array.isArray(data.expenses)) {
    expenses = data.expenses;
  }
  // Calcular métricas
  let totalSpent = 0;
  let pendingAmount = 0;
  const countsByType = {};
  const days = new Set();
  expenses.forEach(exp => {
    totalSpent += Number(exp.amount) || 0;
    // Pendiente: si payment_method_id es falsy
    if (!exp.payment_method_id) {
      pendingAmount += Number(exp.amount) || 0;
    }
    countsByType[exp.expense_type_id] = (countsByType[exp.expense_type_id] || 0) + (Number(exp.amount) || 0);
    if (exp.date) days.add(exp.date);
  });
  metrics.value = {
    totalSpent,
    pendingAmount,
    expenseCount: expenses.length
  };
  detailedExpenses.value = expenses; // Almacenar los gastos detallados

  loading.value = false; // Establecer loading a false para que se renderice el div con los canvas
  await nextTick();     // Esperar a que Vue actualice el DOM

  renderTypeChart(countsByType);
  await fetchMonthlyComparative();
  // loading.value = false; // Esta línea se movió arriba y ya no es necesaria aquí
}

async function fetchMonthlyComparative() {
  // Extrae gastos de varios meses para gráfico comparativo
  if (!user.value) return;
  const thisYear = selectedPeriod.value?.substring(0, 4);
  const { data, error } = await supabase
    .from('monthly_expenses')
    .select('period,expenses')
    .eq('user_id', user.value.id)
    .gte('period', `${thisYear}-01`)
    .lte('period', `${thisYear}-12`)
    .order('period', { ascending: true });
  if (error) return;
  const periods = [];
  const amounts = [];
  for (const reg of data) {
    periods.push(reg.period);
    let expenses = [];
    if (reg.expenses && typeof reg.expenses === 'string') {
      try { expenses = JSON.parse(reg.expenses); } catch { }
    } else if (Array.isArray(reg.expenses)) {
      expenses = reg.expenses;
    }
    amounts.push(expenses.reduce((sum, exp) => sum + (Number(exp.amount) || 0), 0));
  }
  // Esperar a que el DOM y ref estén listos antes de renderizar el gráfico
  await nextTick();
  renderMonthlyChart(periods, amounts);
}

function renderMonthlyChart(periods, amounts) {
  if (!monthlyChart.value) return;
  if (monthlyChartInstance) monthlyChartInstance.destroy();

  if (periods.length === 0) {
    console.warn('No data available for monthly comparative chart.');
    const ctx = monthlyChart.value.getContext('2d');
    if (ctx) {
      ctx.clearRect(0, 0, monthlyChart.value.width, monthlyChart.value.height);
      // Opcionalmente, mostrar un mensaje como 'Sin datos' en el canvas:
      // ctx.textAlign = 'center';
      // ctx.font = '14px Arial';
      // ctx.fillStyle = '#888';
      // ctx.fillText('Sin datos para mostrar', monthlyChart.value.width / 2, monthlyChart.value.height / 2);
    }
    return;
  }

  monthlyChartInstance = new Chart(monthlyChart.value, {
    type: 'bar',
    data: {
      labels: periods,
      datasets: [{ label: 'Gasto mensual', data: amounts, backgroundColor: '#60a5fa' }]
    },
    options: { responsive: true, plugins: { legend: { display: false } } }
  });
}

function renderTypeChart(countsByType) {
  if (!typeChart.value) {
    console.warn('Attempted to render type chart, but canvas ref is not available.');
    return;
  }
  // Limpia el gráfico anterior
  if (typeChartInstance) typeChartInstance.destroy();

  const labels = Object.keys(countsByType).map(id => {
    return expenseTypes.value[id] || `Tipo Desconocido (${id})`; // Usar nombre del tipo o fallback
  });
  const dataValues = Object.values(countsByType);

  if (labels.length === 0) {
    console.warn('No data available for type chart.');
    const ctx = typeChart.value.getContext('2d');
    if (ctx) {
      ctx.clearRect(0, 0, typeChart.value.width, typeChart.value.height);
      // Opcionalmente, mostrar un mensaje como 'Sin datos' en el canvas:
      // ctx.textAlign = 'center';
      // ctx.font = '14px Arial';
      // ctx.fillStyle = '#888';
      // ctx.fillText('Sin datos para mostrar', typeChart.value.width / 2, typeChart.value.height / 2);
    }
    return;
  }

  typeChartInstance = new Chart(typeChart.value, {
    type: 'doughnut',
    data: { labels, datasets: [{ data: dataValues, backgroundColor: ['#3490dc', '#fbbf24', '#ef4444', '#22d3ee', '#6d28d9'] }] },
    options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
  });
}

onMounted(async () => {
  // Obtener el usuario logueado (ajusta según cómo gestionas el usuario)
  const { data: userData } = await supabase.auth.getUser();
  user.value = userData?.user || null;

  if (user.value) {
    await fetchExpenseTypes(); // Cargar tipos de gasto primero
    await fetchPaymentMethods(); // Cargar métodos de pago
  }
  await fetchMonthlyReport(); // Luego cargar el reporte mensual que usa los tipos y métodos
});

watch(selectedPeriod, async () => {
  await fetchMonthlyReport();
});
</script>

<style scoped>
canvas {
  background: #fff;
}
</style>