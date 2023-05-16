<template>
<v-sheet
  :class="{'add-field': showOverflow && requirement !== null}"
  class="mx-4 mb-2"
  :elevation="editorElevation"
  :rounded="showOverflow"
>
  <v-row class="align-center justify-start no-gutters mt-4">
    <v-col
      v-if="requirement !== null"
      class="flex-grow-0 text-no-wrap px-2"
    >
      <span class="highlight-background pa-2 rounded">{{ requirement.name }}</span>
    </v-col>

    <v-col
      v-if="requirement !== null && operator !== null"
      class="flex-grow-0 text-no-wrap px-2"
    >
      {{ operator.operatorType }}
    </v-col>

    <v-col
      v-if="requirement !== null && operator !== null && value?.secondaryRequirement"
      class="flex-grow-0 text-no-wrap px-2"
    >
      <span class="highlight-background pa-2 rounded">{{ value.dataTypeValue }}</span>
    </v-col>

    <v-col class="flex-grow-1">
      <v-autocomplete
        v-show="showFieldInput"
        ref="requirementField"
        v-model="requirement"
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
        v-model="psEventId"
        :items="calculatedAvailablePsEvents"
        item-text="name"
        item-value="id"
        return-object
        placeholder="Type or Select Name"
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
        v-model="operator"
        :items="availableOperators"
        item-text="operatorType"
        item-value="id"
        return-object
        placeholder="Type or Select Operator"
        solo
        flat
        hide-details="true"
        :class="{'field-selector': !showOverflow}"
        @blur="(requirement?.hasListValues) ? focus(listOfValueField) : focus(valueField)"
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

      <span v-if="operator !== null && !value?.secondaryRequirement">
            <v-combobox
              v-show="!requirement.hasListValues"
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
              v-show="requirement.hasListValues"
              ref="listOfValueField"
              v-model="value"
              :items="calculatedAvailableValues"
              item-text="name"
              item-value="id"
              return-object
              placeholder="Type or Select Value"
              solo
              flat
              hide-details="true"
              :multiple="requirement.allowMultiple"
              ripple="false"
              :class="{'field-selector': !showOverflow}"
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
                  @click.stop="reset"
                >
                  <v-icon>mdi-close</v-icon>
                </v-btn>
              </template>
            </v-autocomplete>
          </span>

      <v-text-field
        v-show="value?.secondaryRequirement"
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
</template>

<script setup>
import { getRequest, logError, UUID } from '@/helpers/helpers'
import { computed, getCurrentInstance, nextTick, ref } from 'vue'
import cloneDeep from 'lodash.clonedeep'

const emit = defineEmits(['added', 'updated', 'overflow-required'])

const props = defineProps({
  availableFields: {
    type: Array,
    required: true
  }
})

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar

const availableDataTypeRequirements = ref([])
const availableOperators = ref([])

const requirement = ref(null)
const psEventId = ref(null)
const operator = ref(null)
const value = ref(null)
const secondaryValue = ref(null)

const requirementField = ref(null)
const psEventField = ref(null)
const operatorField = ref(null)
const valueField = ref(null)
const listOfValueField = ref(null)
const secondaryValueField = ref(null)
const showOverflow = ref(false)

const editorElevation = computed(() => (showOverflow.value) ? 1 : 0)

const showFieldInput = computed(() => requirement.value === null)

const showPsEventInput = computed(() => {
  const isPsEventSmartlistField = !!requirement.value?.smartlistFieldId && [4,6].includes(requirement.value?.objectTypeId)
  return !showFieldInput.value && isPsEventSmartlistField && psEventId.value === null
})

const showOperatorInput = computed(() => {
  return !showFieldInput.value &&
    !showPsEventInput.value &&
    operator.value === null
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

const calculatedAvailablePsEvents = computed(() => {

  if (requirement.value === null) {
    return []
  }

  let items = []
  props.availableFields.filter(f => {
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

const toggleOverflow = (toggle) => {
  showOverflow.value = toggle
  emit('overflow-required', toggle)
}

const afterFieldSelected = () => {
  getDataTypeRequirements()
  getOperators()

  const isPsEventSmartlistField = !!requirement.value?.smartlistFieldId && [4,6].includes(requirement.value?.objectTypeId)

  if (!showFieldInput.value && isPsEventSmartlistField) {
    focus(psEventField.value)
  } else {
    focus(operatorField.value)
  }
}

const afterValueSelected = (userCheckedToAdd) => {
  if (requirement.value?.allowMultiple) {
    const dataTypeRequirement = value.value.find(v => v.isDataTypeRequirement)

    if (dataTypeRequirement) {
      value.value = dataTypeRequirement
      add()
    }

    if (userCheckedToAdd) {
      add()
    }

  } else if (value.value?.secondaryRequirement) {
    focus(secondaryValueField.value)
  } else {
    add()
  }
}

const reset = () => {
  requirement.value = null
  psEventId.value = null
  operator.value = null
  value.value = null
  psEventField.value = null
  listOfValueField.value = null
  secondaryValue.value = null
  showOverflow.value = null

  if (valueField.value !== null && Object.hasOwn(valueField.value, 'isMenuActive')) {
    valueField.value.isMenuActive = false
  }

  emit('overflow-required', false)
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

  if (psEventId.value !== null) {
    if (requirement.value.objectTypeId === 4) {
      requirement.value.processStepId = psEventId.value.id
      requirement.value.processStepName = psEventId.value.name
    } else {
      requirement.value.eventId = psEventId.value.id
      requirement.value.eventName = psEventId.value.name
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

  requirement.value.isCustomValue = typeof value.value === 'string'

  emit('added', requirement.value)
  reset()
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
</script>

<style scoped lang="scss">

</style>