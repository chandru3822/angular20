<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-btn text color="primary" class="pl-1 pr-2" :to="'/settings/workQueue/types'">
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
              <v-btn text color="primary" v-if="!editType" class="" @click="[editType = !editType]">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn text color="primary" class="" v-else @click="saveType()">
                <v-icon>save</v-icon>
              </v-btn>
              <v-btn text color="primary" v-if="editType" class="" @click="[editType = !editType]">
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
              <table class="one-hunned" v-if="workQueueType && workQueueType.id">
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
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Work Queue In Use By</v-toolbar-title>
        </v-toolbar>
        <v-card flat color="rowShadeCustom" class="square-card my-2 px-4">
          <v-list class="pa-0">
            <v-list-item v-for="(l, index) in itemsUsingType" :key="l.id" :class="{'shaded-row': index % 2}">
              <a :href="l.isEvent ? `/settings/processStep/${l.primaryId}/event/${l.secondaryId}` : `/settings/processStep/${l.primaryId}/components`">{{l.name}}</a>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Work Queue Access Control</v-toolbar-title>
        </v-toolbar>
        <multi-select-group
          v-if="!workQueueLoading"
          :userCanEdit="userCanEdit"
          :returnObject="workQueueType"
          :content="positions"
          :dropdownEnabled="workQueueType.hidden"
          :selectedContent="workQueueType.hiddenWhiteListedPositions"
          :title="'Hidden'"
          :label="'Allowed Positions'"
          :alternateLabel = "'Denied Positions'"
          :allow="workQueueType.hiddenAllow"
          :contentLoading="positionsLoading"
          backgroundColor="transparent"
          @selected-changed="workQueueTypeHiddenSelectedEventListener"
          @allow-changed="workQueueTypeHiddenAllowEventListener"
          @checkbox-changed="workQueueTypeHiddenCheckboxEventListener"></multi-select-group>
            <br/>
            <v-btn v-if="this.userCanEdit" color="primary" dark class="d-inline-block white--text"
                   @click="saveHiddenAndWhiteList()">
              <v-icon class="mr-2">save</v-icon>
              Save
            </v-btn>

      </v-col>
    </v-row>
    <v-row v-if="workQueueType && workQueueType.id && !workQueueType.useEventData">
      <v-col cols="12" class="pt-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title>Set Queue Schedule</v-toolbar-title>
          <v-spacer/>
          <v-toolbar-items>
            <div v-if="userCanEdit || userIsAdmin" class="wqt-buttons">
              <v-btn text color="primary" v-if="!editSchedule" class="" @click="[editSchedule = !editSchedule, savePrevSchedule()]">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn text color="primary" class="" v-else @click="saveType()">
                <v-icon>save</v-icon>
              </v-btn>
              <v-btn text color="primary" v-if="editSchedule" class="" @click="[editSchedule = !editSchedule, workQueueType.schedule = prevSchedule]">
                cancel
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>

        <v-col>
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
    <!--    Default Columns-->
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title class="app-title">Default Column Visibility</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div v-if="userCanEdit || userIsAdmin" class="wqt-buttons">
              <v-btn v-if="!editDefaultFields" text color="primary" @click="editDefaultFields = !editDefaultFields">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn v-else text color="primary" class="" @click="saveType()">
                <v-icon>save</v-icon>
              </v-btn>
              <v-btn text color="primary" v-if="editDefaultFields" @click="editDefaultFields = false">
                cancel
              </v-btn>
            </div>
          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12">
        <v-data-table
          :items="defaultFields"
          :headers="defaultCheckboxHeaders"
          class="table-striped pa-0 ma-0"
          hide-default-footer
        >
          <template v-slot:item.show="{ item }">
            <v-checkbox
              :input-value="item.show"
              :disabled="!editDefaultFields"
              @change="updateDefaultFields(item)"
            >
            </v-checkbox>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

    <v-row>
      <SmartlistColumn
        v-if="this.workQueueType.smartlistId"
        :can-edit="this.userIsAdmin"
        :smartlist-id="this.workQueueType.smartlistId"
        :company-object-types="filteredCompanyObjectTypes"
      />

      <v-btn color="primary" class="white--text build-sql" @click="buildSql"
             v-if="is7oaksAdmin || userId === 2350555">
        <div>BUILD SQL</div>
        <div>(only 7oaks and Judson)</div>
      </v-btn>
      <div>
        {{ sql }}
      </div>
    </v-row>

  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'
