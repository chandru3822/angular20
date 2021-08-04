<template>
  <v-container class="pt-0">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="headline error--text">
          Error Deleting Requirement
        </v-card-title>

        <v-card-text>
          You cannot delete a requirement that is being used in action logic.<br/><br/>
          Actions using this requirement:
          <v-list v-for="(item, index) in actionsUsingLogic" :key="index">
            <v-list-item-content>
              {{item.actionName}}
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primaryCustom"
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
            <v-btn @click="[getRequirementTypes(), selectedDataTypeRequirement = {}]" text v-if="userCanAdd">
              <v-icon v-if="!addNewRequirement">add</v-icon>
              {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}
            </v-btn>
            <v-btn text @click="expandRequirements = !expandRequirements">
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
                              selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></v-select>
<!--            show this for both custom fields AND statuses-->
            <v-autocomplete
              v-if="newRequirement.processStepRequirementTypeId && (newRequirement.processStepRequirementTypeId === 1 || newRequirement.processStepRequirementTypeId === 7)"
              v-model="parent"
              :items="parentObjects"
              label="Parent Object"
              return-object
              item-text="processStepName"
              attach
              @input="[loadValues(parent), selectedCustomField = {}, selectedDataTypeRequirement = {},
                        validateRequirementForm(),
                        selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,
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
                              selectedFunction = {}, requirementParamDynamicValues = [], newRequirement.operatorTypeId = null,
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
              </v-card>
            </div>
            <v-select
              v-if="(newRequirement.processStepRequirementTypeId !== 2 && newRequirement.processStepRequirementTypeId !== 7 && selectedCustomField.customFieldGroupAssignmentId)
                      || (newRequirement.processStepRequirementTypeId === 2 && selectedFunction.id)
                      || (newRequirement.processStepRequirementTypeId === 7 && parent.id)"
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
              :readonly="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || newRequirement.processStepRequirementTypeId === 7"
              :disabled="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || newRequirement.processStepRequirementTypeId === 7"
              @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null, validateRequirementForm()]"
              class="mx-2"
              label="Custom"
            ></v-switch>
            <v-text-field
              v-if="newRequirement.operatorTypeId && newRequirement.customValue && newRequirement.processStepRequirementTypeId !== 7
                    && ((!selectedCustomField.listOfValueId || selectedCustomField.listOfValueId === null) && (!selectedCustomField.customFieldSqlKey || selectedCustomField.customFieldSqlKey === null) && (!selectedCustomField.companySystemListId || selectedCustomField.companySystemListId === null))"
              v-model="newRequirement.requirementValue"
              placeholder="Enter a value"
              @input="validateRequirementForm()"
              label="Value">
            </v-text-field>
            <v-select
              v-else-if="newRequirement.operatorTypeId
                              && newRequirement.customValue
                              && newRequirement.processStepRequirementTypeId !== 7
                              && ((selectedCustomField.listOfValueId && selectedCustomField.listOfValueId !== null) || (selectedCustomField.customFieldSqlKey && selectedCustomField.customFieldSqlKey !== null) || (selectedCustomField.companySystemListId && selectedCustomField.companySystemListId !== null))
                              && !selectedCustomField.allowMultiple"
              v-model="selectedListValue"
              :items="selectedCustomField.listOfValues"
              @change="validateRequirementForm()"
              label="Available Values"
              item-text="name"
              return-object
            ></v-select>
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
              v-else-if="newRequirement.operatorTypeId && newRequirement.processStepRequirementTypeId === 7"
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
                {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
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
            <div v-if="newRequirement.processStepRequirementTypeId === 7 && newRequirement.operatorTypeId">
              <label>Fail if no
                <strong>{{parent.processStepName}}</strong> steps are found:</label>
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
                        <v-text-field
                          v-if="fp.dataTypeId === 1"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter a date"
                          type="date"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                        <v-text-field
                          v-if="fp.dataTypeId === 2"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter a timestamp"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                        <v-text-field
                          v-if="fp.dataTypeId === 3"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter a boolean"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                        <v-text-field
                          v-if="fp.dataTypeId === 4"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter a number"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                        <v-text-field
                          v-if="fp.dataTypeId === 6"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter an integer"
                          type="number"
                          step="1"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                        <v-text-field
                          v-else
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          placeholder="Enter a dynamic value"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                      </div>
                    </v-card>
                  </div>
                  <v-select attach v-model="item.operatorTypeId"
                            :items="operatorTypes"
                            class="one-hunned"
                            label="Operator"
                            :readonly="newRequirement.operatorTypeId === 5 && selectedCustomField.dataTypeId === 7 || item.immutable || !userCanEdit"
                            :disabled="newRequirement.operatorTypeId === 5 && selectedCustomField.dataTypeId === 7 || item.immutable || !userCanEdit"
                            item-text="operatorType"
                            @change="operatorDataTypeCheck(item)"
                            item-value="id"
                  ></v-select>
                  <v-switch v-model="item.customValue"
                            class="mx-2"
                            :readonly="(item.dataTypeId === 7) || item.dataTypeId === 3 || !userCanEdit || item.processStepRequirementTypeId === 7"
                            :disabled="(item.dataTypeId === 7) || item.dataTypeId === 3 || item.immutable  || !userCanEdit || item.processStepRequirementTypeId === 7"
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
                    v-else-if="item.customValue && item.customField && item.processStepRequirementTypeId !== 7
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
                    v-else-if="item.operatorTypeId && item.processStepRequirementTypeId === 7"
                    v-model="item.listOfValues"
                    :items="item.availableListOfValues"
                    label="Available Values"
                    multiple
                    attach
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
                  <div v-if="item.processStepRequirementTypeId === 7 && item.operatorTypeId">
                    <label>Fail if no
                      <strong>{{item.referenceProcessStepName}}</strong> steps are found:</label>
                    <input type="checkbox" class="ml-3 mb-4" v-model="item.failIfNoReferenceStepFound"
                           :readonly="!userCanEdit"
                           :disabled="!userCanEdit">
                  </div>
                  <v-btn v-if="userCanEdit" @click="updateRequirement(item)">
                    <v-icon>save</v-icon>
                    Save
                  </v-btn>
                </td>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left" style="width: 65px">{{item.requirementNbr}}</td>
                  <td class="text-left">{{item.processStepRequirementType}}</td>
                  <td class="text-left">
                    <span v-if="item.processStepRequirementTypeId === 1">
                      {{ item.parentName }} | {{ item.fieldName }}
                    </span>
                    <span v-else-if="item.processStepRequirementTypeId === 2">
                      {{ item.companyFunctionName }}
                    </span>
                    <span v-else-if="item.processStepRequirementTypeId === 7">
                      {{ item.referenceProcessStepName }}
                    </span>
                    <span v-else>
                      {{ item.fieldName }}
                    </span>
                  </td>
                  <td class="text-left">{{item.operatorType}}</td>
                  <td class="text-left">
                    <span v-if="item.requirementValue">
                      {{item.requirementValue}}
                    </span>
                    <span v-else-if="item.dataTypeRequirementId">
                      {{item.dataTypeRequirement ? item.dataTypeRequirement.dataTypeValue : 'unknown'}} {{item.secondaryRequirementValue}}
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
                      <v-btn small text @click="[expanded = [item], loadOperatorTypes(item.dataTypeId, item.processStepRequirementTypeId),
                                    loadDataTypeRequirements(item.dataTypeId), selectedRequirementIndex = index]"
                             v-if="!expanded.includes(item)">
                        <v-icon v-if="item.immutable">expand_more</v-icon>
                        <v-icon v-else>edit</v-icon>
                      </v-btn>
                      <v-btn small text @click="[expanded = [], selectedRequirementIndex = index]"
                             v-if="expanded.includes(item)">cancel
                      </v-btn>
                      <v-dialog
                        v-if="userCanEdit"
                        v-model="item.deleteConfirm"
                        width="500">
                        <template #activator="{ on }">
                          <v-btn small text v-on="on">
                            <v-icon>delete</v-icon>
                          </v-btn>
                        </template>
                        <v-card>
                          <v-card-title
                            class="headline grey lighten-2"
                            primary-title>
                            Confirm
                          </v-card-title>

                          <v-card-text class="pt-4">
                            Are you sure you want to delete this requirement?
                          </v-card-text>

                          <v-divider></v-divider>

                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                              @click="item.deleteConfirm = false">
                              No
                            </v-btn>
                            <v-btn
                              color="primaryCustom"
                              text
                              @click="deleteRequirement(item)">
                              Yes
                            </v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>
                    </div>
                  </td>
                </tr>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
      <v-divider></v-divider>
      <v-row>
        <v-col cols="12">
          <v-toolbar flat class="action-header-bar">
            <v-toolbar-title class="app-title">Actions</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn @click="addNewAction = !addNewAction" text v-if="userCanAdd">
                <v-icon v-if="!addNewAction">add</v-icon>
                {{ addNewAction ? 'Cancel' : 'Add Action'}}
              </v-btn>
              <v-btn text @click="expandActions = !expandActions">
                <v-icon v-if="!expandActions">mdi-chevron-down</v-icon>
                <v-icon v-else>mdi-chevron-up</v-icon>
              </v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card flat class="mb-3 mx-3" v-if="addNewAction">
            <v-text-field v-model="newAction.actionName"
                          placeholder="Enter a name"
                          label="Action Name">
            </v-text-field>
            <v-select attach v-model="newAction.actionTypeId"
                      :items="actionTypes"
                      label="Action Type"
                      item-text="actionType"
                      item-value="id"
            ></v-select>
            <v-select attach v-model="newAction.companyProcessStepStatusTypeId"
                      :items="statusTypes"
                      :clearable="true"
                      label="Action changes status of parent process step to"
                      item-text="processStepStatusType"
                      item-value="id"
            ></v-select>
            <v-select attach v-model="newAction.companyProjectStatusTypeId"
                      :items="companyProjectStatusTypes"
                      :clearable="true"
                      label="Action changes project status to"
                      item-text="projectStatusType"
                      item-value="id"
            ></v-select>
            <v-checkbox
              dense
              hide-details
              :readonly="!userCanEdit"
              :disabled="!userCanEdit"
              v-model="newAction.removeProcessStepOwner"
              label="Clear Process Step Owner"
            />
            <v-checkbox
              dense
              hide-details
              v-model="newAction.multipleUses"
              @change="newAction.triggerAutomatically = false"
              label="Allow Multiple Uses"
            />
            <v-checkbox
              dense
              hide-details
              v-model="newAction.hideFromMobile"
              label="Hide From Mobile"
            />
            <v-checkbox
              dense
              hide-details
              v-model="newAction.hideFromWeb"
              label="Hide From Web"
            />
            <v-checkbox
              dense
              hide-details
              v-model="newAction.triggerAutomatically"
              @change="newAction.multipleUses = false"
              label="Trigger Automatically"
            />
            <v-checkbox
              class="pl-3 pt-0"
              dense
              v-if="newAction.triggerAutomatically"
              hide-details
              v-model="newAction.timeBasedTrigger"
              label="Time Based"
            />
            <v-btn v-if="newAction.actionName && newAction.actionTypeId"
                   @click="saveNewAction">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-card>
          <v-card flat v-if="expandActions">
            <v-data-table
              :headers="actionHeaders"
              :items="filterActions()"
              :items-per-page="-1"
              single-expand
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              :mobile-breakpoint="0"
              :expanded.sync="actionExpanded"
              hide-default-footer
              class="action-table elevation-1 fix-column-width-bug"
            >
              <template #no-data>
                No actions for this process step
              </template>

              <template #no-results>
                No actions for this process step
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="actionHeaders.length" class="pb-4" :class="{'shaded-row': selectedActionIndex % 2}">
                  <v-card flat class="text-left pt-3 px-3" color="transparent">
                    <v-text-field v-model="item.actionName"
                                  placeholder="Enter a name"
                                  :readonly="!userCanEdit"
                                  :disabled="!userCanEdit"
                                  label="Action Name">
                    </v-text-field>
                    <v-select attach v-model="item.actionTypeId"
                              :items="actionTypes"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              label="Action Type"
                              item-text="actionType"
                              item-value="id"
                    ></v-select>
                    <v-select attach v-model="item.companyProcessStepStatusTypeId"
                              :items="statusTypes"
                              :clearable="userCanEdit"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              label="Action changes status of parent process step to"
                              item-text="processStepStatusType"
                              item-value="id"
                    ></v-select>
                    <v-select attach v-model="item.companyProjectStatusTypeId"
                              :items="companyProjectStatusTypes"
                              :clearable="true"
                              label="Action changes project status to"
                              item-text="projectStatusType"
                              item-value="id"
                    ></v-select>
                    <v-checkbox
                      dense
                      hide-details
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      v-model="item.removeProcessStepOwner"
                      label="Clear Process Step Owner"
                    />
                    <v-checkbox
                      dense
                      hide-details
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      v-model="item.multipleUses"
                      @change="item.triggerAutomatically = false"
                      label="Allow Multiple Uses"
                    />
                    <v-checkbox
                      dense
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      hide-details
                      v-model="item.hideFromMobile"
                      label="Hide From Mobile"
                    />
                    <v-checkbox
                      dense
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      hide-details
                      v-model="item.hideFromWeb"
                      label="Hide From Web"
                    />
                    <v-checkbox
                      dense
                      hide-details
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      v-model="item.triggerAutomatically"
                      @change="item.multipleUses = false"
                      label="Trigger Automatically"
                    />
                    <v-checkbox
                      class="pl-3 pt-0 pb-3"
                      dense
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      v-if="item.triggerAutomatically"
                      hide-details
                      v-model="item.timeBasedTrigger"
                      label="Time Based"
                    />

                    <!-- LINK -->
                    <div v-if="item.actionTypeId === 1">
                      <v-divider></v-divider>
                      <v-toolbar flat color="transparent">
                        <v-toolbar-title class="app-title">
                          Child Links
                        </v-toolbar-title>
                        <v-spacer></v-spacer>
                        <v-toolbar-items>
                          <v-btn v-if="!addChildLink && userCanEdit"
                                 @click="[addChildLink = true, loadLinks(item.id)]">
                            <v-icon>add</v-icon>
                          </v-btn>
                        </v-toolbar-items>
                      </v-toolbar>
                      <v-card class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                              v-if="addChildLink">
                        <h3>Add Child Link</h3>
                        <v-select attach v-model="selectedLink"
                                  :items="availableLinks"
                                  label="Available Links"
                                  item-text="link"
                                  return-object
                                  @input="saveLinkToAction(item)"
                        ></v-select>
                        <v-btn @click="addChildLink = false">
                          <v-icon>remove</v-icon>
                          Cancel
                        </v-btn>
                      </v-card>
                    </div>
                  </v-card>
                  <!-- @randa - move requirements to their own component. it is confusing having them in this file -->

                  <v-row justify="center" class="pl-3 pr-3"
                         v-if="item.actionTypeId === 1 && item.processStepActionLinks && item.processStepActionLinks.length > 0">
                    <v-col cols="12">
                      <v-list v-for="(al, index) in filterBy(item.processStepActionLinks, false, 'archived')"
                              :key="index"
                              :class="{ 'shaded-row': index % 2 }">
                        <v-list-item>
                          <v-list-item-content class="text-left">
                            {{al.link}}
                          </v-list-item-content>
                          <v-dialog
                            v-if="userCanEdit"
                            v-model="al.deleteConfirm"
                            width="500">
                            <template v-slot:activator="{ on }">
                              <v-list-item-action class="clickable" v-on="on">
                                <v-icon>delete</v-icon>
                              </v-list-item-action>
                            </template>
                            <v-card>
                              <v-card-title
                                class="headline grey lighten-2"
                                primary-title
                              >
                                Confirm
                              </v-card-title>

                              <v-card-text>
                                Are you sure you want to delete <strong>{{ al.link }}</strong> from <strong>{{
                                item.actionName }}</strong>?
                              </v-card-text>

                              <v-divider></v-divider>

                              <v-card-actions>
                                <v-spacer></v-spacer>
                                <v-btn
                                  @click="al.deleteConfirm = false">
                                  No
                                </v-btn>
                                <v-btn
                                  color="primaryCustom"
                                  text
                                  @click="[al.archived = true, deleteLinkFromAction(item.id, al.id)]">
                                  Yes
                                </v-btn>
                              </v-card-actions>
                            </v-card>
                          </v-dialog>
                        </v-list-item>
                      </v-list>
                    </v-col>
                  </v-row>
                  <!-- BUTTON -->
                  <div v-if="item.actionTypeId === 2">
                    <v-divider></v-divider>
                    <v-toolbar flat color="transparent">
                      <v-toolbar-title class="app-title">
                        Child Process Steps
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                        <v-btn text v-if="!addChildProcess && userCanAdd"
                               @click="[addChildProcess = true, loadChildProcessSteps(item.id)]">
                          <v-icon>add</v-icon>
                        </v-btn>
                      </v-toolbar-items>
                    </v-toolbar>
                    <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                            v-if="addChildProcess">
                      <h3>Add Child Process Step</h3>
                      <v-autocomplete v-model="newChildProcessStep.processStepId"
                                      :items="childProcessSteps"
                                      label="Process Step"
                                      @input="[getCancelledStatuses(newChildProcessStep), getStatusesAssignedToStep(newChildProcessStep)]"
                                      item-text="processStepName"
                                      item-value="id"
                                      attach
                      ></v-autocomplete>
                      <v-autocomplete v-model="newChildProcessStep.initialCompanyProcessStepStatusTypeId"
                                      :items="activeStatusesAssignedToStep"
                                      label="Set initial status to:"
                                      item-text="processStepStatusType"
                                      item-value="id"
                                      attach
                      >
                        <template slot="item" slot-scope="data">
                          {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                        </template>
                      </v-autocomplete>
                      <v-autocomplete v-model="newChildProcessStep.existingCompanyProcessStepStatusTypeId"
                                      :items="cancelledCompanyStatuses"
                                      label="Set status of existing Active steps of the same type to:"
                                      item-text="processStepStatusType"
                                      item-value="id"
                                      attach
                      >
                        <template slot="item" slot-scope="data">
                          {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                        </template>
                      </v-autocomplete>
                      <div class="mt-3">
                        <v-btn :disabled="!newChildProcessStep.processStepId || !newChildProcessStep.existingCompanyProcessStepStatusTypeId || !newChildProcessStep.initialCompanyProcessStepStatusTypeId"
                               @click="saveProcessStepToAction(item)">
                          <v-icon>save</v-icon>
                          Save
                        </v-btn>
                        <v-btn class="ml-3" @click="[addChildProcess = false, newChildProcessStep = {}]">
                          <v-icon>remove</v-icon>
                          Cancel
                        </v-btn>
                      </div>
                    </v-card>
                  </div>
                  <v-row justify="center" class="pl-3 pr-3"
                         v-if="item.actionTypeId === 2 && item.processStepActionChildProcesses && item.processStepActionChildProcesses.length > 0">
                    <v-col cols="12" class="pt-0">
                      <v-data-table
                        :headers="childProcessStepHeaders"
                        :items="filterItems(item.processStepActionChildProcesses)"
                        :fixed-header="true"
                        :items-per-page="100"
                        hide-default-footer
                        disable-sort
                        single-expand
                        :expanded.sync="cpExpanded"
                        class="elevation-1"
                      >

                        <template #expanded-item="{ headers, item:cp }">
                          <tr>
                            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': item.processStepActionChildProcesses.indexOf(cp) % 2}">
                              <v-autocomplete v-model="cp.initialCompanyProcessStepStatusTypeId"
                                              :items="activeStatusesAssignedToStep"
                                              label="Set initial status as:"
                                              item-text="processStepStatusType"
                                              item-value="id"
                                              attach
                              ></v-autocomplete>
                              <v-autocomplete v-model="cp.existingCompanyProcessStepStatusTypeId"
                                              :items="cancelledCompanyStatuses"
                                              label="Set status of existing Active steps of the same type to:"
                                              item-text="processStepStatusType"
                                              item-value="id"
                                              attach
                              ></v-autocomplete>
                              <v-btn color="primaryCustom" class="white--text"
                                     :disabled="!cp.existingCompanyProcessStepStatusTypeId || !cp.initialCompanyProcessStepStatusTypeId"
                                     @click="saveChildProcessCancelledStatus(item, cp)">Save Changes</v-btn>
                            </td>
                          </tr>
                        </template>

                        <template #item="{ item:cp, index }">
                          <tr :class="{'shaded-row': index % 2}">
                            <td class="text-left">{{cp.processStepName}}</td>
                            <td class="text-left">{{cp.initialProcessStepStatusType}}</td>
                            <td class="text-left">{{cp.existingProcessStepStatusType}}</td>
                            <td class="text-right">
                              <v-btn text v-if="!cpExpanded.includes(cp)" @click="[ cpExpanded = [cp], getStatusesAssignedToStep(cp), getCancelledStatuses(cp)]">
                                <v-icon>edit</v-icon>
                              </v-btn>
                              <v-btn small text v-if="cpExpanded.includes(cp)" @click="cpExpanded = []">cancel</v-btn>
                              <v-dialog v-if="userCanEdit" v-model="cp.deleteConfirm" width="500">
                                <template v-slot:activator="{ on }">
                                  <v-btn text v-on="on">
                                    <v-icon>delete</v-icon>
                                  </v-btn>
                                </template>
                                <v-card>
                                  <v-card-title
                                    class="headline grey lighten-2"
                                    primary-title
                                  >
                                    Confirm
                                  </v-card-title>

                                  <v-card-text>
                                    Are you sure you want to delete <strong>{{ cp.processStepName }}</strong> from
                                    <strong>{{
                                      item.actionName }}</strong>?
                                  </v-card-text>

                                  <v-divider></v-divider>

                                  <v-card-actions>
                                    <v-spacer></v-spacer>
                                    <v-btn
                                      @click="cp.deleteConfirm = false">
                                      No
                                    </v-btn>
                                    <v-btn
                                      color="primaryCustom"
                                      text
                                      @click="[cp.archived = true, deleteChildProcessFromAction(item.id, cp.id)]">
                                      Yes
                                    </v-btn>
                                  </v-card-actions>
                                </v-card>
                              </v-dialog>
                            </td>

                          </tr>
                        </template>
                      </v-data-table>

                    </v-col>
                  </v-row>
                  <!-- FUNCTIONS CAN ONLY BE ADDED TO BUTTONS -->
                  <div v-if="item.actionTypeId === 2">
                    <v-divider></v-divider>
                    <v-toolbar flat color="transparent">
                      <v-toolbar-title class="app-title">
                        Child Functions
                      </v-toolbar-title>
                      <v-spacer></v-spacer>
                      <v-toolbar-items>
                        <v-btn text v-if="!addChildFunction && userCanAdd"
                               @click="[addChildFunction = true, loadChildFunctions(item.id)]">
                          <v-icon>add</v-icon>
                        </v-btn>
                      </v-toolbar-items>
                    </v-toolbar>
                    <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                            v-if="addChildFunction">
                      <h3>Add Child Function</h3>
                      <v-autocomplete v-model="selectedChildFunction"
                                      :items="childFunctions"
                                      label="Function"
                                      item-text="companyFunctionName"
                                      return-object
                                      attach
                                      @input="loadFunctionParams(selectedChildFunction.dbFunctionId, false)"
                      ></v-autocomplete>
                      <div v-if="selectedChildFunction.id && selectedChildRequirementParamDynamicValues.length > 0">
                        <h5 class="text-left">Dynamic Function Parameters</h5>
                        <v-card flat color="transparent">
                          <div v-for="(fp, index) in selectedChildRequirementParamDynamicValues">
                            <v-text-field
                              v-if="fp.dataTypeId === 4 || fp.dataTypeId === 6"
                              type="number"
                              :key="index"
                              placeholder="Enter a dynamic value (number)"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></v-text-field>
                            <v-text-field
                              v-else
                              :key="index"
                              placeholder="Enter a dynamic value"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></v-text-field>
                          </div>
                        </v-card>
                      </div>
                      <div class="mt-3">
                        <v-btn :disabled="!selectedChildFunction.id"
                               @click="saveFunctionToAction(item)">
                          <v-icon>save</v-icon>
                          Save
                        </v-btn>
                        <v-btn class="ml-3" @click="addChildFunction = false">
                          <v-icon>remove</v-icon>
                          Cancel
                        </v-btn>
                      </div>
                    </v-card>
                  </div>
                  <v-row justify="center" class="pl-3 pr-3"
                         v-if="item.actionTypeId === 2 && item.processStepActionChildFunctions && item.processStepActionChildFunctions.length > 0">
                    <v-col cols="12" class="pt-0">
                      <v-list v-for="(cp, index) in filterBy(item.processStepActionChildFunctions, false, 'archived')"
                              :key="index"
                              :class="{ 'shaded-row': index % 2 }">
                        <v-list-item>
                          <v-list-item-content class="text-left">
                            <v-list-item-title>{{cp.companyFunctionName}}</v-list-item-title>
                            <div class="mt-2"
                                 v-if="cp.actionParamDynamicValues && cp.actionParamDynamicValues.length > 0">
                              <h5 class="text-left">Dynamic Function Parameters</h5>
                              <v-card flat color="transparent">
                                <div v-for="(fp, index) in cp.actionParamDynamicValues" :key="index">
                                  <v-text-field
                                    v-if="fp.dataTypeId === 1"
                                    placeholder="Enter a date"
                                    type="date"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-if="fp.dataTypeId === 2"
                                    placeholder="Enter a timestamp"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-if="fp.dataTypeId === 3"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a boolean"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-if="fp.dataTypeId === 4"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a number"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-if="fp.dataTypeId === 6"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter an integer"
                                    type="number"
                                    step="1"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-else
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a dynamic value"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                </div>
                              </v-card>
                            </div>
                            <v-list-item-subtitle>
                              <v-btn color="primaryCustom" class="white--text" v-if="cp.edit && userCanEdit"
                                     @click="updateChildFunction(item.id, cp)">
                                Save
                              </v-btn>
                            </v-list-item-subtitle>
                          </v-list-item-content>
                          <v-btn text color="primaryCustom" class="white--text" v-if="userCanEdit"
                                 @click="cp.edit = !cp.edit">
                            <v-icon v-if="cp.edit">remove</v-icon>
                            <v-icon v-else>edit</v-icon>
                          </v-btn>
                          <v-dialog
                            v-if="userCanEdit"
                            v-model="cp.deleteConfirm"
                            width="500">
                            <template v-slot:activator="{ on }">
                              <v-list-item-action class="clickable" v-on="on">
                                <v-icon>delete</v-icon>
                              </v-list-item-action>
                            </template>
                            <v-card>
                              <v-card-title
                                class="headline grey lighten-2"
                                primary-title
                              >
                                Confirm
                              </v-card-title>

                              <v-card-text>
                                Are you sure you want to delete <strong>{{ cp.functionName }}</strong> from <strong>{{
                                item.actionName }}</strong>?
                              </v-card-text>

                              <v-divider></v-divider>

                              <v-card-actions>
                                <v-spacer></v-spacer>
                                <v-btn
                                  @click="cp.deleteConfirm = false">
                                  No
                                </v-btn>
                                <v-btn
                                  color="primaryCustom"
                                  text
                                  @click="[cp.archived = true, deleteChildFunctionFromAction(item.id, cp.id)]">
                                  Yes
                                </v-btn>
                              </v-card-actions>
                            </v-card>
                          </v-dialog>
                        </v-list-item>
                      </v-list>
                    </v-col>
                  </v-row>
                  <v-divider class="mt-2"></v-divider>
                  <v-toolbar flat dense color="transparent">
                    <v-toolbar-title class="app-title">Current Logic</v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items
                      v-if="((item.processStepLogicList && item.processStepLogicList.length > 0) || item.alwaysEnabled) && userCanEdit">
                      <v-btn text
                             @click="[item.logicListChanged = true, item.processStepLogicList = [], item.alwaysEnabled = false]">
                        <v-icon>clear</v-icon>
                        Clear All
                      </v-btn>
                    </v-toolbar-items>
                  </v-toolbar>
                  <v-card flat class="text-left px-3" color="transparent">
                    <v-btn small class="ml-1 mr-1 mt-1"
                           :disabled="!userCanEdit"
                           v-for="(l, index) in filterBy(item.processStepLogicList, false, 'archived')" :key="index"
                           @click="[l.archived = true, item.logicListChanged = true]">
                      {{l.processStepRequirementId ? l.requirementNbr : l.operationType}}
                    </v-btn>
                    <v-btn small class="ml-1 mr-1 mt-1" v-if="item.alwaysEnabled"
                           :disabled="!userCanEdit"
                           @click="[item.logicListChanged = true, item.alwaysEnabled = !item.alwaysEnabled]">
                      Always Enabled
                    </v-btn>
                  </v-card>
                  <v-toolbar flat dense color="transparent">
                    <v-toolbar-title class="app-title">Available Operations</v-toolbar-title>
                  </v-toolbar>
                  <v-card flat class="text-left px-3" color="transparent">
                    <v-btn small class="ml-1 mr-1 mt-1" v-for="(ot, index) in operationTypes" :key="index"
                           :disabled="!userCanEdit"
                           @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})]">
                      {{ot.operationType}}
                    </v-btn>
                    <v-btn small class="ml-1 mr-1 mt-1"
                           :disabled="!userCanEdit"
                           @click="[item.logicListChanged = true, item.processStepLogicList = [], item.alwaysEnabled = true]">
                      Always Enabled
                    </v-btn>
                  </v-card>
                  <v-toolbar flat dense color="transparent">
                    <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
                  </v-toolbar>
                  <v-card flat class="text-left mb-4 px-3" color="transparent">
                    <v-btn small class="ml-1 mr-1 mt-1" v-for="r in requirements" :key="r.id"
                           :disabled="!userCanEdit"
                           @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({ requirementNbr: r.requirementNbr, processStepRequirementId: r.id, archived: false })]">
                      {{r.requirementNbr}}
                    </v-btn>
                  </v-card>
                  <v-divider></v-divider>
                  <div v-if="actionLogicError" class="error-text ml-3 mt-3">
                    <strong>* ERROR: </strong>{{ actionLogicErrorMsg }}
                  </div>
                  <v-btn v-if="userCanEdit" @click="validateActionLogicString(item, true)" class="mt-4 ml-3">
                    <v-icon class="mr-2">save</v-icon>
                    Save Changes
                  </v-btn>
                </td>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': actions.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <v-btn text v-if="userCanEdit" icon small class="handle">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">{{item.actionName}}</td>
                  <td class="text-left">{{item.actionType}}</td>
                  <td class="text-left">{{item.processStepStatusType || 'N/A'}}</td>
                  <td class="text-left">{{item.projectStatusType || 'N/A'}}</td>
                  <td>
                    <div style="display: flex; float: right;">
                      <v-btn small text @click="[validateActionLogicString(item), actionExpanded = [item], selectedActionIndex = index]"
                             v-if="!actionExpanded.includes(item)">
                        <v-icon>edit</v-icon>
                      </v-btn>
                      <v-btn small text @click="[actionExpanded = [], selectedActionIndex = index]"
                             v-if="actionExpanded.includes(item)">cancel
                      </v-btn>
                      <v-dialog
                        v-if="userCanEdit"
                        v-model="item.deleteConfirm"
                        width="500">
                        <template #activator="{ on }">
                          <v-btn small text v-on="on">
                            <v-icon>delete</v-icon>
                          </v-btn>
                        </template>
                        <v-card>
                          <v-card-title
                            class="headline grey lighten-2"
                            primary-title>
                            Confirm
                          </v-card-title>

                          <v-card-text>
                            Are you sure you want to delete this action?
                          </v-card-text>

                          <v-divider></v-divider>

                          <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn
                              @click="item.deleteConfirm = false">
                              No
                            </v-btn>
                            <v-btn
                              color="primaryCustom"
                              text
                              @click="[item.archived = true, deleteAction(item)]">
                              Yes
                            </v-btn>
                          </v-card-actions>
                        </v-card>
                      </v-dialog>
                    </div>
                  </td>
                </tr>
              </template>

            </v-data-table>
          </v-card>
        </v-col>
      </v-row>

    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import {AppMutations} from '@/stores/AppStore'
  import cloneDeep from 'lodash.clonedeep'
  import {getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
  import {getActiveAssignedToProcessStep, getAssignedToProcessStep, getCancelledCompanyStatusTypesAssignedToProcessStep} from '@/services/processStepStatusTypeService'
  import {
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getRequestWithParams,
    getSnackbar
  } from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'
  import Sortable from "sortablejs";

  export default {
    name: 'ProcessStepActions',
    mixins: [Vue2Filters.mixin],

    mounted() {
      let table = document.querySelector('.action-table tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({newIndex, oldIndex}) {
          const rowSelected = _self.actions.splice(oldIndex, 1)[0]
          _self.actions.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.actions)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if (save) {
              _self.actions[idx].newDisplayOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      })
    },
    data() {
      return {
        snackbar: {},
        expandRequirements: true,
        expandActions: true,
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
        actionHeaders: [
          {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
          {text: 'Name', value: 'actionName', show: true},
          {text: 'Type', value: 'actionType', show: true},
          {text: 'Parent Status Change', value: 'processStepStatusType', show: true},
          {text: 'Project Status Change', value: 'projectStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        childProcessStepHeaders: [
          {text: 'Child Step', value: 'processStepName', show: true},
          {text: 'Initial Status', value: 'initialProcessStepStatusType', show: true},
          {text: 'Status for any Existing Active', value: 'existingProcessStepStatusType', show: true},
          {text: null, value: 'icons', show: true}
        ],
        addNewRequirement: false,
        newRequirement: {
          requirementParamDynamicValues: [],
          customValue: false
        },
        dataTypeRequirements: [],
        selectedDataTypeRequirement: {},
        selectedCustomField: {},
        listOfValues: [],
        selectedListOfValues: [],
        selectedListValue: {},
        selectedFunction: {},
        selectedRequirementIndex: null,
        selectedActionIndex: null,
        availableRequirementTypes: [],
        processStepId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        parentObjects: [],
        parent: {},
        customFields: [],
        operatorTypes: [],
        operationTypes: [],
        selectedProcessStepStatus: {},
        processStepStatuses: [],

        requirements: [],
        availableFunctions: [],


        addNewAction: false,
        newAction: {},
        actions: [],
        statusTypes: [],
        companyProjectStatusTypes: [],
        expanded: [],
        cpExpanded: [],
        actionExpanded: [],
        //todo: get these from endpoint but i am lazy right now
        actionTypes: [
          {id: 1, actionType: 'Link'},
          {id: 2, actionType: 'Button'}
        ],
        addChildProcess: false,
        addChildFunction: false,
        actionLogicError: false,
        actionLogicErrorMsg: '',
        newChildProcessStep: {},
        cancelledCompanyStatuses: [],
        activeStatusesAssignedToStep: [],
        selectedChildFunction: {},
        selectedChildRequirementParamDynamicValues: [],

        childProcessSteps: [],
        childFunctions: [],
        addChildLink: false,
        selectedLink: {},
        availableLinks: [],

        //action logic string stuff
        invalidTypeCombos: [
          '1,2', // open and close paren next to each other
          '2,1', // close then open paren next to each other -- right, this isn't valid? `(8)(17)`
          '0,0', // two requirements right next to each other
          '3,4', // AND OR next to each other
          '1,3', // open paren then AND
          '1,4', // open paren then OR
          '5,2', // not then close paren
          '5,3', // not then and
          '5,4', // not then or
          '3,3', // and and
          '4,4', // or or
          '5,5', // not not
          '0,5', // requirement then not ...needs and/or in between
        ],
        //doing these as strings since the filtered list will be too
        invalidFirsts: ['2', '3', '4'],
        invalidLasts: ['1', '3', '4', '5']
      }
    },
    computed: {},
    async created() {
      this.getRequirements()
      this.getActions()
      this.getStatusTypes()
      this.getCompanyProjectStatusTypes()
      this.getOperationTypes()
    },
    methods: {
      //requirements
      async getRequirements() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/requirement`)
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
            const {data} = await getRequest(`/processStep/${this.processStepId}/requirement/types`)
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
          //1 == process step custom field, 2 == function, 3 == project custom field, 4 == contact custom field
          if (this.newRequirement.processStepRequirementTypeId === 1 || this.newRequirement.processStepRequirementTypeId === 7) {
            this.loadParentObjects()
          } else if (this.newRequirement.processStepRequirementTypeId === 3) {
            //get project custom fields
            this.loadCustomFieldsByObjectType(1)
          } else if (this.newRequirement.processStepRequirementTypeId === 4) {
            //get contact custom fields
            this.loadCustomFieldsByObjectType(2)
          } else {
            const {data} = await getRequest(`/function/requirement`)
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
      async loadChildFunctions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/function/action`)
          this.childFunctions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
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
        if(this.newRequirement?.processStepRequirementTypeId === 1) {
          await this.loadFieldsByParent(parent)
        } else if (this.newRequirement?.processStepRequirementTypeId === 7) {
          this.newRequirement.customValue = true
          await this.getStatusesAssignedToProcessStep(parent)
          //this 7 = data type for multi select
          await this.loadOperatorTypes(7, 7)
        }
      },
      async getStatusesAssignedToProcessStep(parent) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getAssignedToProcessStep(parent.id)
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
      async loadFieldsByParent(parent) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customField/getByParentProcessStep/${parent.id}`)
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
          const {data} = await getRequest(`/customField/getByParentType/${objectTypeId}`)
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
          if(processStepRequirementTypeId === 7) {
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
            if(this.newRequirement.processStepRequirementTypeId === 7) {
              this.newRequirement.listOfValueIds = this.selectedListOfValues.map(v => v.id)
              this.newRequirement.referenceProcessStepId = this.parent.id
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

          const {data} = await postRequest(`/processStep/${this.processStepId}/requirement`, this.newRequirement)
          this.requirements.push(data)
          this.selectedCustomField = {}
          this.selectedListOfValues = []
          this.selectedListValue = {}
          this.addNewRequirement = false
          this.newRequirement = {
            requirementParamDynamicValues: []
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

          const {data} = await putRequest(`/processStep/${this.processStepId}/requirement`, requirement)
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
      async deleteRequirement(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/processStep/${this.processStepId}/requirement/${item.id}`)
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
      },
      //ACTIONS
      filterItems(items) {
        return items.filter(i => !i.archived)
      },
      async getStatusesAssignedToStep(item) {
        this.activeStatusesAssignedToStep = []
        try {
          const {data} = await getActiveAssignedToProcessStep(item.processStepId)
          this.activeStatusesAssignedToStep = data
          if (data?.length === 1) {
            item.initialCompanyProcessStepStatusTypeId = data[0].id
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getCancelledStatuses(item) {
        this.cancelledCompanyStatuses = []
        try {
          const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(item.processStepId)
          this.cancelledCompanyStatuses = data
          if (data?.length === 1) {
            item.existingCompanyProcessStepStatusTypeId = data[0].id
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching process step statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getActions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/action`)
          this.actions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterActions() {
        return this.actions.filter(a => {
          return !a.archived
        })
      },
      async saveNewAction() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if (!this.newAction.triggerAutomatically) {
            //if they unset the trigger automatically flag, then unset the timeBasedTrigger too.  has to be both to be time based
            this.newAction.timeBasedTrigger = false
          }
          this.newAction.processStepId = this.processStepId
          const {data} = await postRequest(`/processStep/${this.processStepId}/action`, this.newAction)
          this.actions.push(data)
          this.addNewAction = false
          this.newAction = {}
          this.snackbar = getSnackbar('SUCCESS', 'Action Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          action.processStepLogicList = action.processStepLogicList.filter(l => {
            return !l.archived
          })
          if (!action.triggerAutomatically) {
            //if they unset the trigger automatically flag, then unset the timeBasedTrigger too.  has to be both to be time based
            action.timeBasedTrigger = false
          }

          // build the list of psr's that need to be set to immutable  do that if the save is successful
          const psrListToUpdate = action.processStepLogicList.filter(l => {
            return l.processStepRequirementId && !l.processStepRequirementImmutable
          })

          const {data} = await putRequest(`/processStep/${this.processStepId}/action`, action)
          // this forces the list to update the values displayed ... using action = data did not work
          action.actionType = data.actionType
          action.processStepStatusType = data.processStepStatusType
          action.processStepActionChildProcesses = data.processStepActionChildProcesses
          action.processStepActionLinks = data.processStepActionLinks
          action.processStepLogicList = data.processStepLogicList
          action.triggerAutomatically = data.triggerAutomatically
          this.actionExpanded = []

          //update the necessary psr's to immutable
          if (psrListToUpdate.length > 0) {
            psrListToUpdate.forEach(psr => {
              let match = this.requirements.find(r => r.id === psr.processStepRequirementId)
              match.immutable = true
            })
          }

          this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getAssignedToProcessStep(this.processStepId)
          this.statusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyProjectStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getCompanyProjectStatusTypes()
          this.companyProjectStatusTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOperationTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/operation`)
          this.operationTypes = orderBy(data, [o => o.operationType.toLowerCase()])
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAction(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      //child process steps
      async loadChildProcessSteps(actionId) {
        const {data} = await getRequest(`/processStep/${this.processStepId}/action/${actionId}/childProcessSteps`)
        this.childProcessSteps = data
      },
      async saveChildProcessCancelledStatus(action, cp) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/processStep/${this.processStepId}/action/${action.id}/child/${cp.id}/status`, {
            existingCompanyProcessStepStatusTypeId: cp.existingCompanyProcessStepStatusTypeId,
            initialCompanyProcessStepStatusTypeId: cp.initialCompanyProcessStepStatusTypeId,
          })
          this.cpExpanded = []
          cp.existingProcessStepStatusType = data.existingProcessStepStatusType
          cp.initialProcessStepStatusType = data.initialProcessStepStatusType
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Status Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Child Process Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveProcessStepToAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addChildStepToAction`, {
            processStepId: this.newChildProcessStep.processStepId,
            existingCompanyProcessStepStatusTypeId: this.newChildProcessStep.existingCompanyProcessStepStatusTypeId,
            initialCompanyProcessStepStatusTypeId: this.newChildProcessStep.initialCompanyProcessStepStatusTypeId,
            displayOrder: 0
          })
          action.processStepActionChildProcesses.push(data)
          this.newChildProcessStep = {}
          this.addChildProcess = false
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Added To Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Child Process Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteChildProcessFromAction(actionId, id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteChildStep/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Deleted From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Child Process From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      // async updateChildStep(actionId, childStep) {
      //   this.$store.commit(AppMutations.SET_LOADING, true)
      //   try {
      //     await putRequest(`/processStep/${this.processStepId}/action/${actionId}/updateActionChildStep`, childStep)
      //     this.snackbar = getSnackbar('SUCCESS', 'Child Process Updated')
      // this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   } catch (e) {
      //     console.error('*** ERROR ***', e)
      //     this.snackbar = getSnackbar('ERROR', 'Error Updating Child Process')
      // this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      //     this.$store.commit(AppMutations.SET_LOADING, false)
      //   }
      // },
      async saveFunctionToAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addChildFunctionToAction`, {
            companyFunctionId: this.selectedChildFunction.id,
            displayOrder: 0,
            actionParamDynamicValues: this.selectedChildRequirementParamDynamicValues
          })
          action.processStepActionChildFunctions.push(data)
          this.selectedChildFunction = {}
          this.selectedChildRequirementParamDynamicValues = []
          this.addChildFunction = false
          this.snackbar = getSnackbar('SUCCESS', 'Child Function Added To Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Child Function Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteChildFunctionFromAction(actionId, id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteChildFunction/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Child Function Deleted From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Child Function From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateChildFunction(actionId, childFunction) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/action/${actionId}/updateActionChildFunction`, childFunction)
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Child Process')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      // child links
      async loadLinks(actionId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/links/action/${actionId}`)
          this.availableLinks = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveLinkToAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addLinkToAction`, {
            linkId: this.selectedLink.id
          })
          action.processStepActionLinks.push(data)
          this.selectedLink = {}
          this.addChildLink = false
          this.snackbar = getSnackbar('SUCCESS', 'Link Added to Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Link to Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteLinkFromAction(actionId, id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteLinkFromAction/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Link Deleted From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link From Action')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getListValueName(item) {
        let idToUse = item.customSqlOptionId ? item.customSqlOptionId :
          item.systemListOptionId ? item.systemListOptionId : item.listOfValueId
        let match = item.availableListOfValues.find(i => i.id === idToUse)
        return match ? match.name : 'unknown'
      },
      async saveRowChanges(rows) {
        if (rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await putRequest(`/processStep/${this.processStepId}/action/order`, rows)
            this.snackbar = getSnackbar('SUCCESS', 'Action Order Saved')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Action Order')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      operatorDataTypeCheck(item) {
        // keeps multiselects using the right operator with the right lists.  i could probably do this better
        if (item) {
          if (item.operatorTypeId === 5 && item.dataTypeId === 7) {
            item.customValue = true
            item.dataTypeRequirement = {}
          } else if (item.dataTypeId === 7) {
            item.customValue = false
            item.listOfValues = []
            this.loadDataTypeRequirements(item.dataTypeId)
          }
        } else {
          if (this.newRequirement.operatorTypeId === 5 && this.selectedCustomField.dataTypeId === 7) {
            this.newRequirement.customValue = true
            this.selectedDataTypeRequirement = {}
          } else if (this.selectedCustomField.dataTypeId) {
            this.newRequirement.customValue = false
            this.selectedListOfValues = []
            let dataTypeToUse = this.newRequirement.processStepRequirementTypeId === 7 ? 7 : this.selectedCustomField.dataTypeId
            this.loadDataTypeRequirements(dataTypeToUse)
          }
        }
      },
      validateActionLogicString (item, saveChanges) {
        // using 0 to represent a logic item using a requirement
        // 1 = (  2 = )  3 = AND  4 = OR  5 = NOT

        //filter the logic list to exclude any archived
        let nonArchivedLogic = item.processStepLogicList?.filter(l => !l.archived)

        //compare number of open vs closing paren (probably not a perfect check but catches a lot)
        let countOpenParen = nonArchivedLogic?.filter(l => l.operationTypeId === 1)?.length
        let countCloseParen = nonArchivedLogic?.filter(l => l.operationTypeId === 2)?.length

        //get the type ids so we can loop through them and count parens as we go
        let operationTypeIds = nonArchivedLogic?.map(l => l.operationTypeId ?? 0)
        let openCount = 0, closeCount = 0, parenProblem = false

        //this part checks the parens more closely based on the order they appear in
        operationTypeIds?.forEach(id => {
          if(id === 1) {
            openCount++
          } else if (id === 2) {
            closeCount++
          }
          //after each id, check if close > open. if so, there is a problem
          if(closeCount > openCount) {
            parenProblem = true
          }
        })

        // turn the operation type ids into a string we can compare to invalid sequences
        let operationTypeString = operationTypeIds?.toString()

        // get the first and last operations to compare to invalid first and last options
        let firstOperationTypeId = operationTypeString?.charAt(0)
        let lastOperationTypeId = operationTypeString?.slice(-1)

        if(countOpenParen !== countCloseParen || parenProblem) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Logic is missing opening or closing parenthesis.'
        } else if ( this.invalidTypeCombos.some(v => operationTypeString?.includes(v)) ) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Logic is invalid.'
        } else if ( this.invalidFirsts.includes(firstOperationTypeId) ) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Invalid first logic operation.'
        } else if ( this.invalidLasts.includes(lastOperationTypeId) ) {
          this.actionLogicError = true
          this.actionLogicErrorMsg = 'Invalid last logic operation.'
        } else {
          this.actionLogicError = false
          this.actionLogicErrorMsg = ''
          if(saveChanges) {
            this.updateAction(item)
          }
        }


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

  .action-header-bar {
    border-top: 1px solid #E6E6E6;
    border-bottom: 1px solid #E6E6E6;
  }
</style>
