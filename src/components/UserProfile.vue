<template>
    <div class="bg-white dark:bg-slate-800 p-6 rounded-xl shadow-lg max-w-lg mx-auto">
        <h2 class="text-xl font-semibold mb-6 text-gray-700 dark:text-gray-100">Personalización de Usuario</h2>
        <div class="flex flex-col items-center mb-6">
            <img :src="avatarPreview || userAvatar" alt="Foto de perfil"
                class="w-28 h-28 rounded-full object-cover border-4 border-blue-500 mb-3" />
            <input type="file" accept="image/*" @change="onFileChange" class="mb-2" />
        </div>
        <form @submit.prevent="saveProfile" class="space-y-4">
            <div>
                <label class="block text-gray-700 dark:text-gray-200 mb-1">Nombre completo</label>
                <input v-model="fullName"
                    class="w-full px-4 py-2 border rounded-lg bg-gray-100 dark:bg-slate-700 dark:text-gray-100" />
            </div>
            <div>
                <label class="block text-gray-700 dark:text-gray-200 mb-1">Email (no editable)</label>
                <input :value="user.email" disabled
                    class="w-full px-4 py-2 border rounded-lg bg-gray-100 dark:bg-slate-700 dark:text-gray-100" />
            </div>
            <div>
                <label class="block text-gray-700 dark:text-gray-200 mb-1">Nueva contraseña</label>
                <input v-model="newPassword" type="password"
                    class="w-full px-4 py-2 border rounded-lg bg-gray-100 dark:bg-slate-700 dark:text-gray-100"
                    autocomplete="new-password" />
            </div>
            <button :disabled="loading" type="submit"
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-lg focus:outline-none mt-3">
                {{ loading ? 'Guardando...' : 'Guardar Cambios' }}
            </button>
            <p v-if="message" :class="isError ? 'text-red-500' : 'text-green-500'" class="text-center mt-2">{{ message
                }}</p>
        </form>
    </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { supabase } from '../supabase';

const props = defineProps({ user: Object });
const emit = defineEmits(['profileUpdated']);
const user = props.user;

const fullName = ref(user.user_metadata?.full_name || '');
const newPassword = ref('');
const loading = ref(false);
const message = ref('');
const isError = ref(false);
const avatarFile = ref(null);
const avatarPreview = ref('');

const userAvatar = computed(() => user.user_metadata?.avatar_url || 'https://via.placeholder.com/80');

function onFileChange(event) {
    const file = event.target.files[0];
    if (file) {
        avatarFile.value = file;
        const reader = new FileReader();
        reader.onload = e => { avatarPreview.value = e.target.result; };
        reader.readAsDataURL(file);
    }
}

async function saveProfile() {
    loading.value = true;
    message.value = '';
    isError.value = false;
    try {
        // Actualizar nombre
        let updateObj = {};
        if (fullName.value && fullName.value !== user.user_metadata?.full_name) {
            updateObj.full_name = fullName.value;
        }
        let avatar_url = user.user_metadata?.avatar_url;
        // Subir nueva imagen
        if (avatarFile.value) {
            const fileExt = avatarFile.value.name.split('.').pop();
            const fileName = `${user.id}_${Date.now()}.${fileExt}`;
            const { data, error } = await supabase.storage.from('avatars').upload(fileName, avatarFile.value, {
                cacheControl: '3600',
                upsert: true
            });
            if (error) throw new Error('No se pudo subir la imagen de perfil.');
            const { data: urlData } = supabase.storage.from('avatars').getPublicUrl(fileName);
            if (urlData?.publicUrl) {
                avatar_url = urlData.publicUrl;
                updateObj.avatar_url = avatar_url;
            }
        }
        // Actualización de perfil
        if (Object.keys(updateObj).length > 0) {
            const { error } = await supabase.auth.updateUser({ data: updateObj });
            if (error) throw error;
        }
        // Cambiar contraseña
        if (newPassword.value) {
            const { error } = await supabase.auth.updateUser({ password: newPassword.value });
            if (error) throw error;
        }
        message.value = 'Cambios guardados correctamente.';
        isError.value = false;
        emit('profileUpdated', { ...user, ...updateObj, avatar_url });
    } catch (err) {
        message.value = err.message || 'Hubo un error al actualizar el perfil.';
        isError.value = true;
    } finally {
        loading.value = false;
        newPassword.value = '';
    }
}
</script>

<style scoped>
input[type="file"]::-webkit-file-upload-button {
    background: #3b82f6;
    color: white;
    padding: 0.5em 1em;
    border-radius: 0.375rem;
    cursor: pointer;
    border: none;
}
</style>