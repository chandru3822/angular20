<template>
  <v-container class="pt-0">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          Error Deleting Requirement
        </v-card-title>

        <v-card-text>
          You cannot delete a requirement that is being used in action logic.<br/><br/>
          Actions using this requirement:
          <v-list v-for="(item, index) in actionsUsingLogic" :key="index">
            <v-list-item-content>
              {{ item.actionName }}
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primary"
            text
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="[getRequirementTypes(), selectedDataTypeRequirement = {}]" text color="primary" v-if="userCanAdd">
              <v-icon v-if="!addNewRequirement">add</v-icon>
              {{ addNewRequirement ? 'Cancel' : 'Add Requirement' }}
            </v-btn>
            <v-btn color="primary" text @click="expandRequirements = !expandRequirements">
              <v-icon v-if="!expandRequirements">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewRequirement">
          <v-col cols="12">
            <!--  TODO: need to protect against bad data when they go back and change the requirement type but have already selected other values lower in the form      -->
            <v-select attach v-model="newRequirement.processStepRequirementTypeId"
                      :items="availableRequirementTypes"
                      label="Select Requirement Type"
                      item-value="id"
                      item-text="processStepRequirementType"
                      @input="[selectRequirementType(), parent = {}, selectedCustomField = {}, selectedDataTypeRequirement = {},
                              validateRequirementForm(),
                              selectedFunction = {}, newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></v-select>
            <!--            show this for both custom fields AND statuses-->
            <v-autocomplete
              v-if="newRequirement.processStepRequirementTypeId && (newRequirement.processStepRequirementTypeId === 1 || newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8)"
              v-model="parent"
              :items="parentObjects"
              label="Parent Object"
              return-object
              item-text="processStepName"
              attach
              @input="[loadValues(parent), selectedCustomField = {}, selectedDataTypeRequirement = {},
                        validateRequirementForm(),
                        selectedFunction = {}, newRequirement.operatorTypeId = null,
                        newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></v-autocomplete>
            <!-- if it is a process step custom field it needs parent, other custom fields do not-->
            <v-autocomplete
              v-if="newRequirement.processStepRequirementTypeId && ((newRequirement.processStepRequirementTypeId === 1 && parent.id) || newRequirement.processStepRequirementTypeId === 3 || newRequirement.processStepRequirementTypeId === 4)"
              v-model="selectedCustomField"
              :items="customFields"
              label="Custom Field"
              return-object
              attach
              item-text="fieldName"
              @input="[loadOperatorTypes(selectedCustomField.dataTypeId), loadDataTypeRequirements(selectedCustomField.dataTypeId),
                              selectedDataTypeRequirement = {},
                              validateRequirementForm(),
                              selectedFunction = {}, newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></v-autocomplete>
            <!-- if it is a function -->
            <v-select
              v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"
              v-model="selectedFunction"
              :items="availableFunctions"
              label="Function"
              item-text="companyFunctionName"
              returnObject
              @input="[loadFunctionParams(selectedFunction.dbFunctionId, true), loadOperatorTypes(selectedFunction.returnDataTypeId), loadDataTypeRequirements(selectedFunction.returnDataTypeId), validateRequirementForm()]"
            ></v-select>
            <div v-if="selectedFunction.id && newRequirement.requirementParamDynamicValues.length > 0">
              <h5 class="text-left">Dynamic Function Parameters</h5>
              <v-card flat>
                <div v-for="(fp, index) in newRequirement.requirementParamDynamicValues">
                  <v-tooltip
                    v-if="fp.description != null"
                    content-class="full-opacity-tooltip"
                    :max-width="300"
                    top
                  >
                    <template v-slot:activator="{ on, attrs }">
                      <v-btn
                        text
                        class="d-inline-block"
                        v-bind="attrs"
                        v-on="on"
                      >
                        <v-icon>
                          mdi-information
                        </v-icon>
                      </v-btn>
                    </template>
                    <span>{{ fp.description }}</span>
                  </v-tooltip>
                  <div class="dynamic-field-container">
                    <v-text-field
                      v-if="fp.dataTypeId === 4 || fp.dataTypeId === 6"
                      :key="index"
                      type="number"
                      placeholder="Enter a dynamic value (number)"
                      v-model="fp.dynamicValue"
                      @input="validateRequirementForm()"
                      :label="fp.parameterName"></v-text-field>
                    <v-text-field
                      :key="index"
                      v-else
                      placeholder="Enter a dynamic value"
                      v-model="fp.dynamicValue"
                      @input="validateRequirementForm()"
                      :label="fp.parameterName"></v-text-field>
                  </div>
                </div>
              </v-card>
            </div>
            <v-select
              v-if="(newRequirement.processStepRequirementTypeId !== 2 && newRequirement.processStepRequirementTypeId !== 7 && selectedCustomField.customFieldGroupAssignmentId)
                      || (newRequirement.processStepRequirementTypeId === 2 && selectedFunction.id)
                      || ((newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8) && parent.id)
                      || [9,10,11].includes(newRequirement.processStepRequirementTypeId)"
              v-model="newRequirement.operatorTypeId"
              :items="operatorTypes"
              label="Operator"
              @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null, validateRequirementForm(), operatorDataTypeCheck()]"
              item-text="operatorType"
              item-value="id"
            ></v-select>
            <v-switch
              v-if="newRequirement.operatorTypeId"
              v-model="newRequirement.customValue"
              :readonly="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || [7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)"
              :disabled="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || [7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)"
              @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null, validateRequirementForm()]"
              class="mx-2"
              label="Custom"
            ></v-switch>
            <v-text-field
              v-if="newRequirement.operatorTypeId && newRequirement.customValue && ![7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)
                    && ((!selectedCustomField.listOfValueId || selectedCustomField.listOfValueId === null) && (!selectedCustomField.customFieldSqlKey || selectedCustomField.customFieldSqlKey === null) && (!selectedCustomField.companySystemListId || selectedCustomField.companySystemListId === null))"
              v-model="newRequirement.requirementValue"
              placeholder="Enter a value X"
              @input="validateRequirementForm()"
              label="Value">
            </v-text-field>
            <v-select
              v-else-if="newRequirement.operatorTypeId
                              && newRequirement.customValue
                              && ![7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)
                              && ((selectedCustomField.listOfValueId && selectedCustomField.listOfValueId !== null) || (selectedCustomField.customFieldSqlKey && selectedCustomField.customFieldSqlKey !== null) || (selectedCustomField.companySystemListId && selectedCustomField.companySystemListId !== null))
                              && !selectedCustomField.allowMultiple"
              v-model="selectedListValue"
              :items="selectedCustomField.listOfValues"
              @change="validateRequirementForm()"
              label="Available Values"
              item-text="name"
              return-object
            ></v-select>
            <!-- if the requirement is event status -->
            <v-autocomplete
              v-else-if="newRequirement.operatorTypeId && newRequirement.processStepRequirementTypeId === 11"
              v-model="selectedListOfValues"
              :items="eventStatuses"
              label="Event Status"
              multiple
              attach
              @change="validateRequirementForm()"
              item-text="eventStatusType"
              return-object
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.eventStatusType }}
              </template>
            </v-autocomplete>
            <!-- currently only a listOfValueId can be a multiselect.  we may change this down the road for custom sql and system lists -->
            <v-select
              v-else-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId !== null && selectedCustomField.allowMultiple"
              v-model="selectedListOfValues"
              :items="selectedCustomField.listOfValues"
              label="Available Values"
              multiple
              @change="validateRequirementForm()"
              item-text="name"
              return-object
            ></v-select>
            <v-autocomplete
              v-else-if="newRequirement.operatorTypeId && (newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8)"
              v-model="selectedListOfValues"
              :items="processStepStatuses"
              label="Available Values"
              multiple
              attach
              @change="validateRequirementForm()"
              item-text="processStepStatusType"
              return-object
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.processStepStatusType }}
                <span v-if="newRequirement.processStepRequirementTypeId === 7"
                      class="ml-1">({{ data.item.rootProcessStepStatusType }})</span>
              </template>
            </v-autocomplete>
            <v-autocomplete
              v-else-if="newRequirement.operatorTypeId && (newRequirement.processStepRequirementTypeId === 9 || newRequirement.processStepRequirementTypeId === 10)"
              v-model="selectedListOfValues"
              :items="projectStatuses"
              label="Available Values"
              multiple
              attach
              @change="validateRequirementForm()"
              item-text="projectStatusType"
              return-object
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.projectStatusType }}
                <span v-if="newRequirement.projectStatusTypeId === 9" class="ml-1">({{
                    data.item.projectStatusType
                  }})</span>
              </template>
            </v-autocomplete>
            <v-select
              v-else-if="newRequirement.operatorTypeId && !newRequirement.customValue"
              v-model="selectedDataTypeRequirement"
              :items="dataTypeRequirements"
              label="Available Values"
              @change="validateRequirementForm()"
              item-text="dataTypeValue"
              return-object
            ></v-select>
            <v-text-field v-if="selectedDataTypeRequirement && selectedDataTypeRequirement.secondaryRequirement"
                          type="number"
                          v-model="newRequirement.secondaryRequirementValue"
                          placeholder="Enter a value"
                          @input="validateRequirementForm()"
                          label="Value">
            </v-text-field>
            <div
              v-if="(newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8) && newRequirement.operatorTypeId">
              <label>Fail if no
                <strong>{{ parent.processStepName }}</strong> steps are found:</label>
              <input type="checkbox" class="ml-3 mb-4" v-model="newRequirement.failIfNoReferenceStepFound"
                     :readonly="!userCanEdit"
                     :disabled="!userCanEdit">
            </div>
            <v-btn :disabled="invalidRequirement"
                   @click="saveNewRequirement">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandRequirements">
          <v-col cols="12" class="pt-0">
            <v-data-table
              :headers="headers"
              :items="filterRequirements()"
              :items-per-page="-1"
              :mobile-breakpoint="0"
              disable-sort
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              class="elevation-1 fix-column-width-bug square-card"
            >
              <template #no-data>
                No requirements for this process step
              </template>

              <template #no-results>
                No requirements for this process step
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': selectedRequirementIndex % 2}">
                  <div v-if="item.requirementParamDynamicValues && item.requirementParamDynamicValues.length > 0">
                    <h5 class="text-left">Dynamic Function Parameters</h5>
                    <v-card flat color="transparent">
                      <div v-for="(fp, index) in item.requirementParamDynamicValues" :key="index">
                        <v-tooltip
                          v-if="fp.description != null"
                          content-class="full-opacity-tooltip"
                          :max-width="300"
                          top
                        >
                          <template v-slot:activator="{ on, attrs }">
                            <v-btn
                              text
                              class="d-inline-block"
                              v-bind="attrs"
                              v-on="on"
                            >
                              <v-icon>
                                mdi-information
                              </v-icon>
                            </v-btn>
                          </template>
                          <span>{{ fp.description }}</span>
                        </v-tooltip>
                        <div class="dynamic-field-container">
                          <v-text-field
                            v-if="fp.dataTypeId === 1"
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter a date"
                            type="date"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                          <v-text-field
                            v-if="fp.dataTypeId === 2"
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter a timestamp"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                          <v-text-field
                            v-if="fp.dataTypeId === 3"
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter a boolean"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                          <v-text-field
                            v-if="fp.dataTypeId === 4"
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter a number"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                          <v-text-field
                            v-if="fp.dataTypeId === 6"
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter an integer"
                            type="number"
                            step="1"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                          <v-text-field
                            v-else
                            :readonly="item.immutable || !userCanEdit"
                            :disabled="item.immutable || !userCanEdit"
                            placeholder="Enter a dynamic value"
                            v-model="fp.dynamicValue"
                            :label="fp.parameterName"></v-text-field>
                        </div>
                      </div>
                    </v-card>
                  </div>
                  <v-select attach v-model="item.operatorTypeId"
                            :items="operatorTypes"
                            class="one-hunned"
                            label="Operator"
                            :readonly="(newRequirement.operatorTypeId === 5 && (selectedCustomField.dataTypeId === 7 || selectedCustomField.dataTypeId === 8)) || item.immutable || !userCanEdit"
                            :disabled="(newRequirement.operatorTypeId === 5 && (selectedCustomField.dataTypeId === 7 || selectedCustomField.dataTypeId === 8)) || item.immutable || !userCanEdit"
                            item-text="operatorType"
                            @change="operatorDataTypeCheck(item)"
                            item-value="id"
                  ></v-select>
                  <v-switch v-model="item.customValue"
                            class="mx-2"
                            :readonly="(item.dataTypeId === 7) || item.dataTypeId === 3 || !userCanEdit || [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                            :disabled="(item.dataTypeId === 7) || item.dataTypeId === 3 || item.immutable  || !userCanEdit || [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                            label="Custom"
                  ></v-switch>
                  <!-- single text field for non list custom values -->
                  <v-text-field
                    v-if="item.customValue && item.processStepRequirementTypeId !== 7 && (!item.listOfValues || item.listOfValues.length === 0) && !item.listOfValueId && !item.customFieldSqlKey && !item.systemListId "
                    v-model="item.requirementValue"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    placeholder="Enter a value"
                    label="Value">
                  </v-text-field>
                  <!-- single select for dropdown, custom sql list, or system list -->
                  <v-select
                    v-else-if="item.customValue && item.customField && ![7,8,9,10,11].includes(item.processStepRequirementTypeId)
                            && ((item.customField.listOfValueId !== null || item.customField.customFieldSqlKey !== null || item.customField.companySystemListId !== null) && !item.customField.allowMultiple)"
                    v-model="item.listOfValueId"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    item-text="name"
                    item-value="id"
                  ></v-select>
                  <v-autocomplete
                    v-else-if="item.operatorTypeId && [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                    v-model="item.listOfValues"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    multiple
                    @change="validateRequirementForm()"
                    item-text="name"
                    return-object
                  >
                  </v-autocomplete>
                  <v-select
                    v-else-if="item.customValue && item.systemListId"
                    v-model="item.systemListOptionId"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    item-text="name"
                    item-value="id"
                  ></v-select>
                  <!-- not sure what to do with this custom sql one yet -->
                  <v-select
                    v-else-if="item.customValue && item.customFieldSqlKey"
                    v-model="item.listOfValueId"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    item-text="name"
                    item-value="id"
                  ></v-select>
                  <!-- at this point it should only show for multiselects -->
                  <v-select
                    v-else-if="item.customValue && item.customField && item.customField.allowMultiple"
                    v-model="item.listOfValues"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    item-text="name"
                    multiple
                    return-object
                  ></v-select>
                  <v-select
                    v-else
                    v-model="item.dataTypeRequirement"
                    :items="dataTypeRequirements"
                    :disabled="item.immutable || !userCanEdit"
                    :readonly="item.immutable || !userCanEdit"
                    label="Available Values"
                    item-text="dataTypeValue"
                    item-value="id"
                    return-object
                  ></v-select>
                  <v-text-field v-if="item.dataTypeRequirement.secondaryRequirement"
                                type="number"
                                v-model="item.secondaryRequirementValue"
                                placeholder="Enter a value"
                                :disabled="item.immutable || !userCanEdit"
                                :readonly="item.immutable || !userCanEdit"
                                label="Value">
                  </v-text-field>
                  <div
                    v-if="(item.processStepRequirementTypeId === 7 || item.processStepRequirementTypeId === 8) && item.operatorTypeId">
                    <label>Fail if no
                      <strong>{{ item.referenceProcessStepName }}</strong> steps are found:</label>
                    <input type="checkbox" class="ml-3 mb-4" v-model="item.failIfNoReferenceStepFound"
                           :readonly="item.immutable || !userCanEdit"
                           :disabled="item.immutable || !userCanEdit">
                  </div>
                  <v-btn v-if="userCanEdit" @click="updateRequirement(item)">
                    <v-icon>save</v-icon>
                    Save
                  </v-btn>
                </td>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left" style="width: 65px">{{ item.requirementNbr }}</td>
                  <td class="text-left">{{ item.processStepRequirementType }}</td>
                  <td class="text-left">
                    <span v-if="item.processStepRequirementTypeId === 1">
                      {{ item.parentName }} | {{ item.fieldName }}
                    </span>
                    <span v-else-if="item.processStepRequirementTypeId === 2">
                      {{ item.companyFunctionName }}
                    </span>
                    <span
                      v-else-if="item.processStepRequirementTypeId === 7 || item.processStepRequirementTypeId === 8">
                      {{ item.referenceProcessStepName }}
                    </span>
                    <span v-else>
                      {{ item.fieldName }}
                    </span>
                  </td>
                  <td class="text-left">{{ item.operatorType }}</td>
                  <td class="text-left">
                    <span v-if="item.requirementValue">
                      {{ item.requirementValue }}
                    </span>
                    <span v-else-if="item.dataTypeRequirementId">
                      {{
                        item.dataTypeRequirement ? item.dataTypeRequirement.dataTypeValue : 'unknown'
                      }} {{ item.secondaryRequirementValue }}
                    </span>
                    <span v-else-if="item.listOfValueId || item.customFieldSqlKey || item.companySystemListId">
<!--                      {{item.listOfValue ? item.listOfValue.name : 'unknown'}}-->
                      {{ getListValueName(item) }}
                    </span>
                    <span v-else-if="item.listOfValues">
                      <!-- todo: show the selected values here -->
                      {{ item.listOfValues.map(v => ' ' + v.name).toString() }}
                    </span>
                  </td>
                  <td>
                    <div style="display: flex;">
                      <v-btn small text color="primary" @click="[expanded = [item], loadOperatorTypes(item.dataTypeId, item.processStepRequirementTypeId),
                                    loadDataTypeRequirements(item.dataTypeId), selectedRequirementIndex = index]"
                             v-if="!expanded.includes(item)">
                        <v-icon v-if="item.immutable">expand_more</v-icon>
                        <v-icon v-else>edit</v-icon>
                      </v-btn>
                      <v-btn small text color="primary" @click="[expanded = [], selectedRequirementIndex = index]"
                             v-if="expanded.includes(item)">cancel
                      </v-btn>
                      <v-btn small text color="primary" v-if="userCanEdit" @click="[itemToDelete=item, showDeleteDialog=true]"><v-icon>delete</v-icon></v-btn>
                    </div>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-confirm-delete-dialog="showDeleteDialog"
                                 @confirm-delete="deleteRequirement"
                                 @closeConfirmDeleteDialog="closeDeleteDialog">
      Are you sure you want to delete this requirement?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>delete</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import {getCompanyAssignedToProcessStep, getAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import {getProjectStatusTypes, getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
import {
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ProcessStepRequirements',
  components: {ConfirmationDialog},
  mixins: [Vue2Filters.mixin],
  props: {
    eventRequirements: Boolean,
    callback: Function
  },
  mounted() {
  },
  watch: {
    requirements: function () {
      //any time the requirements change, send back to parent component
      this.callback(this.requirements)
    }
  },
  data() {
    return {
      snackbar: {},
      expandRequirements: true,
      expanded: [],
      deleteError: false,
      actionsUsingLogic: [],
      invalidRequirement: true,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      headers: [
        {text: 'ID', value: 'requirementNbr', width: '65px', show: true},
        {text: 'Type', value: 'processStepRequirementType', show: true},
        {text: 'Details', value: 'custom', show: true},
        {text: 'Operator', value: 'operatorType', show: true},
        {text: 'Value', value: 'requirementValue', show: true},
        {text: null, value: 'icons', show: true}
      ],
      addNewRequirement: false,
      newRequirement: {
        requirementParamDynamicValues: [],
        customValue: false,
        failIfNoReferenceStepFound: true
      },
      eventStatuses: [],
      // selectedEventStatuses: [],
      dataTypeRequirements: [],
      selectedDataTypeRequirement: {},
      selectedCustomField: {},
      listOfValues: [],
      selectedListOfValues: [],
      selectedListValue: {},
      selectedFunction: {},
      selectedRequirementIndex: null,
      availableRequirementTypes: [],
      processStepId: this.$route.params.id,
      processStepEventId: this.$route.params.eventId,
      companyId: this.$store.state.user.details.companyId,
      parentObjects: [],
      parent: {},
      customFields: [],
      operatorTypes: [],
      operationTypes: [],
      selectedProcessStepStatus: {},
      processStepStatuses: [],
      projectStatuses: [],

      requirements: [],
      availableFunctions: [],
      apiUrl: '',
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  computed: {},
  async created() {
    //api = process step requirements OR process step event requirements
    this.apiUrl = this.eventRequirements ? `/processStep/${this.processStepId}/event/${this.processStepEventId}/requirement` : `/processStep/${this.processStepId}/requirement`
    this.getRequirements()
  },
  methods: {
    //requirements
    async getRequirements() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(this.apiUrl)
        this.requirements = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterRequirements() {
      return this.requirements.filter(r => {
        return !r.archived
      })
    },
    async getRequirementTypes() {
      this.addNewRequirement = !this.addNewRequirement
      if (this.addNewRequirement) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let url = this.eventRequirements ? `/processStep/${this.processStepId}/requirement/event/types` : `/processStep/${this.processStepId}/requirement/types`
          const {data} = await getRequest(url)
          this.availableRequirementTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async selectRequirementType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //1 == process step custom field, 2 == function,
        // 3 == project custom field, 4 == contact custom field
        if (this.newRequirement.processStepRequirementTypeId === 1 || this.newRequirement.processStepRequirementTypeId === 7 || this.newRequirement.processStepRequirementTypeId === 8) {
          this.loadParentObjects()
        } else if (this.newRequirement.processStepRequirementTypeId === 3) {
          //get project custom fields
          this.loadCustomFieldsByObjectType(1)
        } else if (this.newRequirement.processStepRequirementTypeId === 4) {
          //get contact custom fields
          this.loadCustomFieldsByObjectType(2)
        } else if (this.newRequirement.processStepRequirementTypeId === 9) {
          //get project statuses
          this.getCompanyProjectStatuses()
          //load operator types from here for this kind
          this.newRequirement.customValue = true
          this.loadOperatorTypes(7, 9)
        } else if (this.newRequirement.processStepRequirementTypeId === 10) {
          //get company project statuses
          this.getProjectStatuses()
          this.newRequirement.customValue = true
          this.loadOperatorTypes(7, 10)
        } else if (this.newRequirement.processStepRequirementTypeId === 11) {
          this.newRequirement.customValue = true
          this.loadOperatorTypes(7, 11)
          this.getEventStatuses()
        } else {
          let objectTypeId = this.eventRequirements ? 6 : 4;
          const {data} = await getRequest(`/function/requirement/${objectTypeId}`)
          this.availableFunctions = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadParentObjects() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/processStep/getParentObjects`, {params: {id: this.processStepId}})
        this.parentObjects = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadValues(parent) {
      if (this.newRequirement?.processStepRequirementTypeId === 1) {
        await this.loadFieldsByParent(parent)
      } else if (this.newRequirement?.processStepRequirementTypeId === 7) {
        this.newRequirement.customValue = true
        await this.getCompanyStatusesAssignedToProcessStep(parent)
        //this 7 = data type for multi select
        await this.loadOperatorTypes(7, 7)
      } else if (this.newRequirement?.processStepRequirementTypeId === 8) {
        this.newRequirement.customValue = true
        await this.getStatusesAssignedToProcessStep(parent)
        //this 7 = data type for multi select
        await this.loadOperatorTypes(7, 8)
      }
    },
    async getCompanyStatusesAssignedToProcessStep(parent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyAssignedToProcessStep(parent.id)
        //if the selected process step is the same as the active process step being viewed, only allow active process step status types
        this.processStepStatuses = parent.id === parseInt(this.processStepId) ? data.filter(d => d.processStepStatusTypeId === 1) : data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getStatusesAssignedToProcessStep(parent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getAssignedToProcessStep(parent.id)
        //if the selected process step is the same as the active process step being viewed, only allow active process step status types
        this.processStepStatuses = parent.id === parseInt(this.processStepId) ? data.filter(d => d.id === 1) : data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProjectStatuses() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getProjectStatusTypes()
        this.projectStatuses = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getEventStatuses() {
      //this has to load event statuses using the pseId
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/event/statusesForPsEvent/${this.processStepEventId}`)
        this.eventStatuses = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyProjectStatuses() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyProjectStatusTypes()
        this.projectStatuses = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadFieldsByParent(parent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //this exclusion is temporary until requirements/action can handle the new system readonly data type
        //could probably do this cleaner/more generically i just dont want to cuz it is temporary
        const {data} = await getRequestWithParams(`/customField/getByParentProcessStep/${parent.id}`, {
          params: {
            excludedUnhandledDataTypes: true
          }
        })
        this.customFields = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadCustomFieldsByObjectType(objectTypeId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customField/getByParentType/${objectTypeId}`, {
          params: {
            excludedUnhandledDataTypes: true
          }
        })
        this.customFields = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadFunctionParams(dbFunctionId, isRequirement) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/function/${dbFunctionId}/dynamicParams`)
        if (isRequirement) {
          this.newRequirement.requirementParamDynamicValues = data
        } else {
          this.selectedChildRequirementParamDynamicValues = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadOperatorTypes(dataTypeId, processStepRequirementTypeId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/operator/${dataTypeId}`)
        if ([7, 8, 9, 10, 11].includes(processStepRequirementTypeId)) {
          this.operatorTypes = data.filter(d => d.id === 5)
        } else {
          this.operatorTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadDataTypeRequirements(dataTypeId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)
        this.dataTypeRequirements = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    operatorDataTypeCheck(item) {
      // keeps multiselects using the right operator with the right lists.  i could probably do this better
      if (item) {
        if (item.operatorTypeId === 5 && (item.dataTypeId === 7 || item.dataTypeId === 7)) {
          item.customValue = true
          item.dataTypeRequirement = {}
        } else if (item.dataTypeId === 7 || item.dataTypeId === 8) {
          item.customValue = false
          item.listOfValues = []
          this.loadDataTypeRequirements(item.dataTypeId)
        }
      } else {
        if (this.newRequirement.operatorTypeId === 5 && (this.selectedCustomField.dataTypeId === 7 || this.selectedCustomField.dataTypeId === 8)) {
          this.newRequirement.customValue = true
          this.selectedDataTypeRequirement = {}
        } else if (this.selectedCustomField.dataTypeId) {
          this.newRequirement.customValue = false
          this.selectedListOfValues = []
          let dataTypeToUse = this.newRequirement.processStepRequirementTypeId === 7 ? 7 : this.newRequirement.processStepRequirementTypeId === 8 ? 8 : this.selectedCustomField.dataTypeId
          this.loadDataTypeRequirements(dataTypeToUse)
        }
      }
    },
    validateRequirementForm() {
      let invalidParams = false
      //if there are dynamic params, ensure they are all populated
      if (this.newRequirement.requirementParamDynamicValues.length > 0) {
        this.newRequirement.requirementParamDynamicValues.forEach(fp => {
          if (!fp.dynamicValue) {
            invalidParams = true
          }
        })
      }

      //check validity of initial value
      let invalidValue = (!this.newRequirement.requirementValue && !this.selectedDataTypeRequirement.id && !this.selectedListValue.id && this.selectedListOfValues.length === 0)

      //if a secondary requirement is required check for a value there
      let invalidSecondaryValue = (this.selectedDataTypeRequirement.secondaryRequirement && !this.newRequirement.secondaryRequirementValue)

      this.invalidRequirement = invalidParams || invalidValue || invalidSecondaryValue
    },
    async saveNewRequirement() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newRequirement.customFieldGroupAssignmentId = this.selectedCustomField.customFieldGroupAssignmentId
        this.newRequirement.companyFunctionId = this.selectedFunction.id
        this.newRequirement.processStepId = this.processStepId

        //todo: holy crap figure out how to fix the object being sent up so i dont have to do all this validation
        //adjust value of requirementValue as needed:
        if (this.newRequirement.customValue && this.selectedCustomField.listOfValueId && this.selectedCustomField.allowMultiple) {
          // if from list of values and allow multiple build the json array of selected ids
          this.newRequirement.listOfValueIds = this.selectedListOfValues.map(v => v.id)

          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          this.newRequirement.systemListOptionId = null
          this.newRequirement.customSqlOptionId = null
          this.newRequirement.listOfValueId = null
          this.newRequirement.dataTypeRequirementId = null
          this.newRequirement.requirementValue = null
        } else if (this.newRequirement.customValue && this.selectedCustomField.listOfValueId && !this.selectedCustomField.allowMultiple) {
          //  if from a list of values and not allow multiple use the selected value id,
          this.newRequirement.listOfValueId = this.selectedListValue.id
          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          this.newRequirement.systemListOptionId = null
          this.newRequirement.customSqlOptionId = null
          this.newRequirement.listOfValueIds = null
          this.newRequirement.dataTypeRequirementId = null
          this.newRequirement.requirementValue = null
        } else if (this.newRequirement.customValue && this.selectedCustomField.companySystemListId && !this.selectedCustomField.allowMultiple) {
          //  if from a system list and not allow multiple use the selected value id,
          this.newRequirement.systemListOptionId = this.selectedListValue.id
          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          this.newRequirement.listOfValueId = null
          this.newRequirement.listOfValueIds = null
          this.newRequirement.customSqlOptionId = null
          this.newRequirement.dataTypeRequirementId = null
          this.newRequirement.requirementValue = null
        } else if (this.newRequirement.customValue && this.selectedCustomField.customFieldSqlKey && !this.selectedCustomField.allowMultiple) {
          //  if from a list of values and not allow multiple use the selected value id,
          this.newRequirement.customSqlOptionId = this.selectedListValue.id
          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          this.newRequirement.listOfValueId = null
          this.newRequirement.systemListOptionId = null
          this.newRequirement.listOfValueIds = null
          this.newRequirement.dataTypeRequirementId = null
          this.newRequirement.requirementValue = null
        } else if (this.newRequirement.customValue) {
          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          //here
          if ([7, 8].includes(this.newRequirement.processStepRequirementTypeId)) {
            this.newRequirement.listOfValueIds = this.selectedListOfValues.map(v => v.id)
            this.newRequirement.referenceProcessStepId = this.parent.id
          } else if ([9, 10, 11].includes(this.newRequirement.processStepRequirementTypeId)) {
            this.newRequirement.listOfValueIds = this.selectedListOfValues.map(v => v.id)
          } else {
            this.newRequirement.listOfValueIds = null
          }
          this.newRequirement.systemListOptionId = null
          this.newRequirement.customSqlOptionId = null
          this.newRequirement.listOfValueId = null
          this.newRequirement.dataTypeRequirementId = null
        } else if (!this.newRequirement.customValue) {
          this.newRequirement.dataTypeRequirementId = this.selectedDataTypeRequirement.id
          //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
          this.newRequirement.listOfValueIds = null
          this.newRequirement.systemListOptionId = null
          this.newRequirement.customSqlOptionId = null
          this.newRequirement.listOfValueId = null
          this.newRequirement.requirementValue = null
        }

        if (this.eventRequirements) {
          this.newRequirement.processStepEventId = this.processStepEventId
        }
        const {data} = await postRequest(this.apiUrl, this.newRequirement)
        this.requirements.push(data)
        this.selectedCustomField = {}
        this.selectedListOfValues = []
        this.selectedListValue = {}
        this.addNewRequirement = false
        this.newRequirement = {
          requirementParamDynamicValues: [],
          customValue: false,
          failIfNoReferenceStepFound: true
        }
        this.selectedDataTypeRequirement = {}
        this.parent = {}
        this.availableFunctions = []
        this.snackbar = getSnackbar('SUCCESS', 'Requirement Added')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Requirement')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateRequirement(requirement) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        requirement.dataTypeRequirementId = requirement.customValue ? null : requirement.dataTypeRequirement.id
        requirement.dataTypeRequirement = requirement.customValue ? {} : requirement.dataTypeRequirement
        requirement.secondaryRequirementValue = !requirement.customValue && requirement.dataTypeRequirement.secondaryRequirement ? requirement.secondaryRequirementValue : null

        //adjust value of requirementValue as needed:
        if (requirement.customValue && requirement.listOfValues) {
          // if from list of values and allow multiple build the json array of selected ids
          requirement.listOfValueIds = requirement.listOfValues.map(v => v.id)
          //reset this in case they changed values around
          requirement.dataTypeRequirementId = null
        } else if (requirement.customValue && this.selectedCustomField.listOfValueId && !this.selectedCustomField.allowMultiple) {
          //  if from a list of values and not allow multiple use the selected value id,
          requirement.listOfValueId = this.selectedListValue.id
          //reset this in case they changed values around
          requirement.dataTypeRequirementId = null
        } else if (!requirement.customValue) {
          //reset these in case they changed values around
          requirement.listOfValueIds = null
          requirement.listOfValueId = null
          requirement.requirementValue = null
        }

        if (this.eventRequirements) {
          this.newRequirement.processStepEventId = this.processStepEventId
        }

        const {data} = await putRequest(this.apiUrl, requirement)
        this.expanded = []
        // this forces the list to update the operator displayed ... using requirement = data did not work
        requirement.operatorType = data.operatorType
        this.snackbar = getSnackbar('SUCCESS', 'Requirement Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Requirement')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteRequirement() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let url = this.apiUrl + `/${item.id}`
        const {data} = await putRequest(url)
        if (data?.length > 0) {
          this.deleteError = true
          item.deleteConfirm = false
          this.actionsUsingLogic = data
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Requirement')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          item.archived = true
          this.requirements = this.requirements.filter(r => !r.archived)
          this.snackbar = getSnackbar('SUCCESS', 'Requirement Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Requirement')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    getListValueName(item) {
      let idToUse = item.customSqlOptionId ? item.customSqlOptionId :
        item.systemListOptionId ? item.systemListOptionId : item.listOfValueId
      let match = item.availableListOfValues.find(i => i.id === idToUse)
      return match ? match.name : 'unknown'
    },
    closeDeleteDialog(){
      this.showDeleteDialog = false
      this.itemToDelete = null
    }
  }

}
</script>

<style scoped lang="scss">
.params {
  width: 100%;
}

.req-header-bar {
  border-bottom: 1px solid #E6E6E6;
}

.dynamic-field-container {
  width: 80%;
  display: inline-block;
}

</style>
