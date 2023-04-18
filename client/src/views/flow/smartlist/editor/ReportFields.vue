<template>
<fragment>
<v-autocomplete
  :items="availableFields"
  item-text="name"
  return-object
  :loading="loading"
  @change="add"
/>
<draggable
  v-model="fields"
  @change="reorder"
>
  <v-list-item
    v-for="field in fields"
    :key="UUID()"
  >
    <v-list-item-action>
      <v-icon>drag_handle</v-icon>
    </v-list-item-action>

    <v-list-item-content>
      {{ calculatedName(field) }}
    </v-list-item-content>
  </v-list-item>
</draggable>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'
import draggable from 'vuedraggable'
import { UUID } from '@/helpers/helpers'

const emit = defineEmits(['added'])

const props = defineProps({
  fields: {
    type: Array,
    required: true
  },
  availableFields: {
    type: Array,
    required: true
  },
  loading: {
    type: Boolean,
    required: true
  }
})

const calculatedName = (field) => {
  let name = field.name

  if (field.objectTypeId === 4) {
    name += ` - (PS) ${field.processStepName}`
  } else if (field.objectTypeId === 6) {
    name += ` - (E) ${field.eventName}`
  }

  return name
}

const add = (field) => {
  emit('added', field)
}

const reorder = () => {
  console.log('reorder')
}
</script>

<style scoped lang="scss">

</style>