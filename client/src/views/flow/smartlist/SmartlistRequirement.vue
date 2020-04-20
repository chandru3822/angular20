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
    <v-col>
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
          @input="[getOperators(), getDataTypeRequirements()]"
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
  >
    <template #no-data>
      No requirements for this process step
    </template>

    <template #no-results>
      No requirements for this process step
    </template>

<!--        <template #expanded-item="{ headers, item }">-->
<!--          <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedRequirementIndex % 2}">-->
<!--            <div v-if="item.requirementParamDynamicValues && item.requirementParamDynamicValues.length > 0">-->
<!--              <h5 class="text-left">Dynamic Function Parameters</h5>-->
<!--              <v-card flat color="transparent">-->
<!--                <div v-for="(fp, index) in item.requirementParamDynamicValues" :key="index">-->
<!--                  <v-text-field-->
<!--                      v-if="fp.dataTypeId === 1"-->
<!--                      placeholder="Enter a date"-->
<!--                      type="date"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                  <v-text-field-->
<!--                      v-if="fp.dataTypeId === 2"-->
<!--                      placeholder="Enter a timestamp"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                  <v-text-field-->
<!--                      v-if="fp.dataTypeId === 3"-->
<!--                      placeholder="Enter a boolean"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                  <v-text-field-->
<!--                      v-if="fp.dataTypeId === 4"-->
<!--                      placeholder="Enter a number"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                  <v-text-field-->
<!--                      v-if="fp.dataTypeId === 6"-->
<!--                      placeholder="Enter an integer"-->
<!--                      type="number"-->
<!--                      step="1"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                  <v-text-field-->
<!--                      v-else-->
<!--                      placeholder="Enter a dynamic value"-->
<!--                      v-model="fp.dynamicValue"-->
<!--                      :label="fp.parameterName"></v-text-field>-->
<!--                </div>-->
<!--              </v-card>-->
<!--            </div>-->
<!--            <v-select v-model="item.operatorTypeId"-->
<!--                      :items="operatorTypes"-->
<!--                      class="one-hunned"-->
<!--                      label="Operator"-->
<!--                      :disabled="item.immutable"-->
<!--                      item-text="operatorType"-->
<!--                      item-value="id"-->
<!--            ></v-select>-->
<!--            <v-switch v-model="item.customValue" class="mx-2"-->
<!--                      :disabled="item.immutable"-->
<!--                      label="Custom"></v-switch>-->
<!--            &lt;!&ndash; single text field for non list custom values &ndash;&gt;-->
<!--            <v-text-field v-if="item.customValue && !item.listOfValues && !item.listOfValueId && !item.customFieldSqlKeyId && !item.systemListId "-->
<!--                          v-model="item.requirementValue"-->
<!--                          :disabled="item.immutable"-->
<!--                          placeholder="Enter a value"-->
<!--                          label="Value">-->
<!--            </v-text-field>-->
<!--            &lt;!&ndash; single select for dropdown, custom sql list, or system list &ndash;&gt;-->
<!--            <v-select-->
<!--                v-else-if="item.customValue && item.listOfValueId"-->
<!--                v-model="item.listOfValueId"-->
<!--                :disabled="item.immutable"-->
<!--                :items="item.availableListOfValues"-->
<!--                label="Available Values"-->
<!--                item-text="name"-->
<!--                item-value="id"-->
<!--            ></v-select>-->
<!--            <v-select-->
<!--                v-else-if="item.customValue && item.systemListId"-->
<!--                v-model="item.systemListOptionId"-->
<!--                :disabled="item.immutable"-->
<!--                :items="item.availableListOfValues"-->
<!--                label="Available Values"-->
<!--                item-text="name"-->
<!--                item-value="id"-->
<!--            ></v-select>-->
<!--            &lt;!&ndash; not sure what to do with this custom sql one yet &ndash;&gt;-->
<!--            <v-select-->
<!--                v-else-if="item.customValue && item.customFieldSqlKeyId"-->
<!--                v-model="item.listOfValueId"-->
<!--                :disabled="item.immutable"-->
<!--                :items="item.availableListOfValues"-->
<!--                label="Available Values"-->
<!--                item-text="name"-->
<!--                item-value="id"-->
<!--            ></v-select>-->
<!--            &lt;!&ndash; at this point it should only show for multiselects &ndash;&gt;-->
<!--            <v-select-->
<!--                v-else-if="item.customValue && item.listOfValues"-->
<!--                v-model="item.listOfValues"-->
<!--                :disabled="item.immutable"-->
<!--                :items="item.availableListOfValues"-->
<!--                label="Available Values"-->
<!--                item-text="name"-->
<!--                multiple-->
<!--                return-object-->
<!--            ></v-select>-->
<!--            <v-select-->
<!--                v-else-->
<!--                v-model="item.dataTypeRequirement"-->
<!--                :items="dataTypeRequirements"-->
<!--                :disabled="item.immutable"-->
<!--                label="Available Values"-->
<!--                item-text="dataTypeValue"-->
<!--                return-object-->
<!--            ></v-select>-->
<!--            <v-text-field v-if="item.dataTypeRequirement.secondaryRequirement"-->
<!--                          v-model="item.secondaryRequirementValue"-->
<!--                          placeholder="Enter a value"-->
<!--                          :disabled="item.immutable"-->
<!--                          label="Value">-->
<!--            </v-text-field>-->
<!--            <v-btn @click="updateRequirement(item)">-->
<!--              <v-icon>save</v-icon>-->
<!--              Save-->
<!--            </v-btn>-->
<!--          </td>-->
<!--        </template>-->

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
            <td class="text-right">
              <v-icon @click="deleteRequirement(requirement)">delete</v-icon>
            </td>
