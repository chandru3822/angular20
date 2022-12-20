<template>
  <v-container class="pt-0">
    <ProcessStepRequirements :callback="populateRequirements"></ProcessStepRequirements>
    <v-divider></v-divider>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="action-header-bar">
          <v-toolbar-title class="app-title">Actions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="logicStringToggle = !logicStringToggle" text color="primary">
              {{ logicStringToggle ? 'View Logic as Numbers' : 'View Logic as Text' }}
            </v-btn>
            <v-btn @click="[addNewAction = !addNewAction, newAction.color = '#1F3C73', newAction.bgColor = '#878787']"
                   text color="primary" v-if="userCanAdd">
              <v-icon v-if="!addNewAction">add</v-icon>
              {{ addNewAction ? 'Cancel' : 'Add Action' }}
            </v-btn>
            <v-btn text color="primary" @click="expandActions = !expandActions">
              <v-icon v-if="!expandActions">mdi-chevron-down</v-icon>
              <v-icon v-else>mdi-chevron-up</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat color="primary lighten-9" class="square-card my-3 pa-3" v-if="addNewAction">
          <h3>Add New Action</h3>
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
          <div v-if="newAction.actionTypeId && newAction.actionTypeId !== 3">
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
          </div>
          <div v-else-if="newAction.actionTypeId">
            <v-textarea required label="Banner Content" auto-grow filled
                        style="margin: 15px 0 -15px 0"
                        v-model="newAction.content">
            </v-textarea>
            <div>
              <label>Banner Text Color:</label>
              <v-color-picker class="my-3"
                              v-model="newAction.color"
                              :canvas-height="colorOptions.height"
                              :width="colorOptions.width"
                              :mode="colorOptions.mode"
                              :hide-mode-switch="colorOptions.hideModeSwitch">
              </v-color-picker>
            </div>
            <div>
              <label>Banner Background Color:</label>
              <v-color-picker class="my-3"
                              v-model="newAction.bgColor"
                              :canvas-height="colorOptions.height"
                              :width="colorOptions.width"
                              :mode="colorOptions.mode"
                              :hide-mode-switch="colorOptions.hideModeSwitch">
              </v-color-picker>
            </div>
          </div>
          <v-btn color="primary" v-if="newAction.actionName && newAction.actionTypeId"
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
              <span class="default-text-color">No actions for this process step</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No actions for this process step</span>
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
                            :readonly="true"
                            :disabled="true"
                            label="Action Type"
                            item-text="actionType"
                            item-value="id"
                  ></v-select>
                  <div v-if="item.actionTypeId !== 3">
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
                  </div>
                  <div v-else>
                    <v-textarea required label="Banner Content" auto-grow filled
                                style="margin: 15px 0 -15px 0"
                                v-model="item.content">
                    </v-textarea>
                    <div>
                      <label>Banner Text Color:</label>
                      <v-color-picker class="my-3"
                                      v-model="item.color"
                                      :canvas-height="colorOptions.height"
                                      :width="colorOptions.width"
                                      :mode="colorOptions.mode"
                                      :hide-mode-switch="colorOptions.hideModeSwitch">
                      </v-color-picker>
                    </div>
                    <div>
                      <label>Banner Background Color:</label>
                      <v-color-picker class="my-3"
                                      v-model="item.bgColor"
                                      :canvas-height="colorOptions.height"
                                      :width="colorOptions.width"
                                      :mode="colorOptions.mode"
                                      :hide-mode-switch="colorOptions.hideModeSwitch">
                      </v-color-picker>
                    </div>
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
                          {{ al.link }}
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
                              class="text-h5 grey lighten-2"
                              primary-title
                            >
                              Confirm
                            </v-card-title>

                            <v-card-text>
                              Are you sure you want to delete <strong>{{ al.link }}</strong> from <strong>{{
                                item.actionName
                              }}</strong>?
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
                      <v-btn text color="primary" v-if="!addChildProcess && userCanAdd"
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
                      <v-btn
                        :disabled="!newChildProcessStep.processStepId || !newChildProcessStep.existingCompanyProcessStepStatusTypeId || !newChildProcessStep.initialCompanyProcessStepStatusTypeId"
                        @click="saveProcessStepToAction(item)" color="primary">
                        <v-icon>save</v-icon>
                        Save
                      </v-btn>
                      <v-btn class="ml-3" @click="[addChildProcess = false, newChildProcessStep = {}]" text
                             color="primary">
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
                          <td :colspan="headers.length" class="pa-4"
                              :class="{'shaded-row': item.processStepActionChildProcesses.indexOf(cp) % 2}">
                            <v-autocomplete v-model="cp.initialCompanyProcessStepStatusTypeId"
                                            :items="activeStatusesAssignedToStep"
                                            :disabled="!userCanEdit"
                                            label="Set initial status as:"
                                            item-text="processStepStatusType"
                                            item-value="id"
                                            attach
                            ></v-autocomplete>
                            <v-autocomplete v-model="cp.existingCompanyProcessStepStatusTypeId"
                                            :items="cancelledCompanyStatuses"
                                            :disabled="!userCanEdit"
                                            label="Set status of existing Active steps of the same type to:"
                                            item-text="processStepStatusType"
                                            item-value="id"
                                            attach
                            ></v-autocomplete>
                            <v-btn color="primary" class="white--text"
                                   v-if="userCanEdit"
                                   :disabled="!cp.existingCompanyProcessStepStatusTypeId || !cp.initialCompanyProcessStepStatusTypeId"
                                   @click="saveChildProcessCancelledStatus(item, cp)">Save Changes
                            </v-btn>
                          </td>
                        </tr>
                      </template>

                      <template #item="{ item:cp, index }">
                        <tr :class="{'shaded-row': index % 2}">
                          <td class="text-left"><a :href="`/settings/processStep/${cp.processStepId}/components`">{{ cp.processStepName }}</a></td>
                          <td class="text-left">{{ cp.initialProcessStepStatusType }}</td>
                          <td class="text-left">{{ cp.existingProcessStepStatusType }}</td>
                          <td class="text-right">
                            <v-btn text color="primary" v-if="!cpExpanded.includes(cp)"
                                   @click="[ cpExpanded = [cp], getStatusesAssignedToStep(cp), getCancelledStatuses(cp)]">
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
                                  class="text-h5 grey lighten-2"
                                  primary-title
                                >
                                  Confirm
                                </v-card-title>

                                <v-card-text>
                                  Are you sure you want to delete <strong>{{ cp.processStepName }}</strong> from
                                  <strong>{{
                                      item.actionName
                                    }}</strong>?
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
                      <v-btn text color="primary" v-if="!addChildFunction && userCanAdd"
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
                                    item-value="id"
                                    return-object
                                    attach
                                    @input="loadFunctionParams(selectedChildFunction.dbFunctionId, false)"
                    ></v-autocomplete>
                    <div v-if="selectedChildFunction.id && selectedChildRequirementParamDynamicValues.length > 0">
                      <h5 class="text-left">Dynamic Function Parameters</h5>
                      <v-card flat color="transparent">
                        <div v-for="(fp, index) in selectedChildRequirementParamDynamicValues">
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
                              type="number"
                              :key="index"
                              placeholder="Enter a dynamic value (number)"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></v-text-field>
                            <v-checkbox
                              v-else-if="fp.dataTypeId === 3"
                              type="checkbox"
                              :value-comparator="function (a, b) {
                                      return fp.dynamicValue === 'true'
                                    }"
                              :value="fp.dynamicValue === 'true'"
                              @change="changeBooleanValue($event, fp)"
                              :label="fp.parameterName"
                            />
                            <v-text-field
                              v-else
                              :key="index"
                              placeholder="Enter a dynamic value"
                              v-model="fp.dynamicValue"
                              :label="fp.parameterName"></v-text-field>
                          </div>
                        </div>
                      </v-card>
                    </div>
                    <div class="mt-3">
                      <v-btn :disabled="!selectedChildFunction.id" color="primary"
                             @click="saveFunctionToAction(item)">
                        <v-icon>save</v-icon>
                        Save
                      </v-btn>
                      <v-btn class="ml-3" @click="addChildFunction = false" text color="primary">
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
                          <v-list-item-title>{{ cp.companyFunctionName }}</v-list-item-title>
                          <div class="mt-2"
                               v-if="cp.actionParamDynamicValues && cp.actionParamDynamicValues.length > 0">
                            <h5 class="text-left">Dynamic Function Parameters</h5>
                            <v-card flat color="transparent">
                              <div v-for="(fp, index) in cp.actionParamDynamicValues" :key="index">
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
                                    placeholder="Enter a date"
                                    type="date"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-else-if="fp.dataTypeId === 2"
                                    placeholder="Enter a timestamp"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-checkbox
                                    v-else-if="fp.dataTypeId === 3"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    type="checkbox"
                                    :value-comparator="function (a, b) {
                                      return fp.dynamicValue === 'true'
                                    }"
                                    :value="fp.dynamicValue === 'true'"
                                    @change="changeBooleanValue($event, fp)"
                                    :label="fp.parameterName"
                                  />
                                  <v-text-field
                                    v-else-if="fp.dataTypeId === 4"
                                    type="number"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a number"
                                    v-model.number="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-else-if="fp.dataTypeId === 6"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter an integer"
                                    type="number"
                                    step="1"
                                    v-model.number="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-else
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a dynamic value"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                </div>
                              </div>
                            </v-card>
                          </div>
                          <v-list-item-subtitle>
                            <v-btn color="primary" class="white--text" v-if="cp.edit && userCanEdit"
                                   @click="updateChildFunction(item.id, cp)">
                              Save
                            </v-btn>
                          </v-list-item-subtitle>
                        </v-list-item-content>
                        <v-btn text color="primary" class="white--text" v-if="userCanEdit"
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
                              class="text-h5 grey lighten-2"
                              primary-title
                            >
                              Confirm
                            </v-card-title>

                            <v-card-text>
                              Are you sure you want to delete <strong>{{ cp.functionName }}</strong> from <strong>{{
                                item.actionName
                              }}</strong>?
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
                <!-- SMS MESSAGES CAN ONLY BE ADDED TO BUTTONS -->
                <div v-if="item.actionTypeId === 2">
                  <v-divider></v-divider>
                  <ActionChildSms :selected-action-index="selectedActionIndex"
                                  :action="item"
                                  :process-step-id="processStepId"
                                  :add-sms-callback="addSms"
                                  :delete-sms-callback="deleteSms"
                  ></ActionChildSms>
                </div>
                <v-divider class="mt-2"></v-divider>
                <v-toolbar flat dense color="transparent">
                  <v-toolbar-title class="app-title">
                    Current Logic
                    <v-dialog
                      v-if="item.processStepLogicList && item.processStepLogicList.length > 0 && !item.logicListChanged"
                      v-model="showActionLogicString"
                      width="500">
                      <template #activator="{ on }">
                        <v-btn text class="d-inline-block" @click="getActionLogicString(item.id)" v-on="on">
                          <v-icon>mdi-information</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="text-h5 grey lighten-2"
                          primary-title>
                          Action Logic String
                        </v-card-title>

                        <v-card-text class="pt-4">
                          {{ actionLogicString }}
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-btn @click="copyToClipBoard()">
                            Copy
                          </v-btn>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="showActionLogicString = false">
                            OK
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-toolbar-items
                    v-if="((item.processStepLogicList && item.processStepLogicList.length > 0) || item.alwaysEnabled) && userCanEdit">
                    <v-btn text
                           @click="[item.logicListChanged = true, item.logicMargin = 0, item.processStepLogicList = [], item.alwaysEnabled = false]">
                      <v-icon>clear</v-icon>
                      Clear All
                    </v-btn>
                  </v-toolbar-items>
                </v-toolbar>
                <v-card flat class="text-left px-3" color="transparent">
                  <div v-if="logicStringToggle">
                    <div v-for="(l, index) in filterBy(item.processStepLogicList, false, 'archived')"

                         :style="{'margin-left': getLogicMargin(l, item, index)}"
                         :key="index">
                      <v-btn small class="ml-1 mr-1 mt-1"
                             :disabled="!userCanEdit"
                             @click="[l.archived = true, item.logicListChanged = true]">
                        {{ getLogicButtonText(l) }}
                      </v-btn>
                    </div>
                  </div>
                  <div v-else>
                    <v-tooltip top max-width="300px"
                               v-for="(l, idx) in filterBy(item.processStepLogicList, false, 'archived')"
                               :key="idx">
                      <template v-slot:activator="{ on:tooltip }">
                        <v-btn small class="ml-1 mr-1 mt-1"
                               v-on="{ ...tooltip }"
                               :disabled="!userCanEdit"
                               @click="[l.archived = true, item.logicListChanged = true]">
                          {{ l.processStepRequirementId ? l.requirementNbr : l.operationType }}
                        </v-btn>
                      </template>
                      <span>{{ getLogicButtonText(l) }}</span>
                    </v-tooltip>
                  </div>
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
                  <v-btn small class="ml-1 mr-1 mt-1 primary--text" v-for="(ot, index) in operationTypes" :key="index"
                         :disabled="!userCanEdit"
                         @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})]">
                    {{ ot.operationType }}
                  </v-btn>
                  <v-btn small class="ml-1 mr-1 mt-1 primary--text"
                         :disabled="!userCanEdit"
                         @click="[item.logicListChanged = true, item.processStepLogicList = [], item.alwaysEnabled = true]">
                    Always Enabled
                  </v-btn>
                </v-card>
                <v-toolbar flat dense color="transparent">
                  <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
                </v-toolbar>
                <v-card flat class="text-left mb-4 px-3" color="transparent">
                  <v-tooltip top max-width="300px"
                             :disabled="logicStringToggle"
                             v-for="r in requirements" :key="r.id">
                    <template v-slot:activator="{ on:tooltip }">
                      <v-btn :class="{'d-block': logicStringToggle}"
                             small class="ml-1 mr-1 mt-1 primary--text"
                             :disabled="!userCanEdit"
                             v-on="{ ...tooltip }"
                             @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({ requirementNbr: r.requirementNbr, processStepRequirementId: r.id, archived: false, logicString: r.logicString })]">
                        {{ logicStringToggle ? getLogicButtonText(r) : r.requirementNbr }}
                      </v-btn>
                    </template>
                    <span>{{ getLogicButtonText(r) }}</span>
                  </v-tooltip>
                </v-card>
                <v-divider></v-divider>
                <div v-if="actionLogicError" class="error-text ml-3 mt-3">
                  <strong>* ERROR: </strong>{{ actionLogicErrorMsg }}
                </div>
                <v-btn v-if="userCanEdit" color="primary" @click="validateActionLogicString(item, true)"
                       class="mt-4 ml-3">
                  <v-icon class="mr-2">save</v-icon>
                  Save Changes
                </v-btn>
              </td>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': actions.indexOf(item) % 2}">
                <td style="width: 50px">
                  <v-btn text v-if="userCanEdit" icon small class="handle" color="primary">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">{{ item.actionName }}</td>
                <td class="text-left">{{ item.actionType }}</td>
                <td class="text-left">{{ item.processStepStatusType || 'N/A' }}</td>
                <td class="text-left">{{ item.projectStatusType || 'N/A' }}</td>
                <td>
                  <div style="display: flex; float: right;">
                    <v-btn small text color="primary"
                           v-if="userCanEdit"
                           @click="duplicateAction(item.id)">
                      <v-icon>mdi-content-copy</v-icon>
                    </v-btn>
                    <v-btn small text color="primary"
                           @click="[validateActionLogicString(item), actionExpanded = [item], selectedActionIndex = index]"
                           v-if="!actionExpanded.includes(item)">
                      <v-icon>edit</v-icon>
                    </v-btn>
                    <v-btn small text color="primary" @click="[actionExpanded = [], selectedActionIndex = index]"
                           v-if="actionExpanded.includes(item)">cancel
                    </v-btn>
                    <v-btn v-if="userCanEdit" small text color="primary" @click="[itemToDelete=item, showDeleteDialog=true]">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteAction" @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this action?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import cloneDeep from 'lodash.clonedeep'
