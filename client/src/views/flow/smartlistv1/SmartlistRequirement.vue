<template>
<v-col cols="12">
  <v-toolbar color="transparent" class="elevation-0">
    <v-toolbar-title>Requirements</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn
        v-if="!showNewRequirementForm && canEdit"
        @click="showNewRequirementForm = true"
        text
        color="primary"
      >
        <v-icon>add</v-icon>
        <template v-if="!constants.IS_MOBILE">Add Requirement</template>
      </v-btn>

      <v-btn
        v-if="showNewRequirementForm"
        text
        color="primary"
        @click="resetRequirementForm"
      >
        Cancel
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>

  <v-card v-if="showNewRequirementForm" class="elevation-1">
    <v-col class="text-left">

      <template v-if="isProjectDetails === true">
        <v-autocomplete
          v-model="newRequirement.selectedField"
          label="Field"
          :items="filteredProjectDetailsRequirements"
          item-value="project_details_column"
          item-text="name"
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
        <v-autocomplete
          v-model="newRequirement.objectTypeId"
          label="Object Type"
          :items="companyObjectTypes"
          item-value="objectTypeId"
          item-text="objectType"
          @input="[resetNewObjectType(), getAvailableFields()]"
          attach
        />

        <v-autocomplete
          v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 4"
          v-model="newRequirement.processStepId"
          label="Process Step"
          :items="availableProcessSteps"
          item-value="processStepId"
          item-text="processStepName"
          @input="[resetNewProcessStep(), calculateAvailableFields()]"
          attach
        />

        <v-autocomplete
          v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 6"
          v-model="newRequirement.eventId"
          label="Event"
          :items="availableEvents"
          item-value="eventId"
          item-text="eventName"
          @input="[
            resetNewProcessStep(),
            calculateAvailableFields(),
            getProcessStepEvents()
          ]"
          attach
        />

        <v-autocomplete
          v-if="(newRequirement.objectTypeId === 4 && newRequirement.processStepId) || (newRequirement.objectTypeId === 6 && newRequirement.eventId) || (newRequirement.objectTypeId != null && ![4, 6].includes(newRequirement.objectTypeId))"
          v-model="newRequirement.selectedField"
          label="Field"
          :items="availableFields"
          item-text="name"
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

        <v-autocomplete
          v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 6 && newRequirement.eventId"
          v-model="newRequirement.processStepEventId"
          label="Process Step"
          :items="fetchedProcessStepEvents"
          item-value="id"
          item-text="processStepName"
          attach
        />
      </template>

      <v-autocomplete
        v-if="newRequirement.selectedField"
        v-model="newRequirement.operatorTypeId"
        label="Operator"
        :items="operators"
        attach
        item-text="operatorType"
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
      <v-autocomplete
        v-if="newRequirement.operatorTypeId !== null && newRequirement.isCustomValue && isListField && !newRequirement.selectedField.allowMultiple"
        v-model="newRequirement.listOfValueId"
        :items="newRequirement.selectedField.listOfValues"
        label="Available Values (list of value id)"
        item-text="name"
        item-value="id"
      />

<!--      if field is a multi-select list -->
      <v-autocomplete
        v-else-if="newRequirement.operatorTypeId && newRequirement.isCustomValue && newRequirement.selectedField.listOfValueId !== null && newRequirement.selectedField.allowMultiple"
        v-model="newRequirement.listOfValueIds"
        :items="newRequirement.selectedField.listOfValues"
        label="Available Values"
        multiple
        item-text="name"
        item-value="id"
      />

<!--      if field doesn't have any custom values, display the data type requirements -->
      <v-autocomplete
        v-else-if="newRequirement.operatorTypeId !== null && !newRequirement.isCustomValue"
        v-model="newRequirement.dataTypeRequirementId"
        label="Available Values"
        :items="dataTypeRequirements"
        item-text="dataTypeValue"
        item-value="id"
        @input="resetNewDataTypeRequirement"
      />

