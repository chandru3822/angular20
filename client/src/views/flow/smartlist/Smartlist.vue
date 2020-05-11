<template>
<v-container id="smartlist-container">
  <v-row>

    <v-col cols="12" class="text-left">
      <v-btn
        text
        class="btn-back"
        :ripple="false"
        @click="$router.go(-1)"
      >
        Back
      </v-btn>
    </v-col>

    <v-col cols="12">
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Smartlist Editor</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>

<!--          @TODO: Remove once smartlists are "done" -->
          <v-btn
            id="runReport"
            text
            @click="runReport">
            <v-icon>warning</v-icon>
            <span>Run (for testing only)</span>
          </v-btn>

          <v-btn
            text
            color="primary"
            :disabled="showNewFieldForm"
            @click="smartlist.id ? updateSmartlist() : addSmartlist()"
          >
            <v-icon>save</v-icon>
            <span v-if="!IS_MOBILE">Save</span>
          </v-btn>
<!--          <v-btn text to="/smartlist/null" color="primary">-->
<!--            <v-icon>cancel</v-icon>-->
<!--            <span v-if="!IS_MOBILE">Cancel</span>-->
<!--          </v-btn>-->
        </v-toolbar-items>
      </v-toolbar>
    </v-col>

    <v-col cols="12">
      <v-card>
        <v-card-text>
          <v-row>
            <v-col cols="6">
              <v-text-field
                text
                label="Smartlist Name"
                v-model="smartlist.name"
              />
            </v-col>

            <v-col cols="6">
              <v-select
                v-model="smartlist.companyObjectTypeId"
                :items="companyObjectTypes"
                item-text="objectType"
                item-value="companyObjectTypeId"
                label="Object Type"
                placeholder="Select one..."
              />
            </v-col>
          </v-row>

          <v-row>
            <v-col cols="12">
              <v-checkbox
                v-model="smartlist.shared"
                label="Public"
              />
            </v-col>
          </v-row>
        </v-card-text>
      </v-card>
    </v-col>

    <v-col cols="12">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Fields</v-toolbar-title>
        <v-spacer />
        <v-toolbar-items>
          <v-btn
            v-if="!showNewFieldForm"
            text
            :disabled="!smartlist.id"
            @click="showNewFieldForm = true"
          >
            <v-icon>add</v-icon>
            <template v-if="!IS_MOBILE">Add Field</template>
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
          <v-select
            v-model="newField.objectTypeId"
            label="Object Type"
            :items="companyObjectTypes"
            item-value="objectTypeId"
            item-text="objectType"
            @input="getAvailableFields"
          />

          <v-select
            v-if="newField.objectTypeId !== null && newField.objectTypeId === 4"
            v-model="newField.processStepId"
            label="Process Step"
            :items="availableProcessSteps"
            item-value="processStepId"
            item-text="processStepName"
            @input="calculateAvailableFields"
          />

          <v-select
            v-if="(newField.objectTypeId === 4 && newField.processStepId) || (newField.objectTypeId !== 4 && newField.objectTypeId != null)"
            v-model="newField.selectedField"
            label="Field"
            :items="availableFields"
            item-text="name"
            return-object
          />

          <v-btn
            text
            color="primary"
            class="text-left"
            :disabled="isNewFieldButtonDisabled"
            @click="addNewField"
          >
            <v-icon>save</v-icon>
            <span v-if="!IS_MOBILE">Save</span>
          </v-btn>
        </v-col>
      </v-card>

        <v-list dense>
          <v-list-item>
            <v-list-item-action>
              <v-icon></v-icon>
            </v-list-item-action>

            <v-list-item-content>
              <v-row>
                <!--                  @TODO: put inline styles in class -->
                <v-col cols="1" class="text-left" style="font-size: 12px; color: rgba(0,0,0,0.6); font-weight: 700; line-height: 18px;">Order</v-col>
                <v-col cols="3" class="text-left" style="font-size: 12px; color: rgba(0,0,0,0.6); font-weight: 700; line-height: 18px;">Field Name</v-col>
                <v-col cols="4" class="text-left" style="font-size: 12px; color: rgba(0,0,0,0.6); font-weight: 700; line-height: 18px;">Object Type</v-col>
                <v-col cols="4" class="text-left" style="font-size: 12px; color: rgba(0,0,0,0.6); font-weight: 700; line-height: 18px;">Process Step Name</v-col>
              </v-row>
            </v-list-item-content>

            <v-list-item-action>
              <v-icon></v-icon>
            </v-list-item-action>
          </v-list-item>

          <v-divider />
          <v-divider />

          <draggable v-model="assignedFields" @change="reorderFields" group="assignedFields">

            <v-list-item class="grab" v-for="(field, index) in assignedFields" :key="field.id">

              <v-list-item-action>
                <v-icon>drag_handle</v-icon>
              </v-list-item-action>

              <v-list-item-content>
                <v-row>
                  <v-col cols="1" class="text-left">{{field.displayOrder}}</v-col>
                  <v-col cols="3" class="text-left">{{field.name}}</v-col>
                  <v-col cols="4" class="text-left">{{(field.smartlistFieldId) ? field.objectType : 'Custom'}}</v-col>
                  <v-col cols="4" class="text-left">{{field.processStepName}}</v-col>
                </v-row>
              </v-list-item-content>

              <v-list-item-action class="clickable">
                <v-icon @click="deleteField(index)">delete</v-icon>
              </v-list-item-action>
            </v-list-item>
          </draggable>
        </v-list>
    </v-col>

    <SmartlistRequirement
      :requirements="requirements"
      :company-object-types="companyObjectTypes"
      :reset-form="resetRequirementForm"
      @input="addNewRequirement"
      @update="updateRequirement"
      @delete="deleteRequirement"
      @form-reset="resetRequirementForm = false"
    />

    <v-col class="text-left">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Logic</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn v-if="logicUpdated"
                 text
                 @click="restoreLogic"
          >
            <v-icon>restore</v-icon>
            Restore
          </v-btn>
          <v-btn v-if="logic.length > 0"
                 text
                 @click="clearLogic"
          >
            <v-icon>clear</v-icon>
            Clear All
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card flat class="text-left" color="transparent">
        <v-btn small class="ml-1 mr-1 mt-1"
               v-for="(l, index) in logic"
               :key="index"
               @click="removeLogic(index)">
          {{l.smartlistRequirementId ? l.displayOrder : l.operationType}}
        </v-btn>
      </v-card>
      <v-toolbar flat dense color="transparent">
        <v-toolbar-title>Available Operations</v-toolbar-title>
      </v-toolbar>
      <v-card flat class="text-left" color="transparent">
        <v-btn small class="ml-1 mr-1 mt-1"
               v-for="(o, index) in operations"
               :key="index"
               @click="addOperationToLogic(o)">
          {{o.operationType}}
        </v-btn>
      </v-card>
      <v-toolbar flat dense color="transparent">
        <v-toolbar-title>Requirements</v-toolbar-title>
      </v-toolbar>
      <v-card flat class="text-left mb-4" color="transparent">
        <v-btn small
               class="ml-1 mr-1 mt-1"
               v-for="r in requirements"
               :key="r.id"
               @click="addRequirementToLogic(r)">
          {{r.displayOrder}}
        </v-btn>
      </v-card>
      <v-btn class="mt-4"
             :disabled="!logicUpdated"
             @click="updateLogic"
      >
        <v-icon class="mr-2">save</v-icon>
        Save Logic Changes
      </v-btn>
    </v-col>
  </v-row>
  <Snackbar :snackbar="snackbar" />
