<!--suppress CssInvalidPseudoSelector -->
<template>
  <v-card class="mx-4 mt-6">
  <v-row class="px-2" no-gutters>
    <v-col class="ahj-form-btns py-1" cols="12">
      <v-btn text color="primary" class="text-capitalize" @click="toggleMinimizeAll">{{expandedAll !== CollapseExpandEnum.COLLAPSED ? 'Minimize All' : 'Expand All'}}</v-btn>
      <v-btn color="primary" text v-if="dataWasChanged"
         @click="resetForm"
         class="cancel-link text-capitalize"
         style="margin-right: 10px"
      >Cancel</v-btn>
      <v-btn class="text-capitalize mr-0 save-btn"
             v-if="userCanEdit"
             color="primary"
             @click="validateForm()"
      >Save
      </v-btn>
    </v-col>
  </v-row>
    <!-- UPPER SECTION -->
    <v-form ref="ahjInspectionForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry :custom-field-groups= customFieldGroups
                           :user-can-edit="userCanEdit"
                           :expanded-all="expandedAll"
                           :callback="(field) => updateDirtyValue(field)"
                           @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED">
        </TwoColumnMasonry>
          <!--        <v-col cols="12" md="6" class="group px-2 py-2" v-for="group in customFieldGroups">-->
