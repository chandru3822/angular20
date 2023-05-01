<template>
<fragment>
<v-sheet
  :class="{'add-field': showOverflow && newRequirement !== null}"
  class="mx-4 mb-2"
  :elevation="editorElevation"
  :rounded="showOverflow"
>
  <v-row class="align-center justify-start no-gutters mt-2">
    <v-col
      v-if="newRequirement !== null"
      class="flex-grow-0 text-no-wrap px-2"
    >
      <span class="highlight-background pa-2 rounded">{{ newRequirement.name }}</span>
    </v-col>

    <v-col
      v-if="newRequirement !== null && newOperator !== null"
      class="flex-grow-0 text-no-wrap px-2"
    >
      {{ newOperator.operatorType }}
    </v-col>

    <v-col
      v-if="newRequirement !== null && newOperator !== null && newValue?.secondaryRequirement"
      class="flex-grow-0 text-no-wrap px-2"
    >
      <span class="highlight-background pa-2 rounded">{{ newValue.dataTypeValue }}</span>
    </v-col>

    <v-col class="flex-grow-1">
      <v-autocomplete
        v-show="showFieldInput"
        ref="requirementField"
        v-model="newRequirement"
        :items="availableFields"
        item-text="name"
        return-object
        placeholder="Add Filter"
        solo
        :flat="showOverflow"
        hide-details="true"
        :class="{'field-selector': !showOverflow}"
        @blur="afterFieldSelected"
        @focus="toggleOverflow(true)"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="reset"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <v-autocomplete
        v-if="showPsEventInput"
        ref="psEventField"
        v-model="newPsEventId"
        :items="calculatedAvailablePsEvents"
        item-text="name"
        item-value="id"
        return-object
        placeholder="Type or Select Process Step"
        solo
        :flat="showOverflow"
        hide-details="true"
        :class="{'field-selector': !showOverflow}"
        @blur="focus(operatorField)"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="reset"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <v-autocomplete
        v-show="showOperatorInput"
        ref="operatorField"
        v-model="newOperator"
        :items="availableOperators"
        item-text="operatorType"
        item-value="id"
        return-object
        placeholder="Type or Select Operator"
        solo
        flat
        hide-details="true"
        :class="{'field-selector': !showOverflow}"
        @blur="(newRequirement?.hasListValues) ? focus(listOfValueField) : focus(valueField)"
      >
        <template #append v-if="showOverflow">
          <v-btn
            icon
            @click.stop="reset"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <span v-if="newOperator !== null && !newValue?.secondaryRequirement">
        <v-combobox
          v-show="!newRequirement.hasListValues"
          ref="valueField"
          v-model="newValue"
          :key="UUID()"
          :items="availableDataTypeRequirements"
          item-text="dataTypeValue"
          item-value="id"
          return-object
          placeholder="Type or Select Value"
          solo
          flat
          hide-details="true"
          :class="{'field-selector': !showOverflow}"
          @change="afterValueSelected"
        >
          <template #append>
            <v-btn
              icon
              @click.stop="reset"
            >
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </template>
        </v-combobox>

        <v-autocomplete
          v-show="newRequirement.hasListValues"
          ref="listOfValueField"
          v-model="newValue"
          :items="calculatedAvailableValues"
          item-text="name"
          item-value="id"
          return-object
          placeholder="Type or Select Value"
          solo
          flat
          hide-details="true"
          :multiple="newRequirement.allowMultiple"
          ripple="false"
          :class="{'field-selector': !showOverflow}"
          @change="afterValueSelected(false)"
        >
          <template #item="data">
            <v-list-item-content>{{ data.item.name }}</v-list-item-content>
          </template>

          <template #append>
            <v-btn
              v-if="newValue !== null && newValue.length > 0"
              icon
              @click="afterValueSelected(true)"
            >
              <v-icon>mdi-check</v-icon>
            </v-btn>
            <v-btn
              icon
              @click.stop="reset"
            >
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </template>
        </v-autocomplete>
      </span>

      <v-text-field
        v-show="newValue?.secondaryRequirement"
        ref="secondaryValueField"
        v-model="secondaryValue"
        placeholder="Type Value"
        solo
        flat
        hide-details="true"
        @change="add"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="reset"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-text-field>
    </v-col>
    </v-row>
</v-sheet>
<v-list>
  <template v-for="(requirement, index) in requirements">
    <v-list-item v-if="requirement.updateType !== updateTypes.DELETE" :key="UUID()">
      <v-list-item-content>
        {{ requirement.name }}
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
import { computed, getCurrentInstance, nextTick, ref } from 'vue'
import { getRequest, logError, UUID } from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const emit = defineEmits(['added', 'updated', 'deleted', 'overflow-required'])

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

const newRequirement = ref(null)
const newPsEventId = ref(null)
const newOperator = ref(null)
const newValue = ref(null)
const secondaryValue = ref(null)

const availableDataTypeRequirements = ref([])
const availableOperators = ref([])
const showOverflow = ref(false)

const requirementField = ref(null)
const psEventField = ref(null)
const operatorField = ref(null)
const valueField = ref(null)
const listOfValueField = ref(null)
const secondaryValueField = ref(null)

const editorElevation = computed(() => (showOverflow.value) ? 1 : 0)

// const calculatedName = (r) => {
//   let name = r.name
//
//   if (r.objectTypeId === 4) {
//     name += ` - (PS) ${r.processStepName}`
//   } else if (r.objectTypeId === 6) {
//     name += ` - (E) ${r.eventName}`
//   }
//
//   return name
// }

