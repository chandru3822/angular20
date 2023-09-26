<template>
<v-sheet
  :class="{'add-field': isEditorInUse && requirement !== null}"
  class="mx-4 mb-2"
  :elevation="editorElevation"
  :rounded="isEditorInUse"
>
  <v-row
    class="align-center justify-start no-gutters mt-4"
    :class="{'py-3': !showFieldInput && !showPsEventInput && !showOperatorInput && !showValueInput}"
  >
    <v-col class="flex-grow-1 flex-shrink-0 d-flex justify-center align-center">
      <v-autocomplete
        v-show="showFieldInput"
        ref="requirementField"
        v-model="requirement"
        :items="calculatedAvailableFields"
        item-text="calculatedName"
        return-object
        placeholder="Add Filter"
        solo
        :flat="isEditorInUse"
        hide-details="true"
        :class="{'field-selector': !isEditorInUse}"
        @change="afterFieldSelected"
        @focus="onFieldFocus"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <span
        v-if="requirement?.displayValue"
        class="flex-grow-0 text-no-wrap px-2"
      >
        <span class="highlight-background pa-2 rounded">{{ requirement.name }}</span>
      </span>

      <v-autocomplete
        v-show="showPsEventInput"
        ref="psEventField"
        v-model="psEvent"
        :items="calculatedAvailablePsEvents"
        item-text="name"
        item-value="id"
        return-object
        placeholder="Type or Select Name"
        solo
        :flat="isEditorInUse"
        hide-details="true"
        :class="{'field-selector': !isEditorInUse}"
        @blur="afterPsEventSelected"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <v-autocomplete
        v-show="showOperatorInput"
        ref="operatorField"
        v-model="operator"
        :items="availableOperators"
        item-text="operatorType"
        item-value="id"
        return-object
        placeholder="Type or Select Operator"
        solo
        flat
        hide-details="true"
        :class="{'field-selector': !isEditorInUse}"
        @change="afterOperatorSelected"
      >
        <template #append v-if="isEditorInUse">
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <span
        v-if="operator?.displayValue"
        class="text-no-wrap px-2"
        :class="{'hover': isEditing}"
        @click="operatorDisplayClicked"
      >
        {{ operator.operatorType }}
      </span>

      <v-combobox
        v-show="showValueInput && !requirement?.hasListValues"
        ref="valueField"
        v-model="value"
        :key="UUID()"
        :items="availableDataTypeRequirements"
        item-text="dataTypeValue"
        item-value="id"
        return-object
        placeholder="Type or Select Value"
        solo
        flat
        hide-details="true"
        :class="{'field-selector': !isEditorInUse}"
        @change="afterValueSelected(false)"
      >
        <template #append>
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-combobox>

      <span
        v-if="value?.displayValue"
        class="text-no-wrap px-2"
        :class="{'hover': isEditing}"
        @click="valueDisplayClicked"
      >
        <span class="highlight-background pa-2 rounded">{{ getValue(requirement, isEditing) }}</span>
      </span>

      <span
        v-if="isEditing && requirement?.displayValue && operator?.displayValue && value?.displayValue && !showSecondaryValueInput"
        class="px-2"
      >
        <v-btn
          icon
          @click.stop="[reset(), emit('cancelled')]"
        >
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </span>

      <v-autocomplete
        v-show="showValueInput && requirement?.hasListValues"
        ref="listOfValueField"
        v-model="value"
        :key="UUID()"
        :items="calculatedAvailableValues"
        item-text="name"
        item-value="id"
        return-object
        placeholder="Type or Select Value"
        solo
        flat
        hide-details="true"
        :multiple="requirement?.allowMultiple"
        ripple="false"
        :class="{'field-selector': !isEditorInUse}"
        @change="afterValueSelected(false)"
      >
        <template #item="data">
          <v-list-item-content>{{ data.item.name }}</v-list-item-content>
        </template>

        <template #append>
          <v-btn
            v-if="value !== null && value.length > 0"
            icon
            @click="afterValueSelected(true)"
          >
            <v-icon>mdi-check</v-icon>
          </v-btn>
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-autocomplete>

      <v-text-field
        v-show="showSecondaryValueInput"
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
            v-if="secondaryValue !== null && secondaryValue.trim().length > 0"
            icon
            @click="afterValueSelected(true)"
          >
            <v-icon>mdi-check</v-icon>
          </v-btn>
          <v-btn
            icon
            @click.stop="[reset(), emit('cancelled')]"
          >
            <v-icon>mdi-close</v-icon>
          </v-btn>
        </template>
      </v-text-field>
    </v-col>
  </v-row>
