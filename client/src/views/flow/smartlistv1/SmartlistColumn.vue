<template>
  <v-col cols="12" class="pt-0">
    <v-toolbar color="transparent" class="elevation-0">
      <v-toolbar-title>Columns</v-toolbar-title>
      <v-spacer />
      <v-toolbar-items>
        <a-btn
            v-if="!showNewFieldForm && canEdit"
            variant="text"
            color="primary"
            prepend-icon="add"
            @click="showNewFieldForm = true"
            text="Add Field"
        ></a-btn>

        <a-btn
            v-if="showNewFieldForm"
            variant="text"
            color="primary"
            @click="resetNewFieldForm"
            text="Cancel"
        ></a-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-card v-if="showNewFieldForm" class="elevation-1">
      <v-col class="text-left">

        <template v-if="isProjectDetails === true">
          <a-autocomplete
              v-model="newField"
              label="Field"
              :items="filteredProjectDetailsColumns"
              item-title="projectDetailsColumn"
              return-object
              item-text="name"
              attach
          />
        </template>

        <template v-else>
          <a-autocomplete
              v-model="newField.objectTypeId"
              label="Object Type"
              :items="companyObjectTypes"
              item-value="objectTypeId"
              item-title="objectType"
              @input="getAvailableFields"
              attach
          />

          <a-autocomplete
              v-if="newField.objectTypeId !== null && newField.objectTypeId === 4"
              v-model="newField.processStepId"
              label="Process Step"
              :items="availableProcessSteps"
              item-value="processStepId"
              item-title="processStepName"
              @input="calculateAvailableFields"
              attach
          />

          <a-autocomplete
              v-if="newField.objectTypeId !== null && newField.objectTypeId === 6"
              v-model="newField.eventId"
              label="Event"
              :items="availableEvents"
              item-value="eventId"
              item-title="eventName"
              @input="[calculateAvailableFields(), getProcessStepEvents()]"
              attach
          />

          <a-autocomplete
              v-if="(newField.objectTypeId === 4 && newField.processStepId) || (newField.objectTypeId === 6 && newField.eventId) || (newField.objectTypeId != null && ![4, 6].includes(newField.objectTypeId))"
              v-model="newField.selectedField"
              label="Field"
              :items="availableFields"
              item-title="name"
              :item-value="item =>`${item.name} - ${item.smartlistFieldId} - ${item.customFieldGroupAssignmentId}`"
              return-object
              attach
          />

          <a-autocomplete
              v-if="newField.objectTypeId !== null && newField.objectTypeId === 6 && newField.eventId"
              v-model="newField.processStepEventId"
              label="Process Step"
              :items="fetchedProcessStepEvents"
              item-value="id"
              item-title="processStepName"
              attach
          />
        </template>

        <a-btn
            variant="text"
            color="primary"
            class="text-left"
            :disabled="isNewFieldButtonDisabled"
            @click="addNewField"
            text="Save"
            prepend-icon="save"
        ></a-btn>
      </v-col>
    </v-card>

    <v-list dense>
      <v-list-item>
        <v-list-item-action v-if="canEdit">
          <v-icon></v-icon>
        </v-list-item-action>

        <v-list-item-content>
          <v-row>
            <v-col cols="1" class="text-left smartlist-field">Order</v-col>
            <v-col cols="3" class="text-left smartlist-field">Field Name</v-col>
            <v-col cols="4" class="text-left smartlist-field">Object Type</v-col>
            <v-col cols="4" class="text-left smartlist-field">Process Step/Event Name</v-col>
          </v-row>
        </v-list-item-content>

        <v-list-item-action>
          <v-icon></v-icon>
        </v-list-item-action>
      </v-list-item>

      <v-divider />
      <v-divider />

      <draggable
          :disabled="!canEdit"
          v-model="assignedFields"
          @change="reorderFields"
          group="assignedFields"
      >

        <v-list-item
            :class="{grab: canEdit}"
            v-for="(field, index) in assignedFields"
            :key="field.id"
        >

          <v-list-item-action v-if="canEdit">
            <v-icon class="primary--text">drag_handle</v-icon>
          </v-list-item-action>

          <v-list-item-content>
            <v-row>
              <v-col cols="1" class="text-left">{{field.displayOrder}}</v-col>
              <v-col cols="3" class="text-left">{{field.name}}</v-col>
              <v-col cols="4" class="text-left">{{field.objectType}}</v-col>
              <v-col cols="4" class="text-left">{{(field.objectTypeId === 6) ? `${field.eventName} (${field.processStepName})` : field.processStepName}}</v-col>
            </v-row>
          </v-list-item-content>

          <v-list-item-action class="clickable">
            <v-icon v-if="canEdit" color="primary" @click="colToDelete={field, index}">delete</v-icon>
            <v-icon v-else></v-icon>
          </v-list-item-action>
        </v-list-item>
      </draggable>
    </v-list>
    <ConfirmationDialog :open-dialog="!!colToDelete" @confirm="deleteField" @close-dialog="colToDelete=null">
      Are you sure you want to delete this column: <b>{{colToDeleteFieldName}}</b>?
    </ConfirmationDialog>
  </v-col>
