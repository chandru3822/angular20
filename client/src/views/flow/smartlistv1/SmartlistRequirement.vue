<template>
  <v-col cols="12">
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Requirements</v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <a-btn
            v-if="!showNewRequirementForm && canEdit"
            @click="showNewRequirementForm = true"
            variant="text"
            color="primary"
            text="Add Requirement"
            prepend-icon="add"
        ></a-btn>

        <a-btn
            v-if="showNewRequirementForm"
            variant="text"
            color="primary"
            @click="resetRequirementForm"
            text="Cancel"
        ></a-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-card v-if="showNewRequirementForm" class="elevation-1">
      <v-col class="text-left">

        <template v-if="isProjectDetails === true">
          <a-autocomplete
              v-model="newRequirement.selectedField"
              label="Field"
              :items="filteredProjectDetailsRequirements"
              item-value="project_details_column"
              item-title="name"
              return-object
              attach
              @input="[
            resetNewField(),
            getOperators(newRequirement.selectedField.dataTypeId),
            getDataTypeRequirements(newRequirement.selectedField.dataTypeId)
          ]"
          />
        </template>

        <template v-else>
          <a-autocomplete
              v-model="newRequirement.objectTypeId"
              label="Object Type"
              :items="companyObjectTypes"
              item-value="objectTypeId"
              item-title="objectType"
              @input="[resetNewObjectType(), getAvailableFields()]"
              attach
          />

          <a-autocomplete
              v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 4"
              v-model="newRequirement.processStepId"
              label="Process Step"
              :items="availableProcessSteps"
              item-value="processStepId"
              item-title="processStepName"
              @input="[resetNewProcessStep(), calculateAvailableFields()]"
              attach
          />

          <a-autocomplete
              v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 6"
              v-model="newRequirement.eventId"
              label="Event"
              :items="availableEvents"
              item-value="eventId"
              item-title="eventName"
              @input="[
            resetNewProcessStep(),
            calculateAvailableFields(),
            getProcessStepEvents()
          ]"
              attach
          />

          <a-autocomplete
              v-if="(newRequirement.objectTypeId === 4 && newRequirement.processStepId) || (newRequirement.objectTypeId === 6 && newRequirement.eventId) || (newRequirement.objectTypeId != null && ![4, 6].includes(newRequirement.objectTypeId))"
              v-model="newRequirement.selectedField"
              label="Field"
              :items="availableFields"
              item-title="name"
              :item-value="item =>`${item.name} - ${item.smartlistFieldId} - ${item.customFieldGroupAssignmentId}`"
              return-object
              attach
              @input="[
            resetNewField(),
            getOperators(newRequirement.selectedField.dataTypeId),
            getDataTypeRequirements(newRequirement.selectedField.dataTypeId),
            getProcessStepFieldData(),
            checkSmartlistSystemList(),
            getSystemFieldListOfValues()
          ]"
          />

          <a-autocomplete
              v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 6 && newRequirement.eventId"
              v-model="newRequirement.processStepEventId"
              label="Process Step"
              :items="fetchedProcessStepEvents"
              item-value="id"
              item-title="processStepName"
              attach
          />
        </template>

        <a-autocomplete
            v-if="newRequirement.selectedField"
            v-model="newRequirement.operatorTypeId"
            label="Operator"
            :items="operators"
            attach
            item-title="operatorType"
            item-value="id"
            @input="resetNewOperatorType"
        />

        <v-switch
            v-if="newRequirement.operatorTypeId !== null"
            v-model="newRequirement.isCustomValue"
            :disabled="newRequirement.selectedField.dataTypeId === 3 || !!newRequirement.selectedField.smartlistSystemListId"
            class="mx-2"
            label="Custom"
            @change="resetInputValues(newRequirement)"
        />

        <!--      if field is a single-select item -->
        <a-autocomplete
            v-if="newRequirement.operatorTypeId !== null && newRequirement.isCustomValue && isListField && !newRequirement.selectedField.allowMultiple"
            v-model="newRequirement.listOfValueId"
            :items="newRequirement.selectedField.listOfValues"
            label="Available Values (list of value id)"
            item-title="name"
            item-value="id"
        />

        <!--      if field is a multi-select list -->
        <a-autocomplete
            v-else-if="newRequirement.operatorTypeId && newRequirement.isCustomValue && newRequirement.selectedField.listOfValueId !== null && newRequirement.selectedField.allowMultiple"
            v-model="newRequirement.listOfValueIds"
            :items="newRequirement.selectedField.listOfValues"
            label="Available Values"
            multiple
            item-title="name"
            item-value="id"
        />

        <!--      if field doesn't have any custom values, display the data type requirements -->
        <a-autocomplete
            v-else-if="newRequirement.operatorTypeId !== null && !newRequirement.isCustomValue"
            v-model="newRequirement.dataTypeRequirementId"
            label="Available Values"
            :items="dataTypeRequirements"
            item-title="dataTypeValue"
            item-value="id"
            @input="resetNewDataTypeRequirement"
        />

        <!--      if nothing else sticks, then it's a regular text input -->
        <!--      @TODO humes: check for date/time here and give a date picker -->
        <a-text-field
            v-else-if="newRequirement.operatorTypeId && newRequirement.isCustomValue"
            v-model="newRequirement.requirementValue"
            placeholder="Enter a value"
            label="Value">
        </a-text-field>

        <a-text-field
            v-if="newRequirement.dataTypeRequirementId && dataTypeRequirements.find(r => r.id === newRequirement.dataTypeRequirementId).secondaryRequirement"
            v-model="newRequirement.secondaryRequirementValue"
            label="Value"
            type="number"
            placeholder="Enter a value"
        />

        <a-btn
            variant="text"
            color="primary"
            class="text-left"
            :disabled="isSaveNewRequirementDisabled"
            @click="addNewRequirement"
            prepend-icon="save"
            text="Save"
        ></a-btn>
      </v-col>
    </v-card>
    <v-data-table
        :headers="headers"
        :items="requirements"
        hide-default-footer
        disable-pagination
        :expanded.sync="expandedRequirementArray"
        single-expand
    >
      <template #no-data>
        <span class="default-text-color">No requirements for this process step</span>
      </template>

      <template #no-results>
        <span class="default-text-color">No requirements for this process step</span>
      </template>

      <template #item="{item: requirement, index}">
        <tr>
          <td class="text-left" style="width: 65px">{{requirement.displayOrder}}</td>
          <td class="text-left">{{requirement.name}}</td>
          <td class="text-left">{{requirement.objectType}}</td>
          <td class="text-left">{{(requirement.objectTypeId === 6) ? requirement.eventName : requirement.processStepName}}</td>
          <td class="text-left">{{requirement.operatorType}}</td>
          <td class="text-left">
            <template v-if="requirement.requirementValue">{{requirement.requirementValue}}</template>
            <template v-else-if="requirement.dataTypeRequirementId">
              {{requirement.dataTypeRequirement ? requirement.dataTypeRequirement.dataTypeValue : 'unknown'}} {{requirement.secondaryRequirementValue}}
            </template>
            <template v-else-if="requirement.listOfValueId || requirement.customFieldSql || requirement.companySystemListId">{{getListValueName(requirement)}}</template>
            <template v-else-if="requirement.listOfValues">{{computeMutliSelectValue(requirement)}}</template>
          </td>
          <td v-if="canEdit" class="action-cell">
            <!--          Vuetify keeps its own copy of requirements, so we can't just send `requirement` to functions for form reset 💩 -->
            <v-icon
                v-if="expandedRequirement && expandedRequirement.id !== requirement.id"
                class="action-icon" color="primary"
                @click="[cancelEditRequirement(), editRequirement(requirements.find(r => r.id === requirement.id))]"
            >
              edit
            </v-icon>

            <a-btn
                v-else
                small
                variant="text"
                color="primary"
                @click="cancelEditRequirement"
                text="Cancel"
            ></a-btn>

            <v-icon
                class="action-icon"
                color="primary"
                @click="reqToDelete=requirement"
            >
              delete
            </v-icon>
          </td>
          <td v-else></td>
        </tr>
      </template>

      <template #expanded-item="{headers}">
        <tr>
          <td :colspan="headers.length" class="text-left expanded-row">

            <template v-if="isProjectDetails === true">
              <a-autocomplete
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Field"
                  item-title="name"
                  disabled
                  attach
              />
            </template>

            <template v-else>
              <a-autocomplete
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Object Type"
                  item-title="objectType"
                  disabled
                  attach
              />

              <a-autocomplete
                  v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 4"
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Process Step"
                  item-title="processStepName"
                  disabled
                  attach
              />

              <a-autocomplete
                  v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 6"
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Event"
                  item-title="eventName"
                  disabled
                  attach
              />

              <a-autocomplete
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Field"
                  item-title="name"
                  disabled
                  attach
              />

              <a-autocomplete
                  v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 6"
                  v-model="expandedRequirement"
                  :items="[expandedRequirement]"
                  label="Process Step"
                  item-title="processStepName"
                  disabled
                  attach
              />
            </template>

            <a-autocomplete
                v-model="expandedRequirement.operatorTypeId"
                label="Operator"
                :items="operators"
                item-title="operatorType"
                item-value="id"
                attach
            />

            <!--      @TODO humes: on change, reset any value that follows -->
            <v-switch
                v-if="expandedRequirement.operatorTypeId !== null"
                v-model="expandedRequirement.isCustomValue"
                :disabled="expandedRequirement.dataTypeId === 3 || !!expandedRequirement.smartlistSystemListId"
                class="mx-2"
                label="Custom"
                @change="resetInputValues(expandedRequirement)"
            />

            <!--      if field is a single-select item -->
            <a-autocomplete
                v-if="expandedRequirement.operatorTypeId !== null && expandedRequirement.isCustomValue && isExpandedListField && !expandedRequirement.allowMultiple"
                v-model="expandedRequirement.listOfValueId"
                :items="expandedRequirement.availableListOfValues"
                label="Available Values"
                item-title="name"
                item-value="id"
            />

            <!--      if field is a multi-select list -->
            <a-autocomplete
                v-else-if="expandedRequirement.operatorTypeId && expandedRequirement.isCustomValue && isExpandedListField && expandedRequirement.allowMultiple"
                v-model="expandedRequirement.listOfValueIds"
                :items="expandedRequirement.availableListOfValues"
                label="Available Values"
                multiple
                item-title="name"
                item-value="id"
            />

            <!--      if field doesn't have any custom values, display the data type requirements -->
            <a-autocomplete
                v-else-if="expandedRequirement.operatorTypeId !== null && !expandedRequirement.isCustomValue"
                v-model="expandedRequirement.dataTypeRequirementId"
                label="Available Values"
                :items="dataTypeRequirements"
                item-title="dataTypeValue"
                item-value="id"
                @input="resetNewDataTypeRequirement"
            />

            <!--      if nothing else sticks, then it's a regular text input -->
            <!--      @TODO humes: check for date/time here and give a date picker -->
            <a-text-field
                v-else-if="expandedRequirement.operatorTypeId && expandedRequirement.isCustomValue"
                v-model="expandedRequirement.requirementValue"
                placeholder="Enter a value"
                label="Value">
            </a-text-field>

            <a-text-field
                v-if="shouldShowEditFormValueInput"
                v-model="expandedRequirement.secondaryRequirementValue"
                label="Value"
                type="number"
                placeholder="Enter a value"
            />

            <a-btn
                variant="text"
                color="primary"
                :disabled="isSaveExpandedRequirementDisabled"
                @click="updateRequirement(expandedRequirement)"
                prepend-icon="save"
                text="Save"
            ></a-btn>
          </td>
        </tr>
      </template>
    </v-data-table>
    <ConfirmationDialog :open-dialog="!!reqToDelete" @confirm="deleteRequirement" @close-dialog="reqToDelete=null">
      Are you sure you want to delete this requirement: <b>{{reqToDeleteFieldName}}</b>?
    </ConfirmationDialog>
  </v-col>
