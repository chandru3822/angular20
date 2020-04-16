<template>
<v-col cols="12">
  <v-toolbar color="transparent" class="elevation-0">
    <v-toolbar-title>Requirements</v-toolbar-title>
    <v-spacer></v-spacer>
    <v-toolbar-items>
      <v-btn @click="[getRequirementTypes(), selectedDataTypeRequirement = {}]" text>
            <v-icon>add</v-icon>
<!--        <v-icon v-if="!addNewRequirement">add</v-icon>-->
<!--        {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}-->
        {{ 'Add Requirement'}}
      </v-btn>
    </v-toolbar-items>
  </v-toolbar>
<!--  <v-row v-if="addNewRequirement">-->
<!--  <v-row>-->
<!--    <v-col cols="12">-->
<!--      &lt;!&ndash;  TODO: need to protect against bad data when they go back and change the requirement type but have already selected other values lower in the form      &ndash;&gt;-->
<!--      <v-select v-model="newRequirement.processStepRequirementTypeId"-->
<!--                :items="availableRequirementTypes"-->
<!--                label="Select Requirement Type"-->
<!--                item-value="id"-->
<!--                item-text="processStepRequirementType"-->
<!--                @input="[selectRequirementType(), parent = {}, selectedCustomField = {}, selectedDataTypeRequirement = {},-->
<!--                            selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,-->
<!--                            newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"-->
<!--      ></v-select>-->
<!--      &lt;!&ndash; if it is a custom field &ndash;&gt;-->
<!--      <v-select-->
<!--          v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 1"-->
<!--          v-model="parent"-->
<!--          :items="parentObjects"-->
<!--          label="Parent Object"-->
<!--          item-text="processStepName"-->
<!--          return-object-->
<!--          @input="[loadFieldsByParent(parent), selectedCustomField = {}, selectedDataTypeRequirement = {},-->
<!--                            selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,-->
<!--                            newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"-->
<!--      ></v-select>-->
<!--      <v-select v-if="parent.id"-->
<!--                v-model="selectedCustomField"-->
<!--                :items="customFields"-->
<!--                label="Custom Field"-->
<!--                item-text="fieldName"-->
<!--                return-object-->
<!--                @input="[loadOperatorTypes(selectedCustomField.dataTypeId), loadDataTypeRequirements(selectedCustomField.dataTypeId),-->
<!--                            selectedDataTypeRequirement = {},-->
<!--                            selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,-->
<!--                            newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"-->
<!--      ></v-select>-->
<!--      &lt;!&ndash; if it is a function &ndash;&gt;-->
<!--      <v-select-->
<!--          v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"-->
<!--          v-model="selectedFunction"-->
<!--          :items="availableFunctions"-->
<!--          label="Function"-->
<!--          item-text="companyFunctionName"-->
<!--          returnObject-->
<!--          @input="[loadFunctionParams(selectedFunction.dbFunctionId, true), loadOperatorTypes(selectedFunction.returnDataTypeId), loadDataTypeRequirements(selectedFunction.returnDataTypeId)]"-->
<!--      ></v-select>-->
<!--      <div v-if="selectedFunction.id && newRequirement.requirementParamDynamicValues.length > 0">-->
<!--        <h5 class="text-left">Dynamic Function Parameters</h5>-->
<!--        <v-card flat>-->
<!--          <v-text-field-->
<!--              v-for="(fp, index) in newRequirement.requirementParamDynamicValues"-->
<!--              :key="index"-->
<!--              placeholder="Enter a dynamic value"-->
<!--              v-model="fp.dynamicValue"-->
<!--              :label="fp.parameterName"></v-text-field>-->
<!--        </v-card>-->
<!--      </div>-->
<!--      <v-select-->
<!--          v-if="(newRequirement.processStepRequirementTypeId === 1 && selectedCustomField.customFieldGroupAssignmentId) || (newRequirement.processStepRequirementTypeId === 2 && selectedFunction.id)"-->
<!--          v-model="newRequirement.operatorTypeId"-->
<!--          :items="operatorTypes"-->
<!--          label="Operator"-->
<!--          @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"-->
<!--          item-text="operatorType"-->
<!--          item-value="id"-->
<!--      ></v-select>-->
<!--      <v-switch v-if="newRequirement.operatorTypeId" v-model="newRequirement.customValue" @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]" class="mx-2" label="Custom"></v-switch>-->
<!--      <v-text-field v-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId === null && selectedCustomField.customFieldSqlKeyId === null && selectedCustomField.systemListId === null"-->
<!--                    v-model="newRequirement.requirementValue"-->
<!--                    placeholder="Enter a value"-->
<!--                    label="Value">-->
<!--      </v-text-field>-->
<!--      <v-select-->
<!--          v-else-if="newRequirement.operatorTypeId-->
<!--                            && newRequirement.customValue-->
<!--                            && (selectedCustomField.listOfValueId !== null || selectedCustomField.customFieldSqlKeyId !== null || selectedCustomField.systemListId !== null)-->
<!--                            && !selectedCustomField.allowMultiple"-->
<!--          v-model="selectedListValue"-->
<!--          :items="selectedCustomField.listOfValues"-->
<!--          label="Available Values"-->
<!--          item-text="name"-->
<!--          return-object-->
<!--      ></v-select>-->
<!--      &lt;!&ndash; currently only a listOfValueId can be a multiselect.  we may change this down the road for custom sql and system lists &ndash;&gt;-->
<!--      <v-select-->
<!--          v-else-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId !== null && selectedCustomField.allowMultiple"-->
<!--          v-model="selectedListOfValues"-->
<!--          :items="selectedCustomField.listOfValues"-->
<!--          label="Available Values"-->
<!--          multiple-->
<!--          item-text="name"-->
<!--          return-object-->
<!--      ></v-select>-->
<!--      <v-select-->
<!--          v-else-if="newRequirement.operatorTypeId && !newRequirement.customValue"-->
<!--          v-model="selectedDataTypeRequirement"-->
<!--          :items="dataTypeRequirements"-->
<!--          label="Available Values"-->
<!--          item-text="dataTypeValue"-->
<!--          return-object-->
<!--      ></v-select>-->
<!--      <v-text-field v-if="selectedDataTypeRequirement && selectedDataTypeRequirement.secondaryRequirement"-->
<!--                    v-model="newRequirement.secondaryRequirementValue"-->
<!--                    placeholder="Enter a value"-->
<!--                    label="Value">-->
<!--      </v-text-field>-->
<!--      <v-btn :disabled="validateRequirementForm()"-->
<!--             @click="saveNewRequirement">-->
<!--        <v-icon>save</v-icon>-->
<!--        Save-->
<!--      </v-btn>-->
<!--    </v-col>-->
<!--  </v-row>-->
  <v-row>
    <v-col cols="12">
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
    </v-col>
  </v-row>
</v-col>
</template>

<script>
export default {
  name: "SmartlistRequirement",
  props: {
    requirements: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      headers: [
        {text: 'ID', value: 'displayOrder'},
        {text: 'Field Name', value: 'name'},
        {text: 'Object Type', value: 'objectType'},
        {text: 'Process Step Name', value: 'processStepName'},
        {text: 'Operator', value: 'operatorType'},
        {text: 'Value', value: 'requirementValue'},
        // {text: null, value: 'icons'}
      ],
    }
  }
}
</script>

<style scoped lang="scss">

</style>