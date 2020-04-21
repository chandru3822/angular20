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
          @input="getAvailableFields"
      />

      <v-select
          v-if="newRequirement.objectTypeId !== null && newRequirement.objectTypeId === 4"
          v-model="newRequirement.processStepId"
          label="Process Step"
          :items="availableProcessSteps"
          item-value="processStepId"
          item-text="processStepName"
          @input="calculateAvailableFields"
      />

      <v-select
          v-if="(newRequirement.objectTypeId === 4 && newRequirement.processStepId) || (newRequirement.objectTypeId !== 4 && newRequirement.objectTypeId != null)"
          v-model="newRequirement.selectedField"
          label="Field"
          :items="availableFields"
          item-text="name"
          return-object
          @input="[getOperators(newRequirement.selectedField.dataTypeId), getDataTypeRequirements(newRequirement.selectedField.dataTypeId)]"
      />

      <v-select
        v-if="newRequirement.selectedField"
        v-model="newRequirement.operatorTypeId"
        label="Operator"
        :items="operators"
        item-text="operatorType"
        item-value="id"
      />

      <v-select
        v-if="newRequirement.operatorTypeId"
        v-model="newRequirement.dataTypeRequirementId"
        label="Available Values"
        :items="dataTypeRequirements"
        item-text="dataTypeValue"
        item-value="id"
      />

      <v-btn
        text
        class="text-left"
        :disabled="!newRequirement.dataTypeRequirementId"
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
            @click="expandedRequirement = []"
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

    <template #expanded-item="{item: requirement, headers}">
      <tr>
        <td :colspan="headers.length" class="text-left expanded-row">
          <v-select
            v-model="requirement"
            :items="[requirement]"
            label="Object Type"
            item-text="objectType"
            disabled
          />

          <v-select
            v-if="requirement.objectTypeId !== null && requirement.objectTypeId === 4"
            v-model="requirement"
            :items="[requirement]"
            label="Process Step"
            item-text="processStepName"
            disabled
          />

          <v-select
            v-model="requirement"
            :items="[requirement]"
            label="Field"
            item-text="name"
            disabled
          />

          <v-select
            v-model="requirement.operatorTypeId"
            label="Operator"
            :items="operators"
            item-text="operatorType"
            item-value="id"
          />

          <v-select
            v-model="requirement.dataTypeRequirementId"
            label="Available Values"
            :items="dataTypeRequirements"
            item-text="dataTypeValue"
            item-value="id"
          />

          <v-btn
            text
            @click="updateRequirement(requirement)"
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
      newRequirement: {},
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
      expandedRequirement: []
    }
  },
  updated () {
    if (this.resetForm) {
      this.resetRequirementForm()
    }
  },
  methods: {
    async getAvailableFields () {
      this.newRequirement = {objectTypeId: this.newRequirement.objectTypeId}
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
      this.getOperators(requirement.dataTypeId)
      this.getDataTypeRequirements(requirement.dataTypeId)
      this.expandedRequirement = [requirement]
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