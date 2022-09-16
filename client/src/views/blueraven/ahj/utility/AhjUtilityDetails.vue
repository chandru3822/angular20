<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-container id="ahj-utility-details-container">
    <v-row>
      <v-col cols="12" class="pt-0">

        <v-row justify="space-between">
          <v-col class="text-left pa-0" cols="12">
            <v-card class="mx-4 pb-4 square-card">
              <v-btn id="back-btn" text color="primary" class="pl-1 pr-2 mb-2" :to="'/ahjUtility'">
                <v-icon>arrow_left</v-icon>
                <span id="back-btn-text">Back to menu</span>
              </v-btn>

              <div class="flex-display justify-space-between align-center px-3 mb-4" style="width: 100%">
                <div class="page-title">Utility</div>
                <div class="page-info">
                  <div>{{ ahjUtility.name }}</div>
                  <div>{{ ahjUtility.metroArea }}</div>
                </div>
              </div>

              <!--            <v-tabs id="utility-tab-bar" class="mb-6" background-color="var(&#45;&#45;v-secondary-base)">-->
              <!--              <v-tab style="cursor: default" :ripple="false" class="text-capitalize my-0 ml-3 mr-0">Details</v-tab>-->
              <!--            </v-tabs>-->
            </v-card>
          </v-col>
        </v-row>
        <v-row dense>
          <v-card class="mx-2 mt-6 px-2 py-3 one-hunned square-card">
            <v-row no-gutters>
              <v-col class="ahj-form-btns" cols="12">
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
            <v-form ref="ahjUtilityForm">
              <!-- UPPER SECTION -->
              <v-row class="mb-4 group-row" no-gutters>
                <TwoColumnMasonry :custom-field-groups="customFieldGroups"
                                  :user-can-edit="userCanEdit"
                                  :expanded-all="expandedAll"
                                  :callback="(field) => updateDirtyValue(field)"
                                  @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"
                ></TwoColumnMasonry>
                <!--              <v-col cols="12" md="6" class="group px-2 py-2" v-for="group in customFieldGroups">-->
                <!--                <AhjCustomFields :group = group-->
                <!--                         :user-can-edit="userCanEdit"-->
                <!--                         :expanded-all="expandedAll"-->
                <!--                         :callback="(field) => updateDirtyValue(field)"-->
                <!--                         @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"-->
                <!--                ></AhjCustomFields>-->
                <!--              </v-col>-->
              </v-row>
              <!-- LOWER SECTION -->
              <h1 id="links" class="pb-2 mb-4 mx-3 lower-section albatross-header-2">Links and Contacts</h1>
              <v-row no-gutters>
                <v-col cols="12" md="6" class="group px-2 py-2">
                  <!-- CONTACTS -->
                  <AhjContact v-if="dataReady"
                              title="Contacts"
                              :user-can-edit="userCanEdit"
                              :contactTypeId="8"
                              :itemId="ahjUtility.id"
                              :itemType="itemType"
                              :contacts="ahjUtility.contacts"
                              show-expanded
                              :expanded-all="expandedAll"
                              @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"
                  ></AhjContact>
                  <AhjCard title="All Documents" show-expanded :expanded-all="expandedAll">
                    <AhjAttachments v-if="!isDocumentsLoading" :user-can-edit="userCanEdit"
                                    :attachment-types="AhjUtilityDocumentTypes" :attachments="documents"
                                    :source-id="ahjUtility.id">
                      >
                    </AhjAttachments>
                  </AhjCard>
                </v-col>
                <v-col v-if="dataReady" class="group px-2 py-2">
                  <ahj-link title="All Links"
                            :user-can-edit="userCanEdit"
                            :linkTypeId="10"
                            :itemId="ahjUtility.id"
                            :itemType="itemType"
                            :links="ahjUtility.links"
                            :isNested="false"
                            show-expanded
                            :expanded-all="expandedAll"
                            @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"
                  ></ahj-link>
                </v-col>
              </v-row>
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
import AhjContact from "../components/AhjContacts"
import AhjLink from "../components/AhjLinks"
import {AppMutations} from "@/stores/AppStore"
import {getRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader, putRequest} from "@/helpers/helpers"
import CustomValueInput from "@/views/flow/components/CustomValueInput.vue"
import AhjCustomFields from "@/views/blueraven/ahj/components/AhjCustomFieldGroup";
import {CollapseExpandEnum, AhjUtilityDocumentTypes} from "@/views/blueraven/ahj/AhjConstants";
import AhjCard from "@/views/blueraven/ahj/components/AhjCard";
import AhjAttachments from "@/views/blueraven/ahj/components/AhjAttachments";
import TwoColumnMasonry from "@/views/blueraven/ahj/components/TwoColumnMasonry";

