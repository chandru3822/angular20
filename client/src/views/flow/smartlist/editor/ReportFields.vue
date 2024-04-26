<template>
<v-row class="no-gutters fill-height flex-column">
  <v-col
    v-if="canEdit"
    class="flex-shrink-1 flex-grow-0"
  >
    <a-autocomplete
      v-show="!showPsEventField"
      v-model="newValue"
      :items="calculatedAvailableFields"
      item-title="calculatedName"
      return-object
      id="qa-smartlist-add-column"
      placeholder="Add Column"
      :loading="loading"
      variant="solo"
      hide-details
      class="field-selector pa-4"
      @change="afterFieldSelected"
    />

    <a-autocomplete
      v-show="showPsEventField"
      ref="psEventField"
      :items="calculatedAvailablePsEvents"
      v-model="newPsEvent"
      item-title="name"
      return-object
      placeholder="Type or Select Name"
      variant="solo"
      hide-details
      class="pa-2"
      @change="add"
    >
      <template #append>
        <a-btn
            icon
            @click.native.stop="reset()"
            color="unset"
            prepend-icon="mdi-close"
        ></a-btn>
      </template>

    </a-autocomplete>
  </v-col>

  <v-col class="flex-grow-1 flex-shrink-0 overflow-auto">
    <draggable
      :list="fields"
      :disabled="!canEdit"
      handle=".handle"
      @change="reorder"
    >
      <template v-for="(field, index) in fields">
        <v-card class="ma-4">
          <v-list-item
            v-if="field.updateType !== updateTypes.DELETE"
            :key="UUID()"
            class="pl-0"
          >
            <v-list-item-action class="handle grab mr-0">
              <v-icon x-large>mdi-drag-vertical</v-icon>
            </v-list-item-action>

            <v-list-item-content>
              {{ field.name }}
            </v-list-item-content>

            <v-list-item-action v-if="canEdit">
              <a-btn
                  icon
                  @click.native.stop="remove(index)"
                  color="unset"
                  prepend-icon="mdi-close"
              ></a-btn>
            </v-list-item-action>
          </v-list-item>
        </v-card>
      </template>
    </draggable>
  </v-col>

  <v-col
    v-if="canEdit"
    class="btn-remove-container flex-shrink-1 flex-grow-0 text-right py-4 pr-4"
  >
    <a-btn
        variant="text"
        @click="showDeleteDialog = true"
        color="unset"
        text="Remove All Columns"
    ></a-btn>
  </v-col>

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
        <a-btn
            variant="text"
            @click="showDeleteDialog = false"
            color="unset"
            text="Cancel"
        ></a-btn>

        <a-btn
            color="primary"
            @click="[showDeleteDialog = false, emit('cleared')]"
            text="Save"
        ></a-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</v-row>
</template>

<script setup>
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
  },
  canEdit: {
    type: Boolean,
    required: true
  }
})

const newValue = ref(null)
const newPsEvent = ref(null)
const psEventField = ref(null)
const showPsEventField = ref(false)
const showDeleteDialog = ref(false)

const calculatedAvailableFields = computed(() => {
  return props.availableFields.filter(f => {
    let keep = false
    if (f?.smartlistFieldId) {
      keep = props.fields.findIndex(field => {
        return (field?.smartlistFieldId === f.smartlistFieldId && field?.updateType !== props.updateTypes.DELETE) &&
               (
                 //PS/event system fields can be added once per PS/event. Other object type system fields can be added just once
                 [1,2,3,5].includes(field.objectTypeId) ||
                 (field.objectTypeId === 4 && field.processStepId !== f.processStepId) ||
                 (field.objectTypeId === 6 && field.eventId !== f.eventId)
               )
      }) === -1
    } else if (f?.customFieldGroupAssignmentId) {
      keep = props.fields.findIndex(field =>
        field?.customFieldGroupAssignmentId === f.customFieldGroupAssignmentId &&
        field?.updateType !== props.updateTypes.DELETE
      ) === -1
    }
    return keep
  }).map(f => {
    let suffix = ''

    switch (f.objectTypeId) {
      case 1:
        suffix = ` - Project`
        break
      case 2:
        suffix = ` - Contact`
        break
      case 3:
        suffix = ` - User`
        break
      case 4:
        suffix = ` - ${f.processStepName}`
        break
      case 5:
        suffix = ` - Org`
        break
      case 6:
        suffix = ` - ${f.eventName} - ${f.processStepName}`
    }

    return {...f, calculatedName: `${f.name}${suffix}`}
  })
})

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
          name: (f.objectTypeId === 4) ? f.processStepName : `${f.eventName} - ${f.processStepName}`,
          processStepEventId: f.processStepEventId
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
      newValue.value.processStepEventId = newPsEvent.value.processStepEventId
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
    nextTick(psEventField.value.focus())
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

.btn-remove-container {

  border-top: 1px solid var(--v-grey-lighten2);

  button:hover::before {
    opacity: 0 !important;
  }
}
</style>