import {getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
import {
  getActiveAssignedToProcessStep,
  getCompanyAssignedToProcessStep,
  getCancelledCompanyStatusTypesAssignedToProcessStep
} from '@/services/processStepStatusTypeService'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar
} from '@/helpers/helpers'
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import ProcessStepRequirements from './ProcessStepRequirements'
import ConfirmationDialog from "@/ConfirmationDialog";
import ActionChildSms from "@/views/flow/settings/processStep/ActionChildSms";

export default {
  name: 'ProcessStepActions',
  mixins: [Vue2Filters.mixin],
  components: {
    ActionChildSms,
    ConfirmationDialog,
    ProcessStepRequirements
  },

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
      colorOptions: {
        canvasHeight: 75,
        width: 200,
        mode: 'hexa',
        hideModeSwitch: true
      },
      dataTypeRequirements: [],
      selectedDataTypeRequirement: {},
      selectedCustomField: {},
      listOfValues: [],
      selectedListOfValues: [],
      selectedListValue: {},
      selectedFunction: {},
      showActionLogicString: false,
      actionLogicString: null,
      selectedRequirementIndex: null,
      selectedActionIndex: null,
      availableRequirementTypes: [],
      processStepId: parseInt(this.$route.params.id),
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

      logicStringToggle: false,
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
        {id: 2, actionType: 'Button'},
        {id: 3, actionType: 'Banner'}
      ],
      addChildProcess: false,
      addChildFunction: false,
      actionLogicError: false,
      actionLogicErrorMsg: '',
      actionSearch: '',
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
      invalidLasts: ['1', '3', '4', '5'],
      showDeleteDialog: false,
      itemToDelete: null
    }
  },
  computed: {},
  async created() {
    this.getActions()
    this.getStatusTypes()
    this.getCompanyProjectStatusTypes()
    this.getOperationTypes()
  },
  methods: {
    changeBooleanValue(e, fp) {
      this.$set(fp, 'dynamicValue', e == null ? 'false' : e.toString())
    },
    //populate requirements so that actions can use them any time they change from the requirements component
    populateRequirements(reqs) {
      this.requirements = reqs
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
    copyToClipBoard() {
      navigator.clipboard.writeText(this.actionLogicString);
      this.snackbar = getSnackbar('SUCCESS', 'Copied text to clipboard')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    },
    getLogicMargin(item, parentItem, index) {
      parentItem.logicMargin = parentItem.logicMargin || 0
      if (item.operationTypeId === 1) {
        if (parentItem.indexOfPreviousAdd !== undefined && parentItem.indexOfPreviousAdd === index - 1) {
          parentItem.logicMargin += 25
        }
        parentItem.indexOfPreviousAdd = index
        return parentItem.logicMargin + 'px'
      } else if (item.operationTypeId === 2) {
        parentItem.indexOfPreviousSubtract = index
        let placeholder = parentItem.logicMargin - 25
        parentItem.logicMargin -= 25
        return placeholder + 'px'
      } else {
        if (parentItem.indexOfPreviousAdd === index - 1) {
          parentItem.logicMargin += 25
        }
        return parentItem.logicMargin + 'px'
      }
    },
    getLogicButtonText(item) {

      if (item.logicString) {
        //this part make it work when clicking a requirement and adding to the current logic section, otherwise unused
        return item.logicString
      } else {
        if (null != item.requirementNbr) {
          //if not a system requirement (like AND, NOT, OR, etc)
          let value = ''
          if (item.dataTypeRequirement?.dataTypeValue) {
            value = item.dataTypeRequirement?.dataTypeValue
          } else if (item.listOfValue?.name) {
            value = item.listOfValue?.name
          } else if (item.listOfValues?.length > 0) {
            item.listOfValues.forEach((lv, idx) => {
              if (idx !== 0) {
                value = value + ', '
              }
              value = value + lv.name
            })
          } else if (item.requirementValue) {
            value = item.requirementValue
          } else {
            value = 'UNKNOWN CONTACT ADMIN'
          }
          if (null != item.secondaryRequirementValue) {
            value = value + ` (${item.secondaryRequirementValue})`
          }
          if ([1, 3, 4].includes(item.processStepRequirementTypeId)) {
            //custom field
            let textStart = item.processStepRequirementTypeId === 1 ? item.parentName : item.processStepRequirementType
            let logicString = textStart + ' - ' + item.fieldName + ' ' + item.operatorType + ' ' + value
            item.logicString = logicString
            return logicString
          } else if (item.processStepRequirementTypeId === 2) {
            //function
            let logicString = item.processStepRequirementType + ' - ' + item.companyFunctionName + ' ' + item.operatorType + ' ' + value
            item.logicString = logicString
            return logicString
          } else if ([7, 8, 9, 10].includes(item.processStepRequirementTypeId)) {
            //status (project or process step)
            let referenceText = item.referenceProcessStepName ? ` - ${item.referenceProcessStepName}` : ''
            let logicString = item.processStepRequirementType + referenceText + ' ' + item.operatorType + ' ' + value
            item.logicString = logicString
            return logicString
          }
        } else {
          //this returns if AND, OR, NOT, etc
          return item.operationType
        }
      }
    },
    addSms(actionId, smsItem) {
      this.actions.find(a => a.id === actionId).processStepActionChildSmsTemplates.push(smsItem)
    },
    deleteSms(actionId, id) {
      this.actions.find(a => a.id === actionId).processStepActionChildSmsTemplates = this.actions.find(a => a.id === actionId).processStepActionChildSmsTemplates.filter(st => {
        return st.id !== id
      })
    },
    async getActionLogicString(actionId) {
      try {
        const {data} = await getRequest(`/processStep/${this.processStepId}/action/${actionId}/logicString`)
        this.actionLogicString = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching logic string')
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
        const {data, status} = await getRequest(`/processStep/${this.processStepId}/action`)
        this.actions = data
        handleHidingGlobalLoader(this, status)
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
    async loadChildFunctions() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/function/action/4`)
        this.childFunctions = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveNewAction() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (!this.newAction.triggerAutomatically) {
          //if they unset the trigger automatically flag, then unset the timeBasedTrigger too.  has to be both to be time based
          this.newAction.timeBasedTrigger = false
        }
        //if action is a banner then null out all the regular action fields (in case they changed type a bunch)
        if (this.newAction.actionTypeId === 3) {
          this.newAction.companyProcessStepStatusTypeId = null
          this.newAction.companyProjectStatusTypeId = null
          this.newAction.companyProjectStatusTypeId = null
          this.newAction.removeProcessStepOwner = null
          this.newAction.triggerAutomatically = null
          this.newAction.hideFromMobile = null
          this.newAction.hideFromWeb = null
          this.newAction.triggerAutomatically = null
          this.newAction.timeBasedTrigger = null
        } else {
          //otherwise null out the banner fields
          this.newAction.content = null
          this.newAction.color = null
          this.newAction.bgColor = null
        }
        this.newAction.processStepId = this.processStepId
        const {data, status} = await postRequest(`/processStep/${this.processStepId}/action`, this.newAction)
        this.actions.push(data)
        this.addNewAction = false
        this.newAction = {}
        this.snackbar = getSnackbar('SUCCESS', 'Action Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async duplicateAction(actionId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/processStep/${this.processStepId}/action/${actionId}/duplicate`)
        this.actions.push(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Duplicating Action')
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

        const {data, status} = await putRequest(`/processStep/${this.processStepId}/action`, action)
        // this forces the list to update the values displayed ... using action = data did not work
        action.actionType = data.actionType
        action.logicListChanged = false
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
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Action')
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
    async getStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyAssignedToProcessStep(this.processStepId)
        this.statusTypes = data
        handleHidingGlobalLoader(this, status)
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
        const {data, status} = await getCompanyProjectStatusTypes()
        this.companyProjectStatusTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      }
    },
    async getOperationTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/operation`)
        this.operationTypes = orderBy(data, [o => o.operationType.toLowerCase()])
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAction() {
      const item = this.itemToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/action/${item.id}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.itemToDelete.archive = true
      this.closeDeleteDialog()
    },
    //child process steps
    async loadChildProcessSteps(actionId) {
      const {data} = await getRequest(`/processStep/${this.processStepId}/action/${actionId}/childProcessSteps`)
      this.childProcessSteps = data
    },
    async saveChildProcessCancelledStatus(action, cp) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await putRequest(`/processStep/${this.processStepId}/action/${action.id}/child/${cp.id}/status`, {
          existingCompanyProcessStepStatusTypeId: cp.existingCompanyProcessStepStatusTypeId,
          initialCompanyProcessStepStatusTypeId: cp.initialCompanyProcessStepStatusTypeId,
        })
        this.cpExpanded = []
        cp.existingProcessStepStatusType = data.existingProcessStepStatusType
        cp.initialProcessStepStatusType = data.initialProcessStepStatusType
        this.snackbar = getSnackbar('SUCCESS', 'Child Process Status Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {
          data,
          status
        } = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addChildStepToAction`, {
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
        handleHidingGlobalLoader(this, status)
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
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteChildStep/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Child Process Deleted From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Child Process From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFunctionToAction(action) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addChildFunctionToAction`, {
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
        handleHidingGlobalLoader(this, status)
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
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteChildFunction/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Child Function Deleted From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {status} = await putRequest(`/processStep/${this.processStepId}/action/${actionId}/updateActionChildFunction`, childFunction)
        this.snackbar = getSnackbar('SUCCESS', 'Child Process Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {data, status} = await getRequest(`/links/action/${actionId}`)
        this.availableLinks = data
        handleHidingGlobalLoader(this, status)
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
        const {
          data,
          status
        } = await postRequest(`/processStep/${this.processStepId}/action/${action.id}/addLinkToAction`, {
          linkId: this.selectedLink.id
        })
        action.processStepActionLinks.push(data)
        this.selectedLink = {}
        this.addChildLink = false
        this.snackbar = getSnackbar('SUCCESS', 'Link Added to Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/action/${actionId}/deleteLinkFromAction/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Link Deleted From Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
          const {status} = await putRequest(`/processStep/${this.processStepId}/action/order`, rows)
          this.snackbar = getSnackbar('SUCCESS', 'Action Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Action Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },

    validateActionLogicString(item, saveChanges) {
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
        if (id === 1) {
          openCount++
        } else if (id === 2) {
          closeCount++
        }
        //after each id, check if close > open. if so, there is a problem
        if (closeCount > openCount) {
          parenProblem = true
        }
      })

      // turn the operation type ids into a string we can compare to invalid sequences
      let operationTypeString = operationTypeIds?.toString()

      // get the first and last operations to compare to invalid first and last options
      let firstOperationTypeId = operationTypeString?.charAt(0)
      let lastOperationTypeId = operationTypeString?.slice(-1)

      if (countOpenParen !== countCloseParen || parenProblem) {
        this.actionLogicError = true
        this.actionLogicErrorMsg = 'Logic is missing opening or closing parenthesis.'
      } else if (this.invalidTypeCombos.some(v => operationTypeString?.includes(v))) {
        this.actionLogicError = true
        this.actionLogicErrorMsg = 'Logic is invalid.'
      } else if (this.invalidFirsts.includes(firstOperationTypeId)) {
        this.actionLogicError = true
        this.actionLogicErrorMsg = 'Invalid first logic operation.'
      } else if (this.invalidLasts.includes(lastOperationTypeId)) {
        this.actionLogicError = true
        this.actionLogicErrorMsg = 'Invalid last logic operation.'
      } else {
        this.actionLogicError = false
        this.actionLogicErrorMsg = ''
        if (saveChanges) {
          this.updateAction(item)
        }
      }
    },
    closeDeleteDialog() {
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

.dynamic-field-container {
  width: 80%;
  display: inline-block;
}

.action-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}
</style>
