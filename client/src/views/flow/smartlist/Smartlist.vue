<template>
<v-container id="smartlist-container">
  <v-row>
    <v-col cols="12">
      <v-card>
        <v-form
          ref="smartlistForm"
          class="one-hunned"
          :disabled="!canEdit"
        >
          <v-col cols="12">
            <v-toolbar flat class="app-toolbar">
              <v-btn
                text
                small
                class="mr-3"
                color="primary"
                @click="$router.go(-1)"
              >
                <v-icon>mdi-arrow-left</v-icon>
              </v-btn>
              <v-toolbar-title class="app-title">Smartlist Editor</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn
                  v-if="smartlist.id"
                  text
                  color="primary"
                  @click="runReport"
                >
                  <v-icon>mdi-cloud-download</v-icon>
                  <span v-if="!constants.IS_MOBILE">Export</span>
                </v-btn>

                <v-btn
                  v-if="smartlist.id"
                  text
                  color="primary"
                  @click="copy"
                >
                  <v-icon>mdi-content-copy</v-icon>
                  <span v-if="!constants.mobile">Duplicate</span>
                </v-btn>

                <v-btn
                  v-if="canEdit"
                  text
                  color="primary"
                  @click="validateForm"
                >
                  <v-icon>save</v-icon>
                  <span v-if="!constants.IS_MOBILE">Save</span>
                </v-btn>
                <v-btn
                    text
                    color="primary"
                    @click="showDeleteDialog=true"
                >
                  <v-icon>delete</v-icon>
                  <span v-if="!constants.IS_MOBILE">Delete</span>
                </v-btn>
                <ConfirmDeleteDialogImproved :open-confirm-delete-dialog="showDeleteDialog" @confirm-delete="[showDeleteDialog = false, deleteSmartlist()]" @closeConfirmDeleteDialog="showDeleteDialog=false">
                  <template v-slot:title>Confirm</template>
                  Are you sure you want to delete this smartlist?
                </ConfirmDeleteDialogImproved>
              </v-toolbar-items>
            </v-toolbar>
          </v-col>

          <v-col cols="12">
            <v-card-text>
              <v-row>
                <v-col cols="12" md="4">
                  <v-text-field
                    text
                    label="Smartlist Name"
                    v-model="smartlist.name"
                    :rules="requiredRules"
                  />
                </v-col>

                <v-col cols="12" md="4">
                  <v-dialog
                    v-model="showObjectTypeDialog"
                    width="500"
                  >
                    <template #activator="{on}">
                      <v-autocomplete
                        v-model="smartlist.companyObjectTypeId"
                        :items="companyObjectTypes"
                        item-text="objectType"
                        item-value="companyObjectTypeId"
                        label="Rows"
                        placeholder="Select one..."
                        :rules="requiredRules"
                        @change="checkObjectTypeChange"
                        attach
                      />
                    </template>

                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title
                      >
                        Confirm
                      </v-card-title>

                      <v-card-text>
                        Toggling to this row type will reset your smartlist, are you sure you want to continue?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="[showObjectTypeDialog = false, smartlist.companyObjectTypeId = companyObjectTypes.find(t => t.objectTypeId === originalObjectTypeId).companyObjectTypeId]">
                          No
                        </v-btn>
                        <v-btn
                          color="primary"
                          text
                          @click="[showObjectTypeDialog = false, toggleSmartlistObjectType()]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-col>

                <v-col
                  cols="12"
                  md="4"
                  v-if="smartlist.companyObjectTypeId && !isUserOrgObjectType"
                  v-cloak
                >
                  <v-autocomplete
                    v-model="smartlist.viewObjectTypeId"
                    :items="viewObjectTypes"
                    item-text="objectType"
                    item-value="objectTypeId"
                    label="Table View Display"
                    placeholder="Select one..."
                    attach
                  />
                </v-col>
              </v-row>

              <v-row>
                <v-col cols="4" md="2">
                  <v-checkbox
                    v-model="smartlist.shared"
                    label="Public"
                  />
                </v-col>

                <v-col cols="4" md="2">

                  <v-checkbox
                    v-if="isUserOrgObjectType"
                    v-model="smartlist.primaryUserPosition"
                    label="Primary Position"
                  />

                  <v-dialog
                    v-if="!isUserOrgObjectType"
                    v-model="showToggleDialog"
                    width="500"
                  >
                    <template #activator="{on}">
                      <v-checkbox
                        v-model="smartlist.projectDetails"
                        label="Project Details"
                        v-on="smartlist.id && on"
                      />
                    </template>

                    <v-card>
                      <v-card-title
                        class="text-h5 grey lighten-2"
                        primary-title
                      >
                        Confirm
                      </v-card-title>

                      <v-card-text>
                        Toggling project details will reset your smartlist, are you sure you want to continue?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="[showToggleDialog = false, smartlist.projectDetails = !smartlist.projectDetails]">
                          No
                        </v-btn>
                        <v-btn
                          color="primary"
                          text
                          @click="[showToggleDialog = false, toggleProjectDetails()]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-col>

                <v-col cols="4" md="2">
                  <v-checkbox
                      v-if="isProcessStepOrEvent"
                      v-model="smartlist.mainProcessSteps"
                      label="Primary Steps Only"
                  />
                </v-col>
              </v-row>
            </v-card-text>
          </v-col>
        </v-form>
      </v-card>
    </v-col>

    <SmartlistColumn
      v-if="smartlist.id"
      :company-object-types="filteredCompanyObjectTypes"
      :can-edit="canEdit"
      :is-project-details="smartlist.projectDetails"
      :project-details-columns="projectDetailsColumns"
      :smartlist-id="$route.params.smartlistId"
      :refresh="refreshData"
      @refreshed="refreshData = false"
    />

    <SmartlistRequirement
      v-if="smartlist.id"
      :requirements="requirements"
      :company-object-types="filteredCompanyObjectTypes"
      :reset-form="resetRequirementForm"
      :can-edit="canEdit"
      :is-project-details="smartlist.projectDetails"
      :project-details-requirements="projectDetailsColumns"
      @input="addNewRequirement"
      @update="updateRequirement"
      @delete="deleteRequirement"
      @form-reset="resetRequirementForm = false"
    />


