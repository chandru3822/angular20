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
                color="primaryCustom"
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
                  @click="runReport"
                >
                  <v-icon>mdi-cloud-download</v-icon>
                  <span v-if="!constants.IS_MOBILE">Export</span>
                </v-btn>

                <v-btn
                  v-if="canEdit"
                  text
                  @click="validateForm"
                >
                  <v-icon>save</v-icon>
                  <span v-if="!constants.IS_MOBILE">Save</span>
                </v-btn>

                <v-btn
                  v-if="smartlist.id && canEdit"
                  text
                  color="brRed"
                >
                  <v-icon>delete</v-icon>
                  <span v-if="!constants.IS_MOBILE">Delete</span>
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
          </v-col>

          <v-col cols="12">
            <v-card-text>
              <v-row>
                <v-col cols="12" md="6">
                  <v-text-field
                    text
                    label="Smartlist Name"
                    v-model="smartlist.name"
                    :rules="requiredRules"
                  />
                </v-col>

                <v-col cols="12" md="6">
                  <v-autocomplete
                    v-model="smartlist.viewObjectTypeId"
                    :items="viewObjectTypes"
                    item-text="objectType"
                    item-value="objectTypeId"
                    label="Table View Display"
                    placeholder="Select one..."
                    :rules="requiredRules"
                  />
                </v-col>


              </v-row>

              <v-row>
                <v-col cols="12" md="6">
                  <v-autocomplete
                    v-model="smartlist.companyObjectTypeId"
                    :items="companyObjectTypes"
                    item-text="objectType"
                    item-value="companyObjectTypeId"
                    label="Rows"
                    placeholder="Select one..."
                    :rules="requiredRules"
                  />
                </v-col>

<!--                @TODO: humes, holding off until after MVP -->
<!--                <v-col cols="6" md="3">-->
<!--                  <v-checkbox-->
<!--                    v-model="smartlist.mainProcessSteps"-->
<!--                    label="Primary Process Steps Only"-->
<!--                  />-->
<!--                </v-col>-->

                <v-col cols="6" md="3">
                  <v-checkbox
                    v-model="smartlist.shared"
                    label="Public"
                  />
                </v-col>

                <v-col cols="6" md="3">
                  <v-checkbox
                    v-model="smartlist.projectDetails"
                    label="Project Details"
                  />
                </v-col>
              </v-row>
            </v-card-text>
          </v-col>
        </v-form>
      </v-card>
    </v-col>

    <v-col cols="12">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Columns</v-toolbar-title>
        <v-spacer />
        <v-toolbar-items>
          <v-btn
            v-if="!showNewFieldForm && canEdit"
            text
            :disabled="!smartlist.id"
            @click="showNewFieldForm = true"
          >
            <v-icon>add</v-icon>
            <template v-if="!constants.IS_MOBILE">Add Field</template>
          </v-btn>

          <v-btn
            v-if="showNewFieldForm"
            text
            @click="resetNewFieldForm"
          >
            Cancel
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>

      <v-card v-if="showNewFieldForm" class="elevation-1">
        <v-col class="text-left">

          <template v-if="smartlist.projectDetails === true">
            <v-autocomplete
              v-model="newField.projectDetailsColumn"
              label="Field"
              :items="projectDetailsColumns"
              item-value="projectDetailsColumn"
              item-text="name"
            />
          </template>

          <template v-else>
            <v-autocomplete
              v-model="newField.objectTypeId"
              label="Object Type"
              :items="companyObjectTypes"
              item-value="objectTypeId"
              item-text="objectType"
              @input="getAvailableFields"
            />

            <v-autocomplete
              v-if="newField.objectTypeId !== null && newField.objectTypeId === 4"
              v-model="newField.processStepId"
              label="Process Step"
              :items="availableProcessSteps"
              item-value="processStepId"
              item-text="processStepName"
              @input="calculateAvailableFields"
            />

            <v-autocomplete
              v-if="(newField.objectTypeId === 4 && newField.processStepId) || (newField.objectTypeId !== 4 && newField.objectTypeId != null)"
              v-model="newField.selectedField"
              label="Field"
              :items="availableFields"
              item-text="name"
              return-object
            />
          </template>

          <v-btn
            text
            color="primaryCustom"
            class="text-left"
            :disabled="isNewFieldButtonDisabled"
            @click="addNewField"
          >
            <v-icon>save</v-icon>
            <span v-if="!constants.IS_MOBILE">Save</span>
          </v-btn>
        </v-col>
      </v-card>

        <v-list dense>
          <v-list-item>
            <v-list-item-action v-if="canEdit">
              <v-icon></v-icon>
            </v-list-item-action>

            <v-list-item-content>
              <v-row>
                <v-col cols="1" class="text-left smartlist-field">Order</v-col>
                <v-col cols="3" class="text-left smartlist-field">Field Name</v-col>
                <v-col cols="4" class="text-left smartlist-field">Object Type</v-col>
                <v-col cols="4" class="text-left smartlist-field">Process Step Name</v-col>
              </v-row>
            </v-list-item-content>

            <v-list-item-action>
              <v-icon></v-icon>
            </v-list-item-action>
          </v-list-item>

          <v-divider />
          <v-divider />

          <draggable
            :disabled="!canEdit"
            v-model="assignedFields"
            @change="reorderFields"
            group="assignedFields"
          >

            <v-list-item
              :class="{grab: canEdit}"
              v-for="(field, index) in assignedFields"
              :key="field.id"
            >

              <v-list-item-action v-if="canEdit">
                <v-icon>drag_handle</v-icon>
              </v-list-item-action>

              <v-list-item-content>
                <v-row>
                  <v-col cols="1" class="text-left">{{field.displayOrder}}</v-col>
                  <v-col cols="3" class="text-left">{{field.name}}</v-col>
                  <v-col cols="4" class="text-left">{{field.objectType}}</v-col>
                  <v-col cols="4" class="text-left">{{field.processStepName}}</v-col>
                </v-row>
              </v-list-item-content>

              <v-list-item-action class="clickable">
                <v-icon v-if="canEdit" @click="deleteField(index)">delete</v-icon>
                <v-icon v-else></v-icon>
              </v-list-item-action>
            </v-list-item>
          </draggable>
        </v-list>
    </v-col>

    <SmartlistRequirement
      :requirements="requirements"
      :company-object-types="companyObjectTypes"
      :reset-form="resetRequirementForm"
      :disabled="!smartlist.id"
      :can-edit="canEdit"
      :is-project-details="smartlist.projectDetails"
      :project-details-columns="projectDetailsColumns"
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
  </v-row>