import orderBy from 'lodash.orderby'
import Vue2Filters from 'vue2-filters'
import {getWorkQueueCategories} from '@/services/workQueueService'
import {
  handleHidingGlobalLoader,
  getRequest,
  logError,
  getMinMaxRule,
  getRequestWithParams,
  putRequest,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import draggable from 'vuedraggable'
import ZonelessTimePickerInput from './availability/ZonelessTimePickerInput'
import SmartlistColumn from '@/views/flow/smartlistv1/SmartlistColumn'
import cloneDeep from 'lodash.clonedeep'

export default {
  name: 'WorkQueueType',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
    ZonelessTimePickerInput,
    SmartlistColumn
  },
  data() {
    return {
      snackbar: {},
      editType: false,
      editSchedule: false,
      constants,
      workQueueCategories: [],
      companyObjectTypes: [],
      durationTypes: [],
      expectedTargetRule: getMinMaxRule(0, 1),
      workQueueTypeId: this.$route.params.id,
      workQueueType: {},
      workQueueLoading: false,
      positions: [],
      itemsUsingType: [],
      positionsLoading: false,
      hiddenPositionsChanged: false,
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
      cardColorToggle: true,
      defaultFields: [],
      defaultCheckboxHeaders: [{text: "Field Name", value: "value", show: true}, {text: "Show", value: "show", show: true}],
      editDefaultFields: false,
    }
  },
  computed: {
    filteredCompanyObjectTypes() {
      let objectTypeIds = []
      if (this.workQueueType.useEventData) {
        objectTypeIds = [1,2,4,6]
      } else {
        objectTypeIds = [1,2,4]
      }
      return this.companyObjectTypes.filter(t => objectTypeIds.includes(t.objectTypeId))
    }
  },
  async created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    let requests = [
      this.getWorkQueueCategories(),
      this.getCompanyObjectTypes(),
      this.getDurationTypes(),
      this.getPositions(),
      this.getPsAndEventsUsingWqt(),
      this.getWorkQueueType(),
    ]
    await Promise.all(requests).then(async () => {
      this.$store.commit(AppMutations.SET_LOADING, false);
    })
  },
  methods: {
    selectAllHidden () {
      return this.workQueueType.hiddenWhiteListedPositions?.length === this.positions?.length
    },
    selectSomeHidden (f) {
      return this.workQueueType.hiddenWhiteListedPositions?.length > 0 && !this.selectAllHidden(f)
    },
    iconOwner () {
      if (this.selectAllHidden()) {
        return 'check_box'
      }
      if (this.selectSomeHidden()) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    toggleSelectAllPositions () {
      this.$nextTick(() => {
        if (this.selectAllHidden()) {
          this.workQueueType.hiddenWhiteListedPositions = []
          this.hiddenPositionsChanged = true
        } else {
          this.workQueueType.hiddenWhiteListedPositions = cloneDeep(this.positions)
          this.hiddenPositionsChanged = true
        }
      })
    },
    async getPositions() {
      if(this.positions?.length === 0) {
        try {
          this.positionsLoading = true
          const {data, status} = await getRequest(`/position/withParent`)
          this.positions = data
          this.positionsLoading = false
        } catch (e) {
          this.positionsLoading = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async saveHiddenAndWhiteList () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/workQueueType/saveHiddenAndWhiteList?savePositions=${this.workQueueType.hiddenWhiteListedPositionsChanged ?? false}`, this.workQueueType)
        this.hiddenPositionsChanged = false
        if(!this.workQueueType.hidden) {
          this.workQueueType.hiddenWhiteListedPositions = []
        }
        this.snackbar = getSnackbar('SUCCESS', 'Saved Successfully')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async buildSql() {
      try {
        const {data} = await getRequestWithParams(`/workQueue/smartlist/${this.workQueueType.smartlistId}/buildSql`, {params: {
          useEventData: this.workQueueType.useEventData
          }})
        this.sql = data
        navigator.clipboard.writeText(this.sql);
        this.snackbar = getSnackbar('SUCCESS', 'Copied query to clipboard')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error fetching sql')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getCompanyObjectTypes() {
      try {
        const {data} = await getRequest(`/smartlistv1/companyObjectTypes`)
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
    async getPsAndEventsUsingWqt() {
      try {
        const {data, status} = await getRequest(`/workQueueType/${this.workQueueTypeId}/inUseBy`)
        this.itemsUsingType = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getWorkQueueType() {
      try {
        this.workQueueLoading = true;
        const {data, status} = await getRequest(`/workQueueType/${this.workQueueTypeId}`)
        this.workQueueType = data
        this.defaultFields = this.workQueueType?.defaultColumnDisplay
        if (this.workQueueType.schedule.length < 1) {
          this.workQueueType.schedule = this.noScheduleDefault;
        }
        this.workQueueLoading = false;
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Work Queue Types')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getWorkQueueCategories() {
      try {
        const {data, status} = await getWorkQueueCategories()
        this.workQueueCategories = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
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
          this.editDefaultFields = false
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
    validateSchedule() {
      let invalidDate = false;
      // Only validate if Hours is selected
      if (this.workQueueType.expectedCycleDurationTypeId != 2) {
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
    },
    workQueueTypeHiddenSelectedEventListener(e){
      this.workQueueType.hiddenWhiteListedPositions = e;
      this.workQueueType.hiddenWhiteListedPositionsChanged = true;
    },
    workQueueTypeHiddenAllowEventListener(e){
      this.workQueueType.hiddenAllow = (e === 0);
    },
    workQueueTypeHiddenCheckboxEventListener(e){
      this.workQueueType.hidden = e;
    },
    updateDefaultFields(fieldName) {
      let fName = fieldName.text
      let fShow = fieldName.show

      this.workQueueType.defaultColumnDisplay.forEach((c) => {
        if (fName === c.text) {
          c.show = !fShow
        }
      })
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

.default-fields {
  font-size: 12px;
  color: var(--v-grey-base);
  font-weight: 700; line-height: 18px;
  text-align: left;
}


</style>