</template>

<script setup>
import {
  deleteRequest,
  getRequest,
  getSnackbar,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  putRequest,
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import draggable from 'vuedraggable'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  canEdit: {
    type: Boolean,
    default: false
  },
  isProjectDetails: {
    type: Boolean,
    default: false
  },
  companyObjectTypes: {
    type: Array,
    default: () => []
  },
  projectDetailsColumns: {
    type: Array,
    default: () => []
  },
  smartlistId: {
    type: [String, Number]
  },
  refresh: {
    type: Boolean,
    default: false
  }
})
const { canEdit, isProjectDetails, companyObjectTypes,
  projectDetailsColumns, smartlistId, refresh } = toRefs(props)

const emit = defineEmits(['refreshed'])

const showNewFieldForm = ref(false)
const newField = ref({})
const availableProcessSteps = ref([])
const availableFields = ref([])
const availableEvents = ref([])
const fetchedAvailableFields = ref([])
const fetchedProcessStepEvents = ref([])
const assignedFields = ref([])
const colToDelete = ref(null)

const filteredProjectDetailsColumns = computed(() => {
  return projectDetailsColumns.value.filter(f => {
    return !assignedFields.value.find(af => af.projectDetailsColumn === f.projectDetailsColumn && (f.processStepEventId === null || af.processStepEventId === f.processStepEventId))
  })
})
const isNewFieldButtonDisabled = computed(() => {
  return !newField.value?.selectedField && !newField.value?.projectDetailsColumn
})
const colToDeleteFieldName = computed(() => {
  return colToDelete.value ? colToDelete.value.field.name : ''
})

const resetNewFieldForm =  () => {
  showNewFieldForm.value = false
  newField.value = {}
}
const getAssignedFields = async () => {
  try {
    let timezone = userStore.timezone.value
    const {data} = await getRequest(`/smartlistv1/${smartlistId.value}/field?timezone=${timezone}`)
    assignedFields.value = data
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching assigned fields')

  }
}

watch(refresh, (newValue, oldValue) => {
  getAssignedFields()
  emit('refreshed')
}, { immediate: true })