</v-container>
</template>

<script>

import {AppMutations} from '@/stores/AppStore'
import {getRequest, putRequest, postRequest, deleteRequest, logError, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'

import draggable from 'vuedraggable'
import SmartlistRequirement from './SmartlistRequirement'
import { saveAs } from 'file-saver'

export default {
  name: 'Smartlist',
  components: {

    draggable,
    SmartlistRequirement
  },
  data () {
    return {
      constants,
      snackbar: {},
      smartlist: {},
      companyObjectTypes: [],
      operations: [],
      fetchedAvailableFields: [],
      availableFields: [],
      availableProcessSteps: [],
      newField: {},
      showNewFieldForm: false,
      newFieldTypes: [
        {id: 1, name: 'Smartlist Field'},
        {id: 2, name: 'Custom Field'}
      ],
      assignedFields: [],
      requirements: [],
      fetchedLogic: [],
      logic: [],
      logicUpdated: false,
      resetRequirementForm: false,
      viewObjectTypes: [
        {objectTypeId: 1, objectType: 'Project'},
        {objectTypeId: 2, objectType: 'Contact'}
      ],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      projectDetailsColumns: []
    }
  },
  created () {
    if (this.$route.params?.smartlistId !== "null") {
      this.getSmartlist()
      this.getAssignedFields()
      this.getRequirements()
      this.getLogic()
      this.getProjectDetailsColumns()
    }
    this.getOperations()
    this.getCompanyObjectTypes()
  },
  computed: {
    isNewFieldButtonDisabled () {
      return !this.newField?.selectedField && !this.newField?.projectDetailsColumn
    },
    canEdit () {
      return (!this.smartlist?.id || this.$store.state.user.details.id === this?.smartlist?.ownerId) || this.$store.getters.userHasFeatureAccessLevel('SMARTLIST', 'ADMIN')
    }
  },
  methods: {
    async getSmartlist () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}`)
        this.smartlist = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getAssignedFields () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/field`)
        this.assignedFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching assigned fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCompanyObjectTypes () {
      try {
        const {data} = await getRequest(`/smartlist/customFieldObjectTypes`)
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
    async getAvailableFields () {
      this.newField = {objectTypeId: this.newField.objectTypeId}
      try {
        const {data} = await getRequest(`/smartlist/availableFieldsByType?objectTypeId=${this.newField.objectTypeId}`)
        this.fetchedAvailableFields = data
        if (this.newField.objectTypeId === 4) {
          this.availableProcessSteps = data.reduce((fields, field) => (field.processStepId === null || fields.find(f => f.processStepId === field.processStepId)) ? [...fields] : [...fields, field], [])
          this.availableProcessSteps = this.availableProcessSteps.sort((a, b) => a.processStepName.localeCompare(b.processStepName))
        } else {
          this.calculateAvailableFields()
        }
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching available fields')
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
    calculateAvailableFields () {
      this.availableFields = this.fetchedAvailableFields.sort((a, b) => a.name.localeCompare(b.name))
      if (this.newField.processStepId) {
        this.availableFields = this.availableFields.filter(field => field.processStepId === this.newField.processStepId || field.smartlistFieldId !== null)
      }
    },
    async addSmartlist () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist`, this.smartlist)
        this.smartlist = data
        this.$router.replace({name: 'smartlistEditor', params: {smartlistId: this.smartlist.id}})
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', e.message || 'Error saving smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addNewField () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.smartlist.id}/field`, {
          ...this.newField.selectedField,
          smartlistId: this.smartlist.id,
          displayOrder: this.assignedFields.length + 1,
          processStepId: this.newField.processStepId || null,
          projectDetailsColumn: this.newField.projectDetailsColumn
        })
        this.assignedFields.push(data)
        this.resetNewFieldForm()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding field to smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addNewRequirement (requirement) {
      try {
        const maxNumber = this.requirements.map(r => r.displayOrder).reduce((max, cur) => Math.max(max, cur), 0)
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.smartlist.id}/requirement`, {
          ...requirement,
          smartlistId: this.smartlist.id,
          secondaryRequirementValue: requirement.secondaryRequirementValue || null,
          displayOrder: maxNumber + 1,
          projectDetailsColumn: requirement.projectDetailsColumn
        })
        this.requirements.push(data)
        this.resetRequirementForm = true
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding requirement to smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateSmartlist () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await putRequest(`/smartlist/${this.smartlist.id}`, this.smartlist)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', e.message || 'Error saving smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateLogic () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await putRequest(`/smartlist/${this.smartlist.id}/logic`, this.logic)
        this.fetchedLogic = [...data]
        this.logic = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating smartlist logic')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateRequirement (requirement) {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await putRequest(`/smartlist/${this.smartlist.id}/requirement/${requirement.id}`, requirement)
        this.requirements.splice(this.requirements.findIndex(r => r.id === requirement.id), 1, data)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating requirement')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField (fieldIndex) {

      try {
        const fieldToDelete = this.assignedFields[fieldIndex]
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.$route.params.smartlistId}/field/${fieldToDelete.id}`)
        this.assignedFields.splice(fieldIndex, 1)
        await this.reorderFields({moved: {newIndex: 0, oldIndex: 1}})
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error removing field from smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async reorderFields ({moved}) {

      // If a drag happened but order wasn't changed
      if (moved.newIndex === moved.oldIndex) {
        return
      }
      this.assignedFields.forEach((field, index) => field.displayOrder = index + 1)

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await putRequest(`/smartlist/${this.$route.params.smartlistId}/order`, this.assignedFields)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating field order')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
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
    resetNewFieldForm () {
      this.showNewFieldForm = false
      this.newField = {}
    },
    async runReport () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequest(`/smartlist/${this.smartlist.id}/csv`)
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, "smartlist.csv");
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', e.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateForm () {
      if (this.$refs.smartlistForm.validate()) {
        this.smartlist.id ? this.updateSmartlist() : this.addSmartlist()
      }
    }
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

.smartlist-field {
  font-size: 12px;
  color: rgba(0,0,0,0.6);
  font-weight: 700; line-height: 18px;
}

.v-list {
  padding: 0 !important;
}

.v-list-item:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