<!--            <td>-->
<!--              <div style="display: flex;">-->
<!--                <v-btn small text @click="[expanded = [item], loadOperatorTypes(item.dataTypeId),-->
<!--                                  loadDataTypeRequirements(item.dataTypeId), selectedRequirementIndex = index]"-->
<!--                       v-if="!expanded.includes(item)">-->
<!--                  <v-icon v-if="item.immutable">expand_more</v-icon>-->
<!--                  <v-icon v-else>edit</v-icon>-->
<!--                </v-btn>-->
<!--                <v-btn small text @click="[expanded = [], selectedRequirementIndex = index]"-->
<!--                       v-if="expanded.includes(item)">cancel-->
<!--                </v-btn>-->
<!--                <v-dialog-->
<!--                    v-model="item.deleteConfirm"-->
<!--                    width="500">-->
<!--                  <template #activator="{ on }">-->
<!--                    <v-btn small text v-on="on">-->
<!--                      <v-icon>delete</v-icon>-->
<!--                    </v-btn>-->
<!--                  </template>-->
<!--                  <v-card>-->
<!--                    <v-card-title-->
<!--                        class="headline grey lighten-2"-->
<!--                        primary-title>-->
<!--                      Confirm-->
<!--                    </v-card-title>-->

<!--                    <v-card-text class="pt-4">-->
<!--                      <div class="error-text">-->
<!--                        WARNING: Any actions currently using this requirement will be reset.-->
<!--                      </div>-->
<!--                      Are you sure you want to delete this requirement?-->
<!--                    </v-card-text>-->

<!--                    <v-divider></v-divider>-->

<!--                    <v-card-actions>-->
<!--                      <v-spacer></v-spacer>-->
<!--                      <v-btn-->
<!--                          @click="item.deleteConfirm = false">-->
<!--                        No-->
<!--                      </v-btn>-->
<!--                      <v-btn-->
<!--                          color="primary"-->
<!--                          text-->
<!--                          @click="[item.archived = true, deleteRequirement(item.id)]">-->
<!--                        Yes-->
<!--                      </v-btn>-->
<!--                    </v-card-actions>-->
<!--                  </v-card>-->
<!--                </v-dialog>-->
<!--              </div>-->
<!--            </td>-->
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
      operations: [],
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
    }
  },
  created () {
    this.getOperations()
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
    async getOperations () {
      try {
        const {data} = await getRequest(`/operation`)
        this.operations = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operations')
      }
    },
    async getOperators () {
      try {
        const {data} = await getRequest(`/operator/${this.newRequirement.selectedField.dataTypeId}`)
        this.operators = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operators for selected field')
      }
    },
    async getDataTypeRequirements () {
      try {
        const {data} = await getRequest(`/dataType/getDataTypeRequirements/${this.newRequirement.selectedField.dataTypeId}`)
        this.dataTypeRequirements = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching data type requirements for selected field')
      }
    },
    addNewRequirement () {
      this.$emit('input', this.newRequirement)
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
</style>