</template>

<script setup>

import {getRequest, logError, } from '@/helpers/helpers'
import constants from '@/helpers/constants'

import ConfirmationDialog from "@/components/ConfirmationDialog";

import {getCurrentInstance, toRefs, computed, ref, onMounted, watch, onUpdated} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const emit = defineEmits(['input', 'update', 'delete', 'form-reset'])

const newRequirementStructure = {
  selectedField: null,
  objectTypeId: null,
  processStepId: null,
  eventId: null,
  operatorTypeId: null,
  dataTypeRequirementId: null,
  requirementValue: null,
  secondaryRequirement: null,
  secondaryRequirementValue: null,
  isCustomValue: null,
  allowMultiple: null,
  customFieldSql: null,
  companySystemListId: null,
  availableListOfValues: [],
  listOfValueId: null,
  listOfValueIds: [],
}

const props = defineProps({
  requirements: {
    type: Array,
    default: () => []
  },
  companyObjectTypes: {
    type: Array,
    default: () => []
  },
  resetForm: {
    type: Boolean,
    default: false
  },
  canEdit: {
    type: Boolean,
    default: false
  },
  isProjectDetails: {
    type: Boolean,
    default: false
  },
  projectDetailsRequirements: {
    type: Array,
    default: () => []
  }
})
const { requirements, companyObjectTypes, resetForm, canEdit, isProjectDetails, projectDetailsRequirements } = toRefs(props)

