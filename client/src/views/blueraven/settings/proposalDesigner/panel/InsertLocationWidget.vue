<template>
  <div>
    <v-btn-toggle v-model="toggle" class="pb-4">
      <a-btn
        variant="text"
        size="small"
        value="first"
        color="unset"
        text="First"
        @click="onChange"
      ></a-btn>
      <a-btn
        variant="text"
        size="small"
        value="before"
        color="unset"
        text="Before Block"
      ></a-btn>
      <a-btn
        variant="text"
        size="small"
        value="after"
        color="unset"
        text="After Block"
      ></a-btn>
      <a-btn
        variant="text"
        size="small"
        value="last"
        color="unset"
        text="Last"
        @click="onChange"
      ></a-btn>
    </v-btn-toggle>

    <v-card flat color="transparent" v-if="toggle === 'before' || toggle === 'after'">
        <a-select
            density="compact"
            variant="outlined"
            v-model="relativeBlock"
            :items="existingBlocks"
            item-title="displayName"
            item-value="id"
            return-object
            label="Select an existing block"
        />
      </v-card>
  </div>
</template>
<script setup>
import SizeWidget from './SizeWidget.vue'
import { ref, toRefs, watch } from 'vue'

const emit = defineEmits(['input'])
const props = defineProps({
  attr: {
    type: String,
    required: true
  },
  existingBlocks: Array
})
const toggle = ref(null)
const relativeBlock = ref(null)


const onChange = (updated) => {
  Object.keys(updated).forEach((key) => {
    this[key] = updated[key]
  })

  emit('input', { [props.attr]: {location: toggle, relativeBlock: relativeBlock.value } })
}
</script>
