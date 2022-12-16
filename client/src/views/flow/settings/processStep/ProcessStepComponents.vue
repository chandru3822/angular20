<template>
  <v-container class="custom-field-group-container py-0">
    <div class="text-center">
      <v-dialog width="700"
                v-model="deleteError"
      >
        <v-card>
          <v-card-title class="text-h5 grey lighten-2 error--text">
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
              color="primary"
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
                <v-btn text color="primary"
                       @click="[addNewProcessStepStatusType = !addNewProcessStepStatusType, expanded = [], getCompanyProcessStepStatusTypes()]"
                       v-if="userCanAdd">
                  <v-icon v-if="!addNewProcessStepStatusType">add</v-icon>
                  {{ addNewProcessStepStatusType ? 'Cancel' : 'Add Process Step Status Type' }}
                </v-btn>
                <v-btn text color="primary" @click="expandPsst = !expandPsst">
                  <v-icon v-if="!expandPsst">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <div class="mb-4">
              <v-card flat class="square-card mb-3 pa-3" color="primary lighten-9" v-if="addNewProcessStepStatusType">
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
                  <span class="default-text-color">No available process step status types</span>
                </template>

                <template #no-results>
                  <span class="default-text-color">No available process step status types</span>
                </template>

                <template #item="{ item, index }">
                  <tr class="clickable" :class="{'shaded-row': index % 2}">
                    <td class="text-left"><a href="/settings/processStepStatuses" >{{ item.processStepStatusType }}</a></td>
                    <td class="text-left">{{ item.rootProcessStepStatusType }}</td>
                    <td class="text-left" v-if="allowNonAdminAdd">
                      <input type="checkbox" v-model="item.allowNonAdminUse"
                             @input="saveNonAdminUse($event, item)"
                             :disabled="!userCanEdit" :readonly="!userCanEdit" />
                    </td>
                    <td class="text-right">
                      <div class="flex-display">
                        <v-btn v-if="userCanEdit" small text color="primary" @click="deleteProcessStepStatusType=item"><v-icon>delete</v-icon></v-btn>
                      </div>
                    </td>
                  </tr>
                </template>
              </v-data-table>
            </div>
            <ProcessStepWorkQueueTypes :process-step="processStep"></ProcessStepWorkQueueTypes>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" class="mt-1 pa-0">
            <v-toolbar flat class="link-header-bar">
              <v-toolbar-title class="app-title">Links</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text color="primary" @click="getLinksForProcessStep" v-if="userCanAdd">
                  <v-icon v-if="!addNewLink">add</v-icon>
                  {{ addNewLink ? 'Cancel' : 'Add Link' }}
                </v-btn>
                <v-btn text color="primary" @click="expandLinks = !expandLinks">
                  <v-icon v-if="!expandLinks">mdi-chevron-down</v-icon>
                  <v-icon v-else>mdi-chevron-up</v-icon>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="square-card pa-2" color="primary lighten-9" v-if="addNewLink">
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
                      {{ a.link }}
                    </v-list-item-content>
                    <v-btn v-if="userCanEdit" small text color="primary" @click="deleteLink=a"><v-icon>delete</v-icon></v-btn>
                  </v-list-item>
                </v-list>
              </draggable>
            </v-card>
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="12" class="pa-0 mt-4">
            <v-toolbar flat class="access-header-bar">
              <v-toolbar-title class="app-title">Process Step Access Control</v-toolbar-title>
            </v-toolbar>
            <v-card flat color="rowShadeCustom" class="square-card mt-2">
              <v-card-title style="height: 40px" class="py-0">
                Read Only
                <v-checkbox :disabled="!userCanEdit" type="checkbox" class="ml-3"
                            v-model="processStep.readonly"></v-checkbox>
              </v-card-title>
              <v-card-text>
                <v-autocomplete
                  v-if="processStep.readonly"
                  v-model="processStep.whiteListedPositions"
                  :items="positions"
                  :loading="positionsLoading"
                  multiple
                  clearable
                  label="White Listed Positions"
                  item-text="position"
                  item-value="positionId"
                  return-object
                  height="35px"
                  class="d-inline-block mr-3"
                  @change="readOnlyPositionsChanged = true">
                  <v-list-item
                    slot="prepend-item"
                    ripple
                    @click="toggleSelectAllPositionsOwner()"
                  >
                    <v-list-item-action>
                      <v-icon>{{ iconOwner() }}</v-icon>
                    </v-list-item-action>
                    <v-list-item-title>Select All</v-list-item-title>
                  </v-list-item>
                  <v-divider
                    slot="prepend-item"
                    class="mt-2"
                  ></v-divider>
                  <template
                    slot="selection"
                    slot-scope="{ item, index }"
                  >
                    <v-chip small
                            v-if="index === 0 && processStep.whiteListedPositions && processStep.whiteListedPositions.length < 2">
                      <span>{{ item.position }}</span>
                    </v-chip>
                    <span
                      v-if="index === 1 && processStep.whiteListedPositions && processStep.whiteListedPositions.length >= 2"
                      class="primary--text text-caption"
                    >{{ processStep.whiteListedPositions.length }} selected</span>
                  </template>
                </v-autocomplete>
                <br/>
                <v-btn v-if="userCanEdit" color="primary" class="d-inline-block"
                       @click="saveReadOnlyAndWhiteList()">
                  <v-icon class="mr-2">save</v-icon>
                  Save
                </v-btn>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="confirmDelete" @close-dialog="[deleteProcessStepStatusType = null, deleteLink = null, deleteAttachment = null]">
      Are you sure you want to delete {{deleteDialogText}}<strong>{{deleteDialogItemText}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import {getAvailableForProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import ProcessStepWorkQueueTypes from './ProcessStepWorkQueueTypes'
import orderBy from "lodash.orderby"
import cloneDeep from 'lodash.clonedeep'

import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar,
  getRequestWithParams
} from '@/helpers/helpers'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ProcessStepComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ConfirmDeleteDialog,
    ProcessStepWorkQueueTypes,
    ProcessStepCustomFieldGroups,
    draggable,
  },
  props: {
    nonAdminAdd: Boolean
  },
  data() {
    return {
      snackbar: {},
      expandPsst: true,
      expandLinks: true,
      expanded: [],
      deleteError: false,
      cannotDeleteReasons: {},
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
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
      positions: [],
      positionsLoading: false,
      readOnlyPositionsChanged: false,
      companyStatusesLoading: false,
      availableCompanyProcessStepStatusTypes: [],
      addNewProcessStepStatusType: false,
      newProcessStepStatusTypeId: null,
      checkedIds: [],
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/settings/processSteps`
        },
      ],
      deleteProcessStepStatusType: null,
      deleteLink: null,
      deleteAttachment: null
    }
  },
  computed: {
    allowNonAdminAdd() {
      return this.nonAdminAdd
    },
    processStepHeaders() {
      let headers = [
        {text: 'Status Type', value: 'statusType', show: true},
        {text: 'Category', value: 'category', show: true},
        {text: 'Allow Non-Admin Use', value: 'allowNonAdminUse', show: this.nonAdminAdd || false},
        {text: '', value: 'icons', show: true, width: '100px'},
      ]
      return headers.filter(h => h.show)
    },
    showDeleteDialog(){
      return Boolean(this.deleteProcessStepStatusType || this.deleteAttachment || this.deleteLink)
    },
    deleteDialogText(){
      if(this.deleteLink){
        return `this link: `
      }
      if(this.deleteAttachment){
        return `this attachment: `
      }
      return ''
    },
    deleteDialogItemText(){
      if(this.deleteProcessStepStatusType){
        return this.deleteProcessStepStatusType.processStepStatusType
      }
      if(this.deleteLink){
        return this.deleteLink.link
      }
      if(this.deleteAttachment){
        return this.deleteAttachment.attachmentType
      }
      return ''
    }
  },
  async created() {
    await this.getProcessStepDetails()
    this.getPositions()
  },
  methods: {
    selectAllReadOnly () {
      return this.processStep.whiteListedPositions?.length === this.positions?.length
    },
    selectSomeReadOnly (f) {
      return this.processStep.hiteListedPositions?.length > 0 && !this.selectAllReadOnly(f)
    },
    iconOwner () {
      if (this.selectAllReadOnly()) {
        return 'check_box'
      }
      if (this.selectSomeReadOnly()) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    toggleSelectAllPositionsOwner () {
      this.$nextTick(() => {
        if (this.selectAllReadOnly()) {
          this.processStep.whiteListedPositions = []
          this.readOnlyPositionsChanged = true
        } else {
          this.processStep.whiteListedPositions = cloneDeep(this.positions)
          this.readOnlyPositionsChanged = true
        }
      })
    },
    async getPositions() {
      if(this.positions?.length === 0) {
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
    async saveReadOnlyAndWhiteList () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/processStep/saveReadOnlyAndWhiteList?savePositions=${this.readOnlyPositionsChanged ?? false}`, this.processStep)
        this.readOnlyPositionsChanged = false
        if(!this.processStep.readonly) {
          this.processStep.whiteListedPositions = []
        }
        this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyProcessStepStatusTypes() {
      if (this.addNewProcessStepStatusType) {
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
    async deleteStatusTypeFromStep(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //have to close the work queue editor to for the component to refresh available values
        this.addNewWorkQueueType = false
        this.expanded = []
        const {status} = await putRequest(`/processStep/status/removeStatus/${item.id}/fromStep/${this.processStepId}`)
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
    async saveNonAdminUse(e, item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let body = {
          allowNonAdminUse: e.target.checked || false
        }
        const {data, status} = await putRequest(`/processStep/status/${item.id}/updateAllowNonAdminUse`, body)
        this.snackbar = getSnackbar('SUCCESS', 'Changes Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignStatusTypeToProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.processStepId = this.$route.params.id
        const {data, status} = await postRequest(`/processStep/status/assignCompanyStatus/${this.newProcessStepStatusTypeId}/toProcessStep/${this.processStepId}`)
        this.processStep.companyProcessStepStatusTypes.push(data)
        // reset fields
        this.addNewProcessStepStatusType = false
        this.newProcessStepStatusTypeId = null
        this.snackbar = getSnackbar('SUCCESS', 'Status Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Status Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProcessStepDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/processStep/${this.processStepId}`)
        this.processStep = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getLinksForProcessStep() {
      try {
        this.addNewLink = !this.addNewLink
        if (this.addNewLink) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequest(`/links/processStep/${this.$route.params.id}/available`)
          this.availableLinks = data
          handleHidingGlobalLoader(this, status)
        }
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
        const {data, status} = await postRequest(`/links/processStep`, this.newLink)
        this.processStep.links.push(data)
        // reset fields
        this.addNewLink = false
        this.newLink = {}
        this.snackbar = getSnackbar('SUCCESS', 'Link Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {status} = await deleteRequest(`/links/processStep/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Link Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Link')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterAssignedProcessStepStatusTypes() {
      return orderBy(this.processStep?.companyProcessStepStatusTypes?.filter(u => {
        return !u.archived
      }), [f => f.processStepStatusType])
    },
    async saveLinkOrder(links) {
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
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await putRequest(`/links/updateOrderInProcessStep`, linksToSave)
          handleHidingGlobalLoader(this, status)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Links Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Links')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    confirmDelete(){
      if(this.deleteProcessStepStatusType){
        this.deleteStatusTypeFromStep(this.deleteProcessStepStatusType)
        this.deleteProcessStepStatusType = null
      }else if(this.deleteLink){
        this.deleteLink.archived = true
        this.deleteLinkFromStep(this.deleteLink.id)
        this.deleteLink = null
      }else if(this.deleteAttachment){
        this.deleteAttachment.archived = true
        this.deleteTypeFromStep(this.deleteAttachment.id)
        this.deleteAttachment = null
      }
    }
  }

}
</script>

<style scoped lang="scss">
.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}

.link-header-bar,
.access-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}

</style>
