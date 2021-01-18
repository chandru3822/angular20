<template>
  <v-container class="custom-field-group-container py-0">
    <v-row>
      <v-col cols="12">
        <v-row class="mb-2">
          <v-col cols="12">
            <v-text-field color="primaryCustom"
                          :readonly="true"
                          :disabled="true"
                          v-model="processStep.processStepName"
                          label="Process Step Name"></v-text-field>
            <div>
              <label class="mt-4">Allow Non-Admin to Add to Project:</label>
              <input class="ml-3" type="checkbox" :readonly="!userCanEdit"
                     :disabled="!userCanEdit" v-model="processStep.nonAdminAdd">
            </div>
            <v-btn color="primaryCustom" dark class="white--text mt-3" v-if="userCanEdit"
                   @click="saveProcessStep">
              Save Process Step
            </v-btn>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row>
          <v-col cols="12" class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Work Queue Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="[newWorkQueueType = { selectedStatuses: [], projectStatuses: [] }, getWorkQueueTypesForStep(), prepTempStatuses(newWorkQueueType)]" v-if="userCanAdd">
                  <v-icon v-if="!addNewWorkQueueType">add</v-icon>
                  {{ addNewWorkQueueType ? 'Cancel' : 'Add Work Queue Type' }}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-card flat class="square-card mb-3" v-if="addNewWorkQueueType">
                <v-autocomplete v-model="newWorkQueueType.workQueueTypeId"
                                :items="workQueueTypes"
                                label="Select Work Queue Type"
                                item-value="id"
                                item-text="workQueueType"
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
                  item-text="fakeText"
                  return-object
                >
                  <template #selection="{ item, index }">
                    <span :class="{'bold': item.projectStatusTypeId == null}">
                      <span v-if="index !== 0" class="grey--text">
                        ,
                      </span>
                      <span class="grey--text">
                        {{ item.projectStatusType }}
                      </span>
                    </span>
                  </template>
                  <template #item="data">
                    <template v-if="typeof data.item !== 'object'">
                      <v-list-item-content v-text="data.item"></v-list-item-content>
                    </template>
                    <template v-else>
                      <v-list-item dense class="combined-statuses">
                        <v-list-item-action>
                          <input type="checkbox" v-model="data.item.selected" @change="addValueToNew(data.item)">
                        </v-list-item-action>
                        <v-list-item-title>
                          {{ data.item.projectStatusType }}
                          {{ data.item.rootProjectStatusType ? `(${data.item.rootProjectStatusType})` : '' }}
                        </v-list-item-title>
                      </v-list-item>
                    </template>
                  </template>
                </v-autocomplete>
                <v-btn :disabled="!newWorkQueueType.workQueueTypeId || !newWorkQueueType.projectStatuses || newWorkQueueType.projectStatuses.length === 0"
                       @click="assignNewWorkQueueType">
                  Save
                </v-btn>
              </v-card>
              <v-card flat v-if="processStep.workQueueTypes && processStep.workQueueTypes.length > 0">
                <v-data-table
                  :headers="headers"
                  :items="filterWorkQueueTypes()"
                  single-expand
                  :expanded.sync="expanded"
                  hide-default-footer
                  :items-per-page="-1"
                  hide-default-header
                  disable-sort
                  class="elevation-1"
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
                        item-text="fakeText"
                        return-object
                      >
                        <template #selection="{ item, index }">
                          <span :class="{'bold': item.projectStatusTypeId == null}">
                            <span v-if="index !== 0 && !item.archived" class="grey--text">
                              ,
                            </span>
                            <span class="grey--text" v-if="!item.archived">
                              {{ item.projectStatusType }}
                            </span>
                          </span>
                        </template>
                        <template #item="data">
                          <template v-if="typeof data.item !== 'object'">
                            <v-list-item-content v-text="data.item"></v-list-item-content>
                          </template>
                          <template v-else>
                            <v-list-item dense class="combined-statuses">
                              <v-list-item-action>
                                <v-checkbox :input-value="getExistingValue(item.projectStatuses, data.item)" @change="[data.item.selected = !data.item.selected, addValueToExisting(item, data.item)]"/>
                              </v-list-item-action>
                              <v-list-item-title>
                                {{ data.item.projectStatusType }}
                                {{ data.item.rootProjectStatusType ? `(${data.item.rootProjectStatusType})` : '' }}
                              </v-list-item-title>
                            </v-list-item>
                          </template>
                        </template>
                      </v-autocomplete>

                      <v-btn dark class="white--text mt-3" v-if="userCanEdit" color="primaryCustom"
                             :disabled="!item.projectStatuses || item.projectStatuses.length === 0"
                             @click="saveProjectStatusesToWorkQueueType(item)">
                        Save
                      </v-btn>
                    </td>
                  </template>

                  <template #item="{ item, index }">
                    <tr class="clickable" :class="{'shaded-row': index % 2}">
                      <td class="text-left">{{ item.workQueueCategory }} - {{ item.workQueueType }}</td>
                      <td class="text-left">
                        <span v-for="(ps, idx) in item.projectStatuses">
                          <span v-if="idx !== 0">, </span>
                          <span :class="{'bold': ps.projectStatusTypeId != null}">{{ ps.projectStatusType }}</span>
                        </span>
                      </td>
                      <td class="text-right flex-display">
                        <v-btn text @click="[expanded = [item], prepTempStatuses(item)]" v-if="!expanded.includes(item)">
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
                      </td>
                    </tr>
                  </template>
                </v-data-table>
              </v-card>
            </div>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row>
          <v-col cols="12" class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Links</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getLinksForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewLink">add</v-icon>
                  {{ addNewLink ? 'Cancel' : 'Add Link' }}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-select v-if="addNewLink"
                        v-model="newLink.linkId"
                        :items="availableLinks"
                        label="Select Link"
                        item-text="link"
                        item-value="id"
                        @input="assignNewLink"
              ></v-select>
              <v-card flat v-if="processStep.links && processStep.links.length > 0">
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
            </div>
          </v-col>
        </v-row>
        <v-divider></v-divider>
        <v-row v-if="processStepId">
          <v-col cols="12" class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getAttachmentTypesForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewType">add</v-icon>
                  {{ addNewType ? 'Cancel' : 'Add Type' }}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="pl-5">
              <v-autocomplete v-if="addNewType"
                              v-model="newType.attachmentTypeId"
                              :items="availableAttachmentTypes"
                              label="Select Attachment Type"
                              item-text="attachmentType"
                              item-value="id"
                              @input="assignNewType"
              ></v-autocomplete>
              <v-card flat v-if="processStep.attachmentTypes && processStep.attachmentTypes.length > 0">
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
            </div>
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
import {getProjectStatusTypes, getCompanyProjectStatusTypes} from '@/services/projectStatusTypeService'
import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import orderBy from "lodash.orderby"
import cloneDeep from 'lodash.clonedeep'