const showNewRequirementForm = ref(false)
const newRequirement = ref(Object.assign({}, newRequirementStructure))
const fetchedAvailableFields = ref([])
const availableFields = ref([])
const availableProcessSteps = ref([])
const availableEvents = ref([])
const fetchedProcessStepEvents = ref([])
const operators = ref([])
const dataTypeRequirements = ref([])
const headers = ref([
  {text: 'ID', value: 'displayOrder'},
  {text: 'Field Name', value: 'name'},
  {text: 'Object Type', value: 'objectType'},
  {text: 'Process Step/Event Name', value: 'processStepName'},
  {text: 'Operator', value: 'operatorType'},
  {text: 'Value', value: 'requirementValue'},
  {text: null, value: 'actions'}
])
const expandedRequirement = ref({selectedField: null,objectTypeId: null,processStepId: null,operatorTypeId: null,dataTypeRequirementId: null,secondaryRequirement: null,secondaryRequirementValue: null,isCustomValue: null,allowMultiple: null,customFieldSql: null,companySystemListId: null,availableListOfValues: []})
const projectStatusTypes = ref([])
const companyProjectStatusTypes = ref([])
const reqToDelete = ref(null)

onMounted(() => {
  getProjectStatusTypes()
  // getProcessStepStatusTypes()
})