</v-container>
</template>

<script>

import {AppMutations} from '@/stores/AppStore'
import {IS_MOBILE, getRequest, putRequest, postRequest, deleteRequest, logError, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar'
import draggable from 'vuedraggable'
import SmartlistRequirement from './SmartlistRequirement'
import { saveAs } from 'file-saver'

export default {
  name: 'Smartlist',
  components: {
    Snackbar,
    draggable,
    SmartlistRequirement
  },
  data () {
    return {
      IS_MOBILE,
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
      resetRequirementForm: false
    }
  },
  created () {
    if (this.$route.params?.smartlistId !== "null") {
      this.getSmartlist()
      this.getAssignedFields()
      this.getRequirements()
      this.getLogic()
    }
    this.getOperations()
    this.getCompanyObjectTypes()
  },
  computed: {
    isNewFieldButtonDisabled () {
      return !this.newField?.selectedField
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
      }
    },
    async getAssignedFields () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/field`)
        this.assignedFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching assigned fields')
      }
    },
    async getCompanyObjectTypes () {
      try {
        const {data} = await getRequest(`/customField/getCustomFieldObjectTypes`)
        this.companyObjectTypes = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
      }
    },
    async getRequirements () {
      try {
        const {data} = await getRequest(`/smartlist/${this.$route.params.smartlistId}/requirement`)
        this.requirements = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching requirements')
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
      }
    },
    async getOperations () {
      try {
        const {data} = await getRequest(`/operation`)
        this.operations = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching operations')
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
        await postRequest(`/smartlist`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
      }
    },
    async addNewField () {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.smartlist.id}/field`, {
          ...this.newField.selectedField,
          smartlistId: this.smartlist.id,
          displayOrder: this.assignedFields.length + 1,
          processStepId: this.newField.processStepId || null
        })
        this.assignedFields.push(data)
        this.resetNewFieldForm()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding field to smartlist')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addNewRequirement (requirement) {
      try {
        const maxNumber = this.requirements.map(r => r.displayOrder).reduce((max, cur) => Math.max(max, cur), 0)
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.smartlist.id}/requirement`, {
          ...requirement.selectedField,
          smartlistId: this.smartlist.id,
          operatorTypeId: requirement.operatorTypeId,
          dataTypeRequirementId: requirement.dataTypeRequirementId,
          secondaryRequirementValue: requirement.secondaryRequirementValue || null,
          displayOrder: maxNumber + 1,
        })
        this.requirements.push(data)
        this.resetRequirementForm = true
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding requirement to smartlist')
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateSmartlist () {
      try {
        await putRequest(`/smartlist/${this.smartlist.id}`, this.smartlist)
        this.$router.back()
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error saving smartlist')
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
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    resetNewFieldForm () {
      this.showNewFieldForm = false
      this.newField = {}
    },
    clearLogic () {
      this.logic = []
      this.logicUpdated = true
    },
    restoreLogic () {
      this.logic = [...this.fetchedLogic]
      this.logicUpdated = false
    },
    removeLogic (index) {
      this.logic.splice(index, 1)
      this.logicUpdated = true
    },
    addOperationToLogic (operation) {
      this.logic.push({
        operationType: operation.operationType,
        operationTypeId: operation.id,
        smartlistId: this.smartlist.id
      })
      this.logicUpdated = true
    },
    addRequirementToLogic (requirement) {
      this.logic.push({
        displayOrder: requirement.displayOrder,
        smartlistRequirementId: requirement.id,
        smartlistId: this.smartlist.id
      })
      this.logicUpdated = true
    },
    async runReport () {
      console.log('running report')
      try {
        const {data, status} = await getRequest(`/smartlist/${this.smartlist.id}/generate`)
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, "smartlist.csv");
      } catch (e) {
        logError(e)
      }
    }
  }
}
</script>

<style scoped lang="scss">

@import "@/styles/main.scss";

::v-deep {
  .btn-back {

    text-transform: capitalize;
    text-decoration: underline;

    &:not(.v-btn--round) {
      padding: 0;
    }

    &:hover:before {
      opacity: 0 !important;
    }

    .v-btn__content {
      justify-content: start;
    }
  }

  #runReport {
    .v-btn__content {
      color: red;
    }

    .v-icon {
      color: red !important;
    }
  }
}

.v-list {
  padding: 0 !important;
}

.v-list-item:nth-of-type(even) {
  @extend .shaded-row;
}
</style>
