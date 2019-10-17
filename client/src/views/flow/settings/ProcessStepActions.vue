<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="getRequirementTypes" text>
              <v-icon v-if="!addNewRequirement">add</v-icon>
              {{ addNewRequirement ? 'Cancel' : 'Add Requirement'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewRequirement">
          <v-col cols="12">
            <!--  TODO: need to protect against bad data when they go back and change the requirement type but have already selected other values lower in the form      -->
            <v-select v-model="newRequirement.processStepRequirementTypeId"
                      :items="availableRequirementTypes"
                      label="Select Requirement Type"
                      item-value="id"
                      item-text="processStepRequirementType"
                      @input="selectRequirementType"
            ></v-select>
            <!-- if it is a custom field -->
            <v-select
                v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 1"
                v-model="parent"
                :items="parentObjects"
                label="Parent Object"
                item-text="processStepName"
                return-object
                @input="loadFieldsByParent(parent)"
            ></v-select>
            <v-select v-if="parent.id"
                      v-model="selectedCustomField"
                      :items="customFields"
                      label="Custom Field"
                      item-text="fieldName"
                      return-object
                      @input="loadOperatorTypes(selectedCustomField.dataTypeId); loadDataTypeRequirements(selectedCustomField.dataTypeId)"
            ></v-select>
            <!-- if it is a function -->
            <v-select
                v-if="newRequirement.processStepRequirementTypeId && newRequirement.processStepRequirementTypeId === 2"
                v-model="selectedFunction"
                :items="availableFunctions"
                label="Function"
                item-text="companyFunctionName"
                returnObject
                @input="loadFunctionParams(); loadOperatorTypes(selectedFunction.returnDataTypeId); loadDataTypeRequirements(selectedFunction.returnDataTypeId)"
            ></v-select>
            <div v-if="selectedFunction.id && newRequirement.requirementParamDynamicValues.length > 0">
              <h5 class="text-left">Dynamic Function Parameters</h5>
              <v-card flat>
                <v-text-field
                    v-for="(fp, index) in newRequirement.requirementParamDynamicValues"
                    :key="index"
                    placeholder="Enter a dynamic value"
                    v-model="fp.dynamicValue"
                    :label="fp.parameterName"></v-text-field>
              </v-card>
            </div>
            <v-select
                v-if="(newRequirement.processStepRequirementTypeId === 1 && selectedCustomField.customFieldGroupAssignmentId) || (newRequirement.processStepRequirementTypeId === 2 && selectedFunction.id)"
                v-model="newRequirement.operatorTypeId"
                :items="operatorTypes"
                label="Operator"
                item-text="operatorType"
                item-value="id"
            ></v-select>
            <v-switch v-if="newRequirement.operatorTypeId" v-model="newRequirement.customValue" class="mx-2" label="Custom"></v-switch>
            <v-text-field v-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId === null"
                          v-model="newRequirement.requirementValue"
                          placeholder="Enter a value"
                          label="Value">
            </v-text-field>
            <v-select
                v-else-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId !== null && !selectedCustomField.allowMultiple"
                v-model="selectedListValue"
                :items="selectedCustomField.listOfValues"
                label="Available Values"
                item-text="name"
                return-object
            ></v-select>
            <v-select
                v-else-if="newRequirement.operatorTypeId && newRequirement.customValue && selectedCustomField.listOfValueId !== null && selectedCustomField.allowMultiple"
                v-model="selectedListOfValues"
                :items="selectedCustomField.listOfValues"
                label="Available Values"
                multiple
                item-text="name"
                return-object
            ></v-select>
            <v-select
                v-else-if="newRequirement.operatorTypeId && !newRequirement.customValue"
                v-model="selectedDataTypeRequirement"
                :items="dataTypeRequirements"
                label="Available Values"
                item-text="dataTypeValue"
                return-object
            ></v-select>
            <v-text-field v-if="selectedDataTypeRequirement && selectedDataTypeRequirement.secondaryRequirement"
                          v-model="newRequirement.secondaryRequirementValue"
                          placeholder="Enter a value"
                          label="Value">
            </v-text-field>
            <v-btn :disabled="validateRequirementForm()"
                   @click="saveNewRequirement">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12">
            <v-data-table
                :headers="headers"
                :items="filterRequirements()"
                :items-per-page="-1"
                single-expand
                :expanded.sync="expanded"
                hide-default-footer
                class="elevation-1 fix-column-width-bug"
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
                    <v-card flat>
                      <v-text-field
                          v-for="(fp, index) in item.requirementParamDynamicValues"
                          :key="index"
                          placeholder="Enter a dynamic value"
                          v-model="fp.dynamicValue"
                          :label="fp.parameterName"></v-text-field>
                    </v-card>
                  </div>
                  <v-select v-model="item.operatorTypeId"
                            :items="operatorTypes"
                            class="one-hunned"
                            label="Operator"
                            item-text="operatorType"
                            item-value="id"
                  ></v-select>
                  <v-switch v-model="item.customValue" class="mx-2"
                            label="Custom"></v-switch>
                  <v-text-field v-if="item.customValue && !item.listOfValueId && !item.listOfValues"
                                v-model="item.requirementValue"
                                placeholder="Enter a value"
                                label="Value">
                  </v-text-field>
                  <v-select
                      v-else-if="item.customValue && item.listOfValueId"
                      v-model="item.listOfValueId"
                      :items="listOfValues"
                      label="Available Values"
                      item-text="name"
                      item-value="id"
                  ></v-select>
                  <v-select
                      v-else-if="item.customValue && item.listOfValues"
                      v-model="item.listOfValues"
                      :items="listOfValues"
                      label="Available Values"
                      item-text="name"
                      multiple
                      return-object
                  ></v-select>
                  <v-select
                      v-else
                      v-model="item.dataTypeRequirement"
                      :items="dataTypeRequirements"
                      label="Available Values"
                      item-text="dataTypeValue"
                      return-object
                  ></v-select>
                  <v-text-field v-if="item.dataTypeRequirement.secondaryRequirement"
                                v-model="item.secondaryRequirementValue"
                                placeholder="Enter a value"
                                label="Value">
                  </v-text-field>
                  <v-btn @click="updateRequirement(item)">
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
                    <span v-else>
                      {{ item.companyFunctionName }}
                    </span>
                  </td>
                  <td class="text-left">{{item.operatorType}}</td>
                  <td class="text-left">
                    <div v-if="item.requirementValue">
                      {{item.requirementValue}}
                    </div>
                    <div v-else-if="item.dataTypeRequirementId">
                      {{item.dataTypeRequirement ? item.dataTypeRequirement.dataTypeValue : 'unknown'}} {{item.secondaryRequirementValue}}
                    </div>
                    <div v-else-if="item.listOfValueId">
                      {{item.listOfValue ? item.listOfValue.name : 'unknown'}}
                    </div>
                    <div v-else-if="item.listOfValues">
                      <!-- todo: show the selected values here -->
                      {{ item.listOfValues.map(v => v.name).toString() }}
                    </div>
                  </td>
                  <td>
                    <div style="display: flex;">
                      <v-btn small text @click="expanded = [item];loadOperatorTypes(item.dataTypeId);
                                    loadDataTypeRequirements(item.dataTypeId); loadListOfValues(item.listOfValueId, item.listOfValues); selectedRequirementIndex = index"
                             v-if="!expanded.includes(item)">
                        <v-icon>edit</v-icon>
                      </v-btn>
                      <v-btn small text @click="expanded = []; selectedRequirementIndex = index"
                             v-if="expanded.includes(item)">cancel
                      </v-btn>
                      <v-dialog
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
                                color="primary"
                                text
                                @click="item.archived = true; deleteRequirement(item.id)">
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
          <v-toolbar flat>
            <v-toolbar-title class="app-title">Actions</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn @click="addNewAction = !addNewAction" text>
                <v-icon v-if="!addNewAction">add</v-icon>
                {{ addNewAction ? 'Cancel' : 'Add Action'}}
              </v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <v-card flat v-if="addNewAction">
            <v-text-field v-model="newAction.actionName"
                          placeholder="Enter a name"
                          label="Action Name">
            </v-text-field>
            <v-select v-model="newAction.actionTypeId"
                      :items="actionTypes"
                      label="Action Type"
                      item-text="actionType"
                      item-value="id"
            ></v-select>
            <v-select v-model="newAction.processStepStatusTypeId"
                      :items="statusTypes"
                      :clearable="true"
                      label="Action changes status of parent process step to"
                      item-text="processStepStatusType"
                      item-value="id"
            ></v-select>
            <v-btn v-if="newAction.actionName && newAction.actionTypeId"
                   @click="saveNewAction">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-card>
          <v-card flat>
            <v-data-table
                :headers="actionHeaders"
                :items="filterActions()"
                :items-per-page="-1"
                single-expand
                :expanded.sync="actionExpanded"
                hide-default-footer
                class="elevation-1 fix-column-width-bug"
            >
              <template #no-data>
                No actions for this process step
              </template>

              <template #no-results>
                No actions for this process step
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="actionHeaders.length" class="pb-4" :class="{'shaded-row': selectedActionIndex % 2}">
                  <v-card flat class="text-left">
                    <v-text-field v-model="item.actionName"
                                  placeholder="Enter a name"
                                  label="Action Name">
                    </v-text-field>
                    <v-select v-model="item.actionTypeId"
                              :items="actionTypes"
                              label="Action Type"
                              item-text="actionType"
                              item-value="id"
                    ></v-select>
                    <v-select v-model="item.processStepStatusTypeId"
                              :items="statusTypes"
                              :clearable="true"
                              label="Action changes status of parent process step to"
                              item-text="processStepStatusType"
                              item-value="id"
                    ></v-select>
                    <!-- BUTTON -->
                    <div v-if="item.actionTypeId === 2">
                      <v-btn v-if="!addChildProcess"
                             @click="addChildProcess = true; loadChildProcessSteps(item.id)">
                        <v-icon>add</v-icon>
                        Add Child Process
                      </v-btn>
                      <v-card class="pa-3" :class="{'shaded-row': !(selectedActionIndex % 2)}" v-if="addChildProcess">
                        <h3>Add Child Process</h3>
                        <v-select v-model="selectedProcessStep"
                                  :items="childProcessSteps"
                                  label="Process Step"
                                  item-text="processStepName"
                                  return-object
                        ></v-select>
                        <input type="checkbox" v-model="selectedProcessStep.triggerAutomatically">
                        Trigger Automatically
                        <div class="mt-3">
                          <v-btn :disabled="!selectedProcessStep.id"
                                 @click="saveProcessStepToAction(item)">
                            <v-icon>save</v-icon>
                            Save
                          </v-btn>
                          <v-btn class="ml-3" @click="addChildProcess = false">
                            <v-icon>remove</v-icon>
                            Cancel
                          </v-btn>
                        </div>
                      </v-card>
                    </div>
                    <!-- LINK -->
                    <div v-if="item.actionTypeId === 1">
                      <v-btn v-if="!addChildLink"
                             @click="addChildLink = true; loadLinks(item.id)">
                        <v-icon>add</v-icon>
                        Add Link
                      </v-btn>
                      <v-card class="pa-3" :class="{'shaded-row': !(selectedActionIndex % 2)}" v-if="addChildLink">
                        <h3>Add Link</h3>
                        <v-select v-model="selectedLink"
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
                      <h3 class="text-left">Child Links</h3>
                      <v-list v-for="(al, index) in filterBy(item.processStepActionLinks, false, 'archived')"
                              :key="index"
                              :class="{ 'shaded-row': index % 2 }">
                        <v-list-item class="grab">
                          <v-list-item-content class="text-left">
                            {{al.link}}
                          </v-list-item-content>
                          <v-dialog
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
                                    color="primary"
                                    text
                                    @click="al.archived = true; deleteLinkFromAction(item.id, al.id)">
                                  Yes
                                </v-btn>
                              </v-card-actions>
                            </v-card>
                          </v-dialog>
                        </v-list-item>
                      </v-list>
                    </v-col>
                  </v-row>
                  <v-row justify="center" class="pl-3 pr-3"
                          v-if="item.actionTypeId === 2 && item.processStepActionChildProcesses && item.processStepActionChildProcesses.length > 0">
                    <v-col cols="12">
                      <h3 class="text-left">Child Process Steps</h3>
                      <v-list v-for="(cp, index) in filterBy(item.processStepActionChildProcesses, false, 'archived')"
                              :key="index"
                              :class="{ 'shaded-row': index % 2 }">
                        <v-list-item class="grab">
                          <v-list-item-content class="text-left">
                            <v-list-item-title>{{cp.processStepName}}</v-list-item-title>
                            <v-list-item-subtitle>
                              <input type="checkbox" v-model="cp.triggerAutomatically"
                                     @change="updateChildStep(item.id, cp)">
                              Trigger Automatically
                            </v-list-item-subtitle>
                          </v-list-item-content>
                          <v-dialog
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
                                Are you sure you want to delete <strong>{{ cp.processStepName }}</strong> from <strong>{{
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
                                    color="primary"
                                    text
                                    @click="cp.archived = true; deleteChildProcessFromAction(item.id, cp.id)">
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
                    <v-toolbar-items v-if="item.processStepLogicList && item.processStepLogicList.length > 0">
                      <v-btn text @click="item.processStepLogicList = []">
                        <v-icon>clear</v-icon>
                        Clear All
                      </v-btn>
                    </v-toolbar-items>
                  </v-toolbar>
                  <v-card flat class="text-left">
                    <v-btn small class="ml-1 mr-1 mt-1"
                           v-for="(l, index) in filterBy(item.processStepLogicList, false, 'archived')" :key="index"
                           @click="l.archived = true">
                      {{l.processStepRequirementId ? l.requirementNbr : l.operationType}}
                    </v-btn>
                  </v-card>
                  <v-toolbar flat dense color="transparent">
                    <v-toolbar-title class="app-title">Available Operations</v-toolbar-title>
                  </v-toolbar>
                  <v-card flat class="text-left">
                    <v-btn small class="ml-1 mr-1 mt-1" v-for="(ot, index) in operationTypes" :key="index"
                           @click="item.processStepLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})">
                      {{ot.operationType}}
                    </v-btn>
                  </v-card>
                  <v-toolbar flat dense color="transparent">
                    <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
                  </v-toolbar>
                  <v-card flat class="text-left mb-4">
                    <v-btn small class="ml-1 mr-1 mt-1" v-for="r in requirements" :key="r.id"
                           @click="item.processStepLogicList.push({ requirementNbr: r.requirementNbr, processStepRequirementId: r.id, archived: false })">
                      {{r.requirementNbr}}
                    </v-btn>
                  </v-card>
                  <v-divider></v-divider>
                  <v-btn @click="updateAction(item)" class="mt-4">
                    <v-icon class="mr-2">save</v-icon>
                    Save Changes
                  </v-btn>
                </td>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">{{item.actionName}}</td>
                  <td class="text-left">{{item.actionType}}</td>
                  <td class="text-left">{{item.processStepStatusType || 'N/A'}}</td>
                  <td>
                    <div style="display: flex; float: right;">
                      <v-btn small text @click="actionExpanded = [item]; selectedActionIndex = index"
                             v-if="!actionExpanded.includes(item)">
                        <v-icon>edit</v-icon>
                      </v-btn>
                      <v-btn small text @click="actionExpanded = []; selectedActionIndex = index"
                             v-if="actionExpanded.includes(item)">cancel
                      </v-btn>
                      <v-dialog
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
                                color="primary"
                                text
                                @click="item.archived = true; deleteAction(item)">
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
      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import orderBy from 'lodash.orderby'

  export default {
    name: 'ProcessStepActions',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        headers: [
          {text: 'ID', value: 'requirementNbr', width: '65px', show: true},
          {text: 'Type', value: 'processStepRequirementType', show: true},
          {text: 'Details', value: 'custom', show: true},
          {text: 'Operator', value: 'operatorType', show: true},
          {text: 'Value', value: 'requirementValue', show: true},
          {text: null, value: 'icons', show: true}
        ],
        actionHeaders: [
          {text: 'Name', value: 'actionName', show: true},
          {text: 'Type', value: 'actionType', show: true},
          {text: 'Parent Status Change', value: 'processStepStatusType', show: true},
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

        requirements: [],
        availableFunctions: [],


        addNewAction: false,
        newAction: {},
        actions: [],
        statusTypes: [],
        expanded: [],
        actionExpanded: [],
        //todo: get these from endpoint but i am lazy right now
        actionTypes: [
          {id: 1, actionType: 'Link'},
          {id: 2, actionType: 'Button'}
        ],
        addChildProcess: false,
        selectedProcessStep: {},

        childProcessSteps: [],
        addChildLink: false,
        selectedLink: {},
        availableLinks: []
      }
    },
    computed: {},
    async created() {
      this.getRequirements()
      this.getActions()
      this.getStatusTypes()
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
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async selectRequirementType() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //1 == custom field, 2 == function
          if (this.newRequirement.processStepRequirementTypeId === 1) {
            this.loadParentObjects()
          } else {
            const {data} = await getRequest(`/function`)
            this.availableFunctions = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadParentObjects() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if (!this.parentObjects || this.parentObjects.length === 0) {
            const {data} = await getRequest(`/processStep/getParentObjects`, {params: {id: this.processStepId}})
            this.parentObjects = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadFunctionParams() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/function/${this.selectedFunction.id}/dynamicParams`)
          this.newRequirement.requirementParamDynamicValues = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadOperatorTypes(dataTypeId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/operator/${dataTypeId}`)
          this.operatorTypes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
        let invalidValue = (!this.newRequirement.requirementValue && !this.selectedDataTypeRequirement.id && !this.selectedListValue.id && this.selectedListOfValues.length === 0 )

        //if a secondary requirement is required check for a value there
        let invalidSecondaryValue = (this.selectedDataTypeRequirement.secondaryRequirement && !this.newRequirement.secondaryRequirementValue)

        return invalidParams || invalidValue || invalidSecondaryValue
      },
      async saveNewRequirement() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newRequirement.customFieldGroupAssignmentId = this.selectedCustomField.customFieldGroupAssignmentId
          this.newRequirement.companyFunctionId = this.selectedFunction.id
          this.newRequirement.processStepId = this.processStepId

          //adjust value of requirementValue as needed:
          if(this.newRequirement.customValue && this.selectedCustomField.listOfValueId && this.selectedCustomField.allowMultiple) {
            // if from list of values and allow multiple build the json array of selected ids
            this.newRequirement.listOfValueIds = this.selectedListOfValues.map(v => v.id)

            //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
            this.newRequirement.listOfValueId = null
            this.newRequirement.dataTypeRequirementId = null
            this.newRequirement.requirementValue = null
          } else if (this.newRequirement.customValue && this.selectedCustomField.listOfValueId && !this.selectedCustomField.allowMultiple) {
            //  if from a list of values and not allow multiple use the selected value id,
            this.newRequirement.listOfValueId = this.selectedListValue.id

            //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
            this.newRequirement.listOfValueIds = null
            this.newRequirement.dataTypeRequirementId = null
            this.newRequirement.requirementValue = null
          } else if (this.newRequirement.customValue) {
            //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
            this.newRequirement.listOfValueIds = null
            this.newRequirement.listOfValueId = null
            this.newRequirement.dataTypeRequirementId = null
          } else if (!this.newRequirement.customValue) {
            this.newRequirement.dataTypeRequirementId = this.selectedDataTypeRequirement.id

            //reset these in case they changed their selections around - it is possible to have all 4 values set because of changing values
            this.newRequirement.listOfValueIds = null
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
          if(requirement.customValue && requirement.listOfValues) {
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Requirement')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteRequirement(id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/requirement/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Requirement Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Requirement')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      //ACTIONS
      async getActions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/${this.processStepId}/action`)
          this.actions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
          this.newAction.processStepId = this.processStepId
          const {data} = await postRequest(`/processStep/${this.processStepId}/action`, this.newAction)
          this.actions.push(data)
          this.addNewAction = false
          this.newAction = {}
          this.snackbar = getSnackbar('SUCCESS', 'Action Added')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          action.processStepLogicList = action.processStepLogicList.filter(l => {
            return !l.archived
          })

          const {data} = await putRequest(`/processStep/${this.processStepId}/action`, action)
          // this forces the list to update the values displayed ... using action = data did not work
          action.actionType = data.actionType
          action.processStepStatusType = data.processStepStatusType
          action.processStepActionChildProcesses = data.processStepActionChildProcesses
          action.processStepActionLinks = data.processStepActionLinks
          this.actionExpanded = []
          this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/processStep/status`)
          this.statusTypes = orderBy(data, [s => s.processStepStatusType.toLowerCase()])
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteAction(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${item.id}`)
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      //child process steps
      async loadChildProcessSteps(actionId) {
        const {data} = await getRequest(`/processStep/${this.processStepId}/action/${actionId}/childProcessSteps`)
        this.childProcessSteps = data
      },
      async saveProcessStepToAction(action) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addChildStepToAction`, {
            processStepId: this.selectedProcessStep.id,
            displayOrder: 0,
            triggerAutomatically: !!this.selectedProcessStep.triggerAutomatically
          })
          action.processStepActionChildProcesses.push(data)
          this.selectedProcessStep = {}
          this.addChildProcess = false
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Added To Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Child Process Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteChildProcessFromAction(actionId, id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteChildStep/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Deleted From Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Child Process From Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateChildStep(actionId, childStep) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/action/${actionId}/updateActionChildStep`, childStep)
          this.snackbar = getSnackbar('SUCCESS', 'Child Process Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Child Process')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Link to Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteLinkFromAction(actionId, id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteLinkFromAction/${id}`)
          this.snackbar = getSnackbar('SUCCESS', 'Link Deleted From Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Link From Action')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadListOfValues(lovId, lovs) {
        if (!lovId && !lovs){
          return
        }
        try {
          let idToUse = lovId ? lovId : lovs[0].id
          const {data} = await getRequest(`/customField/listOfValuesByOption/${idToUse}`)
          this.listOfValues = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Available Values')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }

  }
</script>

<style scoped lang="scss">
  .params {
    width: 100%;
  }
</style>