onUpdated(() => {
  if (resetForm.value) {
    resetRequirementForm()
  }
})


const filteredProjectDetailsRequirements = computed(() => {
  return projectDetailsRequirements.value.filter(f => {
    return !requirements.value.find(af => af.projectDetailsColumn === f.projectDetailsColumn && (f.processStepEventId === null || af.processStepEventId === f.processStepEventId))
  })
})
const shouldShowEditFormValueInput = computed(() => {
  return expandedRequirement.value.dataTypeRequirement?.secondaryRequirement
})
const isListField = computed(() => {
  return newRequirement.value.selectedField.hasListValues || newRequirement.value.selectedField.customFieldSql !== null || newRequirement.value.selectedField.companySystemListId !== null
})
const isExpandedListField = computed(() => {
  return expandedRequirement.value.hasListValues || expandedRequirement.value.customFieldSql !== null || expandedRequirement.value.companySystemListId !== null || (expandedRequirement.value.availableListOfValues != null && expandedRequirement.value.availableListOfValues.length > 0)
})
const expandedRequirementArray = computed(() => {
  return [expandedRequirement.value];
});
const isSaveNewRequirementDisabled = computed(() => {
  if (newRequirement.value.isCustomValue) {
    const isEmptyList = (newRequirement.value.hasListValues === true && newRequirement.value.allowMultiple === false && newRequirement.value.listOfValueId === null) || (newRequirement.value.allowMultiple === true && newRequirement.value.listOfValueIds.length === 0)
    return (newRequirement.value.requirementValue === null || newRequirement.value.requirementValue?.length === 0) && isEmptyList
  } else {
    return newRequirement.value.dataTypeRequirementId === null && newRequirement.value.listOfValueId === null && newRequirement.value.listOfValueIds.length === 0
  }
})
const isSaveExpandedRequirementDisabled = computed(() => {
  if (expandedRequirement.value.isCustomValue) {
    const isEmptyList = (expandedRequirement.value.hasListValues === true && expandedRequirement.value.allowMultiple === false && expandedRequirement.value.listOfValueId === null) || (expandedRequirement.value.allowMultiple === true && expandedRequirement.value.listOfValueIds.length === 0)
    return (expandedRequirement.value.requirementValue === null || expandedRequirement.value.requirementValue?.length === 0) && isEmptyList
  } else {
    return expandedRequirement.value.dataTypeRequirementId === null && expandedRequirement.value.listOfValueId === null && expandedRequirement.value.listOfValueIds.length === 0
  }
})
const reqToDeleteFieldName = computed(() => {
  return reqToDelete.value ? reqToDelete.value.name : '';
})