const calculatedAvailablePsEvents = computed(() => {

  if (newRequirement.value === null) {
    return []
  }

  let items = []
   props.availableFields.filter(f => {
     if (f.objectTypeId === newRequirement.value.objectTypeId && !f.smartlistFieldId) {
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

const calculatedAvailableValues = computed(() => {
  if (newRequirement.value === null || availableDataTypeRequirements.length === 0) {
    return []
  }

  let newValues = cloneDeep(availableDataTypeRequirements.value).map(i => {
    return {
      ...i,
      name: i.dataTypeValue,
      isDataTypeRequirement: true
    }
  })

  if (newRequirement.value.listOfValues?.length > 0) {
    newValues.push({divider: true})

    newValues = newValues.concat(newRequirement.value.listOfValues)
  }

  return newValues
})

const showFieldInput = computed(() => newRequirement.value === null)

const showPsEventInput = computed(() => {
  return !showFieldInput.value && !!newRequirement.value?.smartlistFieldId && newPsEventId.value === null
})

const afterFieldSelected = () => {
  getDataTypeRequirements()
  getOperators()

  if (!showFieldInput.value && !!newRequirement.value?.smartlistFieldId) {
    focus(psEventField.value)
  } else {
    focus(operatorField.value)
  }
}

const afterValueSelected = (userCheckedToAdd) => {
  if (newRequirement.value?.allowMultiple) {
    const dataTypeRequirement = newValue.value.find(v => v.isDataTypeRequirement)

    if (dataTypeRequirement) {
      newValue.value = dataTypeRequirement
      add()
    }

    if (userCheckedToAdd) {
      add()
    }

  } else if (newValue.value?.secondaryRequirement) {
    focus(secondaryValueField.value)
  } else {
    add()
  }
}

const showOperatorInput = computed(() => {
  return !showFieldInput.value &&
         !showPsEventInput.value &&
         newOperator.value === null
})

const toggleOverflow = (toggle) => {
  showOverflow.value = toggle
  emit('overflow-required', toggle)
}

const add = () => {
  //data integrity checks
  if (newRequirement.value === null || newOperator.value === null || newValue.value === null) {
    return
  }

  //vuetify's combobox will return custom input as a string
  if (typeof newValue.value === 'string' && newValue.value.trim().length === 0) {
    snackbar('ERROR', 'Invalid value')
    return
  }

  if (newValue.value?.secondaryRequirement && secondaryValue.value.trim().length === 0) {
    snackbar('ERROR', 'Invalid value')
    return
  }

  if (newPsEventId.value !== null) {
    if (newRequirement.value.objectTypeId === 4) {
      newRequirement.value.processStepId = newPsEventId.value.id
      newRequirement.value.processStepName = newPsEventId.value.name
    } else {
      newRequirement.value.eventId = newPsEventId.value.id
      newRequirement.value.eventName = newPsEventId.value.name
    }
  }

  newRequirement.value.operatorTypeId = newOperator.value.id

  //if select value is custom
  if (typeof newValue.value === 'string') {
    newRequirement.value.requirementValue = newValue.value.trim()
  } else if (Array.isArray(newValue.value)) {
    //if selected value is a multi-select
    newRequirement.value.listOfValueIds = newValue.value.map(v => v.id)
  } else if (newValue.value?.dataTypeId) {
    //if selected value is a data type requirement
    newRequirement.value.dataTypeRequirementId = newValue.value.id
  } else {
    //selected value is a list value
    newRequirement.value.listOfValueId = newValue.value.id
  }

  if (newValue.value?.secondaryRequirement) {
    newRequirement.value.secondaryRequirement = true
    newRequirement.value.secondaryRequirementValue = secondaryValue.value.trim()
  }

  emit('added', newRequirement.value)
  reset()
}

const remove = (index) => {
  emit('deleted', index)
}

const update = (requirement, index) => {
  emit('updated', requirement, index)
}

const getDataTypeRequirements = async () => {
  if (!newRequirement.value?.dataTypeId) {
    return
  }

  try {
    const {data} = await getRequest(`/dataType/getDataTypeRequirements/${newRequirement.value.dataTypeId}`)
    availableDataTypeRequirements.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch data type requirements')
  }
}

const getOperators = async () => {
  if (!newRequirement.value?.dataTypeId) {
    return
  }

  try {
    const {data} = await getRequest(`/operator/${newRequirement.value.dataTypeId}`)
    availableOperators.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch operators')
  }
}

const reset = () => {
  newRequirement.value = null
  newPsEventId.value = null
  newOperator.value = null
  newValue.value = null
  psEventField.value = null
  listOfValueField.value = null
  secondaryValue.value = null
  showOverflow.value = null

  if (valueField.value !== null && Object.hasOwn(valueField.value, 'isMenuActive')) {
    valueField.value.isMenuActive = false
  }

  emit('overflow-required', false)
}

const focus = (field) => {
  if (field === null) {
    return
  }

  if (showOverflow.value) {
    nextTick(field.focus)

    if (Object.hasOwn(field, 'activateMenu')) {
      nextTick(field.activateMenu)
    }
  }
}
</script>

<style scoped lang="scss">
.field-selector {
  :deep(.v-input__append-inner) {
    display: none !important;
  }
}

.add-field {
  width: max-content;
}

.highlight-background {
  background-color: var(--v-primary-lighten9);
}
</style>