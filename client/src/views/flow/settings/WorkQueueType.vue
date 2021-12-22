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
              <div>
                <label>Use Event Data:</label>
                <input type="checkbox" class="ml-3" disabled v-model="workQueueType.useEventData">
              </div>
              <table class="one-hunned" v-if="workQueueType && workQueueType.id && !workQueueType.useEventData">
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
                      @change="expectedCycleDurationChange()"
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
    <v-row v-if="workQueueType && workQueueType.id && !workQueueType.useEventData">
      <v-col cols="12" class="pt-0">
        <v-toolbar color="transparent" class="elevation-0">
          <v-toolbar-title>Set Queue Schedule</v-toolbar-title>
          <v-spacer/>
          <v-toolbar-items>
            <div v-if="userCanEdit || userIsAdmin" class="wqt-buttons">
              <v-btn text v-if="!editSchedule" class="" @click="[editSchedule = !editSchedule, savePrevSchedule()]">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn text class="" v-else @click="saveType()">
                <v-icon>save</v-icon>
              </v-btn>
              <v-btn text v-if="editSchedule" class="" @click="[editSchedule = !editSchedule, workQueueType.schedule = prevSchedule]">
                cancel
              </v-btn>
            </div>

            <v-btn
              v-if="showNewFieldForm"
              text
              @click="resetNewFieldForm"
            >
              Cancel
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>

        <v-col class="text-left">
          <template>
            <v-row>
              <v-card flat tile v-for="item in workQueueType.schedule" class="flex-display  card-main"
                      width="165" height="165">
                <v-card-text class="pa-0"
                             @click="toggleSelection(item)"
                             :class="[{'schedule-error': item.invalid}, {'schedule-selected': (!item.invalid && item.selected)}]">
                  <h4>{{item.day}}</h4>

                  <ZonelessTimePickerInput
                    v-model="item.startTime"
                    :readonly="!editSchedule || workQueueType.expectedCycleDurationTypeId == 1 || !item.selected"
                    :allowed-minutes="allowedMinutesStep"
                    :hide-details="true"
                    @click="item.invalid = false"
                    label="Open"
                  />
                  <ZonelessTimePickerInput
                    v-model="item.endTime"
                    :readonly="!editSchedule || workQueueType.expectedCycleDurationTypeId == 1 || !item.selected"
                    :allowed-minutes="allowedMinutesStep"
                    :hide-details="true"
                    @click="item.invalid = false"
                    label="Close"
                  />

                </v-card-text>
              </v-card>
            </v-row>
          </template>
        </v-col>
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
  handleHidingGlobalLoader, getRequest, logError, deleteRequest, getMinMaxRule,
  putRequest, postRequest, getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import draggable from 'vuedraggable'
import ZonelessTimePickerInput from "./availability/ZonelessTimePickerInput";