const getAvailableFields = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/availableFieldsByType?objectTypeId=${newRequirement.value.objectTypeId}`)
    fetchedAvailableFields.value = data
    if (newRequirement.value.objectTypeId === 4) {
      availableProcessSteps.value = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
      availableProcessSteps.value = availableProcessSteps.value.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
    } else if (newRequirement.value.objectTypeId === 6) {
      availableEvents.value = data.reduce((fields, field) => (field.eventId ===  null || fields.find(f => f.eventName === field.eventName)) ? [...fields] : [...fields, field], [])
      availableEvents.value = availableEvents.value.sort((a, b) => a.eventName.localeCompare(b.eventName))
    } else {
      calculateAvailableFields()
    }
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching available fields')

  }
}
const getOperators = async (dataTypeId) => {
  try {
    const {data} = await getRequest(`/operator/${dataTypeId}`)
    operators.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching operators for selected field')

  }
}
const getDataTypeRequirements = async (dataTypeId) => {
  try {
    const {data} = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)
    dataTypeRequirements.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching data type requirements for selected field')

  }
}
const getProcessStepFieldData = async () => {
  if (newRequirement.value.selectedField.customFieldGroupAssignmentId !== null) {
    try {
      const {data} = await getRequest(`/smartlistv1/availableFieldByCfgaId/${newRequirement.value.selectedField.customFieldGroupAssignmentId}`)
      newRequirement.value.selectedField = data
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error fetching process step data')

    }
  }
}
const getSystemFieldListOfValues = async() => {
  const selectedFieldName = newRequirement.value.selectedField.name

  // @TODO It's bad these check for the field name since it might change. Make better
  if ([1,2,4].includes(newRequirement.value.objectTypeId)) {

    //if this isn't one of the specific system fields we need, bail
    if (!['Project Owner','Contact Owner','Process Step Owner'].includes(selectedFieldName)) {
      return
    }

    try {
      let results
      if (selectedFieldName === 'Project Owner') {
        const {data} = await getRequest(`/project/owners`)
        results = data
      } else if (selectedFieldName === 'Contact Owner') {
        const {data} = await getRequest(`/contact/owners`)
        results = data
      } else if (selectedFieldName === 'Process Step Owner' && newRequirement.value.processStepId !== null) {
        const {data} = await getRequest(`/processStep/${newRequirement.value.processStepId}/owners`)
        results = data
      }

      newRequirement.value.selectedField.listOfValues = results.map(o => ({id: o.userPositionId, name: o.fullName}))
      newRequirement.value.selectedField.hasListValues = true
      newRequirement.value.isCustomValue = true
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error fetching available values')

    }
  } else if (newRequirement.value.eventId !== null) {

    //if this isn't one of the specific system fields we need, bail
    if (!['Event Resource','Event Status','Event Category'].includes(selectedFieldName)) {
      return
    }

    try {
      let results
      if (selectedFieldName === 'Event Resource') {
        const {data} = await getRequest(`/event/${newRequirement.value.eventId}/owners`)
        results = data
      } else if (selectedFieldName === 'Event Status') {
        const {data} = await getRequest(`/event/${newRequirement.value.eventId}/lovStatus`)
        results = data
      } else if (selectedFieldName === 'Event Category') {
        const {data} = await getRequest(`/event/${newRequirement.value.eventId}/lovCategory`)
        results = data
      }

      newRequirement.value.selectedField.listOfValues = results
      newRequirement.value.selectedField.hasListValues = true
      newRequirement.value.isCustomValue = true
    } catch (e) {
      logError(e)
      snackbar('ERROR', 'Error fetching available values')

    }
  }
}
const getProjectStatusTypes = async () => {
  try {
    const [result, companyResult] = await Promise.all([getRequest(`/projectStatus`), getRequest(`/project/companyStatus`)])
    projectStatusTypes.value = result.data
    companyProjectStatusTypes.value = companyResult.data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching project statuses')

  }
}
// const getProcessStepStatusTypes = async () => {
//   try {
//     const [result, companyResult] = await Promise.all([getRequest(`/processStep/status`), getRequest(`/processStep/status/company`)])
//     processStepStatusTypes.value = result.data
//     companyProcessStepStatusTypes.value = companyResult.data
//   } catch (e) {
//     logError(e)
//     snackbar('ERROR', 'Error fetching process step statuses')
//
//   }
// }
const getEventStatuses = async() => {
  if (newRequirement.value.eventId) {
    try {
      const {data} = await getRequest(`/event/${newRequirement.value.eventId}/lovStatus`)

      //find the event status field and insert statues
      const fieldIndex = fetchedAvailableFields.value.findIndex(f => f.name === 'Event Status')
      fetchedAvailableFields.value[fieldIndex].hasListValues = true
      fetchedAvailableFields.value[fieldIndex].listOfValues = data

      calculateAvailableFields()
    } catch(e) {
      logError(e)
      snackbar('ERROR', 'Error fetching event statuses')

    }
  }
}
const getEventCategories = async() => {
  if (newRequirement.value.eventId) {
    try {
      const {data} = await getRequest(`/event/${newRequirement.value.eventId}/lovCategory`)

      //find the event category field and insert categories

      // calculateAvailableFields()
    } catch(e) {
      logError(e)
      snackbar('ERROR', 'Error fetching event categories')

    }
  }
}
const getProcessStepEvents = async() => {
  try {
    const {data} = await getRequest(`/event/${newRequirement.value.eventId}/processStepEvents`)
    fetchedProcessStepEvents.value = data
    const psEventsForSelectedEvent = data.filter(pse => pse.eventId === newRequirement.value.eventId)
    //if this event is attached to only one process step, autoselect the process step event id
    if (psEventsForSelectedEvent.length === 1) {
      newRequirement.value.processStepEventId = psEventsForSelectedEvent[0].id
    }
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching operations')

  }
}
const addNewRequirement = () => {
  // Add the processStepId because system process step fields don't have a processStepId
  emit('input', {
    ...newRequirement.value,
    ...newRequirement.value.selectedField,
    processStepId: newRequirement.value.processStepId,
    processStepEventId: (isProjectDetails.value) ? newRequirement.value.selectedField.processStepEventId : newRequirement.value.processStepEventId
  })
}
const updateRequirement = (requirement) => {
  emit('update', requirement)
  expandedRequirement.value = {}
}
const editRequirement = (requirement) => {
  getOperators(requirement.dataTypeId)
  getDataTypeRequirements(requirement.dataTypeId)
  expandedRequirement.value = {...requirement}
}
const cancelEditRequirement = () => {
  expandedRequirement.value = {}
}
const deleteRequirement = () => {
  emit('delete', reqToDelete.value)
}
const calculateAvailableFields = () => {
  availableFields.value = fetchedAvailableFields.value.filter(f => f.name !== null).sort((a, b) => a.name.localeCompare(b.name))
  if (newRequirement.value.processStepId) {
    availableFields.value = availableFields.value.filter(field => field.processStepId === newRequirement.value.processStepId || field.smartlistFieldId !== null)
  } else if (newRequirement.value.eventId) {
    availableFields.value = availableFields.value.filter(field => field.eventId === newRequirement.value.eventId || field.smartlistFieldId !== null)
  }
}
const resetRequirementForm = () => {
  showNewRequirementForm.value = false
  newRequirement.value = Object.assign({}, newRequirementStructure)
  emit('form-reset', true)
}
const resetNewObjectType = () => {
  newRequirement.value = {
    ...newRequirement.value,
    processStepId: null,
    selectedField: null,
    operatorTypeId: null,
    dataTypeRequirementId: null,
    secondaryRequirementValue: null
  }
}
const resetNewProcessStep = () => {
  newRequirement.value = {
    ...newRequirement.value,
    selectedField: null,
    operatorTypeId: null,
    dataTypeRequirementId: null,
    secondaryRequirementValue: null
  }
}
const resetNewField = () => {
  newRequirement.value = {
    ...newRequirement.value,
    operatorTypeId: null,
    dataTypeRequirementId: null,
    secondaryRequirementValue: null,
    isCustomValue: null
  }
}
const resetNewOperatorType = () => {
  newRequirement.value = {
    ...newRequirement.value,
    dataTypeRequirementId: null,
    secondaryRequirementValue: null
  }
}
const resetNewDataTypeRequirement = () => {
  newRequirement.value = {
    ...newRequirement.value,
    secondaryRequirementValue: null
  }
}
const resetInputValues = (requirement) => {
  requirement.listOfValueId = null
  requirement.listOfValueIds = []
  requirement.dataTypeRequirementId = null
  requirement.requirementValue = null
  requirement.secondaryRequirementValue = null
}
const getListValueName = (listItem) => {
  let idToUse = listItem.customSqlOptionId ? listItem.customSqlOptionId : listItem.systemListOptionId ? listItem.systemListOptionId : listItem.listOfValueId
  let match = listItem.availableListOfValues.find(i => i.id === idToUse)
  return match ? match.name : 'unknown'
}
const checkSmartlistSystemList = () => {
  if (newRequirement.value?.selectedField?.smartlistSystemListId) {
    newRequirement.value.isCustomValue = true
  }
}
const computeMutliSelectValue =(req) => {
  if (req.smartlistSystemListId === null) {
    return req.listOfValues.map(v => ` ${v.name}`).toString()
  } else {
    //The backend returns incorrect listOfValues for smartlist field multiselects
    return req.availableListOfValues.filter(v => req.listOfValueIds.includes(v.id)).map(v => ` ${v.name}`).toString()
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

tr:nth-child(even) {
  @extend .shaded-row;
}

.action-cell {
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.action-icon:not(:first-child) {
  // 16px is the padding vuetify gives to data tables. I thought it should match. Ideally this would use vuetify's sass variable but I couldn't find which one controlled the data table's padding
  margin-left: 16px;
}

.expanded-row {
  padding-top: 12px;
  padding-bottom: 12px;
}
</style>
