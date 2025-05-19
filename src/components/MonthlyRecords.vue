<template>
    <div class="space-y-6">
        <h2 class="text-xl font-semibold text-gray-700 mb-4">Registros Mensuales</h2>



        <!-- Filtro por mes -->
        <div class="bg-white  rounded-lg  max-w-fit">
            <div class="flex items-center space-x-4">
                <div class="flex-1">
                    <label for="filterMonth" class="block text-sm font-medium text-gray-700 mb-1">Filtrar por
                        Mes</label>
                    <input type="month" id="filterMonth" v-model="filterMonth"
                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                </div>
                <button @click="fetchMonthlyRecords"
                    class="mt-6 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                    Filtrar
                </button>
            </div>
        </div>

        <!-- Lista de registros -->
        <div class="bg-white  rounded-lg space-y-4">
            <div v-if="monthlyRecords.length > 0" class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th scope="col"
                                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Mes/Año</th>
                            <th scope="col"
                                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Gastos</th>
                            <th scope="col"
                                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Total</th>
                            <th scope="col"
                                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Pendiente</th>
                            <th scope="col"
                                class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <tr v-for="record in monthlyRecords" :key="record.id">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ record.period
                            }}</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{{ record.expenses.length }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {{ getTotal(record.expenses) }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                {{ getPendiente(record.expenses) }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                                <button @click="editRecord(record)"
                                    class="text-blue-600 hover:text-blue-900 mr-3">Editar</button>
                                <button @click="deleteRecord(record.id)"
                                    class="text-red-600 hover:text-red-900">Eliminar</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div v-else class="text-center text-gray-500 py-6">
                <p>No hay registros mensuales para mostrar.</p>
            </div>
        </div>

        <!-- Modal para editar registro -->
        <div v-if="showEditModal"
            class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                <div class="p-6 space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-xl font-semibold text-gray-800">Editar Registro - {{ editingRecord.period }}
                        </h3>
                        <button @click="showEditModal = false" class="text-gray-500 hover:text-gray-700">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <div class="space-y-4">
                        <div v-for="(expense, index) in editingRecord.expenses" :key="index"
                            class="p-3 bg-gray-50 rounded-md border border-gray-200 space-y-3">
                            <div>
                                <label :for="`editDesc${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
                                <input type="text" :id="`editDesc${index}`" v-model="expense.description" required
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                            </div>

                            <div>
                                <label :for="`editAmount${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Monto</label>
                                <input type="number" :id="`editAmount${index}`" v-model.number="expense.amount"
                                    step="0.01" required
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                            </div>

                            <div>
                                <label :for="`editType${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Tipo de Gasto</label>
                                <select :id="`editType${index}`" v-model="expense.expense_type_id" required
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                    <option :value="null">Seleccionar tipo</option>
                                    <option v-for="type in expenseTypes" :key="type.id" :value="type.id">{{ type.name }}
                                    </option>
                                </select>
                            </div>

                            <div>
                                <label :for="`editMethod${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Método de Pago</label>
                                <select :id="`editMethod${index}`" v-model="expense.payment_method_id"
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                    <option :value="null">Seleccionar método</option>
                                    <option v-for="method in paymentMethods" :key="method.id" :value="method.id">{{
                                        method.name }}</option>
                                </select>
                            </div>

                            <div>
                                <label :for="`editDate${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Fecha de Pago</label>
                                <input type="date" :id="`editDate${index}`" v-model="expense.date" required
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                            </div>
                        </div>
                    </div>

                    <div class="pt-4 flex justify-end space-x-3">
                        <button @click="showEditModal = false"
                            class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            Cancelar
                        </button>
                        <button @click="updateRecord"
                            class="px-4 py-2 border border-transparent rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                            Guardar Cambios
                        </button>
                    </div>
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
const expenseTypes = ref([]);
const paymentMethods = ref([]);
const filterMonth = ref('');
const showEditModal = ref(false);
const editingRecord = ref({
    id: null,
    period: '',
    expenses: []
});
const errorMessage = ref('');

// Obtener registros mensuales
async function fetchMonthlyRecords() {
    if (!user.value) return;

    try {
        let query = supabase
            .from('monthly_expenses')
            .select('*')
            .eq('user_id', user.value.id)
            .order('period', { ascending: false });

        if (filterMonth.value) {
            query = query.eq('period', filterMonth.value);
        }

        const { data, error } = await query;
        console.log(data)

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
                console.error('Error parsing record expenses:', e);
                record.expenses = [];
            }
            return record;
        });
    } catch (error) {
        errorMessage.value = `Error al cargar registros: ${error.message}`;
        console.error('Error fetching monthly records:', error);
    }
}

