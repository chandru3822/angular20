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
        :value="paddingOptions.all"
        :min="min"
        :max="max"
        @input="onChange"
      />
    </div>
    <div v-if="toggle === 'hv'">
      <size-widget
        label="Vertical"
        attr="vertical"
        :value="paddingOptions.vertical"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Horizontal"
        attr="horizontal"
        :value="paddingOptions.horizontal"
        :min="min"
        :max="max"
        @input="onChange"
      />
    </div>
    <div v-if="toggle === 'custom'">
      <size-widget
        label="Top"
        attr="top"
        :value="paddingOptions.top"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Right"
        attr="right"
        :value="paddingOptions.right"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Bottom"
        attr="bottom"
        :value="paddingOptions.bottom"
        :min="min"
        :max="max"
        @input="onChange"
      />
      <size-widget
        label="Left"
        attr="left"
        :value="paddingOptions.left"
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
const paddingOptions = ref({
  all:null,
  horizontal: null,
  vertical: null,
  top: null,
  right: null,
  bottom: null,
  left: null,
})

const toggle = ref(null)

const { value } = toRefs(props)

watch(
  value,
  (newVal) => {
    paddingOptions.value.top = null
    paddingOptions.value.right = null
    paddingOptions.value.bottom = null
    paddingOptions.value.left = null
    paddingOptions.value.horizontal = null
    paddingOptions.value.vertical = null
    paddingOptions.value.all = null

    const args = newVal?.split(' ') ?? []
    if (args.length === 0) {
      return
    }
    if (args?.length === 4) {
      toggle.value = 'custom'

      paddingOptions.value.top = args[0]
      paddingOptions.value.top = args[0]
      paddingOptions.value.right = args[1]
      paddingOptions.value.bottom = args[2]
      paddingOptions.value.left = args[3]
    } else if (args?.length === 2) {
      toggle.value = 'hv'

      paddingOptions.value.vertical = args[0]
      paddingOptions.value.horizontal = args[1]
    } else {
      toggle.value = 'all'
      paddingOptions.value.all = args[0]
    }
  },
  { immediate: true }
)

const onChange = (updated) => {
  Object.keys(updated).forEach((key) => {
    paddingOptions.value[key] = updated[key]
  })
  debugger
  let val = ''
  if (toggle.value === 'all') {
    val = paddingOptions.value.all
  } else if (toggle.value === 'hv') {
    val = [paddingOptions.value.vertical, paddingOptions.value.horizontal]
      .map((x) => (x?.trim()?.length > 1 ? x : '0'))
      .join(' ')
  } else if (toggle.value === 'custom') {
    val = [paddingOptions.value.top, paddingOptions.value.right, paddingOptions.value.bottom, paddingOptions.value.left]
      .map((x) => (x?.trim()?.length > 1 ? x : '0'))
      .join(' ')
  } else {
    throw new Error('Unknown type')
  }
  emit('input', { [props.attr]: val })
}
</script>
