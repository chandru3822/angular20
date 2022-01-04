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
                       @click="[addNewProcessStepStatusType = !addNewProcessStepStatusType, expanded = [], getCompanyProcessStepStatusTypes()]"
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
                              class="text-h5 grey lighten-2"
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
            <ProcessStepWorkQueueTypes :process-step="processStep"></ProcessStepWorkQueueTypes>
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
                          class="text-h5 grey lighten-2"
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
                          class="text-h5 grey lighten-2"
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
import {getAvailableForProcessStep} from '@/services/processStepStatusTypeService'
import ProcessStepCustomFieldGroups from './ProcessStepCustomFieldGroups'
import ProcessStepWorkQueueTypes from './ProcessStepWorkQueueTypes'
import orderBy from "lodash.orderby"
import cloneDeep from 'lodash.clonedeep'

import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'

export default {
  name: 'ProcessStepComponents',
  mixins: [Vue2Filters.mixin],
  components: {
    ProcessStepWorkQueueTypes,
    ProcessStepCustomFieldGroups,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      expandPsst: true,
      expandLinks: true,
      expandAttachmentTypes: true,
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
      checkedIds: [],
      breadcrumbs: [
        {
          text: 'Back',
          disabled: false,
          exact: true,
          to: `/settings/processSteps`
        },
      ],
    }
  },
  computed: {},
  async created() {
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

    async getAttachmentTypesForProcessStep() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if (this.addNewType) {
          const {data} = await getRequest(`/attachmentType/typesForStep/${this.$route.params.id}`)
          this.availableAttachmentTypes = data
        }
        handleHidingGlobalLoader(this, status)
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
        const {data, status} = await postRequest(`/attachmentType/processStepType`, this.newType)
        this.processStep.attachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
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
        const {status} = await deleteRequest(`/attachmentType/processStepType/${id}`)
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
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
    async saveAttachmentTypeOrder(attachmentTypes) {
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
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await putRequest(`/attachmentType/updateOrderInProcessStep`, typesToSave)
          handleHidingGlobalLoader(this, status)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Types Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Attachment Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
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

.link-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}

.attach-header-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;
}
</style>
