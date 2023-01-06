<template>
<v-col cols="12" class="pt-0">
  <v-toolbar color="transparent" class="elevation-0">
    <v-toolbar-title>Columns</v-toolbar-title>
    <v-spacer />
    <v-toolbar-items>
      <v-btn
        v-if="!showNewFieldForm && canEdit"
        text
        color="primary"
        @click="showNewFieldForm = true"
      >
        <v-icon>add</v-icon>
        <template v-if="!constants.IS_MOBILE">Add Field</template>
      </v-btn>

      <v-btn
        v-if="showNewFieldForm"
        text
        color="primary"
        @click="resetNewFieldForm"
      >
        Cancel
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>

  <v-card v-if="showNewFieldForm" class="elevation-1">
    <v-col class="text-left">

      <template v-if="isProjectDetails === true">
        <v-autocomplete
          v-model="newField"
          label="Field"
          :items="filteredProjectDetailsColumns"
          item-value="projectDetailsColumn"
          return-object
          item-text="name"
          attach
        />
      </template>

      <template v-else>
        <v-autocomplete
          v-model="newField.objectTypeId"
          label="Object Type"
          :items="companyObjectTypes"
          item-value="objectTypeId"
          item-text="objectType"
          @input="getAvailableFields"
          attach
        />

        <v-autocomplete
          v-if="newField.objectTypeId !== null && newField.objectTypeId === 4"
          v-model="newField.processStepId"
          label="Process Step"
          :items="availableProcessSteps"
          item-value="processStepId"
          item-text="processStepName"
          @input="calculateAvailableFields"
          attach
        />

        <v-autocomplete
          v-if="newField.objectTypeId !== null && newField.objectTypeId === 6"
          v-model="newField.eventId"
          label="Event"
          :items="availableEvents"
          item-value="eventId"
          item-text="eventName"
          @input="[calculateAvailableFields(), getProcessStepEvents()]"
          attach
        />

        <v-autocomplete
          v-if="(newField.objectTypeId === 4 && newField.processStepId) || (newField.objectTypeId === 6 && newField.eventId) || (newField.objectTypeId != null && ![4, 6].includes(newField.objectTypeId))"
          v-model="newField.selectedField"
          label="Field"
          :items="availableFields"
          item-text="name"
          return-object
          attach
        />

        <v-autocomplete
          v-if="newField.objectTypeId !== null && newField.objectTypeId === 6 && newField.eventId"
          v-model="newField.processStepEventId"
          label="Process Step"
          :items="fetchedProcessStepEvents"
          item-value="id"
          item-text="processStepName"
          attach
        />
      </template>

      <v-btn
        text
        color="primary"
        class="text-left"
        :disabled="isNewFieldButtonDisabled"
        @click="addNewField"
      >
        <v-icon>save</v-icon>
        <span v-if="!constants.IS_MOBILE">Save</span>
      </v-btn>
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

<script>

import constants from '@/helpers/constants'
import draggable from 'vuedraggable'

