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

          <a-btn
              color="primary"
              variant="text"
              class=""
              @click="deleteError = false"
              text="Ok"
          ></a-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="title-large">Requirements</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                @click="[getRequirementTypes(), selectedDataTypeRequirement = {}]"
                variant="text"
                color="primary"
                id="qa-add-requirement-btn"
                v-if="userCanAdd"
                :prepend-icon="!addNewRequirement ? 'add' : 'close'"
                :text="$vuetify.breakpoint.smAndDown ? '' : addNewRequirement ? 'Cancel' : 'Add Requirement' "
            ></a-btn>
            <a-btn
                color="primary"
                variant="text"
                @click="expandRequirements = !expandRequirements"
                :prepend-icon="!expandRequirements ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewRequirement">
          <v-col cols="12">
            <!--  TODO: need to protect against bad data when they go back and change the requirement type but have already selected other values lower in the form      -->
            <a-select attach v-model="newRequirement.processStepRequirementTypeId"
                      :items="availableRequirementTypes"
                      label="Select Requirement Type"
                      item-value="id"
                      item-title="processStepRequirementType"
                      @input="[selectRequirementType(), parent = {}, selectedCustomField = {}, selectedDataTypeRequirement = {},
                              validateRequirementForm(), selectedDataView = {}, selectedDataViewField = {},
                              selectedFunction = {}, newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></a-select>
            <!--            show this for both custom fields AND statuses-->
            <a-autocomplete
                v-if="newRequirement.processStepRequirementTypeId && (newRequirement.processStepRequirementTypeId === 1 || newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8)"
                v-model="parent"
                :items="parentObjects"
                label="Parent Object"
                return-object
                item-title="processStepName"
                attach
                @input="[loadValues(parent), selectedCustomField = {}, selectedDataTypeRequirement = {},
                        validateRequirementForm(),
                        selectedFunction = {}, newRequirement.operatorTypeId = null,
                        newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></a-autocomplete>
            <!-- if it is a process step custom field it needs parent, other custom fields do not-->
            <a-autocomplete
                v-if="newRequirement.processStepRequirementTypeId && ((newRequirement.processStepRequirementTypeId === 1 && parent.id) || newRequirement.processStepRequirementTypeId === 3 || newRequirement.processStepRequirementTypeId === 4)"
                v-model="selectedCustomField"
                :items="customFields"
                label="Custom Field"
                return-object
                attach
                item-title="fieldName"
                @input="[loadOperatorTypes(selectedCustomField.dataTypeId), loadDataTypeRequirements(selectedCustomField.dataTypeId),
                              selectedDataTypeRequirement = {},
                              validateRequirementForm(),
                              selectedFunction = {}, newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></a-autocomplete>
            <a-autocomplete attach
                      v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 12"
                      v-model="selectedDataView"
                      :items="dataViews"
                      label="Select Data View"
                      item-value="id"
                      return-object
                      item-title="displayName"
                      @input="[getDataViewFields()]"
            ></a-autocomplete>
            <a-autocomplete
                v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 12 &&
                      selectedDataView.id != null && availableDataViewFields.length > 0"
                v-model="selectedDataViewField"
                :items="availableDataViewFields"
                label="Data View Field"
                return-object
                attach
                item-title="fieldName"
                @input="[loadOperatorTypes(selectedDataViewField.dataTypeId), loadDataTypeRequirements(selectedDataViewField.dataTypeId),
                              selectedDataTypeRequirement = {},
                              validateRequirementForm(),
                              selectedFunction = {}, newRequirement.operatorTypeId = null,
                              newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null]"
            ></a-autocomplete>
            <!-- if it is a function -->
            <a-autocomplete
                v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"
                v-model="selectedFunction"
                :items="availableFunctions"
                label="Function"
                item-title="companyFunctionName"
                returnObject
                @input="[loadFunctionParams(selectedFunction.dbFunctionId, true), loadOperatorTypes(selectedFunction.returnDataTypeId), loadDataTypeRequirements(selectedFunction.returnDataTypeId), validateRequirementForm()]"
            ></a-autocomplete>
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
                      <a-btn
                          variant="text"
                          class="d-inline-block"
                          v-bind="attrs"
                          :activation-handler="on"
                          color="unset"
                          prepend-icon="mdi-information"
                      ></a-btn>
                    </template>
                    <span>{{ fp.description }}</span>
                  </v-tooltip>
                  <div class="dynamic-field-container">
                    <a-text-field
                        v-if="fp.dataTypeId === 4 || fp.dataTypeId === 6"
                        :key="index"
                        type="number"
                        placeholder="Enter a dynamic value (number)"
                        v-model="fp.dynamicValue"
                        @input="validateRequirementForm()"
                        :label="fp.parameterName"></a-text-field>
                    <v-checkbox
                        v-else-if="fp.dataTypeId === 3"
                        :label="fp.parameterName"
                        :value-comparator="function (a, b) {
                                      return fp.dynamicValue === 'true'
                                    }"
                        :value="fp.dynamicValue === 'true'"
                        @change="changeBooleanValue($event, fp)"></v-checkbox>
                    <a-text-field
                        :key="index"
                        v-else
                        placeholder="Enter a dynamic value"
                        v-model="fp.dynamicValue"
                        @input="validateRequirementForm()"
                        :label="fp.parameterName"></a-text-field>
                  </div>
                </div>
              </v-card>
            </div>
            <a-select
                v-if="(newRequirement.processStepRequirementTypeId !== 2 && newRequirement.processStepRequirementTypeId !== 7 && selectedCustomField.customFieldGroupAssignmentId)
                      || (newRequirement.processStepRequirementTypeId === 2 && selectedFunction.id)
                      || (newRequirement.processStepRequirementTypeId === 12 && selectedDataViewField.id)
                      || ((newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8) && parent.id)
                      || [9,10,11].includes(newRequirement.processStepRequirementTypeId)"
                v-model="newRequirement.operatorTypeId"
                :items="operatorTypes"
                label="Operator"
                @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null, validateRequirementForm(), operatorDataTypeCheck()]"
                item-title="operatorType"
                item-value="id"
            ></a-select>
            <v-switch
                v-if="newRequirement.operatorTypeId"
                v-model="newRequirement.customValue"
                :readonly="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || [7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)"
                :disabled="(selectedCustomField.dataTypeId === 7) || selectedCustomField.dataTypeId === 3 || [7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)"
                @change="[newRequirement.requirementValue = null, selectedListValue = {}, selectedDataTypeRequirement = {}, newRequirement.secondaryRequirementValue = null, validateRequirementForm()]"
                class="mx-2"
                label="Custom"
            ></v-switch>
            <a-text-field
                v-if="newRequirement.operatorTypeId && newRequirement.customValue && ![7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)
                    && ((!selectedCustomField.listOfValueId || selectedCustomField.listOfValueId === null) && (!selectedCustomField.customFieldSql || selectedCustomField.customFieldSql === null) && (!selectedCustomField.companySystemListId || selectedCustomField.companySystemListId === null))"
                v-model="newRequirement.requirementValue"
                placeholder="Enter a value"
                @input="validateRequirementForm()"
                label="Value">
            </a-text-field>
            <a-select
                v-else-if="newRequirement.operatorTypeId
                              && newRequirement.customValue
                              && ![7,8,9,10,11].includes(newRequirement.processStepRequirementTypeId)
                              && ((selectedCustomField.listOfValueId && selectedCustomField.listOfValueId !== null) || (selectedCustomField.customFieldSql && selectedCustomField.customFieldSql !== null) || (selectedCustomField.companySystemListId && selectedCustomField.companySystemListId !== null))
                              && !selectedCustomField.allowMultiple"
                v-model="selectedListValue"
                :items="selectedCustomField.listOfValues"
                @change="validateRequirementForm()"
                label="Available Values"
                item-title="name"
                return-object
            ></a-select>
            <!-- if the requirement is event status -->
            <a-autocomplete
                v-else-if="newRequirement.operatorTypeId && newRequirement.processStepRequirementTypeId === 11"
                v-model="selectedListOfValues"
                :items="eventStatuses"
                label="Event Status"
                multiple
                attach
                @change="validateRequirementForm()"
                item-title="eventStatusType"
                return-object
            >
              <template v-slot:item="{ props, item }">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ item.eventStatusType }}
              </template>
            </a-autocomplete>
            <!-- currently only a listOfValueId can be a multiselect.  we may change this down the road for custom sql and system lists -->
            <a-select
                v-else-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId !== null && selectedCustomField.allowMultiple"
                v-model="selectedListOfValues"
                :items="selectedCustomField.listOfValues"
                label="Available Values"
                multiple
                @change="validateRequirementForm()"
                item-title="name"
                return-object
            ></a-select>
            <a-autocomplete
                v-else-if="newRequirement.operatorTypeId && (newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8)"
                v-model="selectedListOfValues"
                :items="processStepStatuses"
                label="Available Values"
                multiple
                attach
                @change="validateRequirementForm()"
                item-title="processStepStatusType"
                return-object
            >
              <template v-slot:item="{ props, item }">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ item.processStepStatusType }}
                <span v-if="newRequirement.processStepRequirementTypeId === 7"
                      class="ml-1">({{ item.rootProcessStepStatusType }})</span>
              </template>
            </a-autocomplete>
            <a-autocomplete
                v-else-if="newRequirement.operatorTypeId && (newRequirement.processStepRequirementTypeId === 9 || newRequirement.processStepRequirementTypeId === 10)"
                v-model="selectedListOfValues"
                :items="projectStatuses"
                label="Available Values"
                multiple
                attach
                @change="validateRequirementForm()"
                item-title="projectStatusType"
                return-object
            >
              <template v-slot:item="{ props, item }">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ item.projectStatusType }}
                <span v-if="newRequirement.projectStatusTypeId === 9" class="ml-1">({{
                    item.projectStatusType
                  }})</span>
              </template>
            </a-autocomplete>
            <a-select
                v-else-if="newRequirement.operatorTypeId && !newRequirement.customValue"
                v-model="selectedDataTypeRequirement"
                :items="dataTypeRequirements"
                label="Available Values"
                @change="validateRequirementForm()"
                item-title="dataTypeValue"
                return-object
            ></a-select>
            <a-text-field v-if="selectedDataTypeRequirement && selectedDataTypeRequirement.secondaryRequirement"
                          type="number"
                          v-model="newRequirement.secondaryRequirementValue"
                          placeholder="Enter a value"
                          @input="validateRequirementForm()"
                          label="Value">
            </a-text-field>
            <div
                v-if="(newRequirement.processStepRequirementTypeId === 7 || newRequirement.processStepRequirementTypeId === 8) && newRequirement.operatorTypeId">
              <label>Fail if no
                <strong>{{ parent.processStepName }}</strong> steps are found:</label>
              <input type="checkbox" class="ml-3 mb-4" v-model="newRequirement.failIfNoReferenceStepFound"
                     :readonly="!userCanEdit"
                     :disabled="!userCanEdit">
            </div>
            <a-btn
                :disabled="invalidRequirement"
                color="primary"
                @click="saveNewRequirement"
                prepend-icon="save"
                text="Save"
            ></a-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandRequirements">
          <v-col cols="12" class="pt-0">
            <v-data-table
                :headers="headers"
                :items="filteredRequirements"
                :items-per-page="-1"
                :mobile-breakpoint="960"
                disable-sort
                single-expand
                :expanded.sync="expanded"
                hide-default-footer
                class="elevation-1 square-card expanded-row-flatten"
                :item-class="shadeRow"
            >
              <template #no-data>
                <span class="default-text-color">No requirements for this process step</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No requirements for this process step</span>
              </template>

              <template #expanded-item="{ headers, item, index }">
                <td :colspan="$vuetify.breakpoint.smAndDown ? 12 : headers.length"
                    class="pa-4 elevation-0 one-hunned-vw" :class="shadeRow(item)">
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
                            <a-btn
                                variant="text"
                                class="d-inline-block"
                                v-bind="attrs"
                                :activation-handler="on"
                                color="unset"
                                prepend-icon="mdi-information"
                            ></a-btn>
                          </template>
                          <span>{{ fp.description }}</span>
                        </v-tooltip>
                        <div class="dynamic-field-container">
                          <a-text-field
                              v-if="fp.dataTypeId === 1"
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              placeholder="Enter a date"
                              type="date"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></a-text-field>
                          <a-text-field
                              v-else-if="fp.dataTypeId === 2"
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              placeholder="Enter a timestamp"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></a-text-field>
                          <v-checkbox
                              v-else-if="fp.dataTypeId === 3"
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              :value-comparator="function (a, b) {
                                      return fp.dynamicValue === 'true'
                                    }"
                              :value="fp.dynamicValue === 'true'"
                              @change="changeBooleanValue($event, fp)"
                              :label="fp.parameterName"></v-checkbox>
                          <a-text-field
                              v-else-if="fp.dataTypeId === 4"
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              placeholder="Enter a number"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></a-text-field>
                          <a-text-field
                              v-else-if="fp.dataTypeId === 6"
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              placeholder="Enter an integer"
                              type="number"
                              step="1"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></a-text-field>
                          <a-text-field
                              v-else
                              :readonly="requirementIsReadonly(item)"
                              :disabled="requirementIsReadonly(item)"
                              placeholder="Enter a dynamic value"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></a-text-field>
                        </div>
                      </div>
                    </v-card>
                  </div>
                  <a-select attach v-model="item.operatorTypeId"
                            :items="operatorTypes"
                            class="one-hunned"
                            label="Operator"
                            :readonly="(newRequirement.operatorTypeId === 5 && (selectedCustomField.dataTypeId === 7 || selectedCustomField.dataTypeId === 8)) || requirementIsReadonly(item)"
                            :disabled="(newRequirement.operatorTypeId === 5 && (selectedCustomField.dataTypeId === 7 || selectedCustomField.dataTypeId === 8)) || requirementIsReadonly(item)"
                            item-title="operatorType"
                            @change="operatorDataTypeCheck(item)"
                            item-value="id"
                  ></a-select>
                  <v-switch v-model="item.customValue"
                            class="mx-2"
                            :readonly="(item.dataTypeId === 7) || item.dataTypeId === 3 || !userCanEdit || [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                            :disabled="(item.dataTypeId === 7) || item.dataTypeId === 3 || item.immutable  || !userCanEdit || [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                            label="Custom"
                  ></v-switch>
                  <!-- single text field for non list custom values -->
                  <a-text-field
                      v-if="item.customValue && item.processStepRequirementTypeId !== 7 && (!item.listOfValues || item.listOfValues.length === 0) && !item.listOfValueId && !item.customFieldSql && !item.systemListId && !item.companySystemListId "
                      v-model="item.requirementValue"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      placeholder="Enter a value"
                      label="Value">
                  </a-text-field>
                  <!-- single select for dropdown, custom sql list, or system list -->
                  <a-select
                      v-else-if="!item.customField.companySystemListId && item.customValue && item.customField && ![7,8,9,10,11].includes(item.processStepRequirementTypeId)
                            && ((item.customField.listOfValueId !== null || item.customField.customFieldSql !== null) && !item.customField.allowMultiple)"
                      v-model="item.listOfValueId"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      :items="item.availableListOfValues"
                      label="Available Values"
                      item-title="name"
                      item-value="id"
                  ></a-select>
                  <a-autocomplete
                      v-else-if="item.operatorTypeId && [7,8,9,10,11].includes(item.processStepRequirementTypeId)"
                      v-model="item.listOfValues"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      :items="item.availableListOfValues"
                      label="Available Values"
                      multiple
                      @change="validateRequirementForm()"
                      item-title="name"
                      return-object
                  >
                  </a-autocomplete>
                  <a-select
                      v-else-if="(item.customValue && item.systemListId) || item.companySystemListId"
                      v-model="item.systemListOptionId"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      :items="item.availableListOfValues"
                      label="Available Values"
                      item-title="name"
                      item-value="id"
                  ></a-select>
                  <!-- not sure what to do with this custom sql one yet -->
                  <a-select
                      v-else-if="item.customValue && item.customFieldSql"
                      v-model="item.listOfValueId"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      :items="item.availableListOfValues"
                      label="Available Values"
                      item-title="name"
                      item-value="id"
                  ></a-select>
                  <!-- at this point it should only show for multiselects -->
                  <a-select
                      v-else-if="item.customValue && item.customField && item.customField.allowMultiple"
                      v-model="item.listOfValues"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      :items="item.availableListOfValues"
                      label="Available Values"
                      item-title="name"
                      multiple
                      return-object
                  ></a-select>
                  <a-select
                      v-else
                      v-model="item.dataTypeRequirement"
                      :items="dataTypeRequirements"
                      :disabled="requirementIsReadonly(item)"
                      :readonly="requirementIsReadonly(item)"
                      label="Available Values"
                      item-title="dataTypeValue"
                      item-value="id"
                      return-object
                  ></a-select>
                  <a-text-field v-if="item.dataTypeRequirement.secondaryRequirement"
                                type="number"
                                v-model="item.secondaryRequirementValue"
                                placeholder="Enter a value"
                                :disabled="requirementIsReadonly(item)"
                                :readonly="requirementIsReadonly(item)"
                                label="Value">
                  </a-text-field>
                  <div
                      v-if="(item.processStepRequirementTypeId === 7 || item.processStepRequirementTypeId === 8) && item.operatorTypeId">
                    <label>Fail if no
                      <strong>{{ item.referenceProcessStepName }}</strong> steps are found:</label>
                    <input type="checkbox" class="ml-3 mb-4" v-model="item.failIfNoReferenceStepFound"
                           :readonly="requirementIsReadonly(item)"
                           :disabled="requirementIsReadonly(item)">
                  </div>
                  <a-btn
                      v-if="!requirementIsReadonly(item)"
                      @click="updateRequirement(item)"
                      color="primary"
                      prepend-icon="save"
                      text="Save"
                  ></a-btn>
                </td>
              </template>


              <template #item.requirementNbr="{item}" style="width: 65px">{{ item.requirementNbr }}</template>
              <template #item.processStepRequirementType="{item}" class="text-left">{{
                  item.processStepRequirementType
                }}
              </template>
              <template #item.custom="{item}" class="text-left">
                    <span v-if="item.processStepRequirementTypeId === 1">
                      <a :href="`/settings/processStep/${item.processStepId}/components`">{{
                          item.parentName
                        }}</a> | {{ item.fieldName }}
                    </span>
                <span v-else-if="item.processStepRequirementTypeId === 2">
                      <a :href="`/settings/function/${item.companyFunctionId}`">{{ item.companyFunctionName }}</a>
                    </span>
                <span
                    v-else-if="item.processStepRequirementTypeId === 7 || item.processStepRequirementTypeId === 8">
                      <a :href="`/settings/processStep/${item.referenceProcessStepId}/components`">{{
                          item.referenceProcessStepName
                        }}</a>
                    </span>
                <span v-else-if="item.processStepRequirementTypeId === 12">
                      {{ item.dataViewChildFieldName || item.dataViewFieldName }}
                    </span>
                <span v-else>
                      {{ item.fieldName }}
                    </span>
              </template>
              <template #item.operatorType="{item}" class="text-left">{{ item.operatorType }}</template>
              <template #item.requirementValue="{item}" class="text-left">
                    <span v-if="item.requirementValue">
                      {{ item.requirementValue }}
                    </span>
                <span v-else-if="item.dataTypeRequirementId">
                      {{
                    item.dataTypeRequirement ? item.dataTypeRequirement.dataTypeValue : 'unknown'
                  }} {{ item.secondaryRequirementValue }}
                    </span>
                <span v-else-if="item.listOfValueId || item.customFieldSql || item.companySystemListId">
