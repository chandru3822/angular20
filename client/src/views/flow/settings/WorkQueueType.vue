<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/workQueue/types'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>

        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">
            {{ workQueueType.workQueueType }}
            <span :style="{'color': workQueueType.workQueueCategoryColor }">
                ({{ workQueueType.workQueueCategory }})
            </span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div v-if="userCanEdit || userIsAdmin" class="wqt-buttons">
              <v-btn text v-if="!editType" class="" @click="[editType = !editType]">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn text class="" v-else @click="saveType()">
                <v-icon>save</v-icon>
              </v-btn>
              <v-btn text v-if="editType" class="" @click="[editType = !editType]">
                cancel
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
        <div class="flex-display pt-3 px-3 mb-4" style="width: 100%">
          <v-form ref="wqtForm" class="one-hunned">
            <div class="one-hunned">
              <div v-if="editType">
                <v-text-field class="one-hunned"
                              label="Work Queue Type"
                              v-model="workQueueType.workQueueType"></v-text-field>
                <v-autocomplete
                  v-model="workQueueType.workQueueCategoryId"
                  :items="workQueueCategories"
                  label="Work Queue Category"
                  item-text="workQueueCategory"
                  item-value="id"
                  attach
                ></v-autocomplete>
              </div>

              <table class="one-hunned">
                <tr>
                  <td class="wqt-row pr-2">
                    <v-text-field text
                                  label="Short Window"
                                  :disabled="!editType"
                                  v-model.number="workQueueType.shortWindow"></v-text-field>
                  </td>
                  <td class="wqt-row pl-2">
                    <v-autocomplete
                      v-model="workQueueType.shortWindowDurationTypeId"
                      :items="durationTypes"
                      label="Short Window Duration Type"
                      :disabled="!editType"
                      item-text="durationType"
                      item-value="id"
                      attach
                    ></v-autocomplete>
                  </td>
                </tr>
                <tr>
                  <td class="wqt-row pr-2">
                    <v-text-field text
                                  label="Long Window"
                                  :disabled="!editType"
                                  v-model.number="workQueueType.longWindow"></v-text-field>
                  </td>
                  <td class="wqt-row pl-2">
                    <v-autocomplete
                      v-model="workQueueType.longWindowDurationTypeId"
                      :items="durationTypes"
                      label="Long Window Duration Type"
                      :disabled="!editType"
                      item-text="durationType"
                      item-value="id"
                      attach
                    ></v-autocomplete>
                  </td>
                </tr>
                <tr>
                  <td class="wqt-row pr-2">
                    <v-text-field text
                                  label="Expected Cycle"
                                  :disabled="!editType"
                                  v-model.number="workQueueType.expectedCycle"></v-text-field>
                  </td>
                  <td class="wqt-row pl-2">
                    <v-autocomplete
                      v-model="workQueueType.expectedCycleDurationTypeId"
                      :items="durationTypes"
                      label="Expected Cycle Duration Type"
                      :disabled="!editType"
                      item-text="durationType"
                      item-value="id"
                      attach
                    ></v-autocomplete>
                  </td>
                </tr>
                <tr>
                  <td class="wqt-row pr-2">
                    <v-text-field text
                                  label="Expected Target % (between 0 and 1)"
                                  :disabled="!editType"
                                  :rules="expectedTargetRule"
                                  v-model.number="workQueueType.expectedTarget"></v-text-field>
                  </td>
                  <td class="wqt-row pl-2">
                    <label>Inverse Expectation: </label>
                    <input type="checkbox" class="ml-2"
                           :disabled="!editType"
                           :min="0"
                           :max="1"
                           v-model="workQueueType.inverseExpectation">
                  </td>
                </tr>
              </table>
            </div>
          </v-form>
        </div>
        <v-divider></v-divider>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pt-0">
        <v-toolbar color="transparent" class="elevation-0">
          <v-toolbar-title>Columns</v-toolbar-title>
          <v-spacer/>
          <v-toolbar-items>
            <v-btn
              v-if="!showNewFieldForm && (userCanEdit || userIsAdmin)"
              text
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

            <template>
              <v-autocomplete
                v-model="newField.objectTypeId"
                label="Object Type"
                :items="companyObjectTypes"
                item-value="objectTypeId"
                item-text="objectType"
                @input="getAvailableFields"
                attach
              />

              <v-autocomplete
                v-if="newField.objectTypeId !== null && newField.objectTypeId === 4"
                v-model="newField.processStepId"
                label="Process Step"
                :items="availableProcessSteps"
                item-value="processStepId"
                item-text="processStepName"
                @input="calculateAvailableFields"
                attach
              />

              <v-autocomplete
                v-if="(newField.objectTypeId === 4 && newField.processStepId) || (newField.objectTypeId !== 4 && newField.objectTypeId != null)"
                v-model="newField.selectedField"
                label="Field"
                :items="availableFields"
                item-text="name"
                return-object
                attach
              />
            </template>

            <v-btn
              text
              color="primaryCustom"
              class="text-left"
              :disabled="!newField.selectedField"
              @click="addNewField"
            >
              <v-icon>save</v-icon>
              <span v-if="!constants.IS_MOBILE">Save</span>
            </v-btn>
          </v-col>
        </v-card>

        <v-list dense>
          <v-list-item>
            <v-list-item-action v-if="userCanEdit || userIsAdmin">
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

          <v-divider/>
          <v-divider/>

          <draggable
            :disabled="!userCanEdit && !userIsAdmin"
            v-model="assignedFields"
            @change="reorderFields"
            group="assignedFields"
          >

            <v-list-item
              :class="{grab: userCanEdit || userIsAdmin}"
              v-for="(field, index) in assignedFields"
              :key="field.id"
            >

              <v-list-item-action v-if="userCanEdit || userIsAdmin">
                <v-icon>drag_handle</v-icon>
              </v-list-item-action>

              <v-list-item-content>
                <v-row>
                  <v-col cols="1" class="text-left">{{ field.displayOrder }}</v-col>
                  <v-col cols="3" class="text-left">{{ field.name }}</v-col>
                  <v-col cols="4" class="text-left">{{ field.objectType }}</v-col>
                  <v-col cols="4" class="text-left">{{ field.processStepName }}</v-col>
                </v-row>
              </v-list-item-content>

              <v-list-item-action class="clickable">
                <v-icon v-if="userCanDelete || userIsAdmin" @click="deleteField(index)">delete</v-icon>
                <v-icon v-else></v-icon>
              </v-list-item-action>
            </v-list-item>
          </draggable>
        </v-list>

        <v-btn color="primaryCustom" class="white--text build-sql" @click="buildSql"
               v-if="is7oaksAdmin || userId === 2350555">
          <div>BUILD SQL</div>
          <div>(only 7oaks and Judson)</div>
        </v-btn>
        <div>
          {{ sql }}
        </div>
      </v-col>
    </v-row>

  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'
