<template>
<fragment>
<v-row no-gutters>
  <v-col cols="12">
    <v-autocomplete
      v-show="!showPsEventField"
      v-model="newValue"
      :items="availableFields"
      item-text="name"
      return-object
      placeholder="Add Column"
      :loading="loading"
      solo
      hide-details="true"
      class="field-selector pa-2"
      @change="afterFieldSelected"
    />

    <v-autocomplete
      v-show="showPsEventField"
      ref="psEventField"
      :items="calculatedAvailablePsEvents"
      v-model="newPsEvent"
      item-text="name"
      return-object
      placeholder="Type or Select Name"
      solo
      hide-details="true"
      class="field-selector pa-2"
      @change="add"
    />

    <draggable
      :list="fields"
      @change="reorder"
    >
      <template v-for="(field, index) in fields">
        <v-list-item v-if="field.updateType !== updateTypes.DELETE" :key="UUID()">
          <v-list-item-action>
            <v-icon>drag_handle</v-icon>
          </v-list-item-action>

          <v-list-item-content>
            {{ field.name }}
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
    </draggable>
  </v-col>

  <v-col class="clear-btn">
    <v-btn
      text
      @click="showDeleteDialog = true"
    >
      Remove All Columns
    </v-btn>
  </v-col>
</v-row>

<v-dialog
  v-model="showDeleteDialog"
  persistent
  width="450"
>
  <v-card>
    <v-card-title>Clear All Columns</v-card-title>

    <v-card-text>
      Do you want to delete all columns?
    </v-card-text>

    <v-card-actions class="justify-end">
      <v-btn
        text
        @click="showDeleteDialog = false"
      >
        Cancel
      </v-btn>

      <v-btn
        color="primary"
        @click="[showDeleteDialog = false, emit('cleared')]"
      >
        Save
      </v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
</fragment>
</template>

<script setup>
import { Fragment } from 'vue-frag'
import draggable from 'vuedraggable'
import { UUID } from '@/helpers/helpers'
import { computed, nextTick, ref } from 'vue'

const emit = defineEmits(['added', 'reordered', 'deleted', 'cleared'])

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
  },
  updateTypes: {
    type: Object,
    required: true
  }
})

const newValue = ref(null)
const newPsEvent = ref(null)
const psEventField = ref(null)
const showPsEventField = ref(false)
const showDeleteDialog = ref(false)

// const calculatedName = (field) => {
//   let name = field.name
//
//   if (field.objectTypeId === 4) {
//     name += ` - (PS) ${field.processStepName}`
//   } else if (field.objectTypeId === 6) {
//     name += ` - (E) ${field.eventName}`
//   }
//
//   return name
// }

const calculatedAvailablePsEvents = computed(() => {

  if (newValue.value === null) {
    return []
  }

  let items = []
  props.availableFields.filter(f => {
    if (f.objectTypeId === newValue.value.objectTypeId && !f.smartlistFieldId) {
      let notIncluded

      if (f.objectTypeId === 4) {
        notIncluded = items.findIndex(i => i.id === f.processStepId) === -1
      } else if (f.objectTypeId === 6) {
        notIncluded = items.findIndex(i => i.id === f.eventId) === -1
      }

      if (notIncluded) {
        items.push({
          id: (f.objectTypeId === 4) ? f.processStepId : f.eventId,
          name: (f.objectTypeId === 4) ? f.processStepName : f.eventName
        })
      }
    }
  })

  return items.sort((a, b) => a.name.localeCompare(b.name))
})

const add = () => {
  if (newPsEvent.value !== null) {
    if (newValue.value.objectTypeId === 4) {
      newValue.value.processStepId = newPsEvent.value.id
      newValue.value.processStepName = newPsEvent.value.name
    } else {
      newValue.value.eventId = newPsEvent.value.id
      newValue.value.eventName = newPsEvent.value.name
    }
  }

  emit('added', newValue.value)
  nextTick(reset)
}

const remove = (index) => {
  emit('deleted', index)
}

const reorder = () => {
  emit('reordered', props.fields)
}

const reset = () => {
  newValue.value = null
  newPsEvent.value = null
  showPsEventField.value = false
}

const afterFieldSelected = () => {
  const isPsEventSmartlistField = !!newValue.value?.smartlistFieldId && [4,6].includes(newValue.value?.objectTypeId)

  if (isPsEventSmartlistField) {
    showPsEventField.value = true
    nextTick(psEventField.value.focus)
    nextTick(psEventField.value.activateMenu)
  } else {
    add()
  }
}
</script>

<style scoped lang="scss">
.field-selector {
  :deep(.v-input__append-inner) {
    display: none;
  }
}
</style>