<!--                      {{item.listOfValue ? item.listOfValue.name : 'unknown'}}-->
                      {{ getListValueName(item) }}
                    </span>
                <span v-else-if="item.listOfValues">
                      <!-- todo: show the selected values here -->
                      {{ item.listOfValues.map(v => ' ' + v.name).toString() }}
                    </span>
              </template>
              <template #item.icons="{item, index}">
                <div style="display: flex;">
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="[loadOperatorTypes(item.dataTypeId, item.processStepRequirementTypeId), loadDataTypeRequirements(item.dataTypeId), selectedRequirementIndex = index, expanded = [item]]"
                      v-if="!expanded.includes(item)"
                      :prepend-icon="item.immutable ? 'expand_more' : 'edit'"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="[selectedRequirementIndex = index, expanded = []]"
                      v-if="expanded.includes(item)"
                      :prepend-icon="item.immutable ? 'expand_less' : ''"
                      :text="item.immutable ? '' : 'cancel'"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="userCanEdit"
                      @click="[itemToDelete=item, showDeleteDialog=true]"
                      prepend-icon="delete"
                  ></a-btn>
                  <a-btn
                      size="small"
                      variant="text"
                      color="primary"
                      @click="showActionsUsingLogic(item.id)"
                      prepend-icon="mdi-information"
                  ></a-btn>
                </div>
              </template>
            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                        @confirm="deleteRequirement"
                        @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this requirement?
      <div v-if="itemToDelete" class="pt-3">
        <div><b>Requirement Id: </b>{{ itemToDelete.requirementNbr }}</div>
        <div class="text-left"><b>Type: </b>{{ itemToDelete.processStepRequirementType }}</div>
        <div class="text-left">
          <b>Details: </b>
          <span v-if="itemToDelete.processStepRequirementTypeId === 1">
                      <a :href="`/settings/processStep/${itemToDelete.processStepId}/components`">{{
                          itemToDelete.parentName
                        }}</a> | {{ itemToDelete.fieldName }}
                    </span>
          <span v-else-if="itemToDelete.processStepRequirementTypeId === 2">
                      <a :href="`/settings/function/${itemToDelete.companyFunctionId}`">{{
                          itemToDelete.companyFunctionName
                        }}</a>
                    </span>
          <span
              v-else-if="itemToDelete.processStepRequirementTypeId === 7 || itemToDelete.processStepRequirementTypeId === 8">
                      <a :href="`/settings/processStep/${itemToDelete.referenceProcessStepId}/components`">{{
                          itemToDelete.referenceProcessStepName
                        }}</a>
                    </span>
          <span v-if="itemToDelete.processStepRequirementTypeId === 12">
                      {{ itemToDelete.dataViewChildFieldName || itemToDelete.dataViewFieldName }}
                    </span>
          <span v-else>
                      {{ itemToDelete.fieldName }}
                    </span>
        </div>
        <div class="text-left"><b>Operator: </b>{{ itemToDelete.operatorType }}</div>
        <div class="text-left">
          <b>Value: </b>
          <span v-if="itemToDelete.requirementValue">
                      {{ itemToDelete.requirementValue }}
                    </span>
          <span v-else-if="itemToDelete.dataTypeRequirementId">
                      {{
              itemToDelete.dataTypeRequirement ? itemToDelete.dataTypeRequirement.dataTypeValue : 'unknown'
            }} {{ itemToDelete.secondaryRequirementValue }}
                    </span>
          <span
              v-else-if="itemToDelete.listOfValueId || itemToDelete.customFieldSql || itemToDelete.companySystemListId">