import orderBy from 'lodash.orderby'
import Vue2Filters from 'vue2-filters'
import {getWorkQueueCategories} from '@/services/workQueueService'
import {
  getRequest, logError, deleteRequest, getMinMaxRule,
  putRequest, postRequest, getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import draggable from 'vuedraggable'

export default {
  name: 'WorkQueueType',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable
  },
  data() {
    return {
      snackbar: {},
      editType: false,
      constants,
      newField: {},
      showNewFieldForm: false,
      workQueueCategories: [],
      companyObjectTypes: [],
      durationTypes: [],
      expectedTargetRule: getMinMaxRule(0, 1),
      fetchedAvailableFields: [],
      assignedFields: [],
      availableFields: [],
      availableProcessSteps: [],
      workQueueTypeId: this.$route.params.id,
      workQueueType: {},
      sql: '',
      is7oaksAdmin: this.$store.getters.isFullAdmin,
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN')
    }
  },
  computed: {},
  async created() {
    this.getWorkQueueCategories()
    this.getCompanyObjectTypes()
    this.getDurationTypes()
    await this.getWorkQueueType()
    if (this.workQueueType?.smartlistId) {
      this.getAssignedFields()
    }
  },
  methods: {
    async buildSql() {
      try {
        const {data} = await getRequest(`/workQueue/smartlist/${this.workQueueType.smartlistId}/buildSql`)
        this.sql = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching sql')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCompanyObjectTypes() {
      try {
        const {data} = await getRequest(`/smartlist/customFieldObjectTypes`)
        this.companyObjectTypes = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching object types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getDurationTypes() {
      try {
        const {data} = await getRequest(`/workQueueType/durationTypes`)
        this.durationTypes = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching duration types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getWorkQueueType() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/workQueueType/${this.workQueueTypeId}`)
        this.workQueueType = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getWorkQueueCategories() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getWorkQueueCategories()
        this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveType() {
      if (this.$refs.wqtForm.validate()) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/workQueueType/type`, this.workQueueType)
          this.workQueueType = data
          this.editType = false
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Work Queue Type')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    resetNewFieldForm() {
      this.showNewFieldForm = false
      this.newField = {}
    },
    async getAvailableFields() {
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
    calculateAvailableFields() {
      this.availableFields = this.fetchedAvailableFields.filter(f => f.name !== null).sort((a, b) => a.name.localeCompare(b.name))
      if (this.newField.processStepId) {
        this.availableFields = this.availableFields.filter(field => field.processStepId === this.newField.processStepId || field.smartlistFieldId !== null)
      }

      this.availableFields = this.availableFields.filter(f => {
        if (f.customFieldGroupAssignmentId !== null) {
          return !this.assignedFields.map(a => a.customFieldGroupAssignmentId).includes(f.customFieldGroupAssignmentId)
        } else {
          return !this.assignedFields.map(a => a.smartlistFieldId).includes(f.smartlistFieldId)
        }
      })
    },
    async addNewField() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await postRequest(`/smartlist/${this.workQueueType.smartlistId}/field`, {
          ...this.newField.selectedField,
          smartlistId: this.workQueueType.smartlistId,
          displayOrder: this.assignedFields.length + 1,
          processStepId: this.newField.processStepId || null,
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
    async getAssignedFields() {
      try {
        const {data} = await getRequest(`/smartlist/${this.workQueueType.smartlistId}/field`)
        this.assignedFields = data
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching assigned fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async reorderFields({moved}) {

      // If a drag happened but order wasn't changed
      if (moved.newIndex === moved.oldIndex) {
        return
      }
      this.assignedFields.forEach((field, index) => field.displayOrder = index + 1)

      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        await putRequest(`/smartlist/${this.workQueueType.smartlistId}/order`, this.assignedFields)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating field order')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } finally {
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField(fieldIndex) {

      try {
        const fieldToDelete = this.assignedFields[fieldIndex]
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.workQueueType.smartlistId}/field/${fieldToDelete.id}`)
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

  },


}
</script>

<style scoped lang="scss">
.build-sql {
  position: absolute;
  bottom: 10px;
  right: 25px;
}

.wqt-row {
  width: 50%;
}

.wqt-buttons {
  display: flex;
  align-items: center;
}
</style>