import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

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
      expanded: [],
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      companyProjectStatusTypes: [],
      projectStatusTypes: [],
      combinedStatuses: [ {header: 'Category'} ],
      headers: [
        {text: 'Work Queue Types', value: 'workQueueType', show: true},
        {text: 'Project Status', value: 'projectStatus', show: true},
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
      availableAttachmentTypes: [],
      workQueueTypes: [],
      newWorkQueueType: {
        projectStatuses: [],
        selectedStatuses: []
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
      ]
    }
  },
  computed: {

  },
  async created() {
    this.getProjectStatusTypes()
    await this.getProcessStepDetails()
  },
  methods: {
    addValueToNew(selectedItem) {
      if(selectedItem.selected) {
        let tempObj = { id: null, projectStatusType: selectedItem.projectStatusType, fakeText: selectedItem.fakeText }
        if(selectedItem.projectStatusTypeId === null) {
          tempObj.companyProjectStatusTypeId = null
          tempObj.projectStatusTypeId = selectedItem.id;
        } else {
          tempObj.projectStatusTypeId = null
          tempObj.companyProjectStatusTypeId = selectedItem.id;
        }
        this.newWorkQueueType.projectStatuses.push(tempObj)
      } else {
        //remove it if it has already been added
        this.newWorkQueueType.projectStatuses = this.newWorkQueueType.projectStatuses.filter(ps => {
          if(selectedItem.projectStatusTypeId === null) {
            return ps.projectStatusTypeId !== selectedItem.id
          } else {
            return ps.companyProjectStatusTypeId !== selectedItem.id
          }
        })
      }
    },
    addValueToExisting(wqtItem, selectedItem) {
      //check if already in existing - if it is, set archived to opposite of selected
      let exists = false
      let match = selectedItem.projectStatusTypeId === null ? wqtItem.projectStatuses?.find(ps => ps.id !== null && ps.projectStatusTypeId === selectedItem.id) : wqtItem.projectStatuses?.find(ps => ps.id !== null && ps.companyProjectStatusTypeId === selectedItem.id)
      if(match) {
        match.archived = selectedItem.selected
        exists = true
      }

      //if not already exists then if selected - add to existingProjectStatuses
      if(!exists && selectedItem.selected) {
        let tempObj = { id: null, projectStatusType: selectedItem.projectStatusType, fakeText: selectedItem.fakeText }
        if(selectedItem.projectStatusTypeId === null) {
          tempObj.companyProjectStatusTypeId = null
          tempObj.projectStatusTypeId = selectedItem.id;
        } else {
          tempObj.projectStatusTypeId = null
          tempObj.companyProjectStatusTypeId = selectedItem.id;
        }
        wqtItem.projectStatuses.push(tempObj)
      } else if(!exists) {
        //remove it if it has already been added
        wqtItem.projectStatuses = wqtItem.projectStatuses.filter(ps => {
          if(selectedItem.projectStatusTypeId === null) {
            return ps.projectStatusTypeId !== selectedItem.id
          } else {
            return ps.companyProjectStatusTypeId !== selectedItem.id
          }
        })
      }

    },
    getExistingValue(existingProjectStatuses, item) {
      //if ps contains item then return true
      if(item.projectStatusTypeId === null) {
        let match = existingProjectStatuses?.find(ps => ps.projectStatusTypeId === item.id)
        // console.log('metdjlks',match && match.projectStatusType !== null)
        // item.selected = !!(match && match.projectStatusType !== null)
        return match && match.projectStatusType !== null
      } else {
        let match = existingProjectStatuses?.find(ps => ps.companyProjectStatusTypeId === item.id)
        // item.selected = !!(match && match.projectStatusType !== null)
        return match && match.projectStatusType !== null
      }
    },
    prepTempStatuses(item) {
      //this is required so that selections made on one wqt are not auto-selected in other wqt's
      item.tempStatuses = cloneDeep(this.combinedStatuses)
      item.projectStatuses.forEach(ps => {
        ps.fakeText = ps.companyProjectStatusTypeId !== null ? ps.projectStatusType + 'CPST' : ps.projectStatusType + 'PST'
      })
    },
    async getCompanyProjectStatusTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getCompanyProjectStatusTypes()
        this.companyProjectStatusTypes = orderBy(data, ['rootProjectStatusType', 'projectStatusType'])
        this.combinedStatuses.push({divider: true})
        this.combinedStatuses.push({header: 'Project Status'})
        this.companyProjectStatusTypes.forEach(ps => {
          ps.group = 'Project Status'
          ps.fakeText = ps.projectStatusType + 'CPST'
          ps.selected = false
          this.combinedStatuses.push(ps)
        })
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Project Status Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProjectStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getProjectStatusTypes()
          this.projectStatusTypes = data
          this.projectStatusTypes.forEach(ps => {
            ps.group = 'Category'
            ps.fakeText = ps.projectStatusType + 'PST'
            ps.selected = false
            this.combinedStatuses.push(ps)
          })
          this.getCompanyProjectStatusTypes()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Project Status Types')
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
    async saveProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/processStep`, this.processStep)
        this.changesMade = false
        this.snackbar = getSnackbar('SUCCESS', 'Process Step Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Process Step')
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
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newWorkQueueType.processStepId = this.$route.params.id
        const {data} = await postRequest(`/workQueueType/processStep`, this.newWorkQueueType)
        this.processStep.workQueueTypes.push(data)
        // reset fields
        this.addNewWorkQueueType = false
        this.newWorkQueueType = { projectStatuses: []}
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
    async saveProjectStatusesToWorkQueueType(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/workQueueType/saveProjectStatusTypesToWorkQueueType`, item)
        item.projectStatuses = data
        this.expanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Project Status Types Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Project Status Types')
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
</style>
