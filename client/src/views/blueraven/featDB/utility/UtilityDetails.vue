<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-container id="utility-details-container">
    <v-row>
      <v-col cols="12" class="pa-0">

        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-card class="mx-4 square-card">
              <v-toolbar flat>
                <v-toolbar-title class="app-title" v-if="utility && utility.name">
                  {{ utility.name }}, {{ utility.metroArea }}, {{ utility.state }}
                </v-toolbar-title>
              </v-toolbar>
            </v-card>
          </v-col>
        </v-row>
        <v-row dense>
          <v-card class="mx-2 px-2 py-3 one-hunned square-card">
            <v-row no-gutters>
              <v-col class="utility-form-btns" cols="12">
                <v-btn text color="primary" class="text-capitalize" @click="toggleMinimizeAll">
                  {{ expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All' }}
                </v-btn>
                <v-btn v-if="dataWasChanged"
                       @click="resetForm"
                       text
                       color="primary"
                       class="cancel-link"
                       style="margin-right: 10px"
                >Cancel
                </v-btn>
                <v-btn id="save-btn"
                       v-if="userCanEdit"
                       color="primary"
                       class="white--text mr-0"
                       @click="validateForm()"
                >Save
                </v-btn>
              </v-col>
            </v-row>
            <v-form ref="utilityForm">
              <!-- UPPER SECTION -->
              <v-row class="mb-4 group-row" no-gutters>
                <TwoColumnMasonry v-if="dataReady"
                                  :custom-field-groups="customFieldGroups"
                                  :user-can-edit="userCanEdit"
                                  :expanded-all="expandedAll"
                                  :callback="(field) => updateDirtyValue(field)"
                                  @toggle-collapse-expand="toggleCollapseExpand($event)"
                ></TwoColumnMasonry>
              </v-row>
              <!-- LOWER SECTION -->
              <div v-if="dataReady">
                <h1 id="links" class="pb-2 mb-4 mx-3 lower-section albatross-header-2">Links and Contacts</h1>
                <v-row no-gutters>
                  <v-col cols="12" md="6" class="group px-2 py-2">
                    <!-- CONTACTS -->
                    <FeatDbContact title="Contacts"
                                :user-can-edit="userCanEdit"
                                :contactTypeId="8"
                                :itemId="utility.id"
                                :itemType="itemType"
                                :contacts="utility.contacts"
                                show-expanded
                                :expanded-all="expandedAll"
                                @toggle-collapse-expand="toggleCollapseExpand($event)"
                    ></FeatDbContact>
                    <FeatDbCard title="All Documents" show-expanded :expanded-all="expandedAll"
                             @toggle-collapse-expand="toggleCollapseExpand($event)">
                      <FeatDbAttachments v-if="!isDocumentsLoading" :user-can-edit="userCanEdit"
                                      :attachment-types="UtilityDocumentTypes" :attachments="documents"
                                      :source-id="utility.id">
                        >
                      </FeatDbAttachments>
                    </FeatDbCard>
                  </v-col>
                  <v-col class="group px-2 py-2">
                    <FeatDbLinks title="All Links"
                              :user-can-edit="userCanEdit"
                              :linkTypeId="10"
                              :itemId="utility.id"
                              :itemType="itemType"
                              :links="utility.links"
                              :isNested="false"
                              show-expanded
                              :expanded-all="expandedAll"
                              @toggle-collapse-expand="toggleCollapseExpand($event)"></FeatDbLinks>
                  </v-col>
                </v-row>
              </div>
            </v-form>
          </v-card>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import cloneDeep from "lodash.clonedeep"
import orderBy from "lodash.orderby"
import FeatDbContact from "@/views/blueraven/featDB/components/FeatDbContacts.vue"
import FeatDbLinks from "@/views/blueraven/featDB/components/FeatDbLinks.vue"
import {AppMutations} from "@/stores/AppStore"
import {getRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers"
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue"
import FeatDbCustomFields from "@/views/blueraven/featDB/components/FeatDbCustomFieldGroup.vue";
import {CollapseExpandEnum, UtilityDocumentTypes} from "@/views/blueraven/featDB/FeatDbConstants";
import FeatDbCard from "@/views/blueraven/featDB/components/FeatDbCard.vue";
import FeatDbAttachments from "@/views/blueraven/featDB/components/FeatDbAttachments.vue";
import TwoColumnMasonry from "@/views/blueraven/featDB/components/TwoColumnMasonry.vue";

export default {
  name: "UtilityDetails",
  components: {
    TwoColumnMasonry,
    FeatDbAttachments,
    FeatDbCustomFields,
    FeatDbContact,
    FeatDbLinks,
    CustomValueInput,
    FeatDbCard
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel("AHJ_DATABASE", "EDIT")
    },
    expandedAll() {
      if (this.expandedGroups === this.totalGroups) {
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
    UtilityDocumentTypes: UtilityDocumentTypes,
    utilityId: null,
    itemType: "utility",
    snackbar: {},
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    selectedFinancier: {submissionMethod: null},
    utility: {
      customerSignatureLinks: [],
      ptoLinks: [],
      ptoFollowupLinks: [],
      submissionLinks: [],
      submissionChecklist: [],
      approvalChecklist: [],
      ptoChecklist: [],
      utilityInspectionChecklist: [],
      contacts: [],
      utilityRequirements: []
    },
    documents: [],
    utilityRateDocs: [],
    submissionDocs: [],
    approvalDocs: [],
    financiers: [],
    totalGroups: 2,
    expandedGroups: 2,
    isDocumentsLoading: true
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    toggleCollapseExpand(wasExpanded) {
      if (wasExpanded === false) {
        this.expandedGroups--
      } else {
        this.expandedGroups++
      }
    },
    async getUtility() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/featDb/utility/${this.utilityId}`, "blueraven")
        this.utility = cloneDeep(data)
        window.document.title = `Utility - ${this.utility.name}`
        this.utility.links = orderBy(this.utility.links, link => link.name?.toLowerCase())
        this.utility.contacts = orderBy(this.utility.contacts, contact => contact.name?.toLowerCase())
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving Utility")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAllDocuments() {
      this.isDocumentsLoading = true
      let docRequests = []
      for (const docType of this.UtilityDocumentTypes) {
        docRequests.push(this.getDocuments(docType.attachmentTypeId))
        // await this.getDocuments(docType.attachmentTypeId)
      }
      await Promise.all(docRequests).then(() => {
        this.isDocumentsLoading = false
      })
    },
    async getDocuments(docTypeId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.utility.id, attachmentTypeId: docTypeId}
        const {data, status} = await getRequestWithParams('/attachment', {params})
        this.documents = cloneDeep(data).concat(this.documents)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving documents')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.utilityForm.validate()) {
        this.saveUtility()
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getFinancierList() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest("/financier/active", "blueraven")
        this.financiers = cloneDeep(data)
        this.selectedFinancier = this.utility.financierId ? this.financiers.filter(financier => financier.id === this.utility.financierId)[0] : {submissionMethod: null}
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving list of financiers")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroupAssignmentsForScreen() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.utilityId, objectTypeId: 2}
        const {
          data,
          status
        } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, "blueraven")
        this.customFieldGroups = cloneDeep(data)
        this.totalGroups = this.totalGroups + this.customFieldGroups.length;
        this.expandedGroups = this.totalGroups;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving custom fields")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
      this.utility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null
      this.dataWasChanged = false
      this.dataReady = false
      await this.pageLoad(false)
    },
    async pageLoad(loadAttachments) {
      let requests = [
        this.getUtility(),
        this.getFinancierList(),
        this.getCustomFieldGroupAssignmentsForScreen()
      ]
      if(loadAttachments) {
        requests.push(this.getAllDocuments())
      }
      await Promise.all(requests).then(() => {
        this.dataReady = true
      })
    },
    async saveUtility() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.utility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null

      try {
        this.utility.customFieldGroups = this.customFieldGroups
        const {data, status} = await putRequest("/featDb/utility", this.utility, "blueraven")
        this.utility = cloneDeep(data)
        this.dataWasChanged = false
        this.snackbar = getSnackbar("SUCCESS", "Utility saved")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error saving Utility")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.utilityId = parseInt(this.$route.params.utilityId)

    await this.pageLoad(true)
  }
}
</script>

<style scoped lang="scss">
#utility-details-container {
  padding-right: 9px;
  padding-left: 9px;
  padding-top: 10px;
}

#back-btn {
  text-transform: unset;
  letter-spacing: unset;

  &:before {
    background-color: initial;
  }

  #back-btn-text:hover {
    text-decoration: underline;
  }
}

.page-title {
  font-size: 32px;
  font-weight: 200;
}

.page-info {
  font-family: 'Roboto Condensed', sans-serif;
  font-size: 20px;
  text-align: right;
}

#utility-tab-bar {
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}

.utility-form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 10px;
}

#save-btn {
  margin: 0 5px 0 0;
  text-transform: capitalize;
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

.cancel-link {
  font-size: 0.85em !important;
}

.cancel-link:hover {
  text-decoration: underline;
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

.custom-field {
  width: 48%;
}

.other-field {
  margin-top: -20px;
}

.group-row {
  justify-content: space-between;
}

.col-gap {
  width: 3em;
}

.lower-section {
  border-bottom: 1px solid #ccc;
  width: calc(100% - 20px);
}

.v-input--is-disabled ::v-deep .v-input__slot,
.v-input--is-disabled ::v-deep input {
  cursor: not-allowed;
  pointer-events: all;
}

.v-input--is-disabled ::v-deep label {
  color: rgba(0, 0, 0, 0.38) !important;
}
</style>