<!--                      {{item.listOfValue ? item.listOfValue.name : 'unknown'}}-->
                      {{ getListValueName(itemToDelete) }}
                    </span>
          <span v-else-if="itemToDelete.listOfValues">
                      <!-- todo: show the selected values here -->
                      {{ itemToDelete.listOfValues.map(v => ' ' + v.name).toString() }}
                    </span>
        </div>
      </div>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="showInfoDialog"
                        hideConfirm
                        @close-dialog="showInfoDialog=false"
    >
      <template v-slot:title>Actions using this requirement:</template>
      <span v-if="!actionsUsingLogic || actionsUsingLogic.length === 0">No actions using this requirement.</span>
      <v-list dense>
        <v-list-item v-for="(item, index) in actionsUsingLogic" :key="index">
          <v-list-item-icon>
            <v-icon>
              mdi-circle-small
            </v-icon>
          </v-list-item-icon>
          <v-list-item-content>
            {{ item.actionName }}
          </v-list-item-content>
        </v-list-item>
      </v-list>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


import {getCompanyAssignedToProcessStep, getAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import {getProjectStatusTypes, getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
import {
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog"
import constants from "@/helpers/constants";
import {getCurrentInstance, watch, toRefs, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const props = defineProps({
  eventRequirements: Boolean,
  callback: Function
})
const { eventRequirements } = toRefs(props)


const expandRequirements = ref(true)
const expanded = ref([])
const deleteError = ref(false)
const actionsUsingLogic = ref([])
const invalidRequirement = ref(true)
const addNewRequirement = ref(false)
const eventStatuses = ref([])
const dataTypeRequirements = ref([])
const selectedDataTypeRequirement = ref({})
const selectedCustomField = ref({})
const selectedDataViewField = ref({})
const listOfValues = ref([])
const selectedListOfValues = ref([])
const selectedListValue = ref({})
const selectedFunction = ref({})
const selectedDataView = ref({})
const selectedRequirementIndex = ref(null)
const availableRequirementTypes = ref([])
const parentObjects = ref([])
const dataViews = ref([])
const availableDataViewFields = ref([])
const parent = ref({})
const customFields = ref([])
const operatorTypes = ref([])
const operationTypes = ref([])
const selectedProcessStepStatus = ref({})
const processStepStatuses = ref([])
const projectStatuses = ref([])
const requirements = ref([])
const availableFunctions = ref([])
const apiUrl = ref('')
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const showInfoDialog = ref(false)
const headers = ref([
  {text: 'ID', value: 'requirementNbr', width: '65px', show: true},
  {text: 'Type', value: 'processStepRequirementType', show: true},
  {text: 'Details', value: 'custom', show: true},
  {text: 'Operator', value: 'operatorType', show: true},
  {text: 'Value', value: 'requirementValue', show: true},
  {text: null, value: 'icons', show: true}
])
const newRequirement = ref({
  requirementParamDynamicValues: [],
  customValue: false,
  failIfNoReferenceStepFound: true
})

watch(() => requirements.value, () => {
  //any time the requirements change, send back to parent component
  if(props.callback) {
    props.callback(requirements.value)
  }
})
const processStepEventId = computed(() => {
  return route.params.eventId
})
const processStepId = computed(() => {
  return route.params.id
})
const filteredRequirements = computed(() => {
  return requirements.value?.filter(r => !r.archived)
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

onMounted(() => {
  //api = process step requirements OR process step event requirements
  apiUrl.value = eventRequirements.value ? `/processStep/${processStepId.value}/event/${processStepEventId.value}/requirement` : `/processStep/${processStepId.value}/requirement`
  getRequirements()
})

const requirementIsReadonly = (requirement) => {
  return (requirement.immutable && !constants.BYPASS_REQUIREMENT_IMMUTABLE_TYPE_IDS.includes(requirement.processStepRequirementTypeId)) || !userCanEdit.value
}
const shadeRow = (item) => {
  return item.requirementNbr % 2 === 0 ? 'shaded-row' : ''
}
const changeBooleanValue = (e, fp) => {
  vueInstance.$set(fp, 'dynamicValue', e == null ? 'false' : e.toString())
}
const getRequirements = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(apiUrl.value)
    requirements.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}

const getRequirementTypes = async () => {
  addNewRequirement.value = !addNewRequirement.value
  if (addNewRequirement.value) {
    appStore.loading = true
    try {
      let url = eventRequirements.value ? `/processStep/${processStepId.value}/requirement/event/types` : `/processStep/${processStepId.value}/requirement/types`
      const {data} = await getRequest(url)
      availableRequirementTypes.value = data
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
}
const selectRequirementType = async () => {
  appStore.loading = true
  try {
    //1 == process step custom field, 2 == function,
    // 3 == project custom field, 4 == contact custom field
    if (newRequirement.value.processStepRequirementTypeId === 1 || newRequirement.value.processStepRequirementTypeId === 7 || newRequirement.value.processStepRequirementTypeId === 8) {
      loadParentObjects()
    } else if (newRequirement.value.processStepRequirementTypeId === 3) {
      //get project custom fields
      loadCustomFieldsByObjectType(1)
    } else if (newRequirement.value.processStepRequirementTypeId === 4) {
      //get contact custom fields
      loadCustomFieldsByObjectType(2)
    } else if (newRequirement.value.processStepRequirementTypeId === 9) {
      //get project statuses
      getCompanyProjectStatuses()
      //load operator types from here for this kind
      newRequirement.value.customValue = true
      loadOperatorTypes(7, 9)
    } else if (newRequirement.value.processStepRequirementTypeId === 10) {
      //get company project statuses
      getProjectStatuses()
      newRequirement.value.customValue = true
      loadOperatorTypes(7, 10)
    } else if (newRequirement.value.processStepRequirementTypeId === 11) {
      newRequirement.value.customValue = true
      loadOperatorTypes(7, 11)
      getEventStatuses()
    } else if (newRequirement.value.processStepRequirementTypeId === 12) {
      loadDataViews()
    } else {
      let objectTypeId = eventRequirements.value ? 6 : 4;
      const {data} = await getRequest(`/function/requirement/${objectTypeId}`)
      availableFunctions.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadParentObjects = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequestWithParams(`/processStep/getParentObjects`, {params: {id: processStepId.value}})
    parentObjects.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadDataViews = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/dataView`, null, [])
    dataViews.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getDataViewFields = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/customField/getByDataView/${selectedDataView.value.id}`)
    availableDataViewFields.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadValues = async (parent) => {
  if (newRequirement.value?.processStepRequirementTypeId === 1) {
    await loadFieldsByParent(parent)
  } else if (newRequirement.value?.processStepRequirementTypeId === 7) {
    newRequirement.value.customValue = true
    await getCompanyStatusesAssignedToProcessStep(parent)
    //this 7 = data type for multi select
    await loadOperatorTypes(7, 7)
  } else if (newRequirement.value?.processStepRequirementTypeId === 8) {
    newRequirement.value.customValue = true
    await getStatusesAssignedToProcessStep(parent)
    //this 7 = data type for multi select
    await loadOperatorTypes(7, 8)
  }
}
const getCompanyStatusesAssignedToProcessStep = async (parent) => {
  appStore.loading = true
  try {
    const {data} = await getCompanyAssignedToProcessStep(parent.id)
    //if the selected process step is the same as the active process step being viewed, only allow active process step status types
    processStepStatuses.value = parent.id === parseInt(processStepId.value) ? data.filter(d => d.processStepStatusTypeId === 1) : data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getStatusesAssignedToProcessStep = async (parent) => {
  appStore.loading = true
  try {
    const {data} = await getAssignedToProcessStep(parent.id)
    //if the selected process step is the same as the active process step being viewed, only allow active process step status types
    processStepStatuses.value = parent.id === parseInt(processStepId.value) ? data.filter(d => d.id === 1) : data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getProjectStatuses = async () => {
  appStore.loading = true
  try {
    const {data} = await getProjectStatusTypes()
    projectStatuses.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getEventStatuses = async () => {
  //this has to load event statuses using the pseId
  appStore.loading = true
  try {
    const {data} = await getRequest(`/event/statusesForPsEvent/${processStepEventId.value}`)
    eventStatuses.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getCompanyProjectStatuses = async () => {
  appStore.loading = true
  try {
    const {data} = await getCompanyProjectStatusTypes(null, true)
    projectStatuses.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadFieldsByParent = async (parent) => {
  appStore.loading = true
  try {
    //this exclusion is temporary until requirements/action can handle the new system readonly data type
    //could probably do this cleaner/more generically i just dont want to cuz it is temporary
    const {data} = await getRequestWithParams(`/customField/getByParentProcessStep/${parent.id}`, {
      params: {
        excludedUnhandledDataTypes: true
      }
    })
    customFields.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadCustomFieldsByObjectType = async (objectTypeId) => {
  appStore.loading = true
  try {
    const {data} = await getRequestWithParams(`/customField/getByParentType/${objectTypeId}`, {
      params: {
        excludedUnhandledDataTypes: true
      }
    })
    customFields.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadFunctionParams = async (dbFunctionId, isRequirement) => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/function/${dbFunctionId}/dynamicParams`)
    if (isRequirement) {
      newRequirement.value.requirementParamDynamicValues = data
    } else {
      selectedChildRequirementParamDynamicValues.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadOperatorTypes = async (dataTypeId, processStepRequirementTypeId) => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/operator/${dataTypeId}`)
    if ([7, 8, 9, 10, 11].includes(processStepRequirementTypeId)) {
      operatorTypes.value = data.filter(d => d.id === 5)
    } else {
      operatorTypes.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadDataTypeRequirements = async (dataTypeId) => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/dataType/getDataTypeRequirements/${dataTypeId}`)
    dataTypeRequirements.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const operatorDataTypeCheck = (item) => {
  // keeps multiselects using the right operator with the right lists.  i could probably do this better
  if (item) {
    if (item.operatorTypeId === 5 && (item.dataTypeId === 7 || item.dataTypeId === 7)) {
      item.customValue = true
      item.dataTypeRequirement = {}
    } else if (item.dataTypeId === 7 || item.dataTypeId === 8) {
      item.customValue = false
      item.listOfValues = []
      loadDataTypeRequirements(item.dataTypeId)
    }
  } else {
    if (newRequirement.value.operatorTypeId === 5 && (selectedCustomField.value.dataTypeId === 7 || selectedCustomField.value.dataTypeId === 8)) {
      newRequirement.value.customValue = true
      selectedDataTypeRequirement.value = {}
    } else if (selectedCustomField.value.dataTypeId) {
      newRequirement.value.customValue = false
      selectedListOfValues.value = []
      let dataTypeToUse = newRequirement.value.processStepRequirementTypeId === 7 ? 7 : newRequirement.value.processStepRequirementTypeId === 8 ? 8 : selectedCustomField.value.dataTypeId
      loadDataTypeRequirements(dataTypeToUse)
    }
  }
}
const validateRequirementForm = () => {
  let invalidParams = false
  //if there are dynamic params, ensure they are all populated
  if (newRequirement.value.requirementParamDynamicValues.length > 0) {
    newRequirement.value.requirementParamDynamicValues.forEach(fp => {
      if (!fp.nullable && !fp.dynamicValue) {
        invalidParams = true
      }
    })
  }

  //check validity of initial value
  let invalidValue = (!newRequirement.value.requirementValue && !selectedDataTypeRequirement.value.id && !selectedListValue.value.id && selectedListOfValues.value.length === 0)

  //if a secondary requirement is required check for a value there
  let invalidSecondaryValue = (selectedDataTypeRequirement.value.secondaryRequirement && !newRequirement.value.secondaryRequirementValue)

  invalidRequirement.value = invalidParams || invalidValue || invalidSecondaryValue
}
const saveNewRequirement = async () => {
  appStore.loading = true
  try {
    newRequirement.value.customFieldGroupAssignmentId = selectedCustomField.value.customFieldGroupAssignmentId
    newRequirement.value.companyFunctionId = selectedFunction.value.id
    newRequirement.value.processStepId = processStepId.value
    newRequirement.value.dataViewFieldConfigId = selectedDataViewField.value.dataViewFieldConfigId
    newRequirement.value.dataViewChildFieldConfigId = selectedDataViewField.value.dataViewChildFieldConfigId

    //todo: holy crap figure out how to fix the object being sent up so i dont have to do all this validation
    //adjust value of requirementValue as needed:
    if (newRequirement.value.customValue && selectedCustomField.value.listOfValueId && selectedCustomField.value.allowMultiple) {
      // if from list of values and allow multiple build the json array of selected ids
      newRequirement.value.listOfValueIds = selectedListOfValues.value.map(v => v.id)

      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      newRequirement.value.systemListOptionId = null
      newRequirement.value.customSqlOptionId = null
      newRequirement.value.listOfValueId = null
      newRequirement.value.dataTypeRequirementId = null
      newRequirement.value.requirementValue = null
    } else if (newRequirement.value.customValue && selectedCustomField.value.listOfValueId && !selectedCustomField.value.allowMultiple) {
      //  if from a list of values and not allow multiple use the selected value id,
      newRequirement.value.listOfValueId = selectedListValue.value.id
      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      newRequirement.value.systemListOptionId = null
      newRequirement.value.customSqlOptionId = null
      newRequirement.value.listOfValueIds = null
      newRequirement.value.dataTypeRequirementId = null
      newRequirement.value.requirementValue = null
    } else if (newRequirement.value.customValue && selectedCustomField.value.companySystemListId && !selectedCustomField.value.allowMultiple) {
      //  if from a system list and not allow multiple use the selected value id,
      newRequirement.value.systemListOptionId = selectedListValue.value.id
      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      newRequirement.value.listOfValueId = null
      newRequirement.value.listOfValueIds = null
      newRequirement.value.customSqlOptionId = null
      newRequirement.value.dataTypeRequirementId = null
      newRequirement.value.requirementValue = null
    } else if (newRequirement.value.customValue && selectedCustomField.value.customFieldSql && !selectedCustomField.value.allowMultiple) {
      //  if from a list of values and not allow multiple use the selected value id,
      newRequirement.value.customSqlOptionId = selectedListValue.value.id
      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      newRequirement.value.listOfValueId = null
      newRequirement.value.systemListOptionId = null
      newRequirement.value.listOfValueIds = null
      newRequirement.value.dataTypeRequirementId = null
      newRequirement.value.requirementValue = null
    } else if (newRequirement.value.customValue) {
      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      //here
      if ([7, 8].includes(newRequirement.value.processStepRequirementTypeId)) {
        newRequirement.value.listOfValueIds = selectedListOfValues.value.map(v => v.id)
        newRequirement.value.referenceProcessStepId = parent.value.id
      } else if ([9, 10, 11].includes(newRequirement.value.processStepRequirementTypeId)) {
        newRequirement.value.listOfValueIds = selectedListOfValues.value.map(v => v.id)
      } else {
        newRequirement.value.listOfValueIds = null
      }
      newRequirement.value.systemListOptionId = null
      newRequirement.value.customSqlOptionId = null
      newRequirement.value.listOfValueId = null
      newRequirement.value.dataTypeRequirementId = null
    } else if (!newRequirement.value.customValue) {
      newRequirement.value.dataTypeRequirementId = selectedDataTypeRequirement.value.id
      //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
      newRequirement.value.listOfValueIds = null
      newRequirement.value.systemListOptionId = null
      newRequirement.value.customSqlOptionId = null
      newRequirement.value.listOfValueId = null
      newRequirement.value.requirementValue = null
    }

    if (eventRequirements.value) {
      newRequirement.value.processStepEventId = processStepEventId.value
    }
    const {data} = await postRequest(apiUrl.value, newRequirement.value)
    //this is null sometimes and causing issues with refreshing the list
    data.customField = data.customField || {}
    requirements.value.push(data)
    selectedCustomField.value = {}
    selectedListOfValues.value = []
    selectedListValue.value = {}
    addNewRequirement.value = false
    newRequirement.value = {
      requirementParamDynamicValues: [],
      customValue: false,
      failIfNoReferenceStepFound: true
    }
    selectedDataTypeRequirement.value = {}
    parent.value = {}
    availableFunctions.value = []
    appStore.showSnack('SUCCESS', 'Requirement Added')
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Requirement')
  } finally {
    appStore.loading = false
  }
}
const updateRequirement = async (requirement) => {
  appStore.loading = true
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
    } else if (requirement.customValue && selectedCustomField.value.listOfValueId && !selectedCustomField.value.allowMultiple) {
      //  if from a list of values and not allow multiple use the selected value id,
      requirement.listOfValueId = selectedListValue.value.id
      //reset this in case they changed values around
      requirement.dataTypeRequirementId = null
    } else if (!requirement.customValue) {
      //reset these in case they changed values around
      requirement.listOfValueIds = null
      requirement.listOfValueId = null
      requirement.requirementValue = null
    }

    if (eventRequirements.value) {
      newRequirement.value.processStepEventId = processStepEventId.value
    }

    const {data} = await putRequest(apiUrl.value, requirement)
    expanded.value = []
    // this forces the list to update the operator displayed ... using requirement = data did not work
    requirement.operatorType = data.operatorType
    appStore.showSnack('SUCCESS', 'Requirement Updated')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Requirement')
    appStore.loading = false
  }
}

const getActionsUsingLogic = async (requirementId, andDelete = false) => {
  let url = apiUrl.value + `/${requirementId}`
  if (andDelete) {
    //the put request will archive the requirement if it doesn't find any actions using it
    const {data} = await putRequest(url)
    actionsUsingLogic.value = data
  } else {
    const {data} = await getRequest(url)
    actionsUsingLogic.value = data
  }
}

const showActionsUsingLogic = async (requirementId) => {
  appStore.loading = true
  try {
    await getActionsUsingLogic(requirementId)
    showInfoDialog.value = true
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Fetching Requirement Info')
    appStore.loading = false
  }
}

const deleteRequirement = async () => {
  const item = itemToDelete.value
  appStore.loading = true
  try {
    await getActionsUsingLogic(item.id, true)
    if (actionsUsingLogic.value?.length > 0) {
      deleteError.value = true //opens the delete error dialog
      item.deleteConfirm = false
      appStore.showSnack('ERROR', 'Error Deleting Requirement')
    } else {
      item.archived = true
      requirements.value = requirements.value.filter(r => !r.archived)
      appStore.showSnack('SUCCESS', 'Requirement Deleted')
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Requirement')
    appStore.loading = false
  }
  closeDeleteDialog()
}
const getListValueName = (item) => {
  let idToUse = item.customSqlOptionId ? item.customSqlOptionId :
      item.systemListOptionId ? item.systemListOptionId : item.listOfValueId
  let match = item.availableListOfValues.find(i => i.id === idToUse)
  return match ? match.name : 'unknown'
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
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

.one-hunned-vw {
  width: 100vw;
}

</style>