const getAvailableFields = async () => {
  newField.value = {objectTypeId: newField.value.objectTypeId}
  try {
    const {data} = await getRequest(`/smartlistv1/availableFieldsByType?objectTypeId=${newField.value.objectTypeId}`)
    fetchedAvailableFields.value = data
    if (newField.value.objectTypeId === 4) {
      availableProcessSteps.value = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
      availableProcessSteps.value = availableProcessSteps.value.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
    } else if (newField.value.objectTypeId === 6) {
      availableEvents.value = data.reduce((fields, field) => (field.eventId ===  null || fields.find(f => f.eventName === field.eventName)) ? [...fields] : [...fields, field], [])
      availableEvents.value = availableEvents.value.sort((a, b) => a.eventName.localeCompare(b.eventName))
    } else {
      calculateAvailableFields()
    }
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching available fields')

  }
}
const getProcessStepEvents = async() => {
  try {
    const {data} = await getRequest(`/event/${newField.value.eventId}/processStepEvents`)
    fetchedProcessStepEvents.value = data
    const psEventsForSelectedEvent = data.filter(pse => pse.eventId === newField.value.eventId)
    //if this event is attached to only one process step, autoselect the process step event id
    if (psEventsForSelectedEvent.length === 1) {
      newField.value.processStepEventId = psEventsForSelectedEvent[0].id
    }
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error fetching process step events')

  }
}
const addNewField = async () => {
  try {
    appStore.loading = true
    const {data, status} = await postRequest(`/smartlistv1/${smartlistId.value}/field`, {
      ...newField.value.selectedField,
      smartlistId: smartlistId.value,
      displayOrder: assignedFields.value.length + 1,
      processStepId: newField.value.processStepId || null,
      projectDetailsColumn: newField.value.projectDetailsColumn,
      processStepEventId: newField.value.processStepEventId || null
    })
    assignedFields.value.push(data)
    resetNewFieldForm()
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error adding field to smartlist')

    appStore.loading = false
  }
}
const deleteField = async () => {
  const fieldIndex = colToDelete.value.index;
  try {
    const fieldToDelete = assignedFields.value[fieldIndex]
    appStore.loading = true
    await deleteRequest(`/smartlistv1/${smartlistId.value}/field/${fieldToDelete.id}`)
    assignedFields.value.splice(fieldIndex, 1)
    const {status} = await reorderFields({moved: {newIndex: 0, oldIndex: 1}})
    handleHidingGlobalLoader( status)
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error removing field from smartlist')

    appStore.loading = false
  }
}
const reorderFields = async ({moved}) => {

  // If a drag happened but order wasn't changed
  if (moved.newIndex === moved.oldIndex) {
    return
  }
  assignedFields.value.forEach((field, index) => field.displayOrder = index + 1)

  try {
    appStore.loading = true
    const {status} = await putRequest(`/smartlistv1/${smartlistId.value}/order`, assignedFields.value)
    handleHidingGlobalLoader( status)
    return {status}
  } catch (e) {
    logError(e)
    appStore.showSnack('ERROR', 'Error updating field order')

    appStore.loading = false
    return {status: 500}
  }
}
const calculateAvailableFields =  () => {
  availableFields.value = fetchedAvailableFields.value.filter(f => f.name !== null).sort((a, b) => a.name.localeCompare(b.name))
  if (newField.value.objectTypeId === 4) {
    availableFields.value = availableFields.value.filter(field => field.processStepId === newField.value.processStepId || field.smartlistFieldId !== null)
  } else if (newField.value.objectTypeId === 6) {
    availableFields.value = availableFields.value.filter(field => field.eventId === newField.value.eventId || field.smartlistFieldId !== null)
  }

  availableFields.value = availableFields.value.filter(f => {
    if (f.customFieldGroupAssignmentId !== null) {
      return !assignedFields.value.map(a => a.customFieldGroupAssignmentId).includes(f.customFieldGroupAssignmentId)
    } else {
      if (newField.value.objectTypeId === 4) {
        return !assignedFields.value.filter(a => a.processStepId === newField.value.processStepId).map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
      } else if (newField.value.objectTypeId === 6) {
        return !assignedFields.value.filter(a => a.eventId === newField.value.eventId).map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
      } else {
        return !assignedFields.value.map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
      }
    }
  })
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

.smartlist-field {
  font-size: 12px;
  color: var(--v-grey-base);
  font-weight: 700; line-height: 18px;
}

.v-list {
  padding: 0 !important;
}

.v-list-item:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
