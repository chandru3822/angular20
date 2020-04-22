<template>
<v-col cols="12">
  <v-toolbar color="transparent" class="elevation-0">
    <v-toolbar-title>Requirements</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn
        v-if="!showNewRequirementForm"
        @click="showNewRequirementForm = true"
        text
      >
        <v-icon>add</v-icon>
        <template v-if="!IS_MOBILE">Add Requirement</template>
      </v-btn>

      <v-btn
        v-if="showNewRequirementForm"
        text
        @click="resetRequirementForm"
      >
        Cancel
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>

  <v-card v-if="showNewRequirementForm" class="elevation-1">
    <v-col class="text-left">
      <v-select
          v-model="newRequirement.objectTypeId"
          label="Object Type"
          :items="companyObjectTypes"
          item-value="objectTypeId"
          item-text="objectType"
          @input="[resetNewObjectType(), getAvailableFields()]"
      />

      <v-select
          v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 4"
          v-model="newRequirement.processStepId"
          label="Process Step"
          :items="availableProcessSteps"
          item-value="processStepId"
          item-text="processStepName"
          @input="[resetNewProcessStep(), calculateAvailableFields()]"
      />

      <v-select
          v-if="(newRequirement.objectTypeId === 4 && newRequirement.processStepId) || (newRequirement.objectTypeId !== 4 && newRequirement.objectTypeId != null)"
          v-model="newRequirement.selectedField"
          label="Field"
          :items="availableFields"
          item-text="name"
          return-object
          @input="[resetNewField(), getOperators(newRequirement.selectedField.dataTypeId), getDataTypeRequirements(newRequirement.selectedField.dataTypeId)]"
      />

      <v-select
        v-if="newRequirement.selectedField"
        v-model="newRequirement.operatorTypeId"
        label="Operator"
        :items="operators"
        item-text="operatorType"
        item-value="id"
        @input="resetNewOperatorType"
      />

      <v-select
        v-if="newRequirement.operatorTypeId !== null"
        v-model="newRequirement.dataTypeRequirementId"
        label="Available Values"
        :items="dataTypeRequirements"
        item-text="dataTypeValue"
        item-value="id"
        @input="resetNewDataTypeRequirement"
      />

      <v-text-field
        v-if="newRequirement.dataTypeRequirementId && dataTypeRequirements.find(r => r.id === newRequirement.dataTypeRequirementId).secondaryRequirement"
        v-model="newRequirement.secondaryRequirementValue"
        label="Value"
        placeholder="Enter a value"
      />

      <v-btn
        text
        class="text-left"
        :disabled="shouldDisableAddRequirementButton"
        @click="addNewRequirement"
      >
        <v-icon>save</v-icon>
        <template v-if="!IS_MOBILE">Save</template>
      </v-btn>
    </v-col>
  </v-card>
  <v-data-table
    :headers="headers"
    :items="requirements"
    hide-default-footer
    :expanded.sync="expandedRequirement"
    single-expand
  >
    <template #no-data>
      No requirements for this process step
    </template>

    <template #no-results>
      No requirements for this process step
    </template>

    <template #item="{item: requirement, index}">
      <tr>
        <td class="text-left" style="width: 65px">{{requirement.displayOrder}}</td>
        <td class="text-left">{{requirement.name}}</td>
        <td class="text-left">{{(requirement.smartlistFieldId) ? requirement.objectType : 'Custom'}}</td>
        <td class="text-left">{{requirement.processStepName}}</td>
        <td class="text-left">{{requirement.operatorType}}</td>
        <td class="text-left">
          <template v-if="requirement.requirementValue">{{requirement.requirementValue}}</template>
          <template v-else-if="requirement.dataTypeRequirementId">
            {{requirement.dataTypeRequirement ? requirement.dataTypeRequirement.dataTypeValue : 'unknown'}} {{requirement.secondaryRequirementValue}}
          </template>