<!--    ***********       smartlist logic is on hold until Smartlist v2        ********************************  -->
<!--    <v-col class="text-left">-->
<!--      <v-toolbar color="transparent" class="elevation-0">-->
<!--        <v-toolbar-title>Logic</v-toolbar-title>-->
<!--        <v-spacer></v-spacer>-->
<!--        <v-toolbar-items>-->
<!--          <v-btn v-if="logicUpdated"-->
<!--                 text-->
<!--                 @click="restoreLogic"-->
<!--          >-->
<!--            <v-icon>restore</v-icon>-->
<!--            Restore-->
<!--          </v-btn>-->
<!--          <v-btn v-if="logic.length > 0"-->
<!--                 text-->
<!--                 @click="clearLogic"-->
<!--          >-->
<!--            <v-icon>clear</v-icon>-->
<!--            Clear All-->
<!--          </v-btn>-->
<!--        </v-toolbar-items>-->
<!--      </v-toolbar>-->
<!--      <v-card flat class="text-left" color="transparent">-->
<!--        <v-btn small class="ml-1 mr-1 mt-1"-->
<!--               v-for="(l, index) in logic"-->
<!--               :key="index"-->
<!--               @click="removeLogic(index)">-->
<!--          {{l.smartlistRequirementId ? l.displayOrder : l.operationType}}-->
<!--        </v-btn>-->
<!--      </v-card>-->
<!--      <v-toolbar flat dense color="transparent">-->
<!--        <v-toolbar-title>Available Operations</v-toolbar-title>-->
<!--      </v-toolbar>-->
<!--      <v-card flat class="text-left" color="transparent">-->
<!--        <v-btn small class="ml-1 mr-1 mt-1"-->
<!--               v-for="(o, index) in operations"-->
<!--               :key="index"-->
<!--               @click="addOperationToLogic(o)">-->
<!--          {{o.operationType}}-->
<!--        </v-btn>-->
<!--      </v-card>-->
<!--      <v-toolbar flat dense color="transparent">-->
<!--        <v-toolbar-title>Requirements</v-toolbar-title>-->
<!--      </v-toolbar>-->
<!--      <v-card flat class="text-left mb-4" color="transparent">-->
<!--        <v-btn small-->
<!--               class="ml-1 mr-1 mt-1"-->
<!--               v-for="r in requirements"-->
<!--               :key="r.id"-->
<!--               @click="addRequirementToLogic(r)">-->
<!--          {{r.displayOrder}}-->
<!--        </v-btn>-->
<!--      </v-card>-->
<!--      <v-btn class="mt-4"-->
<!--             :disabled="!logicUpdated"-->
<!--             @click="updateLogic"-->
<!--      >-->
<!--        <v-icon class="mr-2">save</v-icon>-->
<!--        Save Logic Changes-->
<!--      </v-btn>-->
<!--    </v-col>-->
    <v-btn color="primary" dark class="white--text build-sql" @click="buildSql"
           v-if="is7oaksAdmin || userId === 2350555">
      <div>BUILD SQL</div>
      <div>(only 7oaks and Judson)</div>
    </v-btn>
    <div v-if="sql != null" class="pa-5">
      {{ sql }}
    </div>
  </v-row>