<!--      if nothing else sticks, then it's a regular text input -->
<!--      @TODO humes: check for date/time here and give a date picker -->
      <v-text-field
          v-else-if="newRequirement.operatorTypeId && newRequirement.isCustomValue"
          v-model="newRequirement.requirementValue"
          placeholder="Enter a value"
          label="Value">
      </v-text-field>

      <v-text-field
        v-if="newRequirement.dataTypeRequirementId && dataTypeRequirements.find(r => r.id === newRequirement.dataTypeRequirementId).secondaryRequirement"
        v-model="newRequirement.secondaryRequirementValue"
        label="Value"
        type="number"
        placeholder="Enter a value"
      />

      <v-btn
        text
        color="primary"
        class="text-left"
        :disabled="isSaveNewRequirementDisabled"
        @click="addNewRequirement"
      >
        <v-icon>save</v-icon>
        <template v-if="!constants.IS_MOBILE">Save</template>
      </v-btn>
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

          <v-btn
            v-else
            small
            text
            color="primary"
            @click="cancelEditRequirement"
          >
            Cancel
          </v-btn>

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
            <v-autocomplete
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Field"
              item-text="name"
              disabled
              attach
            />
          </template>

          <template v-else>
            <v-autocomplete
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Object Type"
              item-text="objectType"
              disabled
              attach
            />

            <v-autocomplete
              v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 4"
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Process Step"
              item-text="processStepName"
              disabled
              attach
            />

            <v-autocomplete
              v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 6"
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Event"
              item-text="eventName"
              disabled
              attach
            />

            <v-autocomplete
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Field"
              item-text="name"
              disabled
              attach
            />

            <v-autocomplete
              v-if="expandedRequirement.objectTypeId !== null && expandedRequirement.objectTypeId === 6"
              v-model="expandedRequirement"
              :items="[expandedRequirement]"
              label="Process Step"
              item-text="processStepName"
              disabled
              attach
            />
          </template>

          <v-autocomplete
            v-model="expandedRequirement.operatorTypeId"
            label="Operator"
            :items="operators"
            item-text="operatorType"
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
          <v-autocomplete
              v-if="expandedRequirement.operatorTypeId !== null && expandedRequirement.isCustomValue && isExpandedListField && !expandedRequirement.allowMultiple"
              v-model="expandedRequirement.listOfValueId"
              :items="expandedRequirement.availableListOfValues"
              label="Available Values"
              item-text="name"
              item-value="id"
          />

          <!--      if field is a multi-select list -->
          <v-autocomplete
              v-else-if="expandedRequirement.operatorTypeId && expandedRequirement.isCustomValue && isExpandedListField && expandedRequirement.allowMultiple"
              v-model="expandedRequirement.listOfValueIds"
              :items="expandedRequirement.availableListOfValues"
              label="Available Values"
              multiple
              item-text="name"
              item-value="id"
          />

          <!--      if field doesn't have any custom values, display the data type requirements -->
          <v-autocomplete
              v-else-if="expandedRequirement.operatorTypeId !== null && !expandedRequirement.isCustomValue"
              v-model="expandedRequirement.dataTypeRequirementId"
              label="Available Values"
              :items="dataTypeRequirements"
              item-text="dataTypeValue"
              item-value="id"
              @input="resetNewDataTypeRequirement"
          />

          <!--      if nothing else sticks, then it's a regular text input -->
          <!--      @TODO humes: check for date/time here and give a date picker -->
          <v-text-field
              v-else-if="expandedRequirement.operatorTypeId && expandedRequirement.isCustomValue"
              v-model="expandedRequirement.requirementValue"
              placeholder="Enter a value"
              label="Value">
          </v-text-field>

          <v-text-field
              v-if="shouldShowEditFormValueInput"
              v-model="expandedRequirement.secondaryRequirementValue"
              label="Value"
              type="number"
              placeholder="Enter a value"
          />

          <v-btn
            text
            color="primary"
            :disabled="isSaveExpandedRequirementDisabled"
            @click="updateRequirement(expandedRequirement)"
          >
            <v-icon>save</v-icon>
            <template v-if="!constants.IS_MOBILE">Save</template>
          </v-btn>
        </td>
      </tr>
    </template>
  </v-data-table>
  <ConfirmationDialog :open-dialog="!!reqToDelete" @confirm="deleteRequirement" @close-dialog="reqToDelete=null">
    Are you sure you want to delete this requirement: <b>{{reqToDeleteFieldName}}</b>?
  </ConfirmationDialog>
</v-col>
</template>

<script>

