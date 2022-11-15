<template>
  <v-card class="design-card square-card">
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

    <v-form ref="ahjDesignForm">
      <v-row class="mb-4 group-row" no-gutters>
        <TwoColumnMasonry v-if="dataReady"
                          :custom-field-groups=customFieldGroups
                          :user-can-edit="userCanEdit"
                          :expanded-all="expandedAll"
                          :callback="(field) => updateDirtyValue(field)"
                          @toggle-collapse-expand="toggleCollapseExpand($event)"/>
      </v-row>

      <v-dialog v-model="saveDialog" max-width="700">
        <v-card>
          <v-card-title>
            <span class="text-h5">Save Changes</span>
          </v-card-title>

          <v-divider></v-divider>

          <v-card-text class="pb-0">
            <v-radio-group v-model="ahjDesign.updateAllInState">
              <v-radio label="Save changes to this AHJ only" :value="false"></v-radio>
              <v-radio :label="`Save changes to all AHJs in ${ahjDesign.stateName}`" :value="true"></v-radio>
            </v-radio-group>
          </v-card-text>

          <v-divider></v-divider>

          <v-card-actions class="px-6">
            <v-spacer></v-spacer>
            <v-btn color="primary" text @click="saveDialog = false"
                   class="cancel-link mr-2"
            >Cancel
            </v-btn>
            <v-btn v-if="ahjDesign.updateAllInState"
                   class="white--text mr-0 save-btn"
                   color="primary"
                   @click="saveConfirmDialog = true"
            >Save
            </v-btn>
            <v-btn v-else
                   class="white--text mr-0 save-btn"
                   color="primary"
                   @click="updateAhjDesign"
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
                   @click="updateAhjDesign"
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
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, getSnackbar} from '@/helpers/helpers'
import {CollapseExpandEnum} from "@/views/blueraven/ahj/AhjConstants";
import TwoColumnMasonry from "@/views/blueraven/ahj/components/TwoColumnMasonry";

export default {
  name: 'ahjDesign',
  components: {
    CustomValueInput,
    TwoColumnMasonry
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
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
    itemType: 'design',
    snackbar: {},
    saveDialog: false,
    saveConfirmDialog: false,
    dataWasChanged: false,
    dataReady: false,
    customFieldGroups: [],
    ahjDesign: {
      designRequirements: [],
      electricalRequirements: [],
      structuralRequirements: [],
      contacts: []
    }
  }),
  methods: {
    updateDirtyValue(item) {
      item.valueWasChanged = true
      this.dataWasChanged = true
    },
    toggleCollapseExpand(wasExpanded) {
      if(wasExpanded === false) {
        this.expandedGroups--
      }else {
        this.expandedGroups++
      }
    },
    toggleMinimizeAll() {
      if (this.expandedAll !== CollapseExpandEnum.COLLAPSED) {
        this.expandedGroups = 0
      } else {
        this.expandedGroups = this.totalGroups
      }
    },
    async getAhjDesign() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/ahj/${this.ahjId}/design`, 'blueraven')
        window.document.title = `AHJ - ${data.ahjName}`
        this.ahjDesign = cloneDeep(data)
        this.ahjDesign.updateAllInState = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving AHJ Design')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroupAssignmentsForScreen() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.ahjDesign.id) {
          const params = {sourceId: this.ahjDesign.id, objectTypeId: 1}
          const {
            data,
            status
          } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          this.customFieldGroups = cloneDeep(data)
          this.totalGroups = this.totalGroups + this.customFieldGroups.length
          this.expandedGroups = this.totalGroups
          handleHidingGlobalLoader(this, status)
        } else {
          console.error('*** ERROR ***', 'Missing parameter "sourceId"')
          this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
        }
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
    resetCustomFieldValueWasChangedFlags() {
      this.customFieldGroups.forEach(group => {
        group.customFieldValues.forEach(cfv => cfv.valueWasChanged = false)
      })
    },
    async resetForm() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.dataWasChanged = false
      this.dataReady = false
      this.getAhjDesign().then(() => {
        this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
      })
    },
    validateForm() {
      //checks for required fields prior to opening the save dialog
      if (this.$refs.ahjDesignForm.validate()) {
        this.saveDialog = true
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async updateAhjDesign() {
      this.saveDialog = false
      this.saveConfirmDialog = false
      let updateAllInState = this.ahjDesign.updateAllInState

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (updateAllInState) {
          try {
            const {data} = await getRequest(`/ahj/${this.ahjId}/design/searchAhjsByState/${this.ahjDesign.stateId}`, 'blueraven')
            this.ahjDesign.ahjIds = []
            this.ahjDesign.designIds = []

            data.forEach(row => {
              this.ahjDesign.ahjIds.push(row.ahjId)
              this.ahjDesign.designIds.push(row.id)
            })
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'An error occurred when preparing to update all designs in ' + this.ahjDesign.stateName)
          }
        }

        this.ahjDesign.customFieldGroups = this.customFieldGroups
        const {
          data,
          status
        } = await putRequest(`/ahj/${this.ahjId}/design/${this.ahjDesign.id}`, this.ahjDesign, 'blueraven')
        this.ahjDesign = cloneDeep(data)
        this.ahjDesign.updateAllInState = false
        this.dataWasChanged = false
        this.resetCustomFieldValueWasChangedFlags()
        let successMessage = updateAllInState ? 'All designs in ' + this.ahjDesign.stateName + ' have been updated successfully' : 'Design updated successfully'
        this.snackbar = getSnackbar('SUCCESS', successMessage)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let errorMessage = updateAllInState ? 'An error occurred when attempting to update all designs in ' + this.ahjDesign.stateName : 'Failed to update design'
        this.snackbar = getSnackbar('ERROR', errorMessage)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    }
  },
  async created() {
    this.ahjId = parseInt(this.$route.params.ahjId)
    this.getAhjDesign().then(() => {
      this.getCustomFieldGroupAssignmentsForScreen().then(() => this.dataReady = true)
    })
  }
}
</script>

<style scoped lang="scss">
.padded-sides {
  padding: 0 5px;
}

.design-card {
  margin-left: 12px;
  margin-right: 12px;
}

.ahj-form-btns {
  display: flex;
  flex-flow: row nowrap;
  justify-content: flex-end;
  align-items: center;
}

.v-text-field,
.v-select,
.v-input ::v-deep label,
.v-list-item__title {
  font-size: 0.95em !important;
}

.cancel-link {
  font-size: 0.85em !important;
}

.cancel-link:hover {
  text-decoration: underline;
}

.save-btn {
  margin: 10px 5px 10px 0;
}

.v-card__title,
.v-toolbar__title {
  font-size: 1em !important;
}

.v-card__subtitle {
  color: var(--v-primaryText-base) !important;
  border-bottom: 1px solid var(--v-primaryText-base) !important;
}

.custom-field,
.structural-design-text-field {
  width: 100%;
}

@media (min-width: 960px) {
  .custom-field,
  .structural-design-text-field {
    max-width: 46%;
  }
}
</style>
