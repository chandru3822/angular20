<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-card class="permit-card square-card">
    <v-row no-gutters class="px-2" id="ahj-permit">
      <v-col class="ahj-form-btns py-1" cols="12">
        <v-btn text color="primary" class="text-capitalize" @click="toggleMinimizeAll">
          {{ expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All' }}
        </v-btn>
        <v-btn v-if="dataWasChanged"
               color="primary" text
               @click="resetForm"
               class="cancel-link"
               style="margin-right: 10px"
        >Cancel
        </v-btn>
        <v-btn class="white--text mr-0 save-btn"
               v-if="userCanEdit"
               color="primary"
               @click="validateForm()"
        >Save
        </v-btn>
      </v-col>
    </v-row>

    <v-form ref="ahjPermitForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups="customFieldGroups"
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          :hardcoded-docs="hardCodedDocsMap"
                          :source-id="ahjId"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"
        ></TwoColumnMasonry>
        <!--        <v-col cols="12" md="6" class="group px-2 py-2" v-for="group in customFieldGroupAssignments">-->
        <!--          <AhjCustomFields :group = group-->
        <!--                   :user-can-edit="userCanEdit"-->
        <!--                   :callback="(field) => updateDirtyValue(field)"-->
        <!--                   @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"-->
        <!--          >-->
        <!--          </AhjCustomFields>-->
        <!--        </v-col>-->
      </v-row>

      <h1 class="pb-2 mb-4"
          style="border-bottom: 1px solid #ccc; width: 100%;"
      >Links and Contacts</h1>
      <v-row no-gutters>
        <!-- FIRST COLUMN -->
        <v-col cols="12" md="6" class="px-1 mb-3">
          <AhjLink v-if="dataReady"
                   title="Submission Links"
                   :linkTypeId="4"
                   :user-can-edit="userCanEdit"
                   :itemId="ahjPermit.id"
                   :itemType="itemType"
                   :ahjId="ahjId"
                   :links="ahjPermit.submissionLinks"
                   show-expanded
                   :expanded-all="expandedAll"
                   @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></AhjLink>

          <AhjContact v-if="dataReady"
                      title="Submission Contacts"
                      :contactTypeId="1"
                      :user-can-edit="userCanEdit"
                      :itemId="ahjPermit.id"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjPermit.submissionContacts"
                      show-expanded
                      :expanded-all="expandedAll"
                      @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></AhjContact>
        </v-col>

        <!-- SECOND COLUMN -->
        <v-col cols="12" md="6" class="px-1 mb-3">
          <AhjLink v-if="dataReady"
                   title="Follow-up and Delivery Links"
                   :linkTypeId="5"
                   :user-can-edit="userCanEdit"
                   :itemId="ahjPermit.id"
                   :itemType="itemType"
                   :ahjId="ahjId"
                   :links="ahjPermit.followUpLinks"
                   show-expanded
                   :expanded-all="expandedAll"
                   @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></AhjLink>
          <AhjContact v-if="dataReady"
                      title="Follow-up and Delivery Contacts"
                      :contactTypeId="6"
                      :user-can-edit="userCanEdit"
                      :itemId="ahjPermit.id"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjPermit.followUpContacts"
                      show-expanded
                      :expanded-all="expandedAll"
                      @toggle-collapse-expand="toggleCollapseExpand($event)"
          ></AhjContact>
          <!--        <AhjContact v-if="dataReady"-->
          <!--                    title="Print Locations"-->
          <!--                    :contactTypeId="7"-->
          <!--                    :user-can-edit="userCanEdit"-->
          <!--                    :itemId="ahjPermit.id"-->
          <!--                    :itemType="itemType"-->
          <!--                    :ahjId="ahjId"-->
          <!--                    :contacts="ahjPermit.printLocations"-->
          <!--        ></AhjContact>-->
        </v-col>

        <!-- THIRD COLUMN -->
        <!--      <v-col cols="12" md="4" class="px-1 mb-3">-->
        <!--        <AhjServicingFot v-if="dataReady"-->
        <!--                         :servicingFots="ahjPermit.servicingFots"-->
        <!--        ></AhjServicingFot>-->

        <!--      </v-col>-->
      </v-row>

      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjPermit.updateAllInState">
              <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjPermit.stateName}`" :value="true"></v-radio>
            </v-radio-group>
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <v-btn @click="saveDialog = false"
                   color="primary" text
                   class="cancel-link mr-2"
            >Cancel
            </v-btn>
            <v-btn v-if="ahjPermit.updateAllInState"
                   class="white--text mr-0 save-btn"
                   color="primary"
                   @click="saveConfirmDialog = true"
            >Save
            </v-btn>
            <v-btn v-else
                   class="white--text mr-0 save-btn"
                   color="primary"
                   @click="updateAhjPermit"
            >Save
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <v-dialog v-model="saveConfirmDialog" max-width="500">
        <v-card>
          <v-card-title>
            <span class="text-h5">Confirm</span>
          </v-card-title>

          <v-card-text class="pb-0 py-2">
            Are you sure you want to update <strong>ALL</strong>? This action cannot be undone.
          </v-card-text>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <v-btn color="primary" text @click="saveConfirmDialog = false"
                   class="cancel-link mr-2"
            >Cancel
            </v-btn>
            <v-btn class="white--text mr-0 save-btn"
                   color="primary"
                   @click="updateAhjPermit"
            >Yes
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>

    </v-form>
  </v-card>
</template>

<script>
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import AhjContact from './components/AhjContacts'
import AhjLink from './components/AhjLinks'
import AhjServicingFot from './components/AhjServicingFots'

import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, getSnackbar} from '@/helpers/helpers'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import AhjCustomFields from "@/views/blueraven/ahj/components/AhjCustomFieldGroup";
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";
import TwoColumnMasonry from "@/views/blueraven/ahj/components/TwoColumnMasonry";

export default {
  name: 'ahjPermit',
  components: {
    TwoColumnMasonry,
    AhjCustomFields,
    AhjContact,
    AhjLink,
    AhjServicingFot,
    CustomValueInput
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
    },
    hardCodedDocsMap(){
      const docsMap = new Map()
      docsMap.set(5, {
        title: "Documents Required for Inspection",
        documents: this.inspectionDocuments,
        attachmentTypeId: 1,
        attachmentType: "All Documents"
      })
      docsMap.set(24, {
        title: "Documents Required for Refund/Cancellation",
        documents: this.cancellationDocuments,
        attachmentTypeId: 462 ,
        attachmentType: "All Documents"
      })
      return docsMap
    },
    expandedAll(){
      if(this.expandedGroups === this.totalGroups){
        return CollapseExpandEnum.EXPANDED
      } else if (this.expandedGroups === 0) {
        return CollapseExpandEnum.COLLAPSED
      } else {
        return CollapseExpandEnum.MIXED
      }
    }
  },
  data: () => ({
    CollapseExpandEnum,
    ahjId: null,
    itemType: 'permit',
    snackbar: {},
    saveDialog: false,
    saveConfirmDialog: false,
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    approvalRequiredOptions: [{id: null, name: ''}],
    submittalMethods: [{id: null, name: ''}],
    businessLicenseMenu: false,
    contractorLicenseMenu: false,
    otherLicenseMenu: false,
    editRevisionSubmissionInstruction: false,
    editSubmissionInstruction: false,
    editAsBuiltSubmissionInstruction: false,
    editNonStandardSubmissionInstruction: false,
    editDeliveryInstruction: false,
    editApprovalInstructions: false,
    editBrsTechnicianPermitPickupAndDeliveryInstructions: false,
    editCancellationAndRefundInstructions: false,
    editBrsTechnicianPermitSubmissionInstructions: false,
    totalGroups: 4,
    expandedGroups:4,
    // userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT'),
    ahjPermit: {
      submissionChecklist: [],
      revisionChecklist: [],
      asBuiltChecklist: [],
      nonStandardChecklist: [],
      submissionLinks: [],
      followUpLinks: [],
      submissionContacts: [],
      printLocations: [],
      followUpContacts: [],
      servicingFots: []
    },
    inspectionDocuments: [],
    cancellationDocuments: [],
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.ahjPermitForm.validate()) {
        this.saveDialog = true
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    toggleCollapseExpand(wasExpanded) {
      if(wasExpanded === false) {
        this.expandedGroups--
      }else {
        this.expandedGroups++
      }
    },
    async getAhjPermit() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/ahj/${this.ahjId}/permit`, 'blueraven')

        if (data.servicingFots && data.servicingFots.length > 0) {
          data.servicingFots.forEach(servicingFot => {
            if (servicingFot.hierarchy && servicingFot.hierarchy.length > 0) {
              servicingFot.hierarchy = servicingFot.hierarchy[0]
            }
          })

          data.servicingFots = orderBy(data.servicingFots, fot => {
            if (fot.hierarchy && fot.hierarchy.orgName) {
              return fot.hierarchy.orgName?.toLowerCase()
            }
          })
        } else {
          data.servicingFots = []
        }

        this.ahjPermit = cloneDeep(data)
        window.document.title = `AHJ - ${this.ahjPermit.ahjName}`
        this.ahjPermit.submissionLinks = orderBy(this.ahjPermit.submissionLinks, link => link.name?.toLowerCase())
        this.ahjPermit.submissionContacts = orderBy(this.ahjPermit.submissionContacts, contact => contact.name?.toLowerCase())
        this.ahjPermit.followUpLinks = orderBy(this.ahjPermit.followUpLinks, link => link.name?.toLowerCase())
        this.ahjPermit.followUpContacts = orderBy(this.ahjPermit.followUpContacts, contact => contact.name?.toLowerCase())
        this.ahjPermit.updateAllInState = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Permit')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroupAssignmentsForScreen() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjPermit.id, objectTypeId: 4}
        const {
          data,
          status
        } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
        this.customFieldGroups = cloneDeep(data)
        this.totalGroups = this.totalGroups + this.customFieldGroups.length;
        this.expandedGroups = this.totalGroups;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getCustomFieldsForGroup(groupId) {
      let match = this.customFieldGroups.find(cfga => cfga.id === groupId)
      return match ? match.customFieldValues : []
    },
    showOtherField(int, list) {
      let match = list.find(l => l.id === int)
      return match ? match.showOther : false
    },
    resetCustomFieldValueWasChangedFlags() {
      this.customFieldGroups.forEach(group => {
        group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
      })
    },
    async resetForm() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.dataWasChanged = false
      this.dataReady = false
      this.getAhjPermit().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen()
        this.dataReady = true
      })
    },
    async getCancellationDocuments() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjPermit.id, attachmentTypeId: 462}
        const {data, status} = await getRequestWithParams('/attachment', {params})
        this.cancellationDocuments = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getInspectionDocuments() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjPermit.id, attachmentTypeId: 1}
        const {data, status} = await getRequestWithParams('/attachment', {params})
        this.inspectionDocuments = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateAhjPermit() {
      this.saveDialog = false
      this.saveConfirmDialog = false
      let updateAllInState = this.ahjPermit.updateAllInState

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (updateAllInState) {
          try {
            const {data} = await getRequest(`/ahj/${this.ahjId}/permit/searchAhjsByState/${this.ahjPermit.stateId}`, 'blueraven')
            this.ahjPermit.ahjIds = []
            this.ahjPermit.permitIds = []

            data.forEach(row => {
              this.ahjPermit.ahjIds.push(row.ahjId)
              this.ahjPermit.permitIds.push(row.id)
            })
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all permits in ' + this.ahjPermit.stateName)
          }
        }

        this.ahjPermit.customFieldGroups = this.customFieldGroups
        const {
          data,
          status
        } = await putRequest(`/ahj/${this.ahjId}/permit/${this.ahjPermit.id}`, this.ahjPermit, 'blueraven')

        if (data.servicingFots && data.servicingFots.length > 0) {
          data.servicingFots.forEach(servicingFot => {
            if (servicingFot.hierarchy && servicingFot.hierarchy.length > 0) {
              servicingFot.hierarchy = servicingFot.hierarchy[0]
            }
          })

          data.servicingFots = orderBy(data.servicingFots, fot => {
            if (fot.hierarchy && fot.hierarchy.orgName) {
              return fot.hierarchy.orgName.toLowerCase()
            }
          })
        } else {
          data.servicingFots = []
        }

        this.ahjPermit = cloneDeep(data)
        this.ahjPermit.updateAllInState = false
        this.dataWasChanged = false
        this.resetCustomFieldValueWasChangedFlags()
        let successMessage = updateAllInState ? 'All permits in ' + this.ahjPermit.stateName + ' have been updated successfully' : 'Permit updated successfully'
        this.snackbar = getSnackbar('SUCCESS', successMessage)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let errorMessage = updateAllInState ? 'An error occurred when attempting to update all permits in ' + this.ahjPermit.stateName : 'Failed to update permit'
        this.snackbar = getSnackbar('ERROR', errorMessage)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },

    toggleMinimizeAll() {
      if (this.expandedAll !== CollapseExpandEnum.COLLAPSED) {
        this.expandedGroups = 0
      } else {
        this.expandedGroups = this.totalGroups
      }
    }
  },
  async created() {
    this.ahjId = parseInt(this.$route.params.ahjId)
    this.getAhjPermit().then(() => {
      this.getCustomFieldGroupAssignmentsForScreen()
      this.getInspectionDocuments()
      this.getCancellationDocuments()
      this.dataReady = true
    })
  }
}
</script>

<style lang="scss">
.override-readonly-font-color textarea {
  color: var(--v-primaryText-base) !important;
}
</style>

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
}

.permit-card {
  margin-left: 12px;
  margin-right: 12px;
}

.row {
  width: 100%;
}

.ahj-form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
}

.title-with-icon {
  display: flex;
  justify-content: space-between;

  .v-icon {
    cursor: pointer;
  }
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-text-field,
.v-select,
.v-input ::v-deep label,
.v-list-item__title,
.list-link {
  font-size: 0.95em !important;
}

.cancel-link,
.empty-list,
.horizontal-dl,
table {
  font-size: 0.85em !important;
}

.link-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;

  button {
    margin: 0 0 0 7px;
  }
}

.save-btn {
  margin: 10px 5px 10px 0;
  text-transform: capitalize;
}

.empty-list {
  padding: 20px;
}

.list-link {
  text-decoration: none;
}

.cancel-link:hover,
.list-link:hover {
  text-decoration: underline;
}

.flex-row-center {
  display: flex;
  flex-flow: row nowrap;
  align-items: center;
}

.row {
  width: 100%;
}

.group-row {
  justify-content: space-between;
}

.col-gap {
  width: 3em;
}

.other-field {
  margin-top: -20px;
}
</style>