</v-sheet>
</template>

<script setup>
import { getRequest, logError, UUID } from '@/helpers/helpers'
import { computed, getCurrentInstance, nextTick, onMounted, ref } from 'vue'
import cloneDeep from 'lodash.clonedeep'

const emit = defineEmits(['adding', 'added', 'updated', 'cancelled', 'in-progress'])

const props = defineProps({
  availableFields: {
    type: Array,
    required: true
  },
  existingRequirement: {
    type: Object,
    required: false,
    default: null
  },
  getValue: {
    type: Function,
    required: true
  }
})

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const companyId = vueInstance.$store.state.user.details.companyId

const availableDataTypeRequirements = ref([])
const availableOperators = ref([])

const requirement = ref(null)
const psEvent = ref(null)
const operator = ref(null)
const value = ref(null)
const secondaryValue = ref(null)

const requirementField = ref(null)
const psEventField = ref(null)
const operatorField = ref(null)
const valueField = ref(null)
const listOfValueField = ref(null)
const secondaryValueField = ref(null)
const isEditorInUse = ref(false)

const isEditing = computed(() => props.existingRequirement !== null)

const editorElevation = computed(() => (isEditorInUse.value) ? 1 : 0)

const showFieldInput = computed(() => requirement.value === null)

const showPsEventInput = computed(() => {
  const isPsEventSmartlistField = !!requirement.value?.smartlistFieldId && [4,6].includes(requirement.value?.objectTypeId)
  return !showFieldInput.value &&
         isPsEventSmartlistField &&
         psEvent.value === null
})

const showOperatorInput = computed(() => {
  return !showFieldInput.value &&
         !showPsEventInput.value &&
         (operator.value === null || !operator.value.displayValue)
})

const showValueInput = computed(() => {
  return operator.value !== null &&
         operator.value?.displayValue &&
         !value.value?.displayValue
})

const showSecondaryValueInput = computed(() => {
  return showValueInput &&
         value.value?.secondaryRequirement &&
         operator.value?.displayValue &&
         value.value?.displayValue
})

const calculatedAvailableValues = computed(() => {
  if (requirement.value === null || availableDataTypeRequirements.length === 0) {
    return []
  }

  let newValues = cloneDeep(availableDataTypeRequirements.value).map(i => {
    return {
      ...i,
      name: i.dataTypeValue,
      isDataTypeRequirement: true
    }
  })

  if (requirement.value.listOfValues?.length > 0) {
    newValues.push({divider: true})

    newValues = newValues.concat(requirement.value.listOfValues)
  }

  return newValues
})

const calculatedAvailableFields = computed(() => {
  return props.availableFields.map(f => {
      let suffix = ''

      if (f?.customFieldGroupAssignmentId) {
        switch (f.objectTypeId) {
          case 1:
            suffix = `- Project`
            break
          case 2:
            suffix = `- Contact`
            break
          case 3:
            suffix = `- User`
            break
          case 4:
            suffix = `- ${f.processStepName}`
            break
          case 5:
            suffix = `- Org`
            break
          case 6:
            suffix = `- ${f.eventName} - ${f.processStepName}`
        }
      }

      f.calculatedName = `${f.name} ${suffix}`
      return f
    })
})

