<template>
  <div>
    <div class="pl-0 label-large">{{ label }} - {{ size }}</div>
    <div class="d-flex flex-row align-end">
      <v-slider
        class="flex-grow-1 flex-shrink-0"
        dense
        thumb-label
        v-model="size"
        @change="onChange"
        :max="max"
        :min="min"
      />
    </div>
  </div>
</template>
<script setup>
import { ref, toRefs, watch } from 'vue'

const emit = defineEmits(['input'])
const props = defineProps({
  label: {
    type: String,
    required: true
  },
  attr: {
    type: String,
    required: true
  },
  value: {
    type: String,
    default: '0px'
  },
  min: {
    type: Number,
    default: 0
  },
  max: {
    type: Number,
    default: 50
  }
})

const unit = ref('px')
const size = ref(0)
const units = ref(['px'])

const { value } = toRefs(props)

watch(
  value,
  (newVal) => {
    const args = newVal?.split(/(\d+)/)?.filter((x) => x !== '')
    if (args?.length === 2) {
      size.value = args[0]
      unit.value = args[1]
    }
  },
  { immediate: true }
)

const onChange = () => {
  emit('input', { [props.attr]: `${size.value}${unit.value}` })
}
</script>
