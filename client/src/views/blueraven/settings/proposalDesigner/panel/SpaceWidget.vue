<template>
  <div>
    <v-btn-toggle v-model="toggle" class="pb-4">
      <a-btn
        variant="text"
        size="small"
        value="all"
        color="unset"
        text="All"
      ></a-btn>
      <a-btn
        variant="text"
        size="small"
        value="hv"
        color="unset"
        text="H/V"
      ></a-btn>
      <a-btn
        variant="text"
        size="small"
        value="custom"
        color="unset"
        text="Custom"
      ></a-btn>
    </v-btn-toggle>

    <div v-if="toggle === 'all'">
      <size-widget
        label="All"
        attr="all"
        :value="all"
        :min="min"
        :max="max"
        @input="onChange"
      />
    </div>
    <div v-if="toggle === 'hv'">
      <size-widget
        label="Vertical"
        attr="vertical"
        :value="vertical"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Horizontal"
        attr="horizontal"
        :value="horizontal"
        :min="min"
        :max="max"
        @input="onChange"
      />
    </div>
    <div v-if="toggle === 'custom'">
      <size-widget
        label="Top"
        attr="top"
        :value="top"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Right"
        attr="right"
        :value="right"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Bottom"
        attr="bottom"
        :value="bottom"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Left"
        attr="left"
        :value="left"
        :min="min"
        :max="max"
        @input="onChange"
      />
    </div>
  </div>
</template>
<script setup>
import SizeWidget from './SizeWidget.vue'
import { ref, toRefs, watch } from 'vue'

const emit = defineEmits(['input'])
const props = defineProps({
  value: {
    type: String
  },
  attr: {
    type: String,
    required: true
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
const all = ref(null)
const horizontal = ref(null)
const vertical = ref(null)
const top = ref(null)
const right = ref(null)
const bottom = ref(null)
const left = ref(null)
const toggle = ref(null)

const { value } = toRefs(props)

watch(
  value,
  (newVal) => {
    top.value = null
    right.value = null
    bottom.value = null
    left.value = null
    horizontal.value = null
    vertical.value = null
    all.value = null

    const args = newVal?.split(' ') ?? []
    if (args.length === 0) {
      return
    }

    if (args?.length === 4) {
      toggle.value = 'custom'

      top.value = args[0]
      right.value = args[1]
      bottom.value = args[2]
      left.value = args[3]
    } else if (args?.length === 2) {
      toggle.value = 'hv'

      vertical.value = args[0]
      horizontal.value = args[1]
    } else {
      toggle.value = 'all'

      all.value = args[0]
    }
  },
  { immediate: true }
)

const onChange = (updated) => {
  Object.keys(updated).forEach((key) => {
    this[key] = updated[key]
  })

  let val = ''
  if (toggle.value === 'all') {
    val = all.value
  } else if (toggle.value === 'hv') {
    val = [vertical.value, horizontal.value]
      .map((x) => (x?.trim()?.length > 1 ? x : '0'))
      .join(' ')
  } else if (toggle.value === 'custom') {
    val = [top.value, right.value, bottom.value, left.value]
      .map((x) => (x?.trim()?.length > 1 ? x : '0'))
      .join(' ')
  } else {
    throw new Error('Unknown type')
  }
  emit('input', { [props.attr]: val })
}
</script>
