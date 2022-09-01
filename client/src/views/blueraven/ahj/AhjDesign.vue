<template>
  <v-row no-gutters>
    <v-col class="ahj-form-btns py-1" cols="12">
      <v-btn color="primary" text v-if="dataWasChanged"
         @click="resetForm"
         class="cancel-link"
         style="margin-right: 10px"
      >Cancel</v-btn>
      <v-btn class="white--text mr-0 save-btn"
             v-if="userCanEdit"
             color="primary"
             @click="validateForm()"
      >Save
      </v-btn>
    </v-col>

    <v-form ref="ahjDesignForm">
      <v-row no-gutters class="mb-3">
        <!-- FIRST COLUMN -->
        <v-col cols="12" md="4" class="pr-sm-0 pr-md-1 mb-sm-0 mb-md-3">

        </v-col>

        <!-- SECOND COLUMN -->
        <v-col cols="12" md="8" class="pl-sm-0 pl-md-1 mb-sm-2 mb-md-3">

        </v-col>
      </v-row>


    </v-form>

  </v-row>
</template>

<script>
import cloneDeep from 'lodash.clonedeep'
import AhjDocumentsButton from './components/AhjDocumentsButton'
import AhjRequirement from './components/AhjRequirements'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, getRequestWithParams, putRequest, getSnackbar} from '@/helpers/helpers'

export default {
  name: 'ahjDesign',
  components: {
    AhjDocumentsButton,
    AhjRequirement,
    CustomValueInput
  },
  computed: {
    userCanEdit() {
      return this.$store.getters.userHasFeatureAccessLevel('AHJ_DATABASE', 'EDIT')
    },
  },
  data: () => ({
    ahjId: null,
    itemType: 'design',
    snackbar: {},
    saveDialog: false,
    saveConfirmDialog: false,
    dataWasChanged: false,
    dataReady: false,
    customFieldGroupAssignments: [],
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
          this.customFieldGroupAssignments = cloneDeep(data)
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
      let match = this.customFieldGroupAssignments.find(cfga => cfga.id === groupId)
      return match ? match.customFieldValues : []
    },
    resetCustomFieldValueWasChangedFlags() {
      this.customFieldGroupAssignments.forEach(group => {
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

        this.ahjDesign.customFieldGroups = this.customFieldGroupAssignments
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
