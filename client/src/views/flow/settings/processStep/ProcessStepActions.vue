<template>
  <v-container class="pt-0">
    <ProcessStepRequirements :callback="populateRequirements"></ProcessStepRequirements>
    <v-divider></v-divider>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="action-header-bar">
          <v-toolbar-title class="title-large">Actions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                @click="logicStringToggle = !logicStringToggle"
                variant="text"
                color="primary"
                :prepend-icon="$vuetify.breakpoint.smAndDown && logicStringToggle ? 'mdi-numeric' : $vuetify.breakpoint.smAndDown ? 'mdi-alphabetical' : ''"
                :text="logicStringToggle ? 'VIEW LOGIC AS NUMBERS' : 'VIEW LOGIC AS TEXT'">
            </a-btn>
            <a-btn
                @click="[addNewAction = !addNewAction, newAction.color = '#1F3C73', newAction.bgColor = '#878787']"
                variant="text"
                color="primary"
                v-if="userCanAdd"
                id="qa-add-action-button"
                :prepend-icon="!addNewAction ? 'add' : $vuetify.breakpoint.smAndDown ? 'close' : ''"
                :text="addNewAction ? 'Cancel' : 'Add Action'"
            ></a-btn>

            <a-btn
                variant="text"
                color="primary"
                @click="expandActions = !expandActions"
                :prepend-icon="!expandActions ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            ></a-btn>

          </v-toolbar-items>
        </v-toolbar>
        <v-card flat color="primary lighten-9" class="square-card my-3 pa-3" v-if="addNewAction">
          <h3>Add New Action</h3>
          <a-text-field v-model="newAction.actionName"
                        placeholder="Enter a name"
                        label="Action Name">
          </a-text-field>
          <a-select attach v-model="newAction.actionTypeId"
                    :items="actionTypes"
                    label="Action Type"
                    item-title="actionType"
                    item-value="id"
          ></a-select>
          <div v-if="newAction.actionTypeId && newAction.actionTypeId !== 3">
            <a-select attach v-model="newAction.companyProcessStepStatusTypeId"
                      :items="statusTypes"
                      :clearable="true"
                      label="Action changes status of parent process step to"
                      item-title="processStepStatusType"
                      item-value="id"
            ></a-select>
            <a-select attach v-model="newAction.companyProjectStatusTypeId"
                      :items="companyProjectStatusTypes"
                      :clearable="true"
                      label="Action changes project status to"
                      item-title="projectStatusType"
                      item-value="id"
            ></a-select>
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
            <a-textarea required label="Banner Content" auto-grow variant="filled"
                        style="margin: 15px 0 -15px 0"
                        v-model="newAction.content">
            </a-textarea>
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
          <a-btn
              color="primary"
              v-if="newAction.actionName && newAction.actionTypeId"
              @click="saveNewAction"
              prepend-icon="save"
              text="Save"
          ></a-btn>

        </v-card>
        <v-card flat v-if="expandActions">
          <v-data-table
              :headers="actionHeaders"
              :items="filteredActions"
              :items-per-page="-1"
              single-expand
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              :expanded.sync="actionExpanded"
              hide-default-footer
              class="action-table elevation-1 expanded-row-flatten table-striped"
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
                  <a-text-field v-model="item.actionName"
                                placeholder="Enter a name"
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                label="Action Name">
                  </a-text-field>
                  <a-select attach v-model="item.actionTypeId"
                            :items="actionTypes"
                            :readonly="true"
                            :disabled="true"
                            label="Action Type"
                            item-title="actionType"
                            item-value="id"
                  ></a-select>
                  <div v-if="item.actionTypeId !== 3">
                    <a-select attach v-model="item.companyProcessStepStatusTypeId"
                              :items="statusTypes"
                              :clearable="userCanEdit"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                              label="Action changes status of parent process step to"
                              item-title="processStepStatusType"
                              item-value="id"
                    ></a-select>
                    <a-select attach v-model="item.companyProjectStatusTypeId"
                              :items="companyProjectStatusTypes"
                              :clearable="true"
                              label="Action changes project status to"
                              item-title="projectStatusType"
                              item-value="id"
                    ></a-select>
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
                        <v-toolbar-title class="title-large">
                          Child Links
                        </v-toolbar-title>
                        <v-spacer></v-spacer>
                        <v-toolbar-items>
                          <a-btn
                              v-if="!addChildLink && userCanEdit"
                              variant="text"
                              color="primary"
                              @click="[addChildLink = true, loadLinks(item.id)]"
                              prepend-icon="add"
                          ></a-btn>

                        </v-toolbar-items>
                      </v-toolbar>
                      <v-card class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                              v-if="addChildLink">
                        <h3>Add Child Link</h3>
                        <a-select attach v-model="selectedLink"
                                  :items="availableLinks"
                                  label="Available Links"
                                  item-title="link"
                                  return-object
                                  @input="saveLinkToAction(item)"
                        ></a-select>
                        <a-btn
                            variant="text"
                            color="primary"
                            @click="addChildLink = false"
                            prepend-icon="remove"
                            text="Cancel"
                        ></a-btn>

                      </v-card>
                    </div>
                  </div>
                  <div v-else>
                    <a-textarea required label="Banner Content" auto-grow variant="filled"
                                style="margin: 15px 0 -15px 0"
                                v-model="item.content">
                    </a-textarea>
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
                    <v-list v-for="(al, index) in item.processStepActionLinks.filter(a => !a.archived)"
                            :key="index"
                            :class="{ 'shaded-row': index % 2 }">
                      <v-list-item>
                        <v-list-item-content class="text-left">
                          {{ al.link }}
                        </v-list-item-content>
                        <v-list-item-action class="clickable"
                                            @click="[linkToDelete=al, parentActionForChildToDelete=item]">
                          <v-icon color="primary">delete</v-icon>
                        </v-list-item-action>
                      </v-list-item>
                    </v-list>
                  </v-col>
                </v-row>
                <!-- BUTTON -->
                <div v-if="item.actionTypeId === 2">
                  <v-divider></v-divider>
                  <v-toolbar flat color="transparent">
                    <v-toolbar-title class="title-large">
                      Child Process Steps
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                      <a-btn
                          variant="text"
                          color="primary"
                          v-if="!addChildProcess && userCanAdd"
                          @click="[addChildProcess = true, loadChildProcessSteps(item.id)]"
                          prepend-icon="add"
                      ></a-btn>
                    </v-toolbar-items>
                  </v-toolbar>
                  <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                          v-if="addChildProcess">
                    <h3>Add Child Process Step</h3>
                    <a-autocomplete v-model="newChildProcessStep.processStepId"
                                    :items="childProcessSteps"
                                    label="Process Step"
                                    @input="[getCancelledStatuses(newChildProcessStep), getStatusesAssignedToStep(newChildProcessStep)]"
                                    item-title="processStepName"
                                    item-value="id"
                                    attach
                    ></a-autocomplete>
                    <a-autocomplete v-model="newChildProcessStep.initialCompanyProcessStepStatusTypeId"
                                    :items="activeStatusesAssignedToStep"
                                    label="Set initial status to:"
                                    item-title="processStepStatusType"
                                    :item-title="item => `${item.processStepStatusType} - (${item.rootProcessStepStatusType})`"
                                    item-value="id"
                                    attach>
                    </a-autocomplete>
                    <a-autocomplete v-model="newChildProcessStep.existingCompanyProcessStepStatusTypeId"
                                    :items="cancelledCompanyStatuses"
                                    label="Set status of existing Active steps of the same type to:"
                                    :item-title="item => `${item.processStepStatusType} - (${item.rootProcessStepStatusType})`"
                                    item-value="id"
                                    attach>
                    </a-autocomplete>
                    <div class="mt-3">
                      <a-btn
                          :disabled="!newChildProcessStep.processStepId || !newChildProcessStep.existingCompanyProcessStepStatusTypeId || !newChildProcessStep.initialCompanyProcessStepStatusTypeId"
                          @click="saveProcessStepToAction(item)"
                          color="primary"
                          prepend-icon="save"
                          text="Save"
                      ></a-btn>
                      <a-btn
                          class="ml-3"
                          @click="[addChildProcess = false, newChildProcessStep = {}]"
                          variant="text"
                          color="primary"
                          prepend-icon="remove"
                          text="Cancel"
                      ></a-btn>
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
                            <a-autocomplete v-model="cp.initialCompanyProcessStepStatusTypeId"
                                            :items="activeStatusesAssignedToStep"
                                            :disabled="!userCanEdit"
                                            label="Set initial status as:"
                                            item-title="processStepStatusType"
                                            item-value="id"
                                            attach
                            ></a-autocomplete>
                            <a-autocomplete v-model="cp.existingCompanyProcessStepStatusTypeId"
                                            :items="cancelledCompanyStatuses"
                                            :disabled="!userCanEdit"
                                            label="Set status of existing Active steps of the same type to:"
                                            item-title="processStepStatusType"
                                            item-value="id"
                                            attach
                            ></a-autocomplete>
                            <a-btn
                                color="primary"
                                class=""
                                v-if="userCanEdit"
                                :disabled="!cp.existingCompanyProcessStepStatusTypeId || !cp.initialCompanyProcessStepStatusTypeId"
                                @click="saveChildProcessCancelledStatus(item, cp)"
                                text="Save Changes"
                            ></a-btn>
                          </td>
                        </tr>
                      </template>

                      <template #item.processStepName="{item:cp}" class="text-left"><a
                          :href="`/settings/processStep/${cp.processStepId}/components`">{{ cp.processStepName }}</a>
                      </template>
                      <template #item.initialProcessStepStatusType="{item:cp}" class="text-left">
                        {{ cp.initialProcessStepStatusType }}
                      </template>
                      <template #item.existingProcessStepStatusType="{item:cp}" class="text-left">
                        {{ cp.existingProcessStepStatusType }}
                      </template>
                      <template #item.icons="{item:cp}" class="text-right">
                        <a-btn
                            variant="text"
                            color="primary"
                            v-if="!cpExpanded.includes(cp)"
                            @click="[ cpExpanded = [cp], getStatusesAssignedToStep(cp), getCancelledStatuses(cp)]"
                            prepend-icon="edit"
                        ></a-btn>
                        <a-btn
                            size="small"
                            variant="text"
                            v-if="cpExpanded.includes(cp)"
                            @click="cpExpanded = []"
                            text="cancel"
                        ></a-btn>
                        <a-btn
                            variant="text"
                            color="primary"
                            @click="[childProcessToDelete = cp, parentActionForChildToDelete = item]"
                            prepend-icon="delete"
                        ></a-btn>
                      </template>
                    </v-data-table>

                  </v-col>
                </v-row>
                <!-- FUNCTIONS CAN ONLY BE ADDED TO BUTTONS -->
                <div v-if="item.actionTypeId === 2">
                  <v-divider></v-divider>
                  <v-toolbar flat color="transparent">
                    <v-toolbar-title class="title-large">
                      Child Functions
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                      <a-btn
                          variant="text"
                          color="primary"
                          v-if="!addChildFunction && userCanAdd"
                          @click="[addChildFunction = true, loadChildFunctions(item.id)]"
                          prepend-icon="add"
                      ></a-btn>
                    </v-toolbar-items>
                  </v-toolbar>
                  <v-card flat class="pa-3" color="transparent" :class="{'shaded-row': !(selectedActionIndex % 2)}"
                          v-if="addChildFunction">
                    <h3>Add Child Function</h3>
                    <a-autocomplete v-model="selectedChildFunction"
                                    :items="childFunctions"
                                    label="Function"
                                    item-title="companyFunctionName"
                                    item-value="id"
                                    return-object
                                    attach
                                    @input="loadFunctionParams(selectedChildFunction.dbFunctionId, false)"
                    ></a-autocomplete>
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
                              <a-btn
                                  variant="text"
                                  class="d-inline-block"
                                  :activation-handler="on"
                                  prepend-icon="mdi-information">
                              </a-btn>

                            </template>
                            <pre class="app-pre-wrapper">{{ fp.description }}</pre>
                          </v-tooltip>
                          <div class="dynamic-field-container">
                            <a-text-field
                                v-if="fp.dataTypeId === 4 || fp.dataTypeId === 6"
                                type="number"
                                :key="index"
                                placeholder="Enter a dynamic value (number)"
                                v-model="fp.dynamicValue"
                                :label="fp.parameterName"></a-text-field>
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
                            <a-text-field
                                v-else
                                :key="index"
                                placeholder="Enter a dynamic value"
                                v-model="fp.dynamicValue"
                                :label="fp.parameterName"></a-text-field>
                          </div>
                        </div>
                      </v-card>
                    </div>
                    <div class="mt-3">
                      <a-btn
                          :disabled="!selectedChildFunction.id"
                          color="primary"
                          @click="saveFunctionToAction(item)"
                          prepend-icon="save"
                          text="Save"
                      ></a-btn>
                      <a-btn
                          class="ml-3"
                          @click="addChildFunction = false"
                          variant="text"
                          color="primary"
                          prepend-icon="remove"
                          text="Cancel"
                      ></a-btn>
                    </div>
                  </v-card>
                </div>
                <v-row justify="center" class="pl-3 pr-3"
                       v-if="item.actionTypeId === 2 && item.processStepActionChildFunctions && item.processStepActionChildFunctions.length > 0">
                  <v-col cols="12" class="pt-0">
                    <draggable v-model="item.processStepActionChildFunctions"
                               v-if="item.processStepActionChildFunctions && item.processStepActionChildFunctions.length > 0"
                               :disabled="!userCanEdit"
                               group="customFields" @start="drag=true" @end="drag=false"
                               @change="saveChildFunctionOrder(item.id, item.processStepActionChildFunctions)">
                      <v-list v-for="(cp, index) in item.processStepActionChildFunctions.filter(a => !a.archived)"
                              :key="index"
                              :class="{ 'shaded-row': index % 2 }">
                        <v-list-item class="grab">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
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
                                      <a-btn
                                          variant="text"
                                          class="d-inline-block"
                                          v-bind="attrs"
                                          :activation-handler="on"
                                          prepend-icon="mdi-information"
                                      ></a-btn>
                                    </template>
                                    <pre class="app-pre-wrapper">{{ fp.description }}</pre>
                                  </v-tooltip>
                                  <div class="dynamic-field-container">
                                    <a-text-field
                                        v-if="fp.dataTypeId === 1"
                                        placeholder="Enter a date"
                                        type="date"
                                        :readonly="!cp.edit || !userCanEdit"
                                        :disabled="!cp.edit || !userCanEdit"
                                        v-model="fp.dynamicValue"
                                        :label="fp.parameterName"></a-text-field>
                                    <a-text-field
                                        v-else-if="fp.dataTypeId === 2"
                                        placeholder="Enter a timestamp"
                                        :readonly="!cp.edit || !userCanEdit"
                                        :disabled="!cp.edit || !userCanEdit"
                                        v-model="fp.dynamicValue"
                                        :label="fp.parameterName"></a-text-field>
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
                                    <a-text-field
                                        v-else-if="fp.dataTypeId === 4"
                                        type="number"
                                        :readonly="!cp.edit || !userCanEdit"
                                        :disabled="!cp.edit || !userCanEdit"
                                        placeholder="Enter a number"
                                        v-model.number="fp.dynamicValue"
                                        :label="fp.parameterName"></a-text-field>
                                    <a-text-field
                                        v-else-if="fp.dataTypeId === 6"
                                        :readonly="!cp.edit || !userCanEdit"
                                        :disabled="!cp.edit || !userCanEdit"
                                        placeholder="Enter an integer"
                                        type="number"
                                        step="1"
                                        v-model.number="fp.dynamicValue"
                                        :label="fp.parameterName"></a-text-field>
                                    <a-text-field
                                        v-else
                                        :readonly="!cp.edit || !userCanEdit"
                                        :disabled="!cp.edit || !userCanEdit"
                                        placeholder="Enter a dynamic value"
                                        v-model="fp.dynamicValue"
                                        :label="fp.parameterName"></a-text-field>
                                  </div>
                                </div>
                              </v-card>
                            </div>
                            <v-list-item-subtitle>
                              <a-btn
                                  color="primary"
                                  class=""
                                  v-if="cp.edit && userCanEdit"
                                  @click="updateChildFunction(item.id, cp)"
                                  text="Save"
                              ></a-btn>
                            </v-list-item-subtitle>
                          </v-list-item-content>
                          <a-btn
                              variant="text"
                              color="primary"
                              class=""
                              v-if="userCanEdit"
                              @click="cp.edit = !cp.edit"
                              :prepend-icon="cp.edit ? 'remove' : 'edit'"
                          ></a-btn>
                          <v-list-item-action class="clickable"
                                              @click="[childFunctionToDelete = cp, parentActionForChildToDelete = item]">
                            <v-icon>delete</v-icon>
                          </v-list-item-action>
                        </v-list-item>
                      </v-list>
                    </draggable>
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
                  <v-toolbar-title class="title-large">
                    Current Logic
                    <a-btn
                        variant="text"
                        class="d-inline-block"
                        color="primary"
                        @click="getActionLogicString(item.id)"
                        prepend-icon="mdi-information"
                    ></a-btn>
                  </v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-toolbar-items
                      v-if="((item.processStepLogicList && item.processStepLogicList.length > 0) || item.alwaysEnabled) && userCanEdit">
                    <a-btn
                        variant="text"
                        color="primary"
                        @click="[item.logicListChanged = true, item.logicMargin = 0, item.processStepLogicList = [], item.alwaysEnabled = false]"
                        prepend-icon="clear"
                        text="Clear All"
                    ></a-btn>
                  </v-toolbar-items>
                </v-toolbar>
                <v-card flat class="text-left px-3" color="transparent">
                  <div>
                    <draggable v-if="userCanEdit" v-model="item.processStepLogicList"
                               group="processStepLogicList" @start="drag=true" @end="drag=false"
                               @change="actionLogicOrderChanged(item)">
                      <span v-for="(l, index) in item.processStepLogicList.filter(a => !a.archived)"
                           :style="{'margin-left': getLogicMargin(l, item, index)}"
                           :key="index">
                        <v-tooltip top max-width="300px"
                        >
                          <template v-slot:activator="{ on:tooltip }">
                            <a-btn
                                size="small"
                                color="unset"
                                class="ml-1 mr-1 mt-1"
                                :activation-handler="tooltip"
                                v-on="{ ...tooltip }"
                                :disabled="!userCanEdit"
                                @click="[l.archived = true, item.logicListChanged = true]"

                            >
                              {{!logicStringToggle && l.requirementNbr ? l.requirementNbr : getLogicButtonText(l)}}
                            </a-btn>
                          </template>
                          <span>{{ logicStringToggle && l.requirementNbr ? l.requirementNbr : getLogicButtonText(l) }}</span>
                        </v-tooltip>
                      </span>
                    </draggable>
                  </div>
                  <a-btn
                      size="small"
                      color="unset"
                      class="ml-1 mr-1 mt-1 primary--text"
                      v-if="item.alwaysEnabled"
                      :disabled="!userCanEdit"
                      @click="[item.logicListChanged = true, item.alwaysEnabled = !item.alwaysEnabled]"
                      text="ALWAYS ENABLED"
                  ></a-btn>
                </v-card>
                <v-toolbar flat dense color="transparent">
                  <v-toolbar-title class="title-large">Available Operations</v-toolbar-title>
                </v-toolbar>
                <v-card flat class="text-left px-3" color="transparent">
                  <a-btn
                      size="small"
                      class="ml-1 mr-1 mt-1 primary--text"
                      v-for="(ot, index) in operationTypes"
                      :key="index"
                      :disabled="!userCanEdit"
                      @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})]"
                      color="unset"
                      :text=" ot.operationType "
                  ></a-btn>
                  <a-btn
                      size="small"
                      class="ml-1 mr-1 mt-1 primary--text"
                      :disabled="!userCanEdit"
                      @click="[item.logicListChanged = true, item.processStepLogicList = [], item.alwaysEnabled = true]"
                      color="unset"
                      text="Always Enabled"
                  ></a-btn>
                </v-card>
                <v-toolbar flat dense color="transparent">
                  <v-toolbar-title class="title-large">Requirements</v-toolbar-title>
                </v-toolbar>
                <v-card flat class="text-left mb-4 px-3" color="transparent">
                  <v-tooltip top max-width="300px"
                             v-for="r in requirements" :key="r.id">
                    <template v-slot:activator="{ on:tooltip }">
                      <a-btn
                          :class="{'d-block': logicStringToggle}"
                          size="small"
                          class="ml-1 mr-1 mt-1 primary--text"
                          :disabled="!userCanEdit"
                          v-on="{ ...tooltip }"
                          :activation-handler="tooltip"
                          @click="[item.logicListChanged = true, item.alwaysEnabled = false, item.processStepLogicList.push({ requirementNbr: r.requirementNbr, processStepRequirementId: r.id, archived: false, logicString: r.logicString, sqlOrder: (item.processStepLogicList[item.processStepLogicList?.length - 1]?.sqlOrder + 1) }), actionLogicOrderChanged(item)]"
                          color="unset"
                      > {{ logicStringToggle ? getLogicButtonText(r) : r.requirementNbr }}
                      </a-btn>
                    </template>
                    <span>{{ logicStringToggle && r.requirementNbr ? r.requirementNbr : getLogicButtonText(r) }}</span>
                  </v-tooltip>
                </v-card>
                <v-divider></v-divider>
                <div v-if="actionLogicError" class="error-text ml-3 mt-3">
                  <strong>* ERROR: </strong>{{ actionLogicErrorMsg }}
                </div>
                <a-btn
                    v-if="userCanEdit"
                    color="primary"
                    @click="validateActionLogicString(item, true)"
                    class="mt-4 ml-3"
                    prepend-icon="save"
                    text="Save Changes"
                ></a-btn>
              </td>
            </template>

            <template #item.draggable="{item}" style="width: 50px">
              <a-btn
                  variant="text"
                  v-if="userCanEdit"
                  icon
                  size="small"
                  class="handle"
                  color="primary"
                  prepend-icon="drag_handle"
              ></a-btn>
            </template>
            <template #item.actionName="{item}" class="text-left">{{ item.actionName }}</template>
            <template #item.actionType="{item}" class="text-left">{{ item.actionType }}</template>
            <template #item.processStepStatusType="{item}" class="text-left">{{
                item.processStepStatusType || 'N/A'
              }}
            </template>
            <template #item.projectStatusType="{item}" class="text-left">{{
                item.projectStatusType || 'N/A'
              }}
            </template>
            <template #item.icons="{item, index}">
              <div style="display: flex; float: right;">
                <v-tooltip left small>
                  <template v-slot:activator="{on, attrs}">
                    <a-btn
                        size="small"
                        variant="text"
                        color="primary"
                        :class="{'squished-btn':$vuetify.breakpoint.smAndDown}"
                        v-if="userCanEdit"
                        v-bind="attrs"
                        :activation-handler="on"
                        @click="duplicateAction(item.id)"
                        prepend-icon="mdi-content-copy"
                    ></a-btn>
                  </template>
                  <span class="label-small">Duplicate action</span>
                </v-tooltip>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    :class="{'squished-btn':$vuetify.breakpoint.smAndDown}"
                    @click="[validateActionLogicString(item), actionExpanded = [item], selectedActionIndex = index]"
                    v-if="!actionExpanded.includes(item)"
                    prepend-icon="edit"
                ></a-btn>
                <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    :class="{'squished-btn':$vuetify.breakpoint.smAndDown}"
                    @click="[actionExpanded = [], selectedActionIndex = index]"
                    v-if="actionExpanded.includes(item)"
                    :prepend-icon="$vuetify.breakpoint.smAndDown ? 'close' : ''"
                    :text="!$vuetify.breakpoint.smAndDown ? 'Cancel' : ''"
                ></a-btn>
                <a-btn
                    v-if="userCanEdit"
                    :class="{'squished-btn':$vuetify.breakpoint.smAndDown}"
                    size="small"
                    variant="text"
                    color="primary"
                    @click="[itemToDelete=item, showDeleteDialog=true]"
                    prepend-icon="delete"
                ></a-btn>
              </div>
            </template>

          </v-data-table>
        </v-card>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteAction" @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this action?
      <div class="pt-2"><b>Action Name:</b> {{ itemToDelete?.actionName }}</div>
      <div><b>Type:</b> {{ itemToDelete?.actionType }}</div>
      <div><b>Parent Status Change:</b> {{ itemToDelete?.processStepStatusType || 'N/A' }}</div>
      <div><b>Project Status Change:</b> {{ itemToDelete?.projectStatusType || 'N/A' }}</div>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!linkToDelete" @confirm="deleteLinkFromAction"
                        @close-dialog="closeLinkDeleteDialog">
      Are you sure you want to delete <strong>{{ linkToDelete?.link }}</strong> from <strong>{{
        parentActionForChildToDelete?.actionName
      }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!childProcessToDelete" @confirm="deleteChildProcessFromAction"
                        @close-dialog="closeChildProcessDialog">
      Are you sure you want to delete <strong>{{ childProcessToDelete?.processStepName }}</strong> from
      <strong>{{ parentActionForChildToDelete?.actionName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!childFunctionToDelete" @confirm="deleteChildFunctionFromAction"
                        @close-dialog="closeChildFunctionDialog">
      Are you sure you want to delete <strong>{{ childFunctionToDelete?.companyFunctionName }}</strong> from
      <strong>{{ parentActionForChildToDelete?.actionName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="showLogicInfoDialog" @confirm="copyToClipBoard"
                        @close-dialog="closeLogicInfoDialog">
      <template v-slot:title>Action Logic String</template>
      {{ actionLogicString }}
      <template v-slot:yes>Copy</template>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import cloneDeep from 'lodash.clonedeep'

import draggable from 'vuedraggable'
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
  defineSortableTable
} from '@/helpers/helpers'
import orderBy from 'lodash.orderby'
import ProcessStepRequirements from './ProcessStepRequirements'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import ActionChildSms from "@/views/flow/settings/processStep/ActionChildSms";

import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute} from "vue-router/composables";
import {useAppStore} from '@/stores/AppStore.js'

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const appStore = useAppStore()

const expandRequirements = ref(true)
const expandActions = ref(true)
const deleteError = ref(false)
const dragging = ref(false)
const actionsUsingLogic = ref([])
const invalidRequirement = ref(true)
const headers = ref([
  {text: 'ID', value: 'requirementNbr', width: '65px', show: true},
  {text: 'Type', value: 'processStepRequirementType', show: true},
  {text: 'Details', value: 'custom', show: true},
  {text: 'Operator', value: 'operatorType', show: true},
  {text: 'Value', value: 'requirementValue', show: true},
  {text: null, value: 'icons', show: true}
])
const actionHeaders = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Name', value: 'actionName', show: true},
  {text: 'Type', value: 'actionType', show: true},
  {text: 'Parent Status Change', value: 'processStepStatusType', show: true},
  {text: 'Project Status Change', value: 'projectStatusType', show: true},
  {text: null, value: 'icons', show: true}
])
const childProcessStepHeaders = ref([
  {text: 'Child Step', value: 'processStepName', show: true},
  {text: 'Initial Status', value: 'initialProcessStepStatusType', show: true},
  {text: 'Status for any Existing Active', value: 'existingProcessStepStatusType', show: true},
  {text: null, value: 'icons', show: true}
])
const addNewRequirement = ref(false)
const newRequirement = ref({
  requirementParamDynamicValues: [],
  customValue: false
})
const colorOptions = ref({
  canvasHeight: 75,
  width: 200,
  mode: 'hexa',
  hideModeSwitch: true
})
const dataTypeRequirements = ref([])
const selectedDataTypeRequirement = ref({})
const selectedCustomField = ref({})
const listOfValues = ref([])
const selectedListOfValues = ref([])
const selectedListValue = ref({})
const selectedFunction = ref({})
const showActionLogicString = ref(false)
const actionLogicString = ref(null)
const selectedRequirementIndex = ref(null)
const selectedActionIndex = ref(null)
const availableRequirementTypes = ref([])
const parentObjects = ref([])
const parent = ref({})
const customFields = ref([])
const operatorTypes = ref([])
const operationTypes = ref([])
const selectedProcessStepStatus = ref({})
const processStepStatuses = ref([])
const requirements = ref([])
const availableFunctions = ref([])
const logicStringToggle = ref(false)
const addNewAction = ref(false)
const newAction = ref({})
const actions = ref([])
const statusTypes = ref([])
const companyProjectStatusTypes = ref([])
const expanded = ref([])
const cpExpanded = ref([])
const actionExpanded = ref([])
const actionTypes = ref([
  {id: 1, actionType: 'Link'},
  {id: 2, actionType: 'Button'},
  {id: 3, actionType: 'Banner'}
])
const addChildProcess = ref(false)
const addChildFunction = ref(false)
const actionLogicError = ref(false)
const actionLogicErrorMsg = ref('')
const actionSearch = ref('')
const newChildProcessStep = ref({})
const cancelledCompanyStatuses = ref([])
const activeStatusesAssignedToStep = ref([])
const selectedChildFunction = ref({})
const selectedChildRequirementParamDynamicValues = ref([])
const childProcessSteps = ref([])
const childFunctions = ref([])
const addChildLink = ref(false)
const selectedLink = ref({})
const availableLinks = ref([])
const invalidTypeCombos = ref([
  '1,2', // open and close paren next to each other
  '2,1', // close then open paren next to each other -- right, this isn't valid? `(8)(17)`
  '2,0', // close paren then requirement next to it
  '0,0', // two requirements right next to each other
  '0,1', // requirement then open paren next to each other like 1 (3)
  '3,4', // AND OR next to each other
  '1,3', // open paren then AND
  '1,4', // open paren then OR
  '5,2', // not then close paren
  '5,3', // not then and
  '5,4', // not then or
  '4,2', // OR then close parent
  '5,2', // NOT then close parent
  '3,2', // AND then close parent
  '3,3', // and and
  '4,4', // or or
  '5,5', // not not
  '0,5', // requirement then not ...needs and/or in between
])
//doing these as strings since the filtered list will be too
const invalidFirsts = ref(['2', '3', '4'])
const invalidLasts = ref(['1', '3', '4', '5'])
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const linkToDelete = ref(null)
const parentActionForChildToDelete = ref(null)
const childProcessToDelete = ref(null)
const childFunctionToDelete = ref(null)
const showLogicInfoDialog = ref(false)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const filteredActions = computed(() => {
  return actions.value.filter(a => !a.archived)
})
const processStepId = computed(() => {
  return parseInt(route.params.id)
})

onMounted(() => {
  defineSortableTable('.action-table tbody', actions, 'displayOrder', saveRowChanges)

  getActions()
  getStatusTypes()
  getTheseCompanyProjectStatusTypes()
  getOperationTypes()
})

const saveChildFunctionOrder = async (actionId, childFns) => {
  appStore.loading = true
  try {
    // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
    // pull those needing to be saved out of list
    let fnsToSave = []
    childFns.forEach((f, idx) => {
      let order = idx + 1
      if (f.displayOrder !== order) {
        f.displayOrder = order
        fnsToSave.push(f)
      }
    })

    // save them here
    if (fnsToSave.length > 0) {
      await putRequest(`/processStep/${processStepId.value}/action/${actionId}/updateChildFunctionOrder`, fnsToSave)
    }
    appStore.showSnack('SUCCESS', 'Function Order Updated')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Function Order')
    appStore.loading = false
  }

}
const actionLogicOrderChanged = (item) => {
  item.processStepLogicList = item.processStepLogicList.filter(psl => !psl.archived)
  item.processStepLogicList?.forEach((f, idx) => {
    let order = idx + 1
    if (f.sqlOrder !== order) {
      f.sqlOrder = order
    }
  })
  item.logicListChanged = true
}
const changeBooleanValue = (e, fp) => {
  vueInstance.$set(fp, 'dynamicValue', e == null ? 'false' : e.toString())
}
//populate requirements so that actions can use them any time they change from the requirements component
const populateRequirements = (reqs) => {
  requirements.value = reqs
}
//ACTIONS
const filterItems = (items) => {
  return items.filter(i => !i.archived)
}
const getStatusesAssignedToStep = async (item) => {
  activeStatusesAssignedToStep.value = []
  try {
    const {data} = await getActiveAssignedToProcessStep(item.processStepId)
    activeStatusesAssignedToStep.value = data
    if (data?.length === 1) {
      item.initialCompanyProcessStepStatusTypeId = data[0].id
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching process step statuses')
  }
}
const copyToClipBoard = () => {
  navigator.clipboard.writeText(actionLogicString.value);
  appStore.showSnack('SUCCESS', 'Copied text to clipboard')
}
const getLogicMargin = (item, parentItem, index) => {
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
}
const getLogicButtonText = (item) => {
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
      } else if (item.processStepRequirementTypeId === 12) {
        //function
        let logicString = item.processStepRequirementType + ' - ' + item.dataViewFieldName + ' ' + item.operatorType + ' ' + value
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
}
const addSms = (actionId, smsItem) => {
  actions.value.find(a => a.id === actionId).processStepActionChildSmsTemplates.push(smsItem)
}
const deleteSms = (actionId, id) => {
  actions.value.find(a => a.id === actionId).processStepActionChildSmsTemplates = actions.value.find(a => a.id === actionId).processStepActionChildSmsTemplates.filter(st => {
    return st.id !== id
  })
}
const getActionLogicString = async (actionId) => {
  try {
    const {data} = await getRequest(`/processStep/${processStepId.value}/action/${actionId}/logicString`)
    actionLogicString.value = data
    showLogicInfoDialog.value = true
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching logic string')
  }
}
const getCancelledStatuses = async (item) => {
  cancelledCompanyStatuses.value = []
  try {
    const {data} = await getCancelledCompanyStatusTypesAssignedToProcessStep(item.processStepId)
    cancelledCompanyStatuses.value = data
    if (data?.length === 1) {
      item.existingCompanyProcessStepStatusTypeId = data[0].id
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error fetching process step statuses')
  }
}
const getActions = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/processStep/${processStepId.value}/action`)
    actions.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const loadChildFunctions = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/function/action/4`)
    childFunctions.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Loading Functions')
    appStore.loading = false
  }
}
const saveNewAction = async () => {
  appStore.loading = true
  try {
    if (!newAction.value.triggerAutomatically) {
      //if they unset the trigger automatically flag, then unset the timeBasedTrigger too.  has to be both to be time based
      newAction.value.timeBasedTrigger = false
    }
    //if action is a banner then null out all the regular action fields (in case they changed type a bunch)
    if (newAction.value.actionTypeId === 3) {
      newAction.value.companyProcessStepStatusTypeId = null
      newAction.value.companyProjectStatusTypeId = null
      newAction.value.companyProjectStatusTypeId = null
      newAction.value.removeProcessStepOwner = null
      newAction.value.triggerAutomatically = null
      newAction.value.hideFromMobile = null
      newAction.value.hideFromWeb = null
      newAction.value.triggerAutomatically = null
      newAction.value.timeBasedTrigger = null
    } else {
      //otherwise null out the banner fields
      newAction.value.content = null
      newAction.value.color = null
      newAction.value.bgColor = null
    }
    newAction.value.processStepId = processStepId.value
    const {data, status} = await postRequest(`/processStep/${processStepId.value}/action`, newAction.value)
    actions.value.push(data)
    addNewAction.value = false
    newAction.value = {}
    appStore.showSnack('SUCCESS', 'Action Added')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Action')
    appStore.loading = false
  }
}
const duplicateAction = async (actionId) => {
  appStore.loading = true
  try {
    const {data} = await putRequest(`/processStep/${processStepId.value}/action/${actionId}/duplicate`)
    actions.value.push(data)
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Duplicating Action')
    appStore.loading = false
  }
}
const updateAction = async (action) => {
  appStore.loading = true
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

    const {data, status} = await putRequest(`/processStep/${processStepId.value}/action`, action)
    // this forces the list to update the values displayed ... using action = data did not work
    action.actionType = data.actionType
    action.logicListChanged = false
    action.processStepStatusType = data.processStepStatusType
    action.projectStatusType = data.projectStatusType
    action.processStepActionChildProcesses = data.processStepActionChildProcesses
    action.processStepActionLinks = data.processStepActionLinks
    action.processStepLogicList = data.processStepLogicList
    action.triggerAutomatically = data.triggerAutomatically
    actionExpanded.value = []

    //update the necessary psr's to immutable
    if (psrListToUpdate.length > 0) {
      psrListToUpdate.forEach(psr => {
        let match = requirements.value.find(r => r.id === psr.processStepRequirementId)
        match.immutable = true
      })
    }

    appStore.showSnack('SUCCESS', 'Action Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Action')
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
const getStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyAssignedToProcessStep(processStepId.value)
    statusTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getTheseCompanyProjectStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyProjectStatusTypes(null, true)
    companyProjectStatusTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    handleHidingGlobalLoader(status)
  }
}
const getOperationTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/operation`)
    operationTypes.value = orderBy(data, [o => o.operationType.toLowerCase()])
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const deleteAction = async () => {
  const item = itemToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processStep/${processStepId.value}/action/${item.id}`)
    item.archived = true
    appStore.showSnack('SUCCESS', 'Action Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Action')
    appStore.loading = false
  }
  itemToDelete.value.archive = true
  closeDeleteDialog()
}
//child process steps
const loadChildProcessSteps = async (actionId) => {
  const {data} = await getRequest(`/processStep/${processStepId.value}/action/${actionId}/childProcessSteps`)
  childProcessSteps.value = data
}
const saveChildProcessCancelledStatus = async (action, cp) => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await putRequest(`/processStep/${processStepId.value}/action/${action.id}/child/${cp.id}/status`, {
      existingCompanyProcessStepStatusTypeId: cp.existingCompanyProcessStepStatusTypeId,
      initialCompanyProcessStepStatusTypeId: cp.initialCompanyProcessStepStatusTypeId,
    })
    cpExpanded.value = []
    cp.existingProcessStepStatusType = data.existingProcessStepStatusType
    cp.initialProcessStepStatusType = data.initialProcessStepStatusType
    appStore.showSnack('SUCCESS', 'Child Process Status Saved')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Child Process Status')
    appStore.loading = false
  }
}
const saveProcessStepToAction = async (action) => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/processStep/${processStepId.value}/action/${action.id}/addChildStepToAction`, {
      processStepId: newChildProcessStep.value.processStepId,
      existingCompanyProcessStepStatusTypeId: newChildProcessStep.value.existingCompanyProcessStepStatusTypeId,
      initialCompanyProcessStepStatusTypeId: newChildProcessStep.value.initialCompanyProcessStepStatusTypeId,
      displayOrder: 0
    })
    action.processStepActionChildProcesses.push(data)
    newChildProcessStep.value = {}
    addChildProcess.value = false
    appStore.showSnack('SUCCESS', 'Child Process Added To Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Child Process Action')
    appStore.loading = false
  }
}
const deleteChildProcessFromAction = async () => {
  childProcessToDelete.value.archived = true
  const actionId = parentActionForChildToDelete.value.id
  const id = childProcessToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processStep/${processStepId.value}/action/${actionId}/deleteChildStep/${id}`)
    appStore.showSnack('SUCCESS', 'Child Process Deleted From Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Child Process From Action')
    appStore.loading = false
  }
}
const saveFunctionToAction = async (action) => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/processStep/${processStepId.value}/action/${action.id}/addChildFunctionToAction`, {
      companyFunctionId: selectedChildFunction.value.id,
      displayOrder: 0,
      actionParamDynamicValues: selectedChildRequirementParamDynamicValues.value
    })
    action.processStepActionChildFunctions.push(data)
    selectedChildFunction.value = {}
    selectedChildRequirementParamDynamicValues.value = []
    addChildFunction.value = false
    appStore.showSnack('SUCCESS', 'Child Function Added To Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Child Function Action')
    appStore.loading = false
  }
}
const deleteChildFunctionFromAction = async () => {
  childFunctionToDelete.value.archived = true
  const actionId = parentActionForChildToDelete.value.id
  const id = childFunctionToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processStep/${processStepId.value}/action/${actionId}/deleteChildFunction/${id}`)
    appStore.showSnack('SUCCESS', 'Child Function Deleted From Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Child Function From Action')
    appStore.loading = false
  }
}
const updateChildFunction = async (actionId, childFunction) => {
  appStore.loading = true
  try {
    const {status} = await putRequest(`/processStep/${processStepId.value}/action/${actionId}/updateActionChildFunction`, childFunction)
    appStore.showSnack('SUCCESS', 'Child Process Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Updating Child Process')
    appStore.loading = false
  }
}
// child links
const loadLinks = async (actionId) => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/links/action/${actionId}`)
    availableLinks.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const saveLinkToAction = async (action) => {
  appStore.loading = true
  try {
    const {
      data,
      status
    } = await postRequest(`/processStep/${processStepId.value}/action/${action.id}/addLinkToAction`, {
      linkId: selectedLink.value.id
    })
    action.processStepActionLinks.push(data)
    selectedLink.value = {}
    addChildLink.value = false
    appStore.showSnack('SUCCESS', 'Link Added to Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Link to Action')
    appStore.loading = false
  }
}
const deleteLinkFromAction = async () => {
  linkToDelete.value.archived = true
  const actionId = parentActionForChildToDelete.value.id
  const id = linkToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processStep/${processStepId.value}/action/${actionId}/deleteLinkFromAction/${id}`)
    appStore.showSnack('SUCCESS', 'Link Deleted From Action')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Link From Action')
    appStore.loading = false
  }
}
const getListValueName = (item) => {
  let idToUse = item.customSqlOptionId ? item.customSqlOptionId :
      item.systemListOptionId ? item.systemListOptionId : item.listOfValueId
  let match = item.availableListOfValues.find(i => i.id === idToUse)
  return match ? match.name : 'unknown'
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    appStore.loading = true
    try {
      const {status} = await putRequest(`/processStep/${processStepId.value}/action/order`, rows)
      appStore.showSnack('SUCCESS', 'Action Order Saved')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Action Order')
      appStore.loading = false
    }
  }
}

const validateActionLogicString = (item, saveChanges) => {
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
    actionLogicError.value = true
    actionLogicErrorMsg.value = 'Logic is missing opening or closing parenthesis.'
  } else if (invalidTypeCombos.value.some(v => operationTypeString?.includes(v))) {
    actionLogicError.value = true
    actionLogicErrorMsg.value = 'Logic is invalid.'
  } else if (invalidFirsts.value.includes(firstOperationTypeId)) {
    actionLogicError.value = true
    actionLogicErrorMsg.value = 'Invalid first logic operation.'
  } else if (invalidLasts.value.includes(lastOperationTypeId)) {
    actionLogicError.value = true
    actionLogicErrorMsg.value = 'Invalid last logic operation.'
  } else {
    actionLogicError.value = false
    actionLogicErrorMsg.value = ''
    if (saveChanges) {
      updateAction(item)
    }
  }
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
const closeLinkDeleteDialog = () => {
  linkToDelete.value = null
  parentActionForChildToDelete.value = null
}
const closeChildProcessDialog = () => {
  childProcessToDelete.value = null
  parentActionForChildToDelete.value = null
}
const closeChildFunctionDialog = () => {
  childFunctionToDelete.value = null
  parentActionForChildToDelete.value = null
}
const closeLogicInfoDialog = () => {
  showLogicInfoDialog.value = false
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

.squished-btn {
  min-width: 0 !important;
  padding: 4px !important;
}
</style>
