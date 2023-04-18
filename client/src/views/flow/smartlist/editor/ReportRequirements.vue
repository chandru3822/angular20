<template>
<fragment>
  <v-autocomplete
    :items="availableFields"
    item-text="name"
    return-object
    @change="add"
  />
<div v-for="r in requirements">
  {{ calculatedName(r) }}
</div>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'

const emit = defineEmits(['added'])

const props = defineProps({
  requirements: {
    type: Array,
    required: true
  },
  availableFields: {
    type: Array,
    required: true
  }
})

const calculatedName = (f) => {
  let name = f.name

  if (f.objectTypeId === 4) {
    name += ` - (PS) ${f.processStepName}`
  } else if (f.objectTypeId === 6) {
    name += ` - (E) ${f.eventName}`
  }

  return name
}

const add = (field) => {
  emit('added', field)
}
</script>

<style scoped lang="scss">

</style>