export default {
  name: 'WorkQueueType',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
    ZonelessTimePickerInput
  },
  data() {
    return {
      snackbar: {},
      editType: false,
      editSchedule: false,
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
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('WORK_QUEUE', 'ADMIN'),
      allowedMinutesStep: m => m % 60 === 0,
      noScheduleDefault: [
        {day: 'Sunday', startTime: null, endTime: null, selected: false},
        {day: 'Monday', startTime: null, endTime: null, selected: false},
        {day: 'Tuesday', startTime: null, endTime: null, selected: false},
        {day: 'Wednesday', startTime: null, endTime: null, selected: false},
        {day: 'Thursday', startTime: null, endTime: null, selected: false},
        {day: 'Friday', startTime: null, endTime: null, selected: false},
        {day: 'Saturday', startTime: null, endTime: null, selected: false}
      ],
      daysDefaultSchedule: [
        {day: 'Sunday', startTime: null, endTime: null, selected: false},
        {day: 'Monday', startTime: null, endTime: null, selected: true},
        {day: 'Tuesday', startTime: null, endTime: null, selected: true},
        {day: 'Wednesday', startTime: null, endTime: null, selected: true},
        {day: 'Thursday', startTime: null, endTime: null, selected: true},
        {day: 'Friday', startTime: null, endTime: null, selected: true},
        {day: 'Saturday', startTime: null, endTime: null, selected: true}
      ],
      hoursDefaultSchedule: [
        {day: 'Sunday', startTime: null, endTime: null, selected: false},
        {day: 'Monday', startTime: '07:00', endTime: '22:00', selected: true},
        {day: 'Tuesday', startTime: '07:00', endTime: '22:00', selected: true},
        {day: 'Wednesday', startTime: '07:00', endTime: '22:00', selected: true},
        {day: 'Thursday', startTime: '07:00', endTime: '22:00', selected: true},
        {day: 'Friday', startTime: '07:00', endTime: '22:00', selected: true},
        {day: 'Saturday', startTime: '07:00', endTime: '22:00', selected: true}
      ],
      prevSchedule: [],
      cardColorToggle: true
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
        const {data, status} = await getRequest(`/workQueueType/${this.workQueueTypeId}`)
        this.workQueueType = data
        if (this.workQueueType.schedule.length < 1) {
          this.workQueueType.schedule = this.noScheduleDefault;
        }
        handleHidingGlobalLoader(this, status)
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
        const {data, status} = await getWorkQueueCategories()
        this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveType() {
      if (this.$refs.wqtForm.validate() && this.validateSchedule()) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/workQueueType/type`, this.workQueueType)
          this.workQueueType = data
          this.editType = false
          this.editSchedule = false
          this.snackbar = getSnackbar('SUCCESS', 'Work Queue Type Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
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
        const {data, status} = await postRequest(`/smartlist/${this.workQueueType.smartlistId}/field`, {
          ...this.newField.selectedField,
          smartlistId: this.workQueueType.smartlistId,
          displayOrder: this.assignedFields.length + 1,
          processStepId: this.newField.processStepId || null,
        })
        this.assignedFields.push(data)
        this.resetNewFieldForm()
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error adding field to smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        const {status} = await putRequest(`/smartlist/${this.workQueueType.smartlistId}/order`, this.assignedFields)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error updating field order')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField(fieldIndex) {

      try {
        const fieldToDelete = this.assignedFields[fieldIndex]
        this.$store.commit(AppMutations.SET_LOADING, true)
        await deleteRequest(`/smartlist/${this.workQueueType.smartlistId}/field/${fieldToDelete.id}`)
        this.assignedFields.splice(fieldIndex, 1)
        const {status} = await this.reorderFields({moved: {newIndex: 0, oldIndex: 1}})
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error removing field from smartlist')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    validateSchedule() {
      let invalidDate = false;
      // Only validate if Hours is selected
      if (this.workQueueType.expectedCycleDurationTypeId != 2) {
        debugger;
        return true;
      }

      for (const dayOfWeek of this.workQueueType.schedule) {
        if (dayOfWeek.selected) {
          if (dayOfWeek.startTime == null || dayOfWeek.endTime == null) {
            invalidDate = true;
            dayOfWeek.invalid = true
            this.$forceUpdate();
          }
          else {
            dayOfWeek.invalid = false
          }
        }
      }

      if (invalidDate) {
        this.snackbar = getSnackbar('ERROR', 'Invalid schedule: All selected days must have a start and end time')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        return false;
      }

      return true;
    },
    toggleSelection(item) {
      // If Weeks is selected, do not allow days to be selected/unselected
      if (this.editSchedule && this.workQueueType.expectedCycleDurationTypeId != 3) {
        // If day is being unselected, remove the hours configured
        if (item.selected) {
          item.startTime = null;
          item.endTime = null;
        }

        item.selected = !item.selected;
        item.invalid = false;
        this.$forceUpdate();
      }
    },
    expectedCycleDurationChange() {
      if (this.workQueueType.expectedCycleDurationTypeId == 1) {
        this.workQueueType.schedule = this.daysDefaultSchedule;
      }
      else if (this.workQueueType.expectedCycleDurationTypeId == 2) {
        this.workQueueType.schedule = this.hoursDefaultSchedule;
      }
      else {
        this.workQueueType.schedule = this.noScheduleDefault;
      }
    },
    savePrevSchedule() {
      this.prevSchedule = JSON.parse(JSON.stringify(this.workQueueType.schedule));
    }
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

.schedule-selected {
  border: solid 6px var(--v-primary-base);
  border-color: #1F3C73!important;
}

.schedule-error {
  border: solid 6px var(--v-primary-base);
  border-color: red !important;
}

.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
  text-align: center;
  border-radius: 11px !important;
  margin-right: 5px;
  margin-left: 5px;
  border: 2px solid #DBE0E3;
}
</style>
