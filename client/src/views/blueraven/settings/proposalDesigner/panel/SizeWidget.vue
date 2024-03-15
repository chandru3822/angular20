<template>
  <div>
    <v-subheader class="pl-0">{{label}} - {{size}}</v-subheader>
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
import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
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
const emit = defineEmits(['input'])

const unit = ref('px')
const size = ref(0)
const units = ref(['px'])

watch(props.value, (newVal) => {
  const args = newVal
      ?.split(/(\d+)/)
      ?.filter(x => x !== '')

  if (args?.length === 2) {
    size.value = args[0]
    unit.value = args[1]
  }
}, {immediate: true});

const onChange = () => {
  emit('input', { [props.attr]: `${size.value}${unit.value}` })
}
</script>