import {getRequest, logError, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {AppMutations} from '@/stores/AppStore'
import ConfirmationDialog from "@/ConfirmationDialog";


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

export default {
  name: "SmartlistRequirement",
  components: {ConfirmationDialog},
  props: {
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
  },
  data () {
    return {
      constants,
      snackbar: {},
      showNewRequirementForm: false,
      newRequirement: Object.assign({}, newRequirementStructure),
      fetchedAvailableFields: [],
      availableFields: [],
      availableProcessSteps: [],
      availableEvents: [],
      fetchedProcessStepEvents: [],
      operators: [],
      dataTypeRequirements: [],
      headers: [
        {text: 'ID', value: 'displayOrder'},
        {text: 'Field Name', value: 'name'},
        {text: 'Object Type', value: 'objectType'},
        {text: 'Process Step/Event Name', value: 'processStepName'},
        {text: 'Operator', value: 'operatorType'},
        {text: 'Value', value: 'requirementValue'},
        {text: null, value: 'actions'}
      ],
      expandedRequirement: {
        selectedField: null,
        objectTypeId: null,
        processStepId: null,
        operatorTypeId: null,
        dataTypeRequirementId: null,
        secondaryRequirement: null,
        secondaryRequirementValue: null,
        isCustomValue: null,
        allowMultiple: null,
        customFieldSql: null,
        companySystemListId: null,
        availableListOfValues: []
      },
      projectStatusTypes: [],
      companyProjectStatusTypes: [],
      reqToDelete: null
    }
  },
  created () {
    this.getProjectStatusTypes()
    // this.getProcessStepStatusTypes()
  },
  updated () {
    if (this.resetForm) {
      this.resetRequirementForm()
    }
  },
  computed: {
    filteredProjectDetailsRequirements () {
      return this.projectDetailsRequirements.filter(f => {
        return !this.requirements.find(af => af.projectDetailsColumn === f.projectDetailsColumn && (f.processStepEventId === null || af.processStepEventId === f.processStepEventId))
      })
    },
    shouldShowEditFormValueInput () {
      return this.expandedRequirement.dataTypeRequirement?.secondaryRequirement
    },
    isListField () {
      return this.newRequirement.selectedField.hasListValues || this.newRequirement.selectedField.customFieldSql !== null || this.newRequirement.selectedField.companySystemListId !== null
    },
    isExpandedListField () {
      return this.expandedRequirement.hasListValues || this.expandedRequirement.customFieldSql !== null || this.expandedRequirement.companySystemListId !== null || (this.expandedRequirement.availableListOfValues != null && this.expandedRequirement.availableListOfValues.length > 0)
    },
    expandedRequirementArray: {
      get: function () {
        return [this.expandedRequirement]
      },
      // Throw away the value vuetify gives back because we don't want to update the expanded row's main row when editing (only upon saving)
      set: () => {}
    },
    isSaveNewRequirementDisabled () {
      if (this.newRequirement.isCustomValue) {
        const isEmptyList = (this.newRequirement.hasListValues === true && this.newRequirement.allowMultiple === false && this.newRequirement.listOfValueId === null) || (this.newRequirement.allowMultiple === true && this.newRequirement.listOfValueIds.length === 0)
        return (this.newRequirement.requirementValue === null || this.newRequirement.requirementValue?.length === 0) && isEmptyList
      } else {
        return this.newRequirement.dataTypeRequirementId === null && this.newRequirement.listOfValueId === null && this.newRequirement.listOfValueIds.length === 0
      }
    },
    isSaveExpandedRequirementDisabled () {
      if (this.expandedRequirement.isCustomValue) {
        const isEmptyList = (this.expandedRequirement.hasListValues === true && this.expandedRequirement.allowMultiple === false && this.expandedRequirement.listOfValueId === null) || (this.expandedRequirement.allowMultiple === true && this.expandedRequirement.listOfValueIds.length === 0)
        return (this.expandedRequirement.requirementValue === null || this.expandedRequirement.requirementValue?.length === 0) && isEmptyList
      } else {
        return this.expandedRequirement.dataTypeRequirementId === null && this.expandedRequirement.listOfValueId === null && this.expandedRequirement.listOfValueIds.length === 0
      }
    },
    reqToDeleteFieldName(){
      return this.reqToDelete ? this.reqToDelete.name : '';
    }
  },
  methods: {
    async getAvailableFields () {
      try {
        const {data} = await getRequest(`/smartlistv1/availableFieldsByType?objectTypeId=${this.newRequirement.objectTypeId}`)
        this.fetchedAvailableFields = data
        if (this.newRequirement.objectTypeId === 4) {
          this.availableProcessSteps = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
          this.availableProcessSteps = this.availableProcessSteps.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
        } else if (this.newRequirement.objectTypeId === 6) {
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
    async getOperators (dataTypeId) {
      try {
        const {data} = await getRequest(`/operator/${dataTypeId}`)
        this.operators = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operators for selected field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getDataTypeRequirements (dataTypeId) {
      try {
        const {data} = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)
        this.dataTypeRequirements = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching data type requirements for selected field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getProcessStepFieldData () {
      if (this.newRequirement.selectedField.customFieldGroupAssignmentId !== null) {
        try {
          const {data} = await getRequest(`/smartlistv1/availableFieldByCfgaId/${this.newRequirement.selectedField.customFieldGroupAssignmentId}`)
          this.newRequirement.selectedField = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async getSystemFieldListOfValues() {
      const selectedFieldName = this.newRequirement.selectedField.name

      // @TODO It's bad these check for the field name since it might change. Make better
      if ([1,2,4].includes(this.newRequirement.objectTypeId)) {

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
          } else if (selectedFieldName === 'Process Step Owner' && this.newRequirement.processStepId !== null) {
            const {data} = await getRequest(`/processStep/${this.newRequirement.processStepId}/owners`)
            results = data
          }

          this.newRequirement.selectedField.listOfValues = results.map(o => ({id: o.userPositionId, name: o.fullName}))
          this.newRequirement.selectedField.hasListValues = true
          this.newRequirement.isCustomValue = true
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching available values')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      } else if (this.newRequirement.eventId !== null) {

        //if this isn't one of the specific system fields we need, bail
        if (!['Event Resource','Event Status','Event Category'].includes(selectedFieldName)) {
          return
        }

        try {
          let results
          if (selectedFieldName === 'Event Resource') {
            const {data} = await getRequest(`/event/${this.newRequirement.eventId}/owners`)
            results = data
          } else if (selectedFieldName === 'Event Status') {
            const {data} = await getRequest(`/event/${this.newRequirement.eventId}/lovStatus`)
            results = data
          } else if (selectedFieldName === 'Event Category') {
            const {data} = await getRequest(`/event/${this.newRequirement.eventId}/lovCategory`)
            results = data
          }

          this.newRequirement.selectedField.listOfValues = results
          this.newRequirement.selectedField.hasListValues = true
          this.newRequirement.isCustomValue = true
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching available values')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async getProjectStatusTypes () {
      try {
        const [result, companyResult] = await Promise.all([getRequest(`/project/status`), getRequest(`/project/companyStatus`)])
        this.projectStatusTypes = result.data
        this.companyProjectStatusTypes = companyResult.data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    // async getProcessStepStatusTypes () {
    //   try {
    //     const [result, companyResult] = await Promise.all([getRequest(`/processStep/status`), getRequest(`/processStep/status/company`)])
    //     this.processStepStatusTypes = result.data
    //     this.companyProcessStepStatusTypes = companyResult.data
    //   } catch (e) {
    //     logError(e)
    //     this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
    //     this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    //   }
    // },
    async getEventStatuses() {
      if (this.newRequirement.eventId) {
        try {
          const {data} = await getRequest(`/event/${this.newRequirement.eventId}/lovStatus`)

          //find the event status field and insert statues
          const fieldIndex = this.fetchedAvailableFields.findIndex(f => f.name === 'Event Status')
          this.fetchedAvailableFields[fieldIndex].hasListValues = true
          this.fetchedAvailableFields[fieldIndex].listOfValues = data

          this.calculateAvailableFields()
        } catch(e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching event statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async getEventCategories() {
      if (this.newRequirement.eventId) {
        try {
          const {data} = await getRequest(`/event/${this.newRequirement.eventId}/lovCategory`)

          //find the event category field and insert categories

          // calculateAvailableFields()
        } catch(e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching event categories')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    },
    async getProcessStepEvents() {
      try {
        const {data} = await getRequest(`/event/${this.newRequirement.eventId}/processStepEvents`)
        this.fetchedProcessStepEvents = data
        const psEventsForSelectedEvent = data.filter(pse => pse.eventId === this.newRequirement.eventId)
        //if this event is attached to only one process step, autoselect the process step event id
        if (psEventsForSelectedEvent.length === 1) {
          this.newRequirement.processStepEventId = psEventsForSelectedEvent[0].id
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operations')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    addNewRequirement () {
      // Add the processStepId because system process step fields don't have a processStepId
      this.$emit('input', {
        ...this.newRequirement,
        ...this.newRequirement.selectedField,
        processStepId: this.newRequirement.processStepId,
        processStepEventId: (this.isProjectDetails) ? this.newRequirement.selectedField.processStepEventId : this.newRequirement.processStepEventId
      })
    },
    updateRequirement (requirement) {
      this.$emit('update', requirement)
      this.expandedRequirement = {}
    },
    editRequirement (requirement) {
      this.getOperators(requirement.dataTypeId)
      this.getDataTypeRequirements(requirement.dataTypeId)
      this.expandedRequirement = {...requirement}
    },
    cancelEditRequirement () {
      this.expandedRequirement = {}
    },
    deleteRequirement () {
      this.$emit('delete', this.reqToDelete)
    },
    calculateAvailableFields () {
      this.availableFields = this.fetchedAvailableFields.filter(f => f.name !== null).sort((a, b) => a.name.localeCompare(b.name))
      if (this.newRequirement.processStepId) {
        this.availableFields = this.availableFields.filter(field => field.processStepId === this.newRequirement.processStepId || field.smartlistFieldId !== null)
      } else if (this.newRequirement.eventId) {
        this.availableFields = this.availableFields.filter(field => field.eventId === this.newRequirement.eventId || field.smartlistFieldId !== null)
      }
    },
    resetRequirementForm () {
      this.showNewRequirementForm = false
      this.newRequirement = Object.assign({}, newRequirementStructure)
      this.$emit('form-reset', true)
    },
    resetNewObjectType () {
      this.newRequirement = {
        ...this.newRequirement,
        processStepId: null,
        selectedField: null,
        operatorTypeId: null,
        dataTypeRequirementId: null,
        secondaryRequirementValue: null
      }
    },
    resetNewProcessStep () {
      this.newRequirement = {
        ...this.newRequirement,
        selectedField: null,
        operatorTypeId: null,
        dataTypeRequirementId: null,
        secondaryRequirementValue: null
      }
    },
    resetNewField () {
      this.newRequirement = {
        ...this.newRequirement,
        operatorTypeId: null,
        dataTypeRequirementId: null,
        secondaryRequirementValue: null,
        isCustomValue: null
      }
    },
    resetNewOperatorType () {
      this.newRequirement = {
        ...this.newRequirement,
        dataTypeRequirementId: null,
        secondaryRequirementValue: null
      }
    },
    resetNewDataTypeRequirement () {
      this.newRequirement = {
        ...this.newRequirement,
        secondaryRequirementValue: null
      }
    },
    resetInputValues (requirement) {
      requirement.listOfValueId = null
      requirement.listOfValueIds = []
      requirement.dataTypeRequirementId = null
      requirement.requirementValue = null
      requirement.secondaryRequirementValue = null
    },
    getListValueName (listItem) {
      let idToUse = listItem.customSqlOptionId ? listItem.customSqlOptionId : listItem.systemListOptionId ? listItem.systemListOptionId : listItem.listOfValueId
      let match = listItem.availableListOfValues.find(i => i.id === idToUse)
      return match ? match.name : 'unknown'
    },
    checkSmartlistSystemList () {
      if (this.newRequirement?.selectedField?.smartlistSystemListId) {
        this.newRequirement.isCustomValue = true
      }
    },
    computeMutliSelectValue(req) {
      if (req.smartlistSystemListId === null) {
        return req.listOfValues.map(v => ` ${v.name}`).toString()
      } else {
        //The backend returns incorrect listOfValues for smartlist field multiselects
        return req.availableListOfValues.filter(v => req.listOfValueIds.includes(v.id)).map(v => ` ${v.name}`).toString()
      }
    }
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