</v-container>
</template>

<script>

import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, deleteRequest, logError, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'


import SmartlistRequirement from './SmartlistRequirement'
import SmartlistColumn from '@/views/flow/smartlist/SmartlistColumn'
import { saveAs } from 'file-saver'
import {DateTime} from 'luxon'
import ConfirmDeleteDialogImproved from "@/ConfirmDeleteDialogImproved";

export default {
  name: 'Smartlist',
  components: {
    ConfirmDeleteDialogImproved,
    SmartlistRequirement,
    SmartlistColumn
  },
  data () {
    return {
      constants,
      snackbar: {},
      smartlist: {
        mainProcessSteps: true
      },
      companyObjectTypes: [],
      operations: [],
      requirements: [],
      fetchedLogic: [],
      logic: [],
      logicUpdated: false,
      resetRequirementForm: false,
      viewObjectTypes: [
        {objectTypeId: 2, objectType: 'Contact'},
        // {objectTypeId: 5, objectType: 'Organization'},
        {objectTypeId: 1, objectType: 'Project'}
        // {objectTypeId: 3, objectType: 'User'}
      ],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      showDeleteDialog: false,
      showToggleDialog: false,
      showObjectTypeDialog: false,
      originalObjectTypeId: null,
      projectDetailsColumns: [],
      sql: '',
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      userId: this.$store.state.user.details.id,
      refreshData: false
    }
  },
  created () {
    if (this.$route.params?.smartlistId !== "null") {
      this.getSmartlist()
      this.getRequirements()
      this.getLogic()
      this.getProjectDetailsColumns()
    }
    this.getOperations()
    this.getCompanyObjectTypes()
  },
  computed: {
    isProcessStepOrEvent () {
      return this.smartlist.companyObjectTypeId !== null && ([4,6].includes(this.companyObjectTypes.find(t => t.companyObjectTypeId === this.smartlist?.companyObjectTypeId)?.objectTypeId))
    },
    isUserOrgObjectType () {
      if (this.smartlist.companyObjectTypeId) {
        const objectTypeId = this.companyObjectTypes.find(t => t.companyObjectTypeId === this.smartlist?.companyObjectTypeId)?.id
        return objectTypeId && [3, 5].includes(objectTypeId)
      }
      return false
    },
    canEdit () {
      return (!this.smartlist?.id || this.$store.state.user.details.id === this?.smartlist?.ownerId) || this.$store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
    },
    filteredCompanyObjectTypes () {
      if (this.smartlist.id) {
        let objectTypeIds = []
        if ([1,2,4].includes(this.smartlist.objectTypeId)) {
          objectTypeIds = [1,2,4]
        } else if ([3,5].includes(this.smartlist.objectTypeId)) {
          objectTypeIds = [3,5]
        } else if (this.smartlist.objectTypeId === 6) {
          objectTypeIds = [1,2,4,6]
        }
        return this.companyObjectTypes.filter(t => objectTypeIds.includes(t.objectTypeId))
      } else {
        return this.companyObjectTypes
      }
    }
  },
  methods: {
    async getSmartlist () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}`)
        this.smartlist = data
        this.originalObjectTypeId = data.objectTypeId
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCompanyObjectTypes () {
      try {
        const {data} = await getRequest(`/smartlist/companyObjectTypes`)
        this.companyObjectTypes = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getRequirements () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/requirement`)
        this.requirements = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching requirements')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getLogic () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/logic`)
        this.fetchedLogic = [...data]
        this.logic = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching smartlist logic')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getProjectDetailsColumns () {
      try {
        const {data} = await getRequest(`/smartlist/availableProjectDetailsFields`)
        this.projectDetailsColumns = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching project details fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getOperations () {
      try {
        const {data} = await getRequest(`/operation`)
        this.operations = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operations')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async addSmartlist () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (!this.isProcessStepOrEvent) {
          this.smartlist.mainProcessSteps = true
        }

        const {data, status} = await postRequest(`/smartlist`, this.smartlist)
        this.smartlist = data
        this.originalObjectTypeId = data.objectTypeId
        this.$router.replace({name: 'smartlistEditor', params: {smartlistId: this.smartlist.id}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', e.message || e.data?.message || 'Error saving smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addNewRequirement (requirement) {
      try {
        const maxNumber = this.requirements.map(r => r.displayOrder).reduce((max, cur) => Math.max(max, cur), 0)
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/smartlist/${this.smartlist.id}/requirement`, {
          ...requirement,
          smartlistId: this.smartlist.id,
          secondaryRequirementValue: requirement.secondaryRequirementValue || null,
          displayOrder: maxNumber + 1,
          projectDetailsColumn: requirement.projectDetailsColumn,
          processStepEventId: requirement.processStepEventId
        })
        this.requirements.push(data)
        this.resetRequirementForm = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding requirement to smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateSmartlist () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)

        if (!this.isProcessStepOrEvent) {
          this.smartlist.mainProcessSteps = true
        }

        const {status} = await putRequest(`/smartlist/${this.smartlist.id}`, this.smartlist)

        const companyObjectType = this.companyObjectTypes.find(t => t.companyObjectTypeId === this.smartlist.companyObjectTypeId)
        this.originalObjectTypeId = companyObjectType.objectTypeId
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', e.message || 'Error saving smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateLogic () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await putRequest(`/smartlist/${this.smartlist.id}/logic`, this.logic)
        this.fetchedLogic = [...data]
        this.logic = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating smartlist logic')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateRequirement (requirement) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await putRequest(`/smartlist/${this.smartlist.id}/requirement/${requirement.id}`, requirement)
        this.requirements.splice(this.requirements.findIndex(r => r.id === requirement.id), 1, data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteSmartlist () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await deleteRequest(`/smartlist/${this.$route.params.smartlistId}`)
        handleHidingGlobalLoader(this, status)
        this.$router.go(-1)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Unable to delete smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteRequirement (requirement) {
      try {
        const deleteIndex = this.requirements.findIndex(r => r.id === requirement.id)
        if (deleteIndex === -1) {
          throw 'Given requirement not found in requirement list'
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.smartlist.id}/requirement/${requirement.id}`)
        this.requirements.splice(deleteIndex, 1)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error deleting requirement')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async runReport () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/smartlist/${this.smartlist.id}/csv`)
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        })
        saveAs(blob, `${this.smartlist.name} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', e.data.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm () {
      if (this.$refs.smartlistForm.validate()) {
        this.smartlist.id ? this.updateSmartlist() : this.addSmartlist()
        if (this.smartlist.projectDetails && this.projectDetailsColumns.length === 0) {
          this.getProjectDetailsColumns()
        }
      }
    },
    async toggleProjectDetails () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {status} = await putRequest(`/smartlist/${this.smartlist.id}/toggleProjectDetails`)
        this.refreshData = true
        this.requirements = []
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.smartlist.projectDetails = !this.smartlist.projectDetails
        this.snackbar = getSnackbar('ERROR', 'Error updating smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    checkObjectTypeChange () {
      if (this.smartlist.id) {
        const newObjectTypeId = this.companyObjectTypes.find(t => t.companyObjectTypeId === this.smartlist.companyObjectTypeId)?.objectTypeId
        if ([1, 2, 4].includes(this.originalObjectTypeId) && [3, 5, 6].includes(newObjectTypeId)) {
          this.showObjectTypeDialog = true
          return
        }

        if ([3, 5].includes(this.originalObjectTypeId) && [1, 2, 4, 6].includes(newObjectTypeId)) {
          this.showObjectTypeDialog = true
          return
        }

        if (this.originalObjectTypeId === 6 && newObjectTypeId !== 6) {
          this.showObjectTypeDialog = true
        }
      }
    },
    async toggleSmartlistObjectType () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const companyObjectType = this.companyObjectTypes.find(t => t.companyObjectTypeId === this.smartlist.companyObjectTypeId)
        this.smartlist.objectTypeId = companyObjectType.objectTypeId

        const {data, status} = await putRequest((`/smartlist/${this.smartlist.id}/toggleObjectType`), this.smartlist)

        this.smartlist = data
        this.originalObjectTypeId = data.objectTypeId
        this.refreshData = true
        this.requirements = []
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating smartlist row type')
        this.smartlist.objectTypeId = this.originalObjectTypeId
        this.smartlist.companyObjectTypeId = this.companyObjectTypes.find(t => t.objectTypeId === this.originalObjectTypeId).companyObjectTypeId
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async copy () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await postRequest(`/smartlist/${this.smartlist.id}/copy`)
        this.$router.push('/smartlist')
        this.snackbar = getSnackbar('SUCCESS', `Smartlist "${data.name}" was created`)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error duplicating smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async buildSql() {
      try {
        const {data} = await getRequest(`/smartlist/${this.smartlist.id}/getSqlString`)
        this.sql = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching sql')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    // **************************** smartlist logic on hold until smartlist v2 ***************************
    // clearLogic () {
    //   this.logic = []
    //   this.logicUpdated = true
    // },
    // restoreLogic () {
    //   this.logic = [...this.fetchedLogic]
    //   this.logicUpdated = false
    // },
    // removeLogic (index) {
    //   this.logic.splice(index, 1)
    //   this.logicUpdated = true
    // },
    // addOperationToLogic (operation) {
    //   this.logic.push({
    //     operationType: operation.operationType,
    //     operationTypeId: operation.id,
    //     smartlistId: this.smartlist.id
    //   })
    //   this.logicUpdated = true
    // },
    // addRequirementToLogic (requirement) {
    //   this.logic.push({
    //     displayOrder: requirement.displayOrder,
    //     smartlistRequirementId: requirement.id,
    //     smartlistId: this.smartlist.id
    //   })
    //   this.logicUpdated = true
    // }
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

::v-deep {
  [v-cloak] {
    display: none;
  }
}

.build-sql {
  position: absolute;
  bottom: 10px;
  right: 25px;
}
</style>