export default {
  name: "ahjUtilityDetails",
  components: {
    TwoColumnMasonry,
    AhjAttachments,
    AhjCustomFields,
    AhjContact,
    AhjLink,
    CustomValueInput,
    AhjCard
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel("AHJ_DATABASE", "EDIT")
    }
  },
  data: () => ({
    CollapseExpandEnum,
    AhjUtilityDocumentTypes,
    ahjUtilityId: null,
    itemType: "utility",
    snackbar: {},
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    selectedFinancier: {submissionMethod: null},
    ahjUtility: {
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
    expandedAll: CollapseExpandEnum.EXPANDED,
    isDocumentsLoading: true
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    async getAhjUtility() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/ahjUtility/${this.ahjUtilityId}`, "blueraven")
        this.ahjUtility = cloneDeep(data)
        window.document.title = `AHJ Utility - ${this.ahjUtility.name}`
        this.ahjUtility.links = orderBy(this.ahjUtility.links, link => link.name?.toLowerCase())
        this.ahjUtility.contacts = orderBy(this.ahjUtility.contacts, contact => contact.name?.toLowerCase())
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error retrieving AHJ Utility")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAllDocuments() {
      this.isDocumentsLoading = true
      for (const docType of this.AhjUtilityDocumentTypes) {
        await this.getDocuments(docType.attachmentTypeId)
      }
      this.isDocumentsLoading = false
    },
    async getDocuments(docTypeId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjUtility.id, attachmentTypeId: docTypeId}
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
      if (this.$refs.ahjUtilityForm.validate()) {
        this.saveAhjUtility()
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
        this.selectedFinancier = this.ahjUtility.financierId ? this.financiers.filter(financier => financier.id === this.ahjUtility.financierId)[0] : {submissionMethod: null}
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
        const params = {sourceId: this.ahjUtility.id, objectTypeId: 2}
        const {
          data,
          status
        } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, "blueraven")
        this.customFieldGroups = cloneDeep(data)
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
      this.ahjUtility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null
      this.dataWasChanged = false
      this.dataReady = false
      this.getAhjUtility().then(() => {
        this.getFinancierList()
        this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
      })
    },
    async saveAhjUtility() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.ahjUtility.financierId = (this.selectedFinancier && this.selectedFinancier.id) ? this.selectedFinancier.id : null

      try {
        this.ahjUtility.customFieldGroups = this.customFieldGroups
        const {data, status} = await putRequest("/ahjUtility", this.ahjUtility, "blueraven")
        this.ahjUtility = cloneDeep(data)
        this.dataWasChanged = false
        this.snackbar = getSnackbar("SUCCESS", "AHJ Utility saved")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error("*** ERROR ***", e)
        this.snackbar = getSnackbar("ERROR", "Error saving AHJ Utility")
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    toggleMinimizeAll() {
      if (this.expandedAll !== CollapseExpandEnum.COLLAPSED) {
        this.expandedAll = CollapseExpandEnum.COLLAPSED
      } else {
        this.expandedAll = CollapseExpandEnum.EXPANDED
      }
    }
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    this.ahjUtilityId = parseInt(this.$route.params.ahjUtilityId)

    this.getAhjUtility().then(() => {
      this.getFinancierList().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen().then(() => {
          this.getAllDocuments().then(() => {
            this.dataReady = true
          })
        })
      })
    })
  }
}
</script>

<style scoped lang="scss">
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

.ahj-form-btns {
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
  width: 100%;
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