<!--        <AhjCustomFields :group = group-->
<!--                 :user-can-edit="userCanEdit"-->
<!--                 :expanded-all="expandedAll"-->
<!--                 :callback="(field) => updateDirtyValue(field)"-->
<!--                 @toggle-collapse-expand="expandedAll = CollapseExpandEnum.MIXED"-->
<!--        ></AhjCustomFields>-->
<!--        </v-col>-->
      </v-row>

      <!-- LOWER SECTION -->
      <h1 class="pb-2 mb-4 lower-section">Links and Contacts</h1>
      <!-- FIRST ROW -->
      <v-row no-gutters>
        <v-col cols="12" md="4" class="px-1">
          <AhjLink v-if="dataReady"
                   title="Scheduling Links"
                   :linkTypeId="1"
                   :user-can-edit="userCanEdit"
                   :itemId="ahjInspection.id"
                   :itemType="itemType"
                   :ahjId="ahjId"
                   :links="ahjInspection.schedulingLinks"
          ></AhjLink>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <AhjLink v-if="dataReady"
                   title="Links for FOT"
                   :linkTypeId="2"
                   :user-can-edit="userCanEdit"
                   :itemId="ahjInspection.id"
                   :itemType="itemType"
                   :ahjId="ahjId"
                   :links="ahjInspection.fotLinks"
          ></AhjLink>
        </v-col>

        <v-col cols="12" md="4" class="px-1">
          <AhjLink v-if="dataReady"
                   title="Results Links"
                   :linkTypeId="3"
                   :user-can-edit="userCanEdit"
                   :itemId="ahjInspection.id"
                   :itemType="itemType"
                   :ahjId="ahjId"
                   :links="ahjInspection.resultsLinks"
          ></AhjLink>
        </v-col>
      </v-row>

      <!-- SECOND ROW -->
      <v-row no-gutters>
        <v-col cols="12" md="3" class="px-1">
          <AhjContact v-if="dataReady"
                      title="Scheduling Contacts"
                      :contactTypeId="2"
                      :user-can-edit="userCanEdit"
                      :itemId="ahjInspection.id"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjInspection.schedulingContacts"
          ></AhjContact>
        </v-col>

        <v-col cols="12" md="3" class="px-1">
          <AhjContact v-if="dataReady"
                      title="Inspector Contacts"
                      :contactTypeId="4"
                      :user-can-edit="userCanEdit"
                      :itemId="ahjInspection.id"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjInspection.feeContacts"
          ></AhjContact>
        </v-col>

        <v-col cols="12" md="3" class="px-1">
          <AhjContact v-if="dataReady"
                      title="Obtaining Results Contacts"
                      :contactTypeId="3"
                      :itemId="ahjInspection.id"
                      :user-can-edit="userCanEdit"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjInspection.obtainingResultsContacts"
          ></AhjContact>
        </v-col>
        <v-col cols="12" md="3" class="px-1">
          <AhjContact v-if="dataReady"
                      title="Utility Service Department Contacts"
                      :contactTypeId="9"
                      :user-can-edit="userCanEdit"
                      :itemId="ahjInspection.id"
                      :itemType="itemType"
                      :ahjId="ahjId"
                      :contacts="ahjInspection.utilityServiceDeptContacts"
                      :isNested="true"
          ></AhjContact>
        </v-col>
      </v-row>

      <!-- THIRD ROW -->
      <v-row no-gutters class="mb-3">
        <v-col cols="12" md="6" class="px-1">
          <AhjServicingFot v-if="dataReady"
                           :servicingFots="ahjInspection.servicingFots"
          ></AhjServicingFot>
        </v-col>
      </v-row>

      <!-- FOURTH ROW -->
      <v-row no-gutters class="mb-6">
        <v-col cols="12" md="12" class="px-1">
          <AhjRequirement v-if="dataReady"
                          title="AHJ Specific Installation Requirements"
                          :transparent="false"
                          :requirementTypeId="5"
                          :itemType="itemType"
                          :itemId="ahjId"
                          :requirements="ahjInspection.installationRequirements"
          ></AhjRequirement>
        </v-col>
      </v-row>

      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjInspection.updateAllInState">
              <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjInspection.stateName}`" :value="true"></v-radio>
            </v-radio-group>
          </v-card-text>

          <v-divider></v-divider>

        <v-card-actions class="px-6">
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="saveDialog = false"
             class="cancel-link mr-2"
          >Cancel</v-btn>
          <v-btn v-if="ahjInspection.updateAllInState"
                 class="white--text mr-0 save-btn"
                 color="primary"
                 @click="saveConfirmDialog = true"
          >Save</v-btn>
          <v-btn v-else
                 class="white--text mr-0 save-btn"
                 color="primary"
                 @click="updateAhjInspection"
          >Save</v-btn>
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
          >Cancel</v-btn>
          <v-btn class="white--text mr-0 save-btn"
                 color="primary"
                 @click="updateAhjInspection"
          >Yes</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    </v-form>
  </v-card>
</template>

<script>
import moment from 'moment'
import cloneDeep from 'lodash.clonedeep'
import AhjChecklist from './components/AhjChecklist'
import AhjContact from './components/AhjContacts'
import AhjLink from './components/AhjLinks'
import AhjRequirement from './components/AhjRequirements'
import AhjServicingFot from './components/AhjServicingFots'
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";

import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, getSnackbar} from '@/helpers/helpers'
import orderBy from "lodash.orderby";
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import AhjCustomFields from "@/views/blueraven/ahj/components/AhjCustomFields";
import TwoColumnMasonry from "@/views/blueraven/ahj/components/TwoColumnMasonry";

export default {
  name: 'ahjInspection',
  components: {
    TwoColumnMasonry,
    AhjCustomFields,
    AhjChecklist,
    AhjContact,
    AhjLink,
    AhjRequirement,
    AhjServicingFot,
    CustomValueInput
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
    },
  },
  data: () => ({
    CollapseExpandEnum,
    ahjId: null,
    itemType: 'inspection',
    snackbar: {},
    saveDialog: false,
    saveConfirmDialog: false,
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    expandedAll: CollapseExpandEnum.EXPANDED,
    ahjInspection: {
      schedulingLinks: [],
      fotLinks: [],
      resultsLinks: [],
      schedulingContacts: [],
      feeContacts: [],
      obtainingResultsContacts: [],
      servicingFots: [],
      installationRequirements: []
    }
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    async getAhjInspection() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/ahj/${this.ahjId}/inspection`, 'blueraven')
        window.document.title = `AHJ - ${data.ahjName}`
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

        this.ahjInspection = cloneDeep(data)
        this.ahjInspection.updateAllInState = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Inspection')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroupAssignmentsForScreen() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {sourceId: this.ahjInspection.id, objectTypeId: 3}
        const {
          data,
          status
        } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
        this.customFieldGroups = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.ahjInspectionForm.validate()) {
        this.saveDialog = true
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
      this.getAhjInspection().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
      })
    },
    async updateAhjInspection() {
      this.saveDialog = false
      this.saveConfirmDialog = false
      let updateAllInState = this.ahjInspection.updateAllInState

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (updateAllInState) {
          try {
            const {data} = await getRequest(`/ahj/${this.ahjId}/inspection/searchAhjsByState/${this.ahjInspection.stateId}`, 'blueraven')
            this.ahjInspection.ahjIds = []
            this.ahjInspection.inspectionIds = []

            data.forEach(row => {
              this.ahjInspection.ahjIds.push(row.ahjId)
              this.ahjInspection.inspectionIds.push(row.id)
            })
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all inspections in ' + this.ahjInspection.stateName)
          }
        }

        this.ahjInspection.customFieldGroups = this.customFieldGroups
        const {
          data,
          status
        } = await putRequest(`/ahj/${this.ahjId}/inspection/${this.ahjInspection.id}`, this.ahjInspection, 'blueraven')
        this.ahjInspection = cloneDeep(data)
        this.ahjInspection.updateAllInState = false
        this.dataWasChanged = false
        this.resetCustomFieldValueWasChangedFlags()
        let successMessage = updateAllInState ? 'All inspections in ' + this.ahjInspection.stateName + ' have been updated successfully' : 'Inspection updated successfully'
        this.snackbar = getSnackbar('SUCCESS', successMessage)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let errorMessage = updateAllInState ? 'An error occurred when attempting to update all inspections in ' + this.ahjInspection.stateName : 'Failed to update inspection'
        this.snackbar = getSnackbar('ERROR', errorMessage)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },

    toggleMinimizeAll(){
      if(this.expandedAll !== CollapseExpandEnum.COLLAPSED){
        this.expandedAll = CollapseExpandEnum.COLLAPSED
      } else {
        this.expandedAll = CollapseExpandEnum.EXPANDED
      }
    }
  },
  async created() {
    this.ahjId = parseInt(this.$route.params.ahjId)
    this.getAhjInspection().then(() => {
      this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
    })
  }
}
</script>

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
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
.empty-list {
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

.group {
}

.lower-section {
  border-bottom: 1px solid #ccc;
  width: 100%;
}

.other-field {
  margin-top: -20px;
}
</style>
