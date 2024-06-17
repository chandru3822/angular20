<template>
  <div class="editable-input d-flex pa-0 align-center">
    <span v-if="!isEditMode">{{ displayText || name }}</span>
    <a-text-field v-else v-model="name" variant="solo" single-line autofocus />
    <div v-if="editable">
      <a-btn
        size="small"
        icon
        color="primary"
        @click="handleEdit"
        class="pa-1 ml-4"
        v-if="editable"
        :prepend-icon="!isEditMode ? 'mdi-pencil' : 'mdi-close'"
      ></a-btn>
      <a-btn
        size="small"
        class="pa-1 ml-2"
        icon
        color="primary"
        @click="handleSave"
        v-if="editable && isEditMode"
        prepend-icon="save"
      ></a-btn>
    </div>
  </div>
</template>
<script setup>
import { toRefs, ref, watch } from 'vue'

const emit = defineEmits(['input'])
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

watch(value, async (val) => {
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
.editable-input .v-text-field__details {
  display: none;
}
</style>