// Obtener tipos de gasto y métodos de pago
async function fetchExpenseTypes() {
    if (!user.value) return;
    try {
        const { data, error } = await supabase
            .from('expense_types')
            .select('*')
            .eq('user_id', user.value.id)
            .order('name', { ascending: true });
        if (error) throw error;
        expenseTypes.value = data;
    } catch (error) {
        console.error('Error fetching expense types:', error);
    }
}

async function fetchPaymentMethods() {
    if (!user.value) return;
    try {
        const { data, error } = await supabase
            .from('payment_methods')
            .select('*')
            .eq('user_id', user.value.id)
            .order('name', { ascending: true });
        if (error) throw error;
        paymentMethods.value = data;
    } catch (error) {
        console.error('Error fetching payment methods:', error);
    }
}

// Editar registro
function editRecord(record) {
    editingRecord.value = {
        id: record.id,
        period: record.period,
        expenses: JSON.parse(JSON.stringify(record.expenses)) // Deep copy
    };
    showEditModal.value = true;
}

// Actualizar registro
async function updateRecord() {
    // Validaciones
    const invalidExpenses = editingRecord.value.expenses.some(expense => {
        return !expense.description.trim() ||
            expense.amount === null ||
            expense.amount <= 0 ||
            !expense.expense_type_id ||
            /* !expense.payment_method_id eliminado para permitir nulo */
            !expense.date;
    });

    if (invalidExpenses) {
        errorMessage.value = 'Por favor completa todos los campos requeridos para cada gasto.';
        return;
    }

    try {
        errorMessage.value = '';

        const { error } = await supabase
            .from('monthly_expenses')
            .update({
                expenses: JSON.stringify(editingRecord.value.expenses)
            })
            .eq('id', editingRecord.value.id);

        if (error) throw error;

        // Actualizar lista
        await fetchMonthlyRecords();
        showEditModal.value = false;

        // Mostrar mensaje de éxito
        alert('Registro actualizado exitosamente');
    } catch (error) {
        errorMessage.value = `Error al actualizar registro: ${error.message}`;
        console.error('Error updating record:', error);
    }
}

// Eliminar registro
async function deleteRecord(recordId) {
    if (!confirm('¿Estás seguro de que deseas eliminar este registro?')) return;

    try {
        errorMessage.value = '';
        const { error } = await supabase
            .from('monthly_expenses')
            .delete()
            .eq('id', recordId);

        if (error) throw error;

        // Actualizar lista
        await fetchMonthlyRecords();
        alert('Registro eliminado exitosamente');
    } catch (error) {
        errorMessage.value = `Error al eliminar registro: ${error.message}`;
        console.error('Error deleting record:', error);
    }
}

// Calcular total
function calculateTotal(expenses) {
    return expenses.reduce((total, expense) => total + (expense.amount || 0), 0);
}

// Formatear moneda
function formatCurrency(amount) {
    return new Intl.NumberFormat('es-CL', { style: 'currency', currency: 'CLP' }).format(amount);
}

const getTotal = (expenses) => {
    const total = calculateTotal(expenses);
    return formatCurrency(total);
};

const getPendiente = (expenses) => {
    const pendientes = expenses.filter(expense => !expense.payment_method_id);
    const total = calculateTotal(pendientes);
    return formatCurrency(total);
};


// Inicializar
onMounted(async () => {
    console.log('montabo')
    user.value = (await supabase.auth.getUser()).data.user;
    await Promise.all([
        fetchMonthlyRecords(),
        fetchExpenseTypes(),
        fetchPaymentMethods()
    ]);
});


</script>