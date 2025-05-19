<template>
    <div class="space-y-6">
        <h2 class="text-xl font-semibold text-gray-700 mb-4">Plantillas de Gastos Recurrentes</h2>

        <div class="grid grid-cols-2 gap-x-5">
            <!-- Formulario para agregar nueva plantilla -->
            <form @submit.prevent="createTemplate" class="bg-white rounded-lg  space-y-4">
                <h3 class="text-lg font-medium text-gray-800">Crear Nueva Plantilla</h3>
                <div>
                    <label for="templateName" class="block text-sm font-medium text-gray-700 mb-1">Nombre de la
                        Plantilla</label>
                    <input type="text" id="templateName" v-model="newTemplate.name" required
                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        placeholder="Ej: Gastos Mensuales Básicos">
                </div>

                <!-- Lista de ítems de la plantilla -->
                <div class="space-y-4">
                    <h4 class="text-md font-medium text-gray-700">Ítems de Gasto Recurrentes</h4>

                    <div v-for="(item, index) in newTemplate.items" :key="index"
                        class="p-3 bg-gray-50 rounded-md border border-gray-200 space-y-3">
                        <div class="flex justify-between">
                            <h5 class="font-medium text-gray-700">Ítem #{{ index + 1 }}</h5>
                            <button type="button" @click="removeTemplateItem(index)"
                                class="text-red-500 hover:text-red-700">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                    xmlns="http://www.w3.org/2000/svg">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                    </path>
                                </svg>
                            </button>
                        </div>

                        <div class="grid grid-cols-3 gap-x-4">
                            <div>
                                <label :for="`itemName${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
                                <input type="text" :id="`itemName${index}`" v-model="item.description" required
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                    placeholder="Ej: Arriendo, Luz, Agua">
                            </div>

                            <div>
                                <label :for="`itemAmount${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Monto
                                    Estimado</label>
                                <input type="number" :id="`itemAmount${index}`" v-model.number="item.amount" step="0.01"
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                                    placeholder="Monto aproximado">
                            </div>

                            <div>
                                <label :for="`itemExpenseType${index}`"
                                    class="block text-sm font-medium text-gray-700 mb-1">Tipo de Gasto</label>
                                <select :id="`itemExpenseType${index}`" v-model="item.expense_type_id"
                                    class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                    <option :value="null">Seleccionar tipo</option>
                                    <option v-for="type in expenseTypes" :key="type.id" :value="type.id">{{ type.name }}
                                    </option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <button type="button" @click="addTemplateItem"
                        class="w-full bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors">
                        + Agregar Ítem
                    </button>
                </div>

                <button type="submit"
                    class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                    Guardar Plantilla
                </button>

            </form>

            <!-- Lista de plantillas existentes -->
            <div class="bg-white">
                <h3 class="text-lg font-medium text-gray-800 mb-4">Mis Plantillas</h3>

                <div v-if="expenseTemplates.length > 0" class="space-y-4">
                    <div v-for="template in expenseTemplates" :key="template.id"
                        class="bg-gray-50 rounded-md border border-gray-200">
                        <div class="p-4 flex justify-between items-center cursor-pointer"
                            @click="toggleTemplateExpansion(template.id)">
                            <h4 class="font-medium text-gray-700 text-lg">{{ template.name }}</h4>
                            <div class="flex items-center space-x-2">
                                <button @click.stop="createMonthlyRecord(template)"
                                    class="text-green-600 hover:text-green-800 font-medium p-1 rounded-md hover:bg-green-100 transition-colors flex items-center">
                                    <svg class="w-5 h-5 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                        xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                    </svg>
                                    Crear Registro Mensual
                                </button>
                                <button @click.stop="removeExpenseTemplate(template.id)"
                                    class="text-red-500 hover:text-red-700 font-medium p-1 rounded-md hover:bg-red-100 transition-colors">
                                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                        xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16">
                                        </path>
                                    </svg>
                                </button>
                                <button @click.stop="toggleTemplateExpansion(template.id)"
                                    class="text-gray-500 hover:text-gray-700 p-1">
                                    <svg class="w-6 h-6 transition-transform duration-200 ease-in-out"
                                        :class="{ 'rotate-180': expandedTemplates.has(template.id) }" fill="none"
                                        stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                            d="M19 9l-7 7-7-7"></path>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <div v-show="expandedTemplates.has(template.id)" class="p-4 border-t border-gray-200 space-y-3">
                            <div class="divide-y divide-gray-200">
                                <div v-for="(item, index) in template.items" :key="index" class="py-2">
                                    <div class="flex justify-between">
                                        <span class="font-medium">{{ item.description }}</span>
                                        <span>{{ formatCurrency(item.amount) }}</span>
                                    </div>
                                    <div class="text-xs text-gray-500">
                                        <span>Tipo: {{ getExpenseTypeName(item.expense_type_id) }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div v-else class="text-center text-gray-500 py-6">
                    <p class="mb-1">No has creado ninguna plantilla de gastos.</p>
                    <p class="text-sm">Usa el formulario de arriba para agregar una.</p>
                </div>
            </div>
        </div>

        <!-- Modal para crear registro mensual -->
        <div v-if="showMonthlyRecordModal"
            class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
            <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                <div class="p-6 space-y-4">
                    <div class="flex justify-between items-center">
                        <h3 class="text-xl font-semibold text-gray-800">Crear Registro Mensual</h3>
                        <button @click="showMonthlyRecordModal = false" class="text-gray-500 hover:text-gray-700">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"
                                xmlns="http://www.w3.org/2000/svg">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                        </button>
                    </div>

                    <div class="space-y-4">
                        <div>
                            <label for="recordMonth" class="block text-sm font-medium text-gray-700 mb-1">Mes y
                                Año</label>
                            <input type="month" id="recordMonth" v-model="monthlyRecord.period" required
                                class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                        </div>

                        <div class="space-y-4">
                            <h4 class="text-md font-medium text-gray-700">Gastos del Mes</h4>

                            <div v-for="(expense, index) in monthlyRecord.expenses" :key="index"
                                class="p-3 bg-gray-50 rounded-md border border-gray-200 space-y-3">
                                <div>
                                    <label :for="`expenseDesc${index}`"
                                        class="block text-sm font-medium text-gray-700 mb-1">Descripción</label>
                                    <input type="text" :id="`expenseDesc${index}`" v-model="expense.description"
                                        required
                                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                </div>

                                <div>
                                    <label :for="`expenseAmount${index}`"
                                        class="block text-sm font-medium text-gray-700 mb-1">Monto</label>
                                    <input type="number" :id="`expenseAmount${index}`" v-model.number="expense.amount"
                                        step="0.01" required
                                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                </div>

                                <div>
                                    <label :for="`expenseType${index}`"
                                        class="block text-sm font-medium text-gray-700 mb-1">Tipo de Gasto</label>
                                    <select :id="`expenseType${index}`" v-model="expense.expense_type_id" required
                                        class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                        <option :value="null">Seleccionar tipo</option>
                                        <option v-for="type in expenseTypes" :key="type.id" :value="type.id">{{
                                            type.name }}</option>
                                    </select>
                                </div>

                                <div>
                                    <label :for="`paymentMethod${index}`"
                                        class="block text-sm font-medium text-gray-700 mb-1">Método de Pago</label>
                                    <select :id="`paymentMethod${index}`" v-model="expense.payment_method_id"
                                        class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                        <option :value="null">Seleccionar método</option>
                                        <option v-for="method in paymentMethods" :key="method.id" :value="method.id">{{
                                            method.name }}</option>
                                    </select>
                                </div>

                                <div>
                                    <label :for="`expenseDate${index}`"
                                        class="block text-sm font-medium text-gray-700 mb-1">Fecha de Pago</label>
                                    <input type="date" :id="`expenseDate${index}`" v-model="expense.date" required
                                        class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                                </div>
                            </div>
                        </div>

                        <div class="pt-4 flex justify-end space-x-3">
                            <button @click="showMonthlyRecordModal = false"
                                class="px-4 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                                Cancelar
                            </button>
                            <button @click="saveMonthlyRecord"
                                class="px-4 py-2 border border-transparent rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                                Guardar Registro
                            </button>
                        </div>
                        <p v-if="errorMessage" class="text-red-500 text-sm">{{ errorMessage }}</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Visualización simple de registros mensuales para depuración -->
        <!-- <div class="bg-gray-100 p-4 rounded-md mt-8">
            <h3 class="text-lg font-semibold text-gray-700 mb-2">Registros Mensuales (debug)</h3>
            <div v-if="errorMessage && errorMessage.includes('mensual')" class="text-red-500 text-sm mb-2">{{
                errorMessage }}</div>
            <div v-if="monthlyRecords.length > 0">
                <ul>
                    <li v-for="reg in monthlyRecords" :key="reg.id" class="border-b border-gray-300 py-2">
                        <strong>Período:</strong> {{ reg.period }} <span
                            v-if="Array.isArray(reg.expenses) && reg.expenses.length"> - {{ reg.expenses.length }}
                            gastos</span>
                        <br>
                        <span class="text-xs text-gray-500">ID: {{ reg.id }}</span>
                    </li>
                </ul>
            </div>
            <div v-else class="text-gray-500">No hay registros mensuales cargados desde la base de datos.</div>
        </div> -->
    </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { supabase } from '../supabase';
import { useToast } from 'vue-toastification'
const toast = useToast()

const user = ref(null);
const expenseTemplates = ref([]);
const expenseTypes = ref([]);
const paymentMethods = ref([]);
const errorMessage = ref('');
const expandedTemplates = ref(new Set()); // Rastrea las plantillas expandidas

function toggleTemplateExpansion(templateId) {
    if (expandedTemplates.value.has(templateId)) {
        expandedTemplates.value.delete(templateId);
    } else {
        expandedTemplates.value.add(templateId);
    }
}

// Nueva estructura para plantillas con múltiples ítems
const newTemplate = ref({
    name: '',
    items: []
});

// Modal y datos para registros mensuales
const showMonthlyRecordModal = ref(false);
const selectedTemplate = ref(null);
const monthlyRecord = ref({
    period: '',
    expenses: []
});

// Funciones para manejar ítems de plantilla
function addTemplateItem() {
    newTemplate.value.items.push({
        description: '',
        amount: null,
        expense_type_id: null
    });
}

function removeTemplateItem(index) {
    newTemplate.value.items.splice(index, 1);
}

// Funciones para obtener datos
// async function fetchMonthlyRecords() {
//     if (!user.value) return;
//     try {
//         const { data, error } = await supabase
//             .from('monthly_expenses')
//             .select('*')
//             .eq('user_id', user.value.id)
//             .order('period', { ascending: false });

//         if (error) throw error;

//         // Procesar los gastos de cada registro
//         for (const record of data) {
//             try {
//                 if (record.expenses && typeof record.expenses === 'string') {
//                     record.expenses = JSON.parse(record.expenses);
//                 } else if (!record.expenses) {
//                     record.expenses = [];
//                 }
//             } catch (e) {
//                 console.error('Error parsing record expenses:', e);
//                 record.expenses = [];
//             }
//         }

//         monthlyRecords.value = data;
//     } catch (error) {
//         console.error('Error fetching monthly records:', error);
//     }
// }

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

async function fetchExpenseTemplates() {
    if (!user.value) return;
    try {
        errorMessage.value = '';
        const { data, error } = await supabase
            .from('expense_templates')
            .select('*')
            .eq('user_id', user.value.id)
            .order('created_at', { ascending: false });

        // await fetchMonthlyRecords();

        if (error) throw error;

        // Procesar las plantillas para extraer los ítems
        for (const template of data) {
            try {
                if (template.items && typeof template.items === 'string') {
                    template.items = JSON.parse(template.items);
                } else if (!template.items) {
                    template.items = [];
                }
            } catch (e) {
                console.error('Error parsing template items:', e);
                template.items = [];
            }
        }

        expenseTemplates.value = data;
    } catch (error) {
        errorMessage.value = `Error al cargar plantillas: ${error.message}`;
        console.error('Error fetching expense templates:', error);
    }
}

// Crear nueva plantilla
async function createTemplate() {
    if (!user.value) return;

    // Validar nombre de plantilla
    if (!newTemplate.value.name.trim()) {
        errorMessage.value = 'El nombre de la plantilla es obligatorio.';
        return;
    }

    // Validar que haya al menos un ítem
    if (newTemplate.value.items.length === 0) {
        errorMessage.value = 'Debes agregar al menos un ítem a la plantilla.';
        return;
    }

    // Validar que todos los ítems tengan datos válidos
    for (const item of newTemplate.value.items) {
        if (!item.description.trim()) {
            errorMessage.value = 'La descripción de todos los ítems es obligatoria.';
            return;
        }

        if (item.amount === null || item.amount <= 0) {
            errorMessage.value = 'El monto debe ser mayor que cero.';
            return;
        }

        if (!item.expense_type_id) {
            errorMessage.value = 'Debes seleccionar un tipo de gasto para todos los ítems.';
            return;
        }
    }

    try {
        errorMessage.value = '';
        const templateData = {
            user_id: user.value.id,
            name: newTemplate.value.name.trim(),
            items: JSON.stringify(newTemplate.value.items)
        };

        const { data, error } = await supabase
            .from('expense_templates')
            .insert([templateData])
            .select();

        if (error) throw error;

        if (data && data.length > 0) {
            // Procesar los ítems antes de agregar a la lista
            try {
                data[0].items = JSON.parse(data[0].items);
            } catch (e) {
                data[0].items = [];
            }
            expenseTemplates.value.unshift(data[0]);
        }

        // Resetear el formulario
        newTemplate.value = { name: '', items: [] };
    } catch (error) {
        errorMessage.value = `Error al agregar plantilla: ${error.message}`;
        console.error('Error adding expense template:', error);
    }
}

// Eliminar plantilla
async function removeExpenseTemplate(templateId) {
    if (!user.value) return;
    try {
        errorMessage.value = '';
        const { error } = await supabase
            .from('expense_templates')
            .delete()
            .match({ id: templateId, user_id: user.value.id });

        if (error) throw error;
        expenseTemplates.value = expenseTemplates.value.filter(template => template.id !== templateId);
    } catch (error) {
        errorMessage.value = `Error al eliminar plantilla: ${error.message}`;
        console.error('Error removing expense template:', error);
    }
}

// Funciones para registros mensuales
function createMonthlyRecord(template) {
    selectedTemplate.value = template;

    // Inicializar el periodo con el mes actual
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    monthlyRecord.value.period = `${year}-${month}`;

    // Crear gastos basados en la plantilla
    monthlyRecord.value.expenses = template.items.map(item => ({
        description: item.description,
        amount: item.amount,
        expense_type_id: item.expense_type_id,
        payment_method_id: null,
        date: new Date().toISOString().split('T')[0] // Fecha actual como valor predeterminado
    }));

    showMonthlyRecordModal.value = true;
}

async function saveMonthlyRecord() {
    if (!user.value) {
        errorMessage.value = 'Debes iniciar sesión para guardar registros.';
        return;
    }

    // Validar periodo
    if (!monthlyRecord.value.period) {
        errorMessage.value = 'Debes seleccionar un mes y año.';
        return;
    }

    // Validar formato del periodo (YYYY-MM)
    if (!/^\d{4}-\d{2}$/.test(monthlyRecord.value.period)) {
        errorMessage.value = 'Formato de periodo inválido. Debe ser YYYY-MM.';
        return;
    }

    // Validar que haya al menos un gasto
    if (monthlyRecord.value.expenses.length === 0) {
        errorMessage.value = 'Debes agregar al menos un gasto.';
        return;
    }

    // Validar que todos los gastos tengan datos válidos
    const invalidExpenses = monthlyRecord.value.expenses.some(expense => {
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

    // Validar fechas dentro del mes seleccionado
    const [year, month] = monthlyRecord.value.period.split('-');
    const invalidDates = monthlyRecord.value.expenses.some(expense => {
        const expenseDate = new Date(expense.date);
        return expenseDate.getFullYear() != year ||
            (expenseDate.getMonth() + 1) != month;
    });

    if (invalidDates) {
        errorMessage.value = 'Todas las fechas deben pertenecer al mes seleccionado.';
        return;
    }

    try {
        errorMessage.value = '';

        // Crear transacción para insertar cada gasto individualmente
        const promises = monthlyRecord.value.expenses.map(expense => {
            return supabase
                .from('expenses')
                .insert([{
                    user_id: user.value.id,
                    description: expense.description,
                    amount: expense.amount,
                    expense_type_id: expense.expense_type_id,
                    payment_method_id: expense.payment_method_id,
                    date: expense.date,
                    is_recurring: true,
                    template_id: selectedTemplate.value.id
                }]);
        });

        // Ejecutar todas las inserciones
        const results = await Promise.all(promises);

        // Verificar errores
        const hasError = results.some(result => result.error);
        if (hasError) {
            throw new Error('Error al guardar uno o más gastos');
        }

        // Guardar también el registro mensual
        const monthlyData = {
            user_id: user.value.id,
            period: monthlyRecord.value.period,
            template_id: selectedTemplate.value.id,
            expenses: JSON.stringify(monthlyRecord.value.expenses)
        };

        const { data, error } = await supabase
            .from('monthly_expenses')
            .insert([monthlyData])
            .select();

        if (error) throw error;

        // Cerrar el modal y resetear los datos
        showMonthlyRecordModal.value = false;
        monthlyRecord.value = { period: '', expenses: [] };
        selectedTemplate.value = null;

        // Mostrar notificación más amigable usando toast
        const successMessage = `Registro para ${monthlyData.period} guardado exitosamente con ${monthlyRecord.value.expenses.length} gastos.`;

        // Usar alert temporalmente (se puede reemplazar por un toast más adelante)
        alert(successMessage);

        // Opcional: Actualizar lista de registros si existe
        // if (typeof fetchMonthlyRecords === 'function') {
        //     await fetchMonthlyRecords();
        // }

    } catch (error) {
        if (error && error.code === '23505') {
            errorMessage.value = 'Ya existe un registro mensual para este mes y plantilla.';
        } else {
            errorMessage.value = `Error al guardar el registro mensual: ${error.message || error}`;
        }
        console.error('Error saving monthly record:', error);
    }
}

// Funciones auxiliares
const getExpenseTypeName = (id) => {
    if (!id) return 'No especificado';
    const type = expenseTypes.value.find(t => t.id === id);
    return type ? type.name : 'N/A';
};

const getPaymentMethodName = (id) => {
    if (!id) return 'No especificado';
    const method = paymentMethods.value.find(m => m.id === id);
    return method ? method.name : 'N/A';
};

const getTemplateName = (id) => {
    if (!id) return 'No especificado';
    const template = expenseTemplates.value.find(t => t.id === id);
    return template ? template.name : 'Plantilla eliminada';
};



function formatCurrency(amount) {
    if (amount === null || amount === undefined) return 'No especificado';
    return new Intl.NumberFormat('es-CL', { style: 'currency', currency: 'CLP' }).format(amount);
}

onMounted(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    user.value = session?.user;

    if (user.value) {
        await fetchExpenseTypes();
        await fetchPaymentMethods();
        await fetchExpenseTemplates();

        // Inicializar con un ítem vacío
        if (newTemplate.value.items.length === 0) {
            addTemplateItem();
        }
    }

    supabase.auth.onAuthStateChange((_event, session) => {
        user.value = session?.user ?? null;
        if (user.value) {
            fetchExpenseTypes();
            fetchPaymentMethods();
            fetchExpenseTemplates();

            // Inicializar con un ítem vacío
            if (newTemplate.value.items.length === 0) {
                addTemplateItem();
            }
        } else {
            expenseTemplates.value = [];
            expenseTypes.value = [];
            paymentMethods.value = [];
        }
    });
});
</script>

<style scoped>
/* Estilos específicos si son necesarios */
</style>

<script>
function mostrarError(mensaje) {
    errorMessage.value = ''
    toast.error(mensaje)
}
function mostrarExito(mensaje) {
    toast.success(mensaje)
}
// Reemplazo de las asignaciones de errorMessage.value y alert
// Por ejemplo:
// errorMessage.value = 'Texto del error'  => mostrarError('Texto del error')
// alert(successMessage) => mostrarExito(successMessage)

// Alternar la visibilidad de los ítems de una plantilla
function toggleTemplateExpansion(templateId) {
    if (expandedTemplates.value.has(templateId)) {
        expandedTemplates.value.delete(templateId);
    } else {
        expandedTemplates.value.add(templateId);
    }
}

// Cargar datos iniciales
onMounted(async () => {
    const { data: { session } } = await supabase.auth.getSession();
    user.value = session?.user;

    if (user.value) {
        await fetchExpenseTypes();
        await fetchPaymentMethods();
        await fetchExpenseTemplates();

        // Inicializar con un ítem vacío
        if (newTemplate.value.items.length === 0) {
            addTemplateItem();
        }
    }

    supabase.auth.onAuthStateChange((_event, session) => {
        user.value = session?.user ?? null;
        if (user.value) {
            fetchExpenseTypes();
            fetchPaymentMethods();
            fetchExpenseTemplates();

            // Inicializar con un ítem vacío
            if (newTemplate.value.items.length === 0) {
                addTemplateItem();
            }
        } else {
            expenseTemplates.value = [];
            expenseTypes.value = [];
            paymentMethods.value = [];
        }
    });
});
</script>