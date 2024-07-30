<template>
  <div>
    <div class="pl-0 label-large">{{ label }} - {{ size }}</div>
    <v-btn-toggle v-if="showUnitOptions" v-model="unitToggle" mandatory @change="onChange">
      <a-btn
          v-for="u in units"
          variant="text"
          size="small"
          :value="u"
          :text="u"
      />
    </v-btn-toggle>
    <div class="d-flex flex-row align-start">
      <v-slider
        class="flex-grow-1 flex-shrink-0"
        dense
        thumb-label
        v-model="size"
        @change="onChange"
        :max="unit === '%' ? 100 : max"
        :min="min"
      />
      <a-btn icon prepend-icon="mdi-arrow-expand-horizontal" @click="setToMax"/>
      <a-btn icon prepend-icon="mdi-close" @click="clear"/>
    </div>
  </div>
</template>
<script setup>
import {computed, ref, toRefs, watch} from 'vue'

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
  },
  showUnitOptions:{
    type: Boolean,
    default: false
  }
})

const unitToggle = ref(null)
const size = ref(0)
const units = ref(['px', '%', 'rem'])
const unit = computed(() => props.showUnitOptions ? unitToggle.value : 'px')

const { value } = toRefs(props)

watch(
  value,
  (newVal) => {
    const args = newVal?.split(/(\d+)/)?.filter((x) => x !== '')
    if (args?.length === 2) {
      size.value = args[0]
    }
  },
  { immediate: true }
)


const onChange = () => {
  emit('input', { [props.attr]: `${size.value}${unit.value}` })
}

const setToMax = () => {
  size.value = unit.value === '%' ? 100 : props.max
  onChange()
}

const clear = () => {
  emit('input', {[props.attr]: undefined})
}

</script>
