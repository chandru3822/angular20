<template>
  <v-container class="custom-field-group-container py-0">
    <div class="text-center">
      <v-dialog width="700"
                v-model="deleteError"
      >
        <v-card>
          <v-card-title class="headline grey lighten-2 error--text">
            Error Deleting Status from Process Step
          </v-card-title>

          <v-card-text class="pt-5">
            <div v-if="cannotDeleteReasons.inUseByWqt" class="mb-5">
              * This status is in use by Work Queue Types. <br/>
              <span class="ml-5">You must delete those before you can delete this status.</span>
            </div>

            <div v-if="cannotDeleteReasons.inUseByInitialStep" class="mb-5">
              * This step is set as an Initial Step in a process and is using this status. <br/>
              <span class="ml-5">You must remove it there before you can delete this status.</span>
            </div>

            <div v-if="cannotDeleteReasons.actions && cannotDeleteReasons.actions.length > 0" class="mb-5">
              * This status is being used as the Parent Status in the following actions on this step:
              <div v-for="a in cannotDeleteReasons.actions" :key="a.id" class="ml-5">
                <strong>{{ a.actionName }}</strong>
              </div>
            </div>

            <div v-if="cannotDeleteReasons.childProcesses && cannotDeleteReasons.childProcesses.length > 0"
                 class="mb-5">
              * This status is being used when creating a Child Process Step in the following step and actions:
              <div v-for="a in cannotDeleteReasons.childProcesses" :key="a.id" class="ml-5">
                <strong>{{ a.processStepName }} - {{ a.actionName }}</strong>
              </div>
            </div>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>

            <v-btn
              color="primaryCustom"
              dark
              class="white--text"
              @click="deleteError = false"
            >
              OK
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
    <v-row>
      <v-col cols="12" class="py-0">
        <v-row>
          <v-col cols="12" class="pt-0 px-0">
            <v-toolbar flat class="wqt-header-bar">
              <v-toolbar-title class="app-title">Process Step Status Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text
                       @click="[addNewProcessStepStatusType = !addNewProcessStepStatusType, expanded = [], addNewWorkQueueType = false, getCompanyProcessStepStatusTypes()]"
                       v-if="userCanAdd">
                  <v-icon v-if="!addNewProcessStepStatusType">add</v-icon>
                  {{ addNewProcessStepStatusType ? 'Cancel' : 'Add Process Step Status Type' }}
                </v-btn>
                <v-btn text @click="expandPsst = !expandPsst">
                  <v-icon v-if="!expandPsst">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="mb-4">
              <v-card flat class="square-card mb-3 pa-3" color="rowShadeCustom" v-if="addNewProcessStepStatusType">
                <h3>Assign a Status Type</h3>
                <v-autocomplete label="Process Step Status Type"
                                :items="availableCompanyProcessStepStatusTypes"
                                v-model="newProcessStepStatusTypeId"
                                item-text="processStepStatusType"
                                item-value="id"
                                attach
                                :loading="companyStatusesLoading"
                                autocomplete="off"
                                @input="assignStatusTypeToProcessStep"
                >
                  <template slot="item" slot-scope="data">
                    <!-- HTML that describes how select should render items when the select is open -->
                    {{ data.item.processStepStatusType }} ({{ data.item.rootProcessStepStatusType }})
                  </template>
                </v-autocomplete>
              </v-card>
              <v-data-table
                v-if="expandPsst"
                :headers="processStepHeaders"
                :items="filterAssignedProcessStepStatusTypes()"
                hide-default-footer
                :items-per-page="-1"
                disable-sort
                class="elevation-1 square-card mb-2"
              >
                <template #no-data>
                  No available process step status types
                </template>

                <template #no-results>
                  No available process step status types
                </template>

                <template #item="{ item, index }">
                  <tr class="clickable" :class="{'shaded-row': index % 2}">
                    <td class="text-left">{{ item.processStepStatusType }}</td>
                    <td class="text-left">{{ item.rootProcessStepStatusType }}</td>
                    <td class="text-right">
                      <div class="flex-display">
                        <v-dialog
                          v-if="userCanEdit"
                          v-model="item.deleteConfirm"
                          width="500">
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
                              Are you sure you want to delete <strong>{{ item.processStepStatusType }}</strong>?
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
                                @click="deleteStatusTypeFromStep(item)">
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
            </div>
            <!--            work queue types -->
            <v-toolbar flat class="wqt-header-bar">
              <v-toolbar-title class="app-title">Work Queue Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text
                       @click="[newWorkQueueType = { projectStatuses: [], processStepStatuses: [] }, getWorkQueueTypesForStep(), prepTempStatuses(newWorkQueueType, false), prepTempProcessStepStatuses(newWorkQueueType, false)]"
                       v-if="userCanAdd">
                  <v-icon v-if="!addNewWorkQueueType">add</v-icon>
                  {{ addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type' }}
                </v-btn>
                <v-btn text @click="expandWqt = !expandWqt">
                  <v-icon v-if="!expandWqt">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div>
              <v-card flat class="square-card mb-3 pa-3" color="rowShadeCustom" v-if="addNewWorkQueueType">
                <v-autocomplete v-model="newWorkQueueType.workQueueTypeId"
                                :items="workQueueTypes"
                                label="Select Work Queue Type"
                                item-value="id"
                                item-text="workQueueType"
                                attach
                >
                  <template slot="item" slot-scope="data">
                    <!-- HTML that describes how select should render items when the select is open -->
                    {{ data.item.workQueueCategory }} - {{ data.item.workQueueType }}
                  </template>
                </v-autocomplete>
                <v-autocomplete
                  v-model="newWorkQueueType.projectStatuses"
                  :items="newWorkQueueType.tempStatuses"
                  multiple
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Project Status Types"
                  item-text="uniqueText"
                  return-object>
                  <template #selection="{ item, index }">
                    <span :class="{'bold': item.isRoot}">
                      <span v-if="index !== 0" class="grey--text">
                        ,
                      </span>
                      <span class="grey--text">
                        {{ item.projectStatusType }}
                      </span>
                    </span>
                  </template>
                  <template #item="data">
                    <template v-if="data.item.header !== null">
                      <v-list-item-content v-text="data.item.header"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <input type="checkbox" :disabled="data.item.disabled" v-model="data.item.selected"
                                 @change="addValueToNew(data.item)">
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.projectStatusType }}
                          {{ !data.item.isRoot ? `(${data.item.rootProjectStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>
                <v-autocomplete
                  v-model="newWorkQueueType.processStepStatuses"
                  :items="newWorkQueueType.tempProcessStepStatuses"
                  multiple
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Process Step Status Types"
                  item-text="uniqueText"
                  return-object>
                  <template #selection="{ item, index }">
                    <span :class="{'bold': item.isRoot}">
                      <span v-if="index !== 0" class="grey--text">
                        ,
                      </span>
                      <span class="grey--text">
                        {{ item.processStepStatusType }}
                      </span>
                    </span>
                  </template>
                  <template #item="data">
                    <template v-if="data.item.header !== null">
                      <v-list-item-content v-text="data.item"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <input type="checkbox" :disabled="data.item.disabled" v-model="data.item.selected"
                                 @change="addProcessStepValueToNew(data.item)">
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.processStepStatusType }}
                          {{ data.item.isRoot ? `(${data.item.rootProcessStepStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>
                <v-btn
                  :disabled="!newWorkQueueType.workQueueTypeId || (!newWorkQueueType.projectStatuses || newWorkQueueType.projectStatuses.length === 0) || (!newWorkQueueType.processStepStatuses || newWorkQueueType.processStepStatuses.length === 0) "
                  @click="assignNewWorkQueueType">
                  Save
                </v-btn>
              </v-card>
              <v-card flat v-if="processStep.workQueueTypes && processStep.workQueueTypes.length > 0 && expandWqt">
                <v-data-table
                  :headers="headers"
                  :items="filterWorkQueueTypes()"
                  single-expand
                  :expanded.sync="expanded"
                  hide-default-footer
                  :items-per-page="-1"
                  disable-sort
                  class="elevation-1 square-card"
                >
                  <template #no-data>
                    No available work queue types
                  </template>

                  <template #no-results>
                    No available work queue types
                  </template>

                  <template #expanded-item="{ headers, item }">
                    <td :colspan="headers.length" class="pa-4"
                        :class="{'shaded-row': processStep.workQueueTypes.indexOf(item) % 2}">

                      <v-autocomplete
                        v-model="item.projectStatuses"
                        :items="item.tempStatuses"
                        multiple
                        menu-props="auto"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Project Status Types"
                        item-text="uniqueText"
                        return-object>
                        <template #selection="{ item: status, index }" v-if="showShit">
                          <span :class="{'bold': status.isRoot}">
                            <span class="grey--text" v-if="!status.archived">{{ status.projectStatusType }}</span>
                            <span v-if="!status.archived && index !== item.projectStatuses.length - 1" class="grey--text mr-1">,</span>
                          </span>
                        </template>
                        <template #item="data" v-if="showShit">
                            <template v-if="data.item.header !== null">
                              <v-list-item-content v-text="data.item"></v-list-item-content>
                            </template>
                            <template v-else>
                              <v-list-item dense class="combined-statuses">
                                <v-list-item-action>
                                  <v-checkbox :disabled="data.item.disabled" :input-value="getExistingValue(item.projectStatuses, data.item)"
                                              @change="[data.item.selected = !data.item.selected, addValueToExisting($event, item, data.item)]"/>
                                </v-list-item-action>
                                <v-list-item-title>
                                  {{ data.item.projectStatusType }}
                                  {{ !data.item.isRoot ? `(${data.item.rootProjectStatusType})` : '' }}
                                </v-list-item-title>
                              </v-list-item>
                            </template>
                        </template>
                      </v-autocomplete>

                      <v-autocomplete
                        v-model="item.processStepStatuses"
                        :items="item.tempProcessStepStatuses"
                        multiple
                        menu-props="auto"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        label="Process Step Status Types"
                        item-text="uniqueText"
                        return-object>
                        <template #selection="{ item: status, index }" v-if="showPsShit">
                          <span :class="{'bold': status.isRoot}">
                            <span class="grey--text" v-if="!status.archived">{{ status.processStepStatusType }}</span>
                            <span v-if="!status.archived && index !== item.processStepStatuses.length - 1" class="grey--text mr-1">,</span>
                          </span>
                        </template>
                        <template #item="data" v-if="showPsShit">
                          <template v-if="data.item.header !== null">
                            <v-list-item-content v-text="data.item"></v-list-item-content>
                          </template>
                          <template v-else>
                            <v-list-item dense class="combined-statuses">
                              <v-list-item-action>
                                <v-checkbox :disabled="data.item.disabled" :input-value="getProcessStepExistingValue(item.processStepStatuses, data.item)"
                                  @change="[data.item.selected = !data.item.selected, addProcessStepValueToExisting($event, item, data.item)]"/>
                              </v-list-item-action>
                              <v-list-item-title>
                                {{ data.item.processStepStatusType }}
                                {{ !data.item.isRoot ? `(${data.item.rootProcessStepStatusType})` : '' }}
                              </v-list-item-title>
                            </v-list-item>
                          </template>
                        </template>
                      </v-autocomplete>

                      <v-btn class="mt-3" v-if="userCanEdit"
                             :disabled="(!item.projectStatuses || item.projectStatuses.filter(ps => !ps.archived).length === 0)
                                          || (!item.processStepStatuses || item.processStepStatuses.filter(ps => !ps.archived).length === 0)"
                             @click="saveStatusesToWorkQueueType(item)">
                        Save
                      </v-btn>
                    </td>
                  </template>

                  <template #item="{ item, index }">
                    <tr class="clickable" :class="{'shaded-row': index % 2}">
                      <td class="text-left">{{ item.workQueueCategory }}</td>
                      <td class="text-left">{{ item.workQueueType }}</td>
                      <td class="text-left">
                        <span v-for="(ps, idx) in filterBy(item.projectStatuses, false, 'archived')">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': ps.isRoot}">{{ ps.projectStatusType }}</span>
                        </span>
                      </td>
                      <td class="text-left">
                        <span v-for="(pss, idx) in filterBy(item.processStepStatuses, false, 'archived')">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': pss.isRoot}">{{pss.processStepStatusType }}</span>
                        </span>
                      </td>
                      <td class="text-right">
                        <div class="flex-display">
                          <v-btn text
                                 @click="[expanded = [item], prepTempStatuses(item, true), prepTempProcessStepStatuses(item, true)]"
                                 v-if="!expanded.includes(item)">
                            <v-icon>edit</v-icon>
                          </v-btn>
                          <v-btn text @click="expanded = []" v-else>cancel
                          </v-btn>
                          <v-dialog
                            v-if="userCanEdit"
                            v-model="item.deleteConfirm"
                            width="500">
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
                                Are you sure you want to delete <strong>{{ item.workQueueType }}</strong>?
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
                                  @click="deleteWorkQueueTypeFromStep(item)">
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
            </div>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" class="mt-1 pa-0">
            <v-toolbar flat class="link-header-bar">
              <v-toolbar-title class="app-title">Links</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getLinksForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewLink">add</v-icon>
                  {{ addNewLink ? 'Cancel' : 'Add Link' }}
                </v-btn>
                <v-btn text @click="expandLinks = !expandLinks">
                  <v-icon v-if="!expandLinks">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="square-card pa-2" color="rowShadeCustom" v-if="addNewLink">
              <v-select attach v-if="addNewLink"
                        v-model="newLink.linkId"
                        :items="availableLinks"
                        label="Select Link"
                        item-text="link"
                        item-value="id"
                        @input="assignNewLink"
              ></v-select>
            </v-card>
            <v-card flat v-if="processStep.links && processStep.links.length > 0 && expandLinks">
              <draggable v-model="processStep.links" group="links"
                         :disabled="!userCanEdit"
                         id="link-draggable"
                         @change="saveLinkOrder(processStep.links)"
                         @start="drag=true" @end="drag=false">
                <v-list class="grab" v-for="(a, index) in filterBy(processStep.links, false, 'archived')"
                        :key="index">
                  <v-list-item dense :class="{'shaded-row': index % 2}">
                    <v-list-item-action>
                      <v-icon>drag_handle</v-icon>
                    </v-list-item-action>
                    <v-list-item-content>
                      {{ a.link }} | {{ a.url }}
                    </v-list-item-content>
                    <v-dialog
                      v-if="userCanEdit"
                      v-model="a.deleteConfirm"
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
                          Are you sure you want to delete this link: <strong>{{ a.link }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="a.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="[a.archived = true, deleteLinkFromStep(a.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </draggable>
            </v-card>
          </v-col>
        </v-row>
        <v-row v-if="processStepId">
          <v-col cols="12" class="pa-0 mt-4">
            <v-toolbar flat class="attach-header-bar">
              <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getAttachmentTypesForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewType">add</v-icon>
                  {{ addNewType ? 'Cancel' : 'Add Type' }}
                </v-btn>
                <v-btn text @click="expandAttachmentTypes = !expandAttachmentTypes">
                  <v-icon v-if="!expandAttachmentTypes">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="square-card pa-2" color="rowShadeCustom" v-if="addNewType">
              <v-autocomplete v-model="newType.attachmentTypeId"
                              :items="availableAttachmentTypes"
                              label="Select Attachment Type"
                              item-text="attachmentType"
                              item-value="id"
                              @input="assignNewType"
                              attach
              ></v-autocomplete>
            </v-card>
            <v-card flat
                    v-if="processStep.attachmentTypes && processStep.attachmentTypes.length > 0 && expandAttachmentTypes">
              <draggable v-model="processStep.attachmentTypes" group="attachmentTypes"
                         :disabled="!userCanEdit"
                         id="attachment-draggable"
                         @change="saveAttachmentTypeOrder(processStep.attachmentTypes)"
                         @start="drag=true" @end="drag=false">
                <v-list v-for="(a, index) in filterBy(processStep.attachmentTypes, false, 'archived')" :key="index">
                  <v-list-item class="grab" dense :class="{'shaded-row': index % 2}">
                    <v-list-item-action>
                      <v-icon>drag_handle</v-icon>
                    </v-list-item-action>
                    <v-list-item-content>
                      {{ a.attachmentType }}
                    </v-list-item-content>
                    <v-dialog
                      v-if="userCanEdit"
                      v-model="a.deleteConfirm"
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
                          Are you sure you want to delete this attachment type: <strong>{{
                            a.attachmentType
                          }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="a.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="[a.archived = true, deleteTypeFromStep(a.id)]">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </v-list-item>
                </v-list>
              </draggable>
            </v-card>
          </v-col>
        </v-row>
      </v-col>

    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import {getStatusTypes, getAvailableForProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import orderBy from "lodash.orderby"
import cloneDeep from 'lodash.clonedeep'

import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'

export default {
  name: 'ProcessStepComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    ProcessStepCustomFieldGroups,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      expandPsst: true,
      expandWqt: true,
      expandLinks: true,
      expandAttachmentTypes: true,
      expanded: [],
      deleteError: false,
      cannotDeleteReasons: {},
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      companyProjectStatusTypes: [],
      projectStatusTypes: [],
      combinedStatuses: [],
      companyProcessStepStatusTypes: [],
      processStepStatusTypes: [],
      combinedProcessStepStatuses: [],
      headers: [
        {text: 'Category', value: 'workQueueCategory', show: true},
        {text: 'Type', value: 'workQueueType', show: true},
        {text: 'Project Status', value: 'projectStatus', show: true},
        {text: 'Process Step Status', value: 'processStepStatus', show: true},
        {text: '', value: 'icons', show: false, width: '100px'},
      ],
      addNewCustomFieldGroup: false,
      changesMade: false,
      addNewType: false,
      newType: {},
      addNewLink: false,
      newLink: {},
      availableLinks: [],
      processStepId: this.$route.params.id,
      companyId: this.$store.state.user.details.companyId,
      processStep: {},
      companyStatusesLoading: false,
      availableAttachmentTypes: [],
      availableCompanyProcessStepStatusTypes: [],
      addNewProcessStepStatusType: false,
      newProcessStepStatusTypeId: null,
      processStepHeaders: [
        {text: 'Status Type', value: 'statusType', show: true},
        {text: 'Category', value: 'category', show: true},
        {text: '', value: 'icons', show: false, width: '100px'},
      ],
      workQueueTypes: [],
      newWorkQueueType: {
        processStepStatuses: [],
        projectStatuses: [],
      },
      addNewWorkQueueType: false,
      checkedIds: [],
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/settings/processSteps`
        },
      ],
      showShit: true,
      showPsShit: true
    }
  },
  computed: {},
  async created() {
    this.getProjectStatusTypesForWorkQueue()
    this.getProcessStepStatusTypesForWorkQueue()
    await this.getProcessStepDetails()
  },
  methods: {
    async getCompanyProcessStepStatusTypes() {
      if(this.addNewProcessStepStatusType) {
        this.companyStatusesLoading = true
        try {
          const {data} = await getAvailableForProcessStep(this.processStepId)
          this.availableCompanyProcessStepStatusTypes = data
          this.companyStatusesLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Process Step Status Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.companyStatusesLoading = false
        }
      }

    },
    addValueToNew(selectedItem) {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          this.newWorkQueueType.projectStatuses = this.newWorkQueueType.projectStatuses.filter(ps => {
            return ps.companyProjectStatusTypeId === null || (ps.projectStatusTypeId !== selectedItem.projectStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          this.newWorkQueueType.tempStatuses = this.newWorkQueueType.tempStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ps.disabled,
            selected: ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? false : ps.selected
          }))
        }
        this.newWorkQueueType.projectStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.projectStatuses = this.newWorkQueueType.projectStatuses.filter(ps => {
          if (selectedItem.companyProjectStatusTypeId === null) {
            return ps.projectStatusTypeId !== selectedItem.projectStatusTypeId
          } else {
            return ps.companyProjectStatusTypeId !== selectedItem.companyProjectStatusTypeId
          }
        })
        //if the item is de-selected and isRoot then enable the child options again
        if (selectedItem.isRoot) {
          this.newWorkQueueType.tempStatuses.forEach(ps => {
            if (ps.companyProjectStatusTypeId !== null && ps.projectStatusTypeId === selectedItem.projectStatusTypeId) {
              ps.disabled = false
            }
          })
        }
      }
    },
    addValueToExisting(e, wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived as needed
      //note: the selectedItem.selected value hasn't changed yet, but "e" should be the accurate event value
      let match = selectedItem.isRoot
                        ? wqtItem.projectStatuses?.find(ps => ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId)
                        : wqtItem.projectStatuses?.find(ps => !ps.isRoot && ps.companyProjectStatusTypeId === selectedItem.companyProjectStatusTypeId)

      if (match !== undefined) {
        match.archived = !e
        selectedItem.archived = !e

        //if the selectedItem isRoot then enable/disable the child options as required
        if(selectedItem.isRoot) {
          this.handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.projectStatuses.push(selectedItem)
        if(selectedItem.isRoot) {
          this.handleTogglingParentStatus(e, wqtItem, selectedItem)
        }
      }

    },
    handleTogglingParentStatus(e, wqtItem, selectedItem) {
      this.showShit = false

      wqtItem.tempStatuses = wqtItem.tempStatuses.map(ts => ({
        ...ts,
        selected: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId && !e ? false : ts.selected,
        disabled: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId ? e : ts.disabled,
        archived: !ts.isRoot && ts.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ts.archived
      }))

      wqtItem.projectStatuses = wqtItem.projectStatuses.map(ps => ({
        ...ps,
        archived: !ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? true : ps.archived,
        selected: !ps.isRoot && ps.projectStatusTypeId === selectedItem.projectStatusTypeId ? false : ps.archived
      }))
      this.showShit = true
    },
    handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem) {
      this.showPsShit = false

      wqtItem.tempProcessStepStatuses = wqtItem.tempProcessStepStatuses.map(ts => ({
        ...ts,
        selected: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId && !e ? false : ts.selected,
        disabled: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? e : ts.disabled,
        archived: !ts.isRoot && ts.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ts.archived
      }))

      wqtItem.processStepStatuses = wqtItem.processStepStatuses.map(ps => ({
        ...ps,
        archived: !ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ps.archived,
        selected: !ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? false : ps.archived
      }))
      this.showPsShit = true
    },
    getExistingValue(existingProjectStatuses, item) {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProjectStatuses?.find(ps => ps.projectStatusTypeId === item.projectStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProjectStatuses?.find(ps => ps.companyProjectStatusTypeId === item.companyProjectStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    },
    prepTempStatuses(item, existingItem) {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempStatuses = cloneDeep(this.combinedStatuses)

      if(existingItem) {
        //if an existing item, then get a list of all the used root statuses and disable the ui as needed
        let rootStatusesIdsUsed = []
        item.projectStatuses.forEach(ps => {
          if(ps.isRoot) {
            rootStatusesIdsUsed.push(ps.projectStatusTypeId)
          }
        })
        //if there are root statuses being used then handle that shit
        if(rootStatusesIdsUsed.length > 0) {
          item.tempStatuses = item.tempStatuses.map(ts => ({
            ...ts,
            disabled: !ts.isRoot && rootStatusesIdsUsed.includes(ts.projectStatusTypeId)
          }))
        }
      }
    },
    async getProjectStatusTypesForWorkQueue() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/project/statusesForWqt`)
        this.combinedStatuses = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Project Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    // process step status repeat of all the project status stuff
    addProcessStepValueToNew(selectedItem) {
      if (selectedItem.selected) {
        if (selectedItem.isRoot) {
          //if it is a root item, then remove any company level ones that were already selected that share the root status
          this.newWorkQueueType.processStepStatuses = this.newWorkQueueType.processStepStatuses.filter(ps => {
            return ps.companyProcessStepStatusTypeId === null || (ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId)
          })
          //disable any of the options in the dropdown that share the same root
          this.newWorkQueueType.tempProcessStepStatuses = this.newWorkQueueType.tempProcessStepStatuses.map(ps => ({
            ...ps,
            disabled: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? true : ps.disabled,
            selected: ps.companyProcessStepStatusTypeId !== null && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId ? false : ps.selected
          }))
        }

        this.newWorkQueueType.processStepStatuses.push(selectedItem)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.processStepStatuses = this.newWorkQueueType.processStepStatuses.filter(ps => {
          if (selectedItem.companyProcessStepStatusTypeId === null) {
            return ps.processStepStatusTypeId !== selectedItem.processStepStatusTypeId
          } else {
            return ps.companyProcessStepStatusTypeId !== selectedItem.companyProcessStepStatusTypeId
          }
        })
      }
    },
    addProcessStepValueToExisting(e, wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived as needed
      //note: the selectedItem.selected value hasn't changed yet, but "e" should be the accurate event value
      let match = selectedItem.isRoot
        ? wqtItem.processStepStatuses?.find(ps => ps.isRoot && ps.processStepStatusTypeId === selectedItem.processStepStatusTypeId)
        : wqtItem.processStepStatuses?.find(ps => !ps.isRoot && ps.companyProcessStepStatusTypeId === selectedItem.companyProcessStepStatusTypeId)

      if (match !== undefined) {
        match.archived = !e
        selectedItem.archived = !e

        //if the selectedItem isRoot then enable/disable the child options as required
        if(selectedItem.isRoot) {
          this.handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      } else if (selectedItem.selected) {
        //if not already exists then if selected - add to existingProjectStatuses
        //then filter/disable as needed
        selectedItem.archived = false //this un-does some crap we do elsewhere
        wqtItem.processStepStatuses.push(selectedItem)
        if(selectedItem.isRoot) {
          this.handleTogglingParentProcessStepStatus(e, wqtItem, selectedItem)
        }
      }
    },
    getProcessStepExistingValue(existingProcessStepStatuses, item) {
      //if ps contains item then return true
      if (item.isRoot) {
        let match = existingProcessStepStatuses?.find(ps => ps.processStepStatusTypeId === item.processStepStatusTypeId && ps.isRoot && !ps.archived)
        return match !== undefined
      } else {
        //company status
        let match = existingProcessStepStatuses?.find(ps => ps.companyProcessStepStatusTypeId === item.companyProcessStepStatusTypeId && !ps.isRoot && !ps.archived)
        return match !== undefined
      }
    },
    prepTempProcessStepStatuses(item, existingItem) {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempProcessStepStatuses = cloneDeep(this.combinedProcessStepStatuses)

      if(existingItem) {
        //if an existing item, then get a list of all the used root statuses and disable the ui as needed
        let rootStatusesIdsUsed = []
        item.processStepStatuses.forEach(ps => {
          if(ps.isRoot) {
            rootStatusesIdsUsed.push(ps.processStepStatusTypeId)
          }
        })
        //if there are root statuses being used then handle that shit
        if(rootStatusesIdsUsed.length > 0) {
          item.tempProcessStepStatuses = item.tempProcessStepStatuses.map(ts => ({
            ...ts,
            disabled: !ts.isRoot && rootStatusesIdsUsed.includes(ts.processStepStatusTypeId)
          }))
        }
      }
    },
    async deleteStatusTypeFromStep(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //have to close the work queue editor to for the component to refresh available values
        this.addNewWorkQueueType = false
        this.expanded = []
        await putRequest(`/processStep/status/removeStatus/${item.id}/fromStep/${this.processStepId}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)

        if (e.status === 400) {
          item.deleteConfirm = false
          this.deleteError = true
          this.cannotDeleteReasons = e.data
        }
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignStatusTypeToProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.processStepId = this.$route.params.id
        const {data} = await postRequest(`/processStep/status/assignCompanyStatus/${this.newProcessStepStatusTypeId}/toProcessStep/${this.processStepId}`)
        this.processStep.companyProcessStepStatusTypes.push(data)
        // reset fields
        this.addNewProcessStepStatusType = false
        this.newProcessStepStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProcessStepStatusTypesForWorkQueue() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequestWithParams(`/processStep/status/forWqt`,  {
          params: { processStepId: this.processStepId }
        })
        this.combinedProcessStepStatuses = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Process Step Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProcessStepDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/processStep/${this.processStepId}`)
        this.processStep = data
        this.$store.commit(AppMutations.SET_LOADING, false)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async getAttachmentTypesForProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if (this.addNewType) {
          const {data} = await getRequest(`/attachmentType/typesForStep/${this.$route.params.id}`)
          this.availableAttachmentTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.processStepId = this.$route.params.id
        const {data} = await postRequest(`/attachmentType/processStepType`, this.newType)
        this.processStep.attachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteTypeFromStep(id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        await deleteRequest(`/attachmentType/processStepType/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getLinksForProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewLink = !this.addNewLink
        if (this.addNewLink) {
          const {data} = await getRequest(`/links/processStep/${this.$route.params.id}/available`)
          this.availableLinks = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewLink() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newLink.processStepId = this.$route.params.id
        const {data} = await postRequest(`/links/processStep`, this.newLink)
        this.processStep.links.push(data)
        // reset fields
        this.addNewLink = false
        this.newLink = {}
        this.snackbar = getSnackbar('SUCCESS', 'Link Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Link')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteLinkFromStep(id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewLink = false
        await deleteRequest(`/links/processStep/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Link Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getWorkQueueTypesForStep() {
      try {
        this.addNewWorkQueueType = !this.addNewWorkQueueType
        if (this.addNewWorkQueueType) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequest(`/workQueueType/processStep/${this.$route.params.id}`)
          this.workQueueTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewWorkQueueType() {
      //todo make this work for both proj and process step types
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newWorkQueueType.processStepId = this.$route.params.id
        const {data} = await postRequest(`/workQueueType/processStep`, this.newWorkQueueType)
        this.processStep.workQueueTypes.push(data)
        // reset fields
        this.addNewWorkQueueType = false
        this.newWorkQueueType = {projectStatuses: [], processStepStatuses: []}
        this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Work Queue Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveStatusesToWorkQueueType(item) {
      //todo: fix this to save both things
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/workQueueType/saveStatusTypesToWorkQueueType`, item)
        item.projectStatuses = data.projectStatuses
        item.processStepStatuses = data.processStepStatuses
        this.expanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Status Types Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWorkQueueTypeFromStep(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewWorkQueueType = false
        await deleteRequest(`/workQueueType/processStep/${item.id}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterWorkQueueTypes() {
      return this.processStep?.workQueueTypes.filter(u => {
        return !u.archived
      })
    },
    filterAssignedProcessStepStatusTypes() {
      return orderBy(this.processStep?.companyProcessStepStatusTypes?.filter(u => {
        return !u.archived
      }), [f => f.processStepStatusType])
    },
    async saveAttachmentTypeOrder(attachmentTypes) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let typesToSave = []
        attachmentTypes.forEach((f, idx) => {
          let order = idx + 1
          if (f.displayOrder !== order) {
            f.displayOrder = order
            typesToSave.push(f)
          }
        })
        // save them here
        if (typesToSave.length > 0) {
          await putRequest(`/attachmentType/updateOrderInProcessStep`, typesToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Types Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveLinkOrder(links) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let linksToSave = []
        links.forEach((f, idx) => {
          let order = idx + 1
          if (f.displayOrder !== order) {
            f.displayOrder = order
            linksToSave.push(f)
          }
        })
        // save them here
        if (linksToSave.length > 0) {
          await putRequest(`/links/updateOrderInProcessStep`, linksToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Links Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Links')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }

}
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-rowShadeCustom-base) !important;
  border-radius: 5px;
}

#attachment-draggable .v-list, #link-draggable .v-list {
  padding-top: 0;
  padding-bottom: 0;
}

.combined-statuses > div.v-list-item__action {
  min-width: 10px !important;
  width: 10px;
  margin-left: 15px;
  margin-right: 20px !important;
}

.wqt-header-bar {
  border-bottom: 1px solid #E6E6E6;
  border-top: 1px solid #E6E6E6;
}

.link-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}

.attach-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}
</style>
