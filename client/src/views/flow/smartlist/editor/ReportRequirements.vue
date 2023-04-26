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
        v-show="newRequirement === null"
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
        @change="[getDataTypeRequirements(), getOperators()]"
        @focus="toggleOverflow(true)"
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
        v-show="newRequirement !== null && newOperator === null"
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
        @blur="focus(valueField)"
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

      <v-combobox
        v-show="newOperator !== null && newValue === null"
        ref="valueField"
        v-model="newValue"
        :items="availableDataTypeRequirements"
        item-text="dataTypeValue"
        item-value="id"
        return-object
        placeholder="Type or Select Value"
        solo
        flat
        hide-details="true"
        :class="{'field-selector': !showOverflow}"
        @change="(!newValue?.secondaryRequirement) ? add() : focus(secondaryValueField)"
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
const newOperator = ref(null)
const newValue = ref(null)
const secondaryValue = ref(null)

const availableDataTypeRequirements = ref([])
const availableOperators = ref([])
const showOverflow = ref(false)

const requirementField = ref(null)
const operatorField = ref(null)
const valueField = ref(null)
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

  newRequirement.value.operatorTypeId = newOperator.value.id

  if (typeof newValue.value === 'string') {
    newRequirement.value.requirementValue = newValue.value.trim()
  } else {
    newRequirement.value.dataTypeRequirementId = newValue.value.id
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
  newOperator.value = null
  newValue.value = null
  secondaryValue.value = null
  showOverflow.value = false
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