<template>
  <div v-if="show" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full flex items-center justify-center z-50">
    <div class="relative mx-auto p-8 border w-full max-w-2xl shadow-lg rounded-xl bg-white">
      <div class="text-center">
        <h3 class="text-2xl font-semibold text-gray-900 mb-6">¿Cómo usar el Gestor de Gastos?</h3>
        <div class="mt-4 text-left space-y-4 text-gray-700">
          <section>
            <h4 class="font-semibold text-lg mb-1 text-blue-600">1. Dashboard (Inicio)</h4>
            <p>Aquí verás un resumen de tus finanzas: cuánto has gastado, cuánto te queda por pagar y el total de gastos registrados en el período seleccionado. También encontrarás gráficos para visualizar tus gastos por tipo y cómo han variado mes a mes.</p>
          </section>
          
          <section>
            <h4 class="font-semibold text-lg mb-1 text-blue-600">2. Métodos de Pago</h4>
            <p>Define los diferentes métodos que usas para pagar (ej. Tarjeta de Crédito Banco X, Efectivo, Cuenta Corriente). Así podrás asociar cada gasto a su origen.</p>
          </section>
          
          <section>
            <h4 class="font-semibold text-lg mb-1 text-blue-600">3. Tipos de Gasto</h4>
            <p>Personaliza las categorías de tus gastos (ej. Alimentación, Transporte, Ocio). Esto te ayudará a organizar mejor tus finanzas y a entender en qué estás gastando más.</p>
          </section>
          
          <section>
            <h4 class="font-semibold text-lg mb-1 text-blue-600">4. Plantillas de Gastos</h4>
            <p>Si tienes gastos que se repiten con frecuencia (ej. arriendo, suscripciones), puedes crear plantillas aquí. Luego, al agregar un gasto en "Registros Mensuales", podrás seleccionar una plantilla para autocompletar la información rápidamente.</p>
          </section>
          <section>
            <h4 class="font-semibold text-lg mb-1 text-blue-600">5. Registros Mensuales</h4>
            <p>Esta es la sección principal para llevar el control de tus gastos. Puedes agregar nuevos gastos, especificando la fecha, descripción, monto, si ya está pagado, el tipo de gasto y el método de pago. También puedes editar o eliminar gastos existentes.</p>
          </section>
          <section>
            <h4 class="font-semibold text-lg mt-6 mb-1 text-gray-800">¡Empieza a organizar tus finanzas!</h4>
            <p>Explora cada sección y comienza a registrar tus movimientos. ¡Verás qué fácil es tener tus gastos bajo control!</p>
          </section>
        </div>
        <div class="mt-8 flex justify-end">
          <button @click="closeModal" class="px-6 py-2 bg-blue-600 text-white text-base font-medium rounded-md shadow-sm hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
            Entendido
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, defineEmits } from 'vue';

const props = defineProps({
  show: {
    type: Boolean,
    required: true
  }
});

const emit = defineEmits(['close']);

function closeModal() {
  emit('close');
}
</script>

<style scoped>
/* Estilos adicionales si son necesarios */
</style>