import {
  deleteRequest,
  getRequest,
  getSnackbar,
  handleHidingGlobalLoader,
  logError,
  postRequest,
  putRequest,
} from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'SmartlistColumn',
  components: {
    ConfirmationDialog,
    draggable
  },
  props: {
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
  },
  watch: {
    refresh: {
      immediate: true,
      handler() {
        this.getAssignedFields()
        this.$emit('refreshed')
      }
    }
  },
  data() {
    return {
      constants,
      showNewFieldForm: false,
      newField: {},
      availableProcessSteps: [],
      availableFields: [],
      availableEvents: [],
      fetchedAvailableFields: [],
      fetchedProcessStepEvents: [],
      assignedFields: [],
      colToDelete: null
    }
  },
  created() {
    // this.getAssignedFields()
  },
  computed: {
    filteredProjectDetailsColumns () {
      return this.projectDetailsColumns.filter(f => {
        return !this.assignedFields.find(af => af.projectDetailsColumn === f.projectDetailsColumn && (f.processStepEventId === null || af.processStepEventId === f.processStepEventId))
      })
    },
    isNewFieldButtonDisabled () {
      return !this.newField?.selectedField && !this.newField?.projectDetailsColumn
    },
    colToDeleteFieldName(){
      return this.colToDelete ? this.colToDelete.field.name : ''
    }
  },
  methods: {
    resetNewFieldForm () {
      this.showNewFieldForm = false
      this.newField = {}
    },
    async getAssignedFields () {
      try {
        const {data} = await getRequest(`/smartlist/${this.smartlistId}/field`)
        this.assignedFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching assigned fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getAvailableFields () {
      this.newField = {objectTypeId: this.newField.objectTypeId}
      try {
        const {data} = await getRequest(`/smartlist/availableFieldsByType?objectTypeId=${this.newField.objectTypeId}`)
        this.fetchedAvailableFields = data
        if (this.newField.objectTypeId === 4) {
          this.availableProcessSteps = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
          this.availableProcessSteps = this.availableProcessSteps.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
        } else if (this.newField.objectTypeId === 6) {
          this.availableEvents = data.reduce((fields, field) => (field.eventId ===  null || fields.find(f => f.eventName === field.eventName)) ? [...fields] : [...fields, field], [])
          this.availableEvents = this.availableEvents.sort((a, b) => a.eventName.localeCompare(b.eventName))
        } else {
          this.calculateAvailableFields()
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching available fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getProcessStepEvents() {
      try {
        const {data} = await getRequest(`/event/${this.newField.eventId}/processStepEvents`)
        this.fetchedProcessStepEvents = data
        const psEventsForSelectedEvent = data.filter(pse => pse.eventId === this.newField.eventId)
        //if this event is attached to only one process step, autoselect the process step event id
        if (psEventsForSelectedEvent.length === 1) {
          this.newField.processStepEventId = psEventsForSelectedEvent[0].id
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching process step events')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async addNewField () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/smartlist/${this.smartlistId}/field`, {
          ...this.newField.selectedField,
          smartlistId: this.smartlistId,
          displayOrder: this.assignedFields.length + 1,
          processStepId: this.newField.processStepId || null,
          projectDetailsColumn: this.newField.projectDetailsColumn,
          processStepEventId: this.newField.processStepEventId || null
        })
        this.assignedFields.push(data)
        this.resetNewFieldForm()
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding field to smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField () {
      const fieldIndex = this.colToDelete.index;
      try {
        const fieldToDelete = this.assignedFields[fieldIndex]
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.smartlistId}/field/${fieldToDelete.id}`)
        this.assignedFields.splice(fieldIndex, 1)
        const {status} = await this.reorderFields({moved: {newIndex: 0, oldIndex: 1}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error removing field from smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async reorderFields ({moved}) {

      // If a drag happened but order wasn't changed
      if (moved.newIndex === moved.oldIndex) {
        return
      }
      this.assignedFields.forEach((field, index) => field.displayOrder = index + 1)

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await putRequest(`/smartlist/${this.smartlistId}/order`, this.assignedFields)
        handleHidingGlobalLoader(this, status)
        return {status}
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating field order')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
        return {status: 500}
      }
    },
    calculateAvailableFields () {
      this.availableFields = this.fetchedAvailableFields.filter(f => f.name !== null).sort((a, b) => a.name.localeCompare(b.name))
      if (this.newField.objectTypeId === 4) {
        this.availableFields = this.availableFields.filter(field => field.processStepId === this.newField.processStepId || field.smartlistFieldId !== null)
      } else if (this.newField.objectTypeId === 6) {
        this.availableFields = this.availableFields.filter(field => field.eventId === this.newField.eventId || field.smartlistFieldId !== null)
      }

      this.availableFields = this.availableFields.filter(f => {
        if (f.customFieldGroupAssignmentId !== null) {
          return !this.assignedFields.map(a => a.customFieldGroupAssignmentId).includes(f.customFieldGroupAssignmentId)
        } else {
          if (this.newField.objectTypeId === 4) {
            return !this.assignedFields.filter(a => a.processStepId === this.newField.processStepId).map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
          } else if (this.newField.objectTypeId === 6) {
            return !this.assignedFields.filter(a => a.eventId === this.newField.eventId).map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
          } else {
            return !this.assignedFields.map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
          }
        }
      })
    }
  }
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
