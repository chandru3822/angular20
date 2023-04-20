<template>
<fragment>
<v-autocomplete
  :items="availableFields"
  item-text="name"
  return-object
  @change="add"
/>
<v-list>
  <template v-for="(requirement, index) in requirements">
    <v-list-item v-if="requirement.updateType !== updateTypes.DELETE">
      <v-list-item-content>
        {{ calculatedName(requirement) }}
      </v-list-item-content>

      <v-list-item-action>
        <v-btn
          icon
          @click.stop="remove(index)"
        >
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-list-item-action>
    </v-list-item>
  </template>
</v-list>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'

const emit = defineEmits(['added', 'updated', 'deleted'])

const props = defineProps({
  requirements: {
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
  },
  updateTypes: {
    type: Object,
    required: true
  }
})

const calculatedName = (r) => {
  let name = r.name

  if (r.objectTypeId === 4) {
    name += ` - (PS) ${r.processStepName}`
  } else if (r.objectTypeId === 6) {
    name += ` - (E) ${r.eventName}`
  }

  return name
}

const add = (requirement) => {
  emit('added', requirement)
}

const remove = (index) => {
  emit('deleted', index)
}

const update = (requirement, index) => {
  emit('updated', requirement, index)
}
</script>

<style scoped lang="scss">

</style>