const calculatedAvailablePsEvents = computed(() => {

  if (requirement.value === null) {
    return []
  }

  let items = []
  calculatedAvailableFields.value.filter(f => {
    if (f.objectTypeId === requirement.value.objectTypeId && !f.smartlistFieldId) {
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

const focus = (field) => {
  if (field.value === null) {
    return
  }

  if (isEditorInUse.value) {
    nextTick(() => {
      field.value.focus()

      if (Object.hasOwn(field.value, 'activateMenu')) {
        field.value.activateMenu()
      }
    })
  }
}

const onFieldFocus = () => {
  if (!isEditing.value) {
    isEditorInUse.value = true
    emit('in-progress', true)
  }
}

const afterFieldSelected = () => {
  requirement.value.displayValue = true
  getDataTypeRequirements()
  getOperators()

  const isPsEventSmartlistField = !!requirement.value?.smartlistFieldId && [4,6].includes(requirement.value?.objectTypeId)

  //check project/contact owner
  if ([1,2].includes(requirement.value?.objectTypeId) && ['Project Owner','Contact Owner'].includes(requirement.value.name)) {
    getSystemListValues()
  }

  if (!showFieldInput.value && isPsEventSmartlistField) {
    focus(psEventField)
  } else {
    focus(operatorField)
  }
}

const afterPsEventSelected = () => {
  if (requirement.value.objectTypeId === 4 && requirement.value.name === 'Process Step Owner') {
    getSystemListValues()
  }

  //@TODO: #smartlistsv2 - Maybe narrow this down
  if (requirement.value.objectTypeId === 6) {
    getSystemListValues()
  }

  focus(operatorField)
}

const afterOperatorSelected = () => {
  operator.value.displayValue = true

  if (requirement.value?.hasListValues) {
    focus(listOfValueField)
  } else {
    focus(valueField)
  }
}

const afterValueSelected = (userCheckedToAdd) => {
  if (isEditing.value) {
    add()
    return
  }

  if (requirement.value?.allowMultiple) {
    const dataTypeRequirement = value.value.find(v => v.isDataTypeRequirement)

    if (dataTypeRequirement) {
      value.value = dataTypeRequirement
      add()
      return
    }

    if (userCheckedToAdd) {
      add()
    }

  } else if (value.value?.secondaryRequirement) {
    if (value.value.displayValue) {
      add()
    } else {
      requirement.value.dataTypeRequirementId = value.value.id
      requirement.value.dataTypeRequirement = value.value
      value.value.displayValue = true
      focus(secondaryValueField)
    }
  } else {
    add()
  }
}

const operatorDisplayClicked = () => {
  operator.value = {...operator.value, displayValue: false}
  value.value = {...value.value, displayValue: false}
  focus(operatorField)
}

const valueDisplayClicked = () => {
  value.value = {...value.value, displayValue: false}

  if (requirement.value?.hasListValues) {
    focus(listOfValueField)
  } else {
    focus(valueField)
  }
}

const reset = () => {
  requirement.value = null
  psEvent.value = null
  operator.value = null
  value.value = null
  listOfValueField.value = null
  secondaryValue.value = null
  isEditorInUse.value = null

  if (valueField.value !== null && Object.hasOwn(valueField.value, 'isMenuActive')) {
    valueField.value.isMenuActive = false
  }

  emit('in-progress', false)
}

const getSystemListValues = async () => {
  if (!requirement.value?.name) {
    return
  }

  let url
  const fieldName = requirement.value.name
  if (fieldName === 'Project Owner') {
    url = `/project/owners`
  } else if (fieldName === 'Contact Owner') {
    url = `/contact/owners`
  } else if (fieldName === 'Process Step Owner' && psEvent.value?.id) {
    url = `/processStep/${psEvent.value.id}/owners`
  } else if (requirement.value.objectTypeId === 6) {
    if (fieldName === 'Event Resource') {
      url = `/event/${psEvent.value.id}/owners`
    } else if (fieldName === 'Event Status') {
      url = `/event/${psEvent.value.id}/lovStatus`
    } else if (fieldName === 'Event Category') {
      url = `/event/${psEvent.value.id}/lovCategory`
    } else {
      return
    }
  } else {
    return
  }

  try {
    const {data} = await getRequest(url)

    requirement.value.isCustomValue = true
    requirement.value.hasListOfValues = true
    //Event data return correctly and doesn't need manipulation
    requirement.value.listOfValues = (requirement.value.objectTypeId === 6) ? data : data.map(v => ({id: v.userPositionId, name: v.fullName}))
  } catch (e) {
    snackbar('ERROR', 'Error fetching available owners')
  }
}

const getDataTypeRequirements = async () => {
  if (!requirement.value?.dataTypeId) {
    return
  }

  try {
    const {data} = await getRequest(`/dataType/getDataTypeRequirements/${requirement.value.dataTypeId}`)
    availableDataTypeRequirements.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch data type requirements')
  }
}

const getOperators = async () => {
  if (!requirement.value?.dataTypeId) {
    return
  }

  try {
    const {data} = await getRequest(`/operator/${requirement.value.dataTypeId}`)
    availableOperators.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Unable to fetch operators')
  }
}

const add = () => {
  //data integrity checks
  if (requirement.value === null || operator.value === null || value.value === null) {
    return
  }

  //vuetify's combobox will return custom input as a string
  if (typeof value.value === 'string' && value.value.trim().length === 0) {
    snackbar('ERROR', 'Invalid value')
    return
  }

  if (value.value?.secondaryRequirement && secondaryValue.value.trim().length === 0) {
    snackbar('ERROR', 'Invalid value')
    return
  }

  if (psEvent.value !== null) {
    if (requirement.value.objectTypeId === 4) {
      requirement.value.processStepId = psEvent.value.id
      requirement.value.processStepName = psEvent.value.name
    } else {
      requirement.value.eventId = psEvent.value.id
      requirement.value.eventName = psEvent.value.name
    }
  }

  requirement.value.operatorTypeId = operator.value.id
  requirement.value.operatorType = operator.value.operatorType

  //if select value is custom
  if (typeof value.value === 'string') {
    requirement.value.requirementValue = value.value.trim()
  } else if (Array.isArray(value.value)) {
    //if selected value is a multi-select
    requirement.value.listOfValueIds = value.value.map(v => v.id)
  } else if (value.value?.dataTypeId) {
    //if selected value is a data type requirement
    requirement.value.dataTypeRequirementId = value.value.id
    requirement.value.dataTypeRequirement = value.value
  } else {
    //selected value is a list value
    requirement.value.listOfValueId = value.value.id
  }

  if (value.value?.secondaryRequirement) {
    requirement.value.secondaryRequirement = true
    requirement.value.secondaryRequirementValue = secondaryValue.value.trim()
  }

  if (requirement.value.hasListOfValues) {
    requirement.value.availableListOfValues = requirement.value.listOfValues
  }

  requirement.value.isCustomValue = (typeof value.value === 'string' || typeof value.value === 'object')

  if (requirement.value.companyId === null) {
    requirement.value.companyId = companyId
  }

  if (isEditing.value) {
    emit('updated', requirement.value)
  } else {
    emit('added', requirement.value)
  }
  reset()
}

onMounted(() => {
  if (isEditing.value) {
    isEditorInUse.value = true
    emit('in-progress', true)

    requirement.value = cloneDeep(props.existingRequirement)
    if (requirement.value.objectTypeId === 4) {
      psEvent.value = {
        id: requirement.value.processStepId,
        name: requirement.value.processStepName
      }
    } else if (requirement.value.objectTypeId === 6) {
      psEvent.value = {
        id: requirement.value.eventId,
        name: requirement.value.eventName
      }
    }

    operator.value = {
      id: requirement.value.operatorTypeId,
      operatorType: requirement.value.operatorType
    }

    if (requirement.value.dataTypeRequirementId) {
      value.value = requirement.value.dataTypeRequirement
    } else if (requirement.value.listOfValueId) {
      requirement.value.listOfValues = requirement.value.availableListOfValues
      value.value = requirement.value.availableListOfValues.find(v => v.id === requirement.value.listOfValueId)
    }

    if (value.value?.secondaryRequirement) {
      secondaryValue.value = requirement.value.secondaryRequirementValue
    }

    requirement.value.displayValue = true
    operator.value.displayValue = true
    value.value.displayValue = true

    getOperators()
    getDataTypeRequirements()
  }
})
</script>

<style scoped lang="scss">

.highlight-background {
  background-color: var(--v-primary-lighten9);
}

.field-selector {
  :deep(.v-input__append-inner) {
    display: none !important;
  }
}

.add-field {
  width: max-content;
}

.hover {
  cursor: pointer;
}
</style>
