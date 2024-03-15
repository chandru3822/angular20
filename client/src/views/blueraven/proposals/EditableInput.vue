<template>
  <div class="editable-input d-flex pa-0 align-center">
    <span v-if="!isEditMode">{{ displayText || name }}</span>
    <a-text-field v-else v-model="name" solo single-line flat autofocus />
    <div v-if="editable">
      <a-btn
          size="small"
          icon
          color="primary"
          @click="handleEdit"
          class="pl-2"
          v-if="editable"
          :prepend-icon="!isEditMode ? 'mdi-pencil' : 'mdi-close'"
      ></a-btn>
      <a-btn
          size="small"
          icon
          color="primary"
          @click="handleSave"
          v-if="editable && isEditMode"
          prepend-icon="mdi-cloud"
      ></a-btn>
    </div>
  </div>
</template>
<script setup>

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const props = defineProps({
  value: { type: String, required: true },
  displayText: { type: String },
  editable: {
    type: Boolean,
    default: false
  }
})
const { value, displayText, editable } = toRefs(props)
const name = ref(`${value.value}`)
const originalValue = ref(`${value.value}`)
const isEditMode = ref(false)

const emit = defineEmits(['input'])

watch(value, async(val) => {
  name.value = `${val}`
  originalValue.value = `${val}`
})

const handleEdit = (evt) => {
  if (isEditMode.value === true) {
    name.value = `${originalValue.value}`
    emit('input', { save: false, value: originalValue.value })
  }
  isEditMode.value = !isEditMode.value
}
const handleSave = (evt) => {
  emit('input', { save: true, value: name.value.trim() })
  isEditMode.value = false
}
</script>
<style lang="scss">
.editable-input .a-text-field__details {
  display: none;
}
</style>