<!--              <span v-else-if="item.listOfValueId || item.customFieldSqlKeyId || item.companySystemListId">-->
<!--&lt;!&ndash;                      {{item.listOfValue ? item.listOfValue.name : 'unknown'}}&ndash;&gt;-->
<!--                    {{ getListValueName(item) }}-->
<!--                  </span>-->
<!--              <span v-else-if="item.listOfValues">-->
<!--                    &lt;!&ndash; todo: show the selected values here &ndash;&gt;-->
<!--                    {{ item.listOfValues.map(v => ' ' + v.name).toString() }}-->
<!--                  </span>-->
        </td>
        <td class="action-cell">
          <v-icon
            v-if="!expandedRequirement.includes(requirement)"
            class="action-icon"
            @click="editRequirement(requirement)"
          >
            edit
          </v-icon>

          <v-btn
            v-if="expandedRequirement.includes(requirement)"
            small
            text
            @click="cancelEditRequirement"
          >
            Cancel
          </v-btn>

          <v-icon
            class="action-icon"
            @click="deleteRequirement(requirement)"
          >
            delete
          </v-icon>
        </td>
      </tr>
    </template>

    <template #expanded-item="{headers}">
      <tr>
        <td :colspan="headers.length" class="text-left expanded-row">
          <v-select
            v-model="expandedRequirement[0]"
            :items="[expandedRequirement[0]]"
            label="Object Type"
            item-text="objectType"
            disabled
          />

          <v-select
            v-if="expandedRequirement[0].objectTypeId !== null && expandedRequirement[0].objectTypeId === 4"
            v-model="expandedRequirement[0]"
            :items="[expandedRequirement[0]]"
            label="Process Step"
            item-text="processStepName"
            disabled
          />

          <v-select
            v-model="expandedRequirement[0]"
            :items="[expandedRequirement[0]]"
            label="Field"
            item-text="name"
            disabled
          />

          <v-select
            v-model="expandedRequirement[0].operatorTypeId"
            label="Operator"
            :items="operators"
            item-text="operatorType"
            item-value="id"
          />

          <v-select
            v-model="expandedRequirement[0].dataTypeRequirementId"
            label="Available Values"
            :items="dataTypeRequirements"
            item-text="dataTypeValue"
            item-value="id"
          />

          <v-text-field
            v-if="expandedRequirement[0].dataTypeRequirement.secondaryRequirement"
            v-model="expandedRequirement[0].secondaryRequirementValue"
            label="Value"
            placeholder="Enter a value"
          />

          <v-btn
            text
            @click="updateRequirement(expandedRequirement[0])"
          >
            <v-icon>save</v-icon>
            <template v-if="!IS_MOBILE">Save</template>
          </v-btn>
        </td>
      </tr>
    </template>
  </v-data-table>
  <Snackbar :snackbar="snackbar" />
</v-col>
</template>

<script>

import {IS_MOBILE, getRequest, logError, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar'

export default {
  name: "SmartlistRequirement",
  components: {
    Snackbar
  },
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
    }
  },
  data () {
    return {
      IS_MOBILE,
      snackbar: {},
      showNewRequirementForm: false,
      newRequirement: {
        selectedField: null,
        objectTypeId: null,
        processStepId: null,
        operatorTypeId: null,
        dataTypeRequirementId: null,
        secondaryRequirementValue: null
      },
      fetchedAvailableFields: [],
      availableFields: [],
      availableProcessSteps: [],
      operators: [],
      dataTypeRequirements: [],
      headers: [
        {text: 'ID', value: 'displayOrder'},
        {text: 'Field Name', value: 'name'},
        {text: 'Object Type', value: 'objectType'},
        {text: 'Process Step Name', value: 'processStepName'},
        {text: 'Operator', value: 'operatorType'},
        {text: 'Value', value: 'requirementValue'},
        {text: null, value: 'actions'}
      ],
      expandedRequirement: [],
      originalExpandedRequirement: null
    }
  },
  updated () {
    if (this.resetForm) {
      this.resetRequirementForm()
    }
  },
  computed: {
    shouldDisableAddRequirementButton () {
      return !this.newRequirement.dataTypeRequirementId && (!this.dataTypeRequirements.find(r => r.id === this.newRequirement.dataTypeRequirementId)?.secondaryRequirement || !this.newRequirement?.secondaryRequirementValue)
    }
  },
  methods: {
    async getAvailableFields () {
      try {
        const {data} = await getRequest(`/smartlist/availableFieldsByType?objectTypeId=${this.newRequirement.objectTypeId}`)
        this.fetchedAvailableFields = data
        if (this.newRequirement.objectTypeId === 4) {
          this.availableProcessSteps = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
          this.availableProcessSteps = this.availableProcessSteps.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
        } else {
          this.calculateAvailableFields()
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching available fields')
      }
    },
    async getOperators (dataTypeId) {
      try {
        const {data} = await getRequest(`/operator/${dataTypeId}`)
        this.operators = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operators for selected field')
      }
    },
    async getDataTypeRequirements (dataTypeId) {
      try {
        const {data} = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)
        this.dataTypeRequirements = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching data type requirements for selected field')
      }
    },
    addNewRequirement () {
      this.$emit('input', this.newRequirement)
    },
    updateRequirement (requirement) {
      this.$emit('update', requirement)
      this.expandedRequirement = []
    },
    editRequirement (requirement) {
      debugger
      this.getOperators(requirement.dataTypeId)
      this.getDataTypeRequirements(requirement.dataTypeId)
      this.originalExpandedRequirement = {...requirement}
      this.expandedRequirement = [requirement]
    },
    cancelEditRequirement () {
      this.requirements[this.requirements.findIndex(r => r.id === this.originalExpandedRequirement.id)] = {...this.originalExpandedRequirement}
      this.expandedRequirement = []
      this.originalExpandedRequirement = null
    },
    deleteRequirement (requirement) {
      this.$emit('delete', requirement)
    },
    calculateAvailableFields () {
      this.availableFields = this.fetchedAvailableFields.sort((a, b) => a.name.localeCompare(b.name))
      if (this.newRequirement.processStepId) {
        this.availableFields = this.availableFields.filter(field => field.processStepId === this.newRequirement.processStepId || field.smartlistFieldId !== null)
      }
    },
    resetRequirementForm () {
      this.showNewRequirementForm = false
      this.newRequirement = {}
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
        secondaryRequirementValue: null
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