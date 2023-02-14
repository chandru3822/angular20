<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">{{ selectedEvent.eventName }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
        <v-card class="pa-4">
          <v-autocomplete
            v-model="selectedEvent.initialCompanyEventStatusTypeId"
            :items="companyEventStatuses"
            label="Initial Event Status"
            item-text="eventStatusType"
            item-value="id"
          >
            <template slot="item" slot-scope="data">
              <!-- HTML that describes how select should render items when the select is open -->
              {{ data.item.eventStatusType }} ({{ data.item.rootEventStatusType }})
            </template>
          </v-autocomplete>
          <v-btn color="primary"
                 @click="saveEventDetails(selectedEvent)"
          >Save
          </v-btn>
        </v-card>
        <v-card class="pa-4 mt-4">
          <v-card-title class="title-medium pa-0 mb-4" style="height: 40px">Readonly
          <v-checkbox :disabled="!userCanEdit" type="checkbox" class="ml-3"
                                                               v-model="selectedEvent.readonly"></v-checkbox>
          </v-card-title>
          <v-card-text>
          <v-autocomplete
              v-if="selectedEvent.readonly"
            v-model="selectedEvent.readonlyWhiteListPositions"
            :items="positions"
            label="Whitelisted Positions"
            item-text="position"
            item-value="positionId"
              :disabled="!userCanEdit"
            return-object
            multiple
            clearable
          >
            <template v-slot:selection="{item, index}">
              <v-chip small
                      v-if="selectedEvent.readonlyWhiteListPositions && selectedEvent.readonlyWhiteListPositions.length < 6">
                <span>{{ item.position }}</span>
              </v-chip>
              <span
                  v-if="index === 1 && selectedEvent.readonlyWhiteListPositions && selectedEvent.readonlyWhiteListPositions.length >= 6"
                  class="primary--text text-caption"
              >{{ selectedEvent.readonlyWhiteListPositions.length }} selected</span>
            </template>
            <template v-slot:prepend-item>
              <v-list-item
                  @click="toggleSelectAllPositions()">
                <v-list-item-action>
                  <v-icon>{{ icon }}</v-icon>
                </v-list-item-action>
                <v-list-item-title>Select All</v-list-item-title>
              </v-list-item>
              <v-divider
                  class="mt-2"
              ></v-divider>
            </template>
          </v-autocomplete>
          </v-card-text>
          <v-btn color="primary" v-if="userCanEdit"
                 @click="saveReadOnlyWhiteList(selectedEvent)"
          >Save Read Only
          </v-btn>
        </v-card>
      </v-col>

      <ProcessStepWorkQueueTypes v-if="!eventLoading && selectedEvent.id"
                                 :event="selectedEvent"></ProcessStepWorkQueueTypes>

      <ProcessStepRequirements :callback="populateRequirements" :event-requirements="true"></ProcessStepRequirements>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Event Actions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn @click="logicStringToggle = !logicStringToggle" text color="primary">
              {{ logicStringToggle ? 'View Logic as Numbers' : 'View Logic as Text' }}
            </v-btn>
            <v-btn text color="primary"
                   @click="[addNewEventAction = !addNewEventAction, newEventAction.color = '#1F3C73', newEventAction.bgColor = '#878787']"
                   v-if="userCanAdd">
              <v-icon v-if="!addNewEventAction">add</v-icon>
              {{ addNewEventAction ? 'Cancel' : 'Add Action' }}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNewEventAction">
          <v-text-field text
                        label="Action Name"
                        v-model="newEventAction.actionName">
          </v-text-field>
          <v-select attach v-model="newEventAction.actionTypeId"
                    :items="actionTypes"
                    label="Action Type"
                    item-text="actionType"
                    item-value="id"
          ></v-select>
          <div v-if="newEventAction.actionTypeId && newEventAction.actionTypeId === 2">
            <v-autocomplete
              v-model="newEventAction.companyEventStatusTypeId"
              :items="companyEventStatuses"
              label="Change Event Status To"
              item-text="eventStatusType"
              item-value="id"
              clearable
            ></v-autocomplete>
            <v-autocomplete
              v-model="newEventAction.companyProcessStepStatusTypeId"
              :items="processStepStatuses"
              label="Change Process Step Status To"
              item-text="processStepStatusType"
              item-value="id"
              clearable
            >
              <template slot="item" slot-scope="data">
                <!-- HTML that describes how select should render items when the select is open -->
                {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
              </template>
            </v-autocomplete>
          </div>
          <div v-else-if="newEventAction.actionTypeId && newEventAction.actionTypeId === 3">
            <v-textarea required label="Banner Content" auto-grow filled
                        style="margin: 15px 0 -15px 0"
                        v-model="newEventAction.content">
            </v-textarea>
            <div>
              <label>Banner Text Color:</label>
              <v-color-picker class="my-3"
                              v-model="newEventAction.color"
                              :canvas-height="colorOptions.height"
                              :width="colorOptions.width"
                              :mode="colorOptions.mode"
                              :hide-mode-switch="colorOptions.hideModeSwitch">
              </v-color-picker>
            </div>
            <div>
              <label>Banner Background Color:</label>
              <v-color-picker class="my-3"
                              v-model="newEventAction.bgColor"
                              :canvas-height="colorOptions.height"
                              :width="colorOptions.width"
                              :mode="colorOptions.mode"
                              :hide-mode-switch="colorOptions.hideModeSwitch">
              </v-color-picker>
            </div>
          </div>
          <v-btn color="primary"
                 @click="saveEventAction(newEventAction)"
                 :disabled="!newEventAction.actionName || !newEventAction.actionTypeId"
          >Add Action
          </v-btn>
        </v-card>
        <v-data-table
          v-show="!addNewEventAction"
          :headers="actionHeaders"
          :items="filterEventActions()"
          :items-per-page="-1"
          :sort-desc="[false]"
          :sort-by="['displayOrder']"
          :mobile-breakpoint="0"
          single-expand
          disable-sort
          :expanded.sync="expanded"
          hide-default-footer
          class="event-actions-table elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No actions for this event</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No actions for this event</span>
          </template>

          <template #expanded-item="{ headers, item: action }">
            <td :colspan="headers.length" class="pa-4">
              <v-text-field text
                            label="Action Name"
                            v-model="action.actionName">
              </v-text-field>
              <v-select attach v-model="action.actionTypeId"
                        :items="actionTypes"
                        :readonly="true"
                        :disabled="true"
                        label="Action Type"
                        item-text="actionType"
                        item-value="id"
              ></v-select>
              <div>
                <v-autocomplete
                  v-model="action.companyEventStatusTypeId"
                  :items="companyEventStatuses"
                  label="Change Event Status To"
                  item-text="eventStatusType"
                  item-value="id"
                  clearable
                  v-if="action.actionTypeId === 2"
                ></v-autocomplete>
                <v-autocomplete
                  v-model="action.companyProcessStepStatusTypeId"
                  :items="processStepStatuses"
                  label="Change Process Step Status To"
                  item-text="processStepStatusType"
                  item-value="id"
                  clearable
                  v-if="action.actionTypeId === 2"
                >
                  <template slot="item" slot-scope="data">
                    <!-- HTML that describes how select should render items when the select is open -->
                    {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                  </template>
                </v-autocomplete>

                <v-card flat class="pb-5" v-if="[1,2].includes(action.actionTypeId)">
                  <table>
                    <tr>
                      <td>Require Start Time</td>
                      <td><input type="checkbox" class="ml-2" v-model="action.requireStartTime"></td>
                    </tr>
                    <tr>
                      <td>Require End Time</td>
                      <td><input type="checkbox" class="ml-2" v-model="action.requireEndTime"></td>
                    </tr>
                    <tr>
                      <td>Require Resource</td>
                      <td><input type="checkbox" class="ml-2" v-model="action.requireResource"></td>
                    </tr>
                    <tr>
                      <td class="pt-3">Allow Multiple Uses</td>
                      <td class="pt-3"><input type="checkbox" class="ml-2" v-model="action.multipleUses"></td>
                    </tr>
                    <tr>
                      <td>Hide From Web</td>
                      <td><input type="checkbox" class="ml-2" v-model="action.hideFromWeb"></td>
                    </tr>
                    <tr>
                      <td>Hide From Mobile</td>
                      <td><input type="checkbox" class="ml-2" v-model="action.hideFromMobile"></td>
                    </tr>
                  </table>
                </v-card>

                <!--              <v-btn class="white&#45;&#45;text"-->
                <!--                     color="primary"-->
                <!--                     @click="saveEventAction(action)"-->
                <!--              >Save Action</v-btn>-->
                <div v-if="action.actionTypeId === 1">
                  <v-divider></v-divider>
                  <v-toolbar flat color="transparent">
                    <v-toolbar-title class="app-title">
                      Child Links
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                      <v-btn v-if="!addChildLink && userCanEdit" color="primary"
                             @click="[addChildLink = true, loadLinks(action.id)]">
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
                              @input="saveLinkToAction(action)"
                    ></v-select>
                    <v-btn @click="addChildLink = false" text color="primary">
                      <v-icon>remove</v-icon>
                      Cancel
                    </v-btn>
                  </v-card>
                </div>

                <v-row justify="center" class="pl-3 pr-3"
                       v-if="action.actionTypeId === 1 && action.childLinks && action.childLinks.length > 0">
                  <v-col cols="12">
                    <v-list v-for="(al, index) in filterBy(action.childLinks, false, 'archived')"
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
                                action.actionName
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
                                @click="[al.archived = true, deleteLinkFromAction(action.id, al.id)]">
                                Yes
                              </v-btn>
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                      </v-list-item>
                    </v-list>
                  </v-col>
                </v-row>

                <div v-if="action.actionTypeId === 2">
                  <v-divider></v-divider>
                  <v-toolbar flat color="transparent">
                    <v-toolbar-title class="app-title">
                      Child Functions
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                      <v-btn text color="primary" v-if="!addChildFunction && userCanAdd"
                             @click="[addChildFunction = true, loadChildFunctions(action.id)]">
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
                          <v-tooltip
                            v-if="fp.description != null"
                            content-class="full-opacity-tooltip"
                            :max-width="300"
                            top
                          >
                            <template v-slot:activator="{ on, attrs }">
                              <v-btn
                                text color="primary"
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
                             @click="saveFunctionToAction(action)">
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
                       v-if="action.childFunctions && action.childFunctions.length > 0">
                  <v-col cols="12" class="pt-0">
                    <v-list v-for="(cp, index) in filterBy(action.childFunctions, false, 'archived')"
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
                                    placeholder="Enter a boolean"
                                    :value-comparator="function (a, b) {
                                      return fp.dynamicValue === 'true'
                                    }"
                                    :value="fp.dynamicValue === 'true'"
                                    @change="changeBooleanValue($event, fp)"
                                    :label="fp.parameterName"></v-checkbox>
                                  <v-text-field
                                    v-else-if="fp.dataTypeId === 4"
                                    :readonly="!cp.edit || !userCanEdit"
                                    :disabled="!cp.edit || !userCanEdit"
                                    placeholder="Enter a number"
                                    v-model="fp.dynamicValue"
                                    :label="fp.parameterName"></v-text-field>
                                  <v-text-field
                                    v-else-if="fp.dataTypeId === 6"
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
                              </div>
                            </v-card>
                          </div>
                          <v-list-item-subtitle>
                            <v-btn color="primary" v-if="cp.edit && userCanEdit"
                                   @click="updateChildFunction(action.id, cp)">
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
                                action.actionName
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
                                @click="[cp.archived = true, deleteChildFunctionFromAction(action.id, cp.id)]">
                                Yes
                              </v-btn>
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
                      </v-list-item>
                    </v-list>
                  </v-col>
                </v-row>
              </div>
              <div v-if="action.actionTypeId === 3">
                <v-textarea required label="Banner Content" auto-grow filled
                            style="margin: 15px 0 -15px 0"
                            v-model="action.content">
                </v-textarea>
                <div>
                  <label>Banner Text Color:</label>
                  <v-color-picker class="my-3"
                                  v-model="action.color"
                                  :canvas-height="colorOptions.height"
                                  :width="colorOptions.width"
                                  :mode="colorOptions.mode"
                                  :hide-mode-switch="colorOptions.hideModeSwitch">
                  </v-color-picker>
                </div>
                <div>
                  <label>Banner Background Color:</label>
                  <v-color-picker class="my-3"
                                  v-model="action.bgColor"
                                  :canvas-height="colorOptions.height"
                                  :width="colorOptions.width"
                                  :mode="colorOptions.mode"
                                  :hide-mode-switch="colorOptions.hideModeSwitch">
                  </v-color-picker>
                </div>
              </div>
              <v-divider></v-divider>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">
                  Current Logic
                  <v-dialog
                    v-if="action.processStepEventLogicList && action.processStepEventLogicList.length > 0 && !action.logicListChanged"
                    v-model="showActionLogicString"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn text class="d-inline-block" @click="getActionLogicString(action.id)" v-on="on">
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
                  v-if="((action.processStepEventLogicList && action.processStepEventLogicList.length > 0) || action.alwaysEnabled) && userCanEdit">
                  <v-btn text color="primary"
                         @click="[action.logicListChanged = true, action.logicMargin = 0, action.processStepEventLogicList = [], action.alwaysEnabled = false]">
                    <v-icon>clear</v-icon>
                    Clear All
                  </v-btn>
                </v-toolbar-items>
              </v-toolbar>
              <v-card flat class="text-left px-3 primary--text" color="transparent">
                <div v-if="logicStringToggle">
                  <div v-for="(l, index) in filterBy(action.processStepEventLogicList, false, 'archived')"
                       :style="{'margin-left': getLogicMargin(l, action, index)}"
                       :key="index">
                    <v-btn small class="ml-1 mr-1 mt-1"
                           :disabled="!userCanEdit"
                           @click="[l.archived = true, action.logicListChanged = true]">
                      {{ getLogicButtonText(l) }}
                    </v-btn>
                  </div>
                </div>
                <div v-else>
                  <v-tooltip top max-width="300px"
                             v-for="(l, idx) in filterBy(action.processStepEventLogicList, false, 'archived')"
                             :key="idx">
                    <template v-slot:activator="{ on:tooltip }">
                      <v-btn small class="ml-1 mr-1 mt-1"
                             v-on="{ ...tooltip }"
                             :disabled="!userCanEdit"
                             @click="[l.archived = true, action.logicListChanged = true]">
                        {{ l.requirementNbr || l.operationType }}
                      </v-btn>
                    </template>
                    <span>{{ getLogicButtonText(l) }}</span>
                  </v-tooltip>
                </div>
                <v-btn small class="ml-1 mr-1 mt-1 primary--text" v-if="action.alwaysEnabled"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.alwaysEnabled = !action.alwaysEnabled]">
                  Always Enabled
                </v-btn>
              </v-card>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Available Operations</v-toolbar-title>
              </v-toolbar>
              <v-card flat class="text-left px-3" color="transparent">
                <v-btn small class="ml-1 mr-1 mt-1 primary--text" v-for="(ot, index) in operationTypes" :key="index"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.alwaysEnabled = false, action.processStepEventLogicList.push({operationType: ot.operationType, operationTypeId: ot.id, archived: false})]">
                  {{ ot.operationType }}
                </v-btn>
                <v-btn small class="ml-1 mr-1 mt-1 primary--text"
                       :disabled="!userCanEdit"
                       @click="[action.logicListChanged = true, action.processStepEventLogicList = [], action.alwaysEnabled = true]">
                  Always Enabled
                </v-btn>
              </v-card>
              <v-toolbar flat dense color="transparent">
                <v-toolbar-title class="app-title">Requirements</v-toolbar-title>
              </v-toolbar>
              <v-card flat class="text-left mb-4 px-3" color="transparent">
                <v-tooltip top max-width="300px"
                           :disabled="logicStringToggle"
                           v-for="r in selectedEventRequirements" :key="r.id">
                  <template v-slot:activator="{ on:tooltip }">
                    <v-btn :class="{'d-block': logicStringToggle}"
                           small class="ml-1 mr-1 mt-1 primary--text"
                           :disabled="!userCanEdit"
                           v-on="{ ...tooltip }"
                           @click="[action.logicListChanged = true, action.alwaysEnabled = false, action.processStepEventLogicList.push({ requirementNbr: r.requirementNbr, processStepEventRequirementId: r.id, archived: false, logicString: r.logicString })]">
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
              <v-btn v-if="userCanEdit" class="mt-4 ml-3 mb-4"
                     :disabled="!action.actionName" color="primary"
                     @click="validateActionLogicString(action, true)">
                <v-icon class="mr-2">save</v-icon>
                Save Changes
              </v-btn>

              <v-toolbar flat>
                <v-toolbar-title class="app-title">Event Custom Fields</v-toolbar-title>
              </v-toolbar>
              <v-data-table
                :headers="eventActionFieldHeaders"
                :items="filteredCustomFields(action)"
                disable-sort
                :items-per-page="-1"
                :mobile-breakpoint="0"
                hide-default-footer
                class="elevation-1 fix-column-width-bug square-card"
              >
                <template #no-data>
                  <span class="default-text-color">No custom fields for this event</span>
                </template>

                <template #no-results>
                  <span class="default-text-color">No custom fields for this event</span>
                </template>

                <template #item="{ item, index }">
                  <tr :class="{'shaded-row': index % 2}">
                    <td class="text-left"><strong>{{ item.groupName }}:</strong> {{ item.fieldName }}</td>
                    <td class="text-center">
                      <v-checkbox type="checkbox" class="ml-2" v-model="item.required"
                                  :key="requiredKey"
                                  @click="alterRequiredFlag(true, item, action.id)"/>
                    </td>
                    <td class="text-center">
                      <v-checkbox class="ml-2" v-model="item.optional"
                                  :key="optionalKey"
                                  @click="alterRequiredFlag(false, item, action.id)"/>
                    </td>
                  </tr>
                </template>
              </v-data-table>
            </td>
          </template>

          <template #item="{ item: action, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <v-btn text v-if="userCanEdit" icon small color="primary" class="handle">
                  <v-icon>drag_handle</v-icon>
                </v-btn>
              </td>
              <td class="text-left">{{ action.actionName }}</td>
              <td class="text-left">{{ action.actionType }}</td>
              <td class="text-left">{{ action.eventStatusType || 'N/A' }}</td>
              <td class="text-left">{{ action.processStepStatusType || 'N/A' }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn text color="primary" v-if="userCanEdit"
                         @click="duplicateAction(action.id)">
                    <v-icon>mdi-content-copy</v-icon>
                  </v-btn>
                  <v-btn text color="primary" @click="[expanded = [action]]" v-if="!expanded.includes(action)">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn text color="primary" @click="expanded = []" v-else>cancel
                  </v-btn>
                  <v-btn small text color="primary" @click="eventActionToDelete = action">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!eventActionToDelete" @confirm="deleteActionFromEvent"
                        @close-dialog="eventActionToDelete = null">
      Are you sure you want to delete this event action?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, logError, handleHidingGlobalLoader
} from '@/helpers/helpers'
import {getCompanyAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepRequirements from "@/views/flow/settings/processStep/ProcessStepRequirements";
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import ProcessStepWorkQueueTypes from './ProcessStepWorkQueueTypes'
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'ProcessStepEvent',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ProcessStepRequirements,
    ProcessStepWorkQueueTypes
  },
  mounted() {
    let table = document.querySelector('.event-actions-table tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({newIndex, oldIndex}) {
        const rowSelected = _self.selectedEvent?.processStepEventActions.splice(oldIndex, 1)[0]
        _self.selectedEvent?.processStepEventActions.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(_self.selectedEvent?.processStepEventActions)

        let rowsToSave = []
        rowsClone.forEach((r, idx) => {
          //check if the row needs to be saved before updating display order
          //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
          let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
          //update display order
          r.displayOrder = idx
          //save only rows that changed
          if (save) {
            let rows = _self.selectedEvent?.processStepEventActions
            rows[idx].newDisplayOrder = idx
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
      companyEventStatuses: [],
      processStepStatuses: [],
      newEventStatuses: [],
      positions: [],
      positionsLoading: false,
      addChildFunction: false,
      selectedChildFunction: {},
      childFunctions: [],
      showActionLogicString: false,
      actionLogicString: null,
      selectedChildRequirementParamDynamicValues: [],
      selectedActionIndex: null,
      selectedEventRequirements: [],
      selectedEvent: {
        processStepEventActions: []
      },
      //todo: get these from endpoint but i am lazy right now
      actionTypes: [
        {id: 1, actionType: 'Link'},
        {id: 2, actionType: 'Button'},
        {id: 3, actionType: 'Banner'}
      ],
      colorOptions: {
        canvasHeight: 75,
        width: 200,
        mode: 'hexa',
        hideModeSwitch: true
      },
      expanded: [],
      eventLoading: true,
      logicStringToggle: false,
      addNewEventAction: false,
      newEventAction: {},
      addRequiredField: false,
      addOptionalField: false,
      requiredKey: 0,
      optionalKey: 0,
      eventCustomFields: [],
      requiredFieldCfga: null,
      optionalFieldCfga: null,
      actionHeaders: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Action Name', value: 'actionName', show: true},
        {text: 'Action Type', value: 'actionType', show: true},
        {text: 'Change Event Status To', value: 'companyEventStatusType', show: true},
        {text: 'Change Process Step Status To', value: 'companyProcessStepStatusType', show: true},
        {text: null, value: 'icons', show: true}
      ],
      processStepId: this.$route.params.id,
      eventId: parseInt(this.$route.params.eventId),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      eventActionFieldHeaders: [
        {text: 'Field', value: 'fieldName', show: true},
        {text: 'Required', value: 'required', width: '75px', show: true},
        {text: 'Optional', value: 'groupName', width: '75px', show: true},
      ],
      //link stuff
      addChildLink: false,
      selectedLink: {},
      availableLinks: [],

      // actionLogic stuff
      operationTypes: [],
      actionLogicError: false,
      actionLogicErrorMsg: '',
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
      eventActionToDelete: null
    }
  },
  computed: {
    selectAll() {
      return this.selectedEvent.readonlyWhiteListPositions?.length === this.positions?.length
    },
    selectSome() {
      return this.selectedEvent.readonlyWhiteListPositions?.length > 0 && !this.selectAll
    },
    icon() {
      if (this.selectAll) {
        return 'check_box'
      }
      if (this.selectSome) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
  },
  async created() {
    //get event details
    this.getCompanyProcessStepStatuses()
    this.getPositions()
    await this.getEventDetails()
    this.getAssignedEventStatusTypes()
    this.getOperationTypes()
  },
  methods: {
    changeBooleanValue(e, fp) {
      this.$set(fp, 'dynamicValue', e == null ? 'false' : e.toString())
    },
    //populate requirements so that events can use them any time they change from the requirements component
    populateRequirements(reqs) {
      this.selectedEventRequirements = reqs
    },
    copyToClipBoard() {
      navigator.clipboard.writeText(this.actionLogicString);
      this.snackbar = getSnackbar('SUCCESS', 'Copied text to clipboard')
      this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
    },
    getLogicMargin(item, parentItem, index) {
      parentItem.logicMargin = parentItem.logicMargin || 0
      if(item.operationTypeId === 1) {
        if(parentItem.indexOfPreviousAdd !== undefined && parentItem.indexOfPreviousAdd === index - 1) {
          parentItem.logicMargin += 25
        }
        parentItem.indexOfPreviousAdd = index
        return parentItem.logicMargin + 'px'
      } else if(item.operationTypeId === 2) {
        parentItem.indexOfPreviousSubtract = index
        let placeholder = parentItem.logicMargin - 25
        parentItem.logicMargin -= 25
        return placeholder + 'px'
      } else {
        if(parentItem.indexOfPreviousAdd === index - 1) {
          parentItem.logicMargin += 25
        }
        return parentItem.logicMargin + 'px'
      }
    },
    getLogicButtonText(item) {

      if(item.logicString) {
        //this part make it work when clicking a requirement and adding to the current logic section, otherwise unused
        return item.logicString
      } else {
        if(null != item.requirementNbr) {
          //if not a system requirement (like AND, NOT, OR, etc)
          let value = ''
          if(item.dataTypeRequirement?.dataTypeValue) {
            value = item.dataTypeRequirement?.dataTypeValue
          } else if (item.listOfValue?.name) {
            value = item.listOfValue?.name
          } else if (item.listOfValues?.length > 0){
            item.listOfValues.forEach((lv, idx) => {
              if(idx !== 0) {
                value = value + ', '
              }
              value = value + lv.name
            })
          } else if(item.requirementValue) {
            value = item.requirementValue
          } else {
            value = 'UNKNOWN CONTACT ADMIN'
          }
          if(null != item.secondaryRequirementValue) {
            value = value + ` (${item.secondaryRequirementValue})`
          }
          if([1,3,4].includes(item.processStepRequirementTypeId)) {
            //custom field
            let textStart = item.processStepRequirementTypeId === 1 ? item.parentName : item.processStepRequirementType
            let logicString = textStart + ' - ' + item.fieldName + ' ' + item.operatorType + ' ' + value
            item.logicString = logicString
            return logicString
          } else if(item.processStepRequirementTypeId === 2) {
            //function
            let logicString = item.processStepRequirementType + ' - ' + item.companyFunctionName + ' '  + item.operatorType + ' ' + value
            item.logicString = logicString
            return logicString
          } else if([7,8,9,10,11].includes(item.processStepRequirementTypeId)){
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
    async getActionLogicString(actionId) {
      try {
        const {data} = await getRequest(`/processStep/${this.processStepId}/event/${this.eventId}/action/${actionId}/logicString`)
        this.actionLogicString = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching logic string')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getEventDetails() {
      try {
        this.eventLoading = true
        const {data} = await getRequest(`/processStep/${this.processStepId}/event/${this.eventId}`)
        this.selectedEvent = data
        this.eventLoading = false
      } catch (e) {
        this.eventLoading = true
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.companyStatusesLoading = false
      }
    },
    async getAssignedEventStatusTypes() {
      try {
        const {data} = await getRequest(`/event/${this.selectedEvent.eventId}/status`)
        this.companyEventStatuses = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Event Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.companyStatusesLoading = false
      }
    },
    async getCompanyProcessStepStatuses() {
      try {
        const {data} = await getCompanyAssignedToProcessStep(this.processStepId)
        this.processStepStatuses = data
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', 'Error fetching available process step statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
      }
    },
    async getPositions() {
      if (this.positions?.length === 0) {
        try {
          this.positionsLoading = true
          const {data, status} = await getRequest(`/position/withParent`)
          this.positions = data
          this.positionsLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          this.positionsLoading = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    filterEventActions() {
      // return this.selectedEvent?.processStepEventActions.filter(e => {
      //   return !e.archived
      // })
      return orderBy(this.selectedEvent?.processStepEventActions.filter(psea => {
        return !psea.archived
      }), [psea => psea.displayOrder])
    },
    toggleSelectAllPositions() {
      this.$nextTick(() => {
        if (this.selectAll) {
          this.selectedEvent.readonlyWhiteListPositions = []
          this.selectedEvent.positionsChanged = true
        } else {
          this.selectedEvent.readonlyWhiteListPositions = cloneDeep(this.positions)
          this.selectedEvent.positionsChanged = true
        }
      })
    },
    async saveEventDetails(psEvent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/processStep/${this.processStepId}/event/${psEvent.eventId}`, psEvent)
        this.snackbar = getSnackbar('SUCCESS', 'Event Updated')
        this.expanded = []
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveReadOnlyWhiteList(psEvent) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/processStep/${this.processStepId}/event/${psEvent.eventId}/saveReadOnlyWhiteList?savePositions=${psEvent.positionsChanged ?? false}`, psEvent)
        psEvent.positionsChanged = false
        handleHidingGlobalLoader(this, status)
        this.snackbar = getSnackbar('SUCCESS', 'Event Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Event')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteActionFromEvent() {
      const action = this.eventActionToDelete
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${action.id}`)
        action.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Action Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.eventActionToDelete = null
    },
    async saveEventAction(action) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //if action is a banner or link then null out all the regular action fields (in case they changed type a bunch)
        if (this.newEventAction.actionTypeId !== 2) {
          this.newEventAction.companyEventStatusTypeId = null
          this.newEventAction.companyProcessStepStatusTypeId = null
        } else {
          //otherwise null out the banner fields
          this.newEventAction.content = null
          this.newEventAction.color = null
          this.newEventAction.bgColor = null
        }
        const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action`, action)
        if (!action.id) {
          this.addNewEventAction = false
          this.newEventAction = {}
          //pre-populate this value so they can save some later
          data.childFunctions = []
          this.selectedEvent.processStepEventActions.push(data)
        } else {
          action.eventStatusType = data.eventStatusType
          action.processStepStatusType = data.processStepStatusType
        }
        this.snackbar = getSnackbar('SUCCESS', 'Action Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Action')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateActionLogicString(item, saveChanges) {
      // using 0 to represent a logic item using a requirement
      // 1 = (  2 = )  3 = AND  4 = OR  5 = NOT

      //filter the logic list to exclude any archived
      let nonArchivedLogic = item.processStepEventLogicList?.filter(l => !l.archived)

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
    async duplicateAction(actionId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/processStep/${this.processStepId}/event/${this.eventId}/action/${actionId}/duplicate`)
        this.selectedEvent.processStepEventActions.push(data)
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
        action.processStepEventLogicList = action.processStepEventLogicList.filter(l => {
          return !l.archived
        })

        // build the list of psr's that need to be set to immutable  do that if the save is successful
        const psrListToUpdate = action.processStepEventLogicList.filter(l => {
          return l.processStepEventRequirementId && !l.processStepRequirementImmutable
        })

        const {data} = await postRequest(`/processStep/${this.processStepId}/event/${this.eventId}/action`, action)
        // this forces the list to update the values displayed ... using action = data did not work
        action.actionType = data.actionType
        action.processStepStatusType = data.processStepStatusType
        action.processStepEventLogicList = data.processStepEventLogicList
        action.triggerAutomatically = data.triggerAutomatically
        this.actionExpanded = []

        //update the necessary psr's to immutable
        if (psrListToUpdate.length > 0) {
          psrListToUpdate.forEach(psr => {
            let match = this.selectedEventRequirements.find(r => r.id === psr.processStepEventRequirementId)
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
    async alterRequiredFlag(requiredChanged, item, actionId) {
      //flip the flags as they change
      if (requiredChanged && item.required) {
        item.optional = false
        this.optionalKey++
      } else if (!requiredChanged && item.optional) {
        item.required = false
        this.requiredKey++
      }

      try {
        const {data} = await putRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${actionId}`, item)
        //resetting the id in case it got archived/added a new one, etc. this will keep multiple updates to the same field working without refreshing the screen
        item.id = data
        this.snackbar = getSnackbar('SUCCESS', 'Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/order`, rows)
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
    filteredCustomFields(action) {
      return action.customFields.filter(cf => {
        return cf.dataTypeId !== 12
      })
    },
    async loadFunctionParams(dbFunctionId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/function/${dbFunctionId}/dynamicParams`)
        this.selectedChildRequirementParamDynamicValues = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFunctionToAction(action) {
      console.log('save fn to action here')
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await postRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${action.id}/addChildFunctionToAction`, {
          companyFunctionId: this.selectedChildFunction.id,
          displayOrder: 0,
          actionParamDynamicValues: this.selectedChildRequirementParamDynamicValues
        })
        action.childFunctions.push(data)
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
    async loadChildFunctions() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/function/action/6`)
        this.childFunctions = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Functions')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateChildFunction(actionId, childFunction) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${actionId}/updateActionChildFunction`, childFunction)
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
    async deleteChildFunctionFromAction(actionId, id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${actionId}/deleteChildFunction/${id}`)
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
    // child links
    async loadLinks(actionId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/links/eventAction/${actionId}`)
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
        } = await postRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${action.id}/addLinkToAction`, {
          linkId: this.selectedLink.id
        })
        action.childLinks.push(data)
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
        const {status} = await deleteRequest(`/processStep/${this.processStepId}/event/${this.selectedEvent.id}/action/${actionId}/deleteLinkFromAction/${id}`)
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
  }

}
</script>

<style lang="scss">


</style>

<style scoped lang="scss">

.required-field-label {
  width: 100px;
}

.dynamic-field-container {
  width: 80%;
  display: inline-block;
}
</style>
