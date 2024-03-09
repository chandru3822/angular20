<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <AlbatrossButton
          variant="text"
          color="primary"
          class="pl-1 pr-2"
          :to="'/settings/workQueue/types'"
          prepend-icon="arrow-left"
          text="BACK"/>


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
              <AlbatrossButton variant="text" color="primary" v-if="!editType" class="" @click="[editType = !editType]" prepend-icon="edit"/>
              <AlbatrossButton variant="text" color="primary" class="" v-else @click="saveType()" prepend-icon="save"/>
              <AlbatrossButton variant="text" color="primary" v-if="editType" class="" @click="[editType = !editType]" text="CANCEL"/>
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
            <AlbatrossButton v-if="userCanEdit" color="primary" dark class="d-inline-block white--text"
                   @click="saveHiddenAndWhiteList()" prepend-icon="save" text="SAVE"/>
      </v-col>
    </v-row>
    <v-row v-if="workQueueType && workQueueType.id && !workQueueType.useEventData">
      <v-col cols="12" class="pt-0">
        <v-toolbar flat class="wqt-header-bar">
          <v-toolbar-title>Set Queue Schedule</v-toolbar-title>
          <v-spacer/>
          <v-toolbar-items>
            <div v-if="userCanEdit || userIsAdmin" class="wqt-buttons">
              <AlbatrossButton variant="text" color="primary" v-if="!editSchedule" class=""
                               @click="[editSchedule = !editSchedule, savePrevSchedule()]" prepend-icon="edit"/>
              <AlbatrossButton variant="text" color="primary" class="" v-else
                               @click="saveType()" prepend-icon="save"/>
              <AlbatrossButton variant="text" color="primary" v-if="editSchedule" class=""
                               @click="[editSchedule = !editSchedule, workQueueType.schedule = prevSchedule]" text="CANCEL"/>
            </div>
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
                    :readonly="!editSchedule || workQueueType.expectedCycleDurationTypeId === 1 || !item.selected"
                    :allowed-minutes="allowedMinutesStep"
                    :hide-details="true"
                    @click="item.invalid = false"
                    label="Open"
                  />
                  <ZonelessTimePickerInput
                    v-model="item.endTime"
                    :readonly="!editSchedule || workQueueType.expectedCycleDurationTypeId === 1 || !item.selected"
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
      <SmartlistColumn
        v-if="workQueueType.smartlistId"
        :can-edit="userIsAdmin"
        :smartlist-id="workQueueType.smartlistId"
        :company-object-types="filteredCompanyObjectTypes"
      />

      <AlbatrossButton color="primary" class="white--text build-sql" @click="buildSql"
             v-if="is7oaksAdmin || userId === 2350555" text="BUILD SQL (only 7oaks)"/>
      <div>
        {{ sql }}
      </div>
    </v-row>

  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import orderBy from 'lodash.orderby'
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

import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const editType = ref(false)
const editSchedule = ref(false)
const workQueueCategories = ref([])
const companyObjectTypes = ref([])
const durationTypes = ref([])
const expectedTargetRule = ref(getMinMaxRule(0, 1))
const workQueueType = ref({})
const workQueueLoading = ref(false)
const positions = ref([])
const itemsUsingType = ref([])
const positionsLoading = ref(false)
const hiddenPositionsChanged = ref(false)
const sql = ref('')
const allowedMinutesStep = ref(m => m % 60 === 0)
const noScheduleDefault = ref([
  {day: 'Sunday', startTime: null, endTime: null, selected: false},
  {day: 'Monday', startTime: null, endTime: null, selected: false},
  {day: 'Tuesday', startTime: null, endTime: null, selected: false},
  {day: 'Wednesday', startTime: null, endTime: null, selected: false},
  {day: 'Thursday', startTime: null, endTime: null, selected: false},
  {day: 'Friday', startTime: null, endTime: null, selected: false},
  {day: 'Saturday', startTime: null, endTime: null, selected: false}
])
const daysDefaultSchedule = ref([
  {day: 'Sunday', startTime: null, endTime: null, selected: false},
  {day: 'Monday', startTime: null, endTime: null, selected: true},
  {day: 'Tuesday', startTime: null, endTime: null, selected: true},
  {day: 'Wednesday', startTime: null, endTime: null, selected: true},
  {day: 'Thursday', startTime: null, endTime: null, selected: true},
  {day: 'Friday', startTime: null, endTime: null, selected: true},
  {day: 'Saturday', startTime: null, endTime: null, selected: true}
])
const hoursDefaultSchedule = ref([
  {day: 'Sunday', startTime: null, endTime: null, selected: false},
  {day: 'Monday', startTime: '07:00', endTime: '22:00', selected: true},
  {day: 'Tuesday', startTime: '07:00', endTime: '22:00', selected: true},
  {day: 'Wednesday', startTime: '07:00', endTime: '22:00', selected: true},
  {day: 'Thursday', startTime: '07:00', endTime: '22:00', selected: true},
  {day: 'Friday', startTime: '07:00', endTime: '22:00', selected: true},
  {day: 'Saturday', startTime: '07:00', endTime: '22:00', selected: true}
])
const prevSchedule = ref([])
const cardColorToggle = ref(true)
const filteredCompanyObjectTypes = computed(() =>{
  let objectTypeIds = []
  if (workQueueType.value.useEventData) {
    objectTypeIds = [1, 2, 4, 6]
  } else {
    objectTypeIds = [1, 2, 4]
  }
  return companyObjectTypes.value.filter(t => objectTypeIds.includes(t.objectTypeId))
})

const workQueueTypeId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'EDIT')
})
const userCanDelete = computed(() => {
  return userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'DELETE')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('WORK_QUEUE', 'Admin')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})
const is7oaksAdmin = computed(() => {
  return userStore.isSystemAdmin
})

onMounted( async () => {
  store.commit(AppMutations.SET_LOADING, true)
  let requests = [
    getAllWorkQueueCategories(),
    getCompanyObjectTypes(),
    getDurationTypes(),
    getPositions(),
    getPsAndEventsUsingWqt(),
    getWorkQueueType()
  ]
  await Promise.all(requests).then(async () => {
    store.commit(AppMutations.SET_LOADING, false);
  })
})

const selectAllHidden = () => {
  return workQueueType.value.hiddenWhiteListedPositions?.length === positions.value?.length
}
const selectSomeHidden = (f) => {
  return workQueueType.value.hiddenWhiteListedPositions?.length > 0 && !selectAllHidden(f)
}
const iconOwner = () => {
  if (selectAllHidden()) {
    return 'check_box'
  }
  if (selectSomeHidden()) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const toggleSelectAllPositions = () => {
  vueInstance.$nextTick(() => {
    if (selectAllHidden()) {
      workQueueType.value.hiddenWhiteListedPositions = []
      hiddenPositionsChanged.value = true
    } else {
      workQueueType.value.hiddenWhiteListedPositions = cloneDeep(positions.value)
      hiddenPositionsChanged.value = true
    }
  })
}
const getPositions = async () => {
  if(positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const saveHiddenAndWhiteList = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/workQueueType/saveHiddenAndWhiteList?savePositions=${workQueueType.value.hiddenWhiteListedPositionsChanged ?? false}`, workQueueType.value)
    hiddenPositionsChanged.value = false
    if(!workQueueType.value.hidden) {
      workQueueType.value.hiddenWhiteListedPositions = []
    }
    snackbar('SUCCESS', 'Saved Successfully')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const buildSql = async () => {
  try {
    const {data} = await getRequestWithParams(`/workQueue/smartlist/${workQueueType.value.smartlistId}/buildSql`, {params: {
      useEventData: workQueueType.value.useEventData
      }})
    sql.value = data
    navigator.clipboard.writeText(sql.value);
    snackbar('SUCCESS', 'Copied query to clipboard')
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching sql')
  }
}
const getCompanyObjectTypes = async () => {
  try {
    const {data} = await getRequest(`/smartlistv1/companyObjectTypes`)
    companyObjectTypes.value = data.sort((a, b) => a.objectType.localeCompare(b.objectType))
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching object types')

  }
}
const getDurationTypes = async () => {
  try {
    const {data} = await getRequest(`/workQueueType/durationTypes`)
    durationTypes.value = data
  } catch (e) {
    logError(e)
    snackbar('ERROR', 'Error fetching duration types')

  }
}
const getPsAndEventsUsingWqt = async () => {
  try {
    const {data, status} = await getRequest(`/workQueueType/${workQueueTypeId.value}/inUseBy`)
    itemsUsingType.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Work Queue Types')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getWorkQueueType = async () => {
  try {
    workQueueLoading.value = true;
    const {data, status} = await getRequest(`/workQueueType/${workQueueTypeId.value}`)
    workQueueType.value = data
    if (workQueueType.value.schedule.length < 1) {
      workQueueType.value.schedule = noScheduleDefault.value;
    }
    workQueueLoading.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Work Queue Types')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getAllWorkQueueCategories = async () => {
  try {
    const {data, status} = await getWorkQueueCategories()
    workQueueCategories.value = orderBy(data, [wt => wt.workQueueCategory.toLowerCase()])
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Work Queue Types')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveType = async () => {
  if (vueInstance.$refs.wqtForm.validate() && validateSchedule()) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await putRequest(`/workQueueType/type`, workQueueType.value)
      workQueueType.value = data
      editType.value = false
      editSchedule.value = false
      snackbar('SUCCESS', 'Work Queue Type Saved')
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Work Queue Type')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const validateSchedule = () => {
  let invalidDate = false;
  // Only validate if Hours is selected
  if (workQueueType.value.expectedCycleDurationTypeId != 2) {
    return true;
  }

  for (const dayOfWeek of workQueueType.value.schedule) {
    if (dayOfWeek.selected) {
      if (dayOfWeek.startTime == null || dayOfWeek.endTime == null) {
        invalidDate = true;
        dayOfWeek.invalid = true
        vueInstance.$forceUpdate();
      }
      else {
        dayOfWeek.invalid = false
      }
    }
  }

  if (invalidDate) {
    snackbar('ERROR', 'Invalid schedule: All selected days must have a start and end time')
    return false;
  }

  return true;
}
const toggleSelection = (item) => {
  // If Weeks is selected, do not allow days to be selected/unselected
  if (editSchedule.value && workQueueType.value.expectedCycleDurationTypeId != 3) {
    // If day is being unselected, remove the hours configured
    if (item.selected) {
      item.startTime = null;
      item.endTime = null;
    }

    item.selected = !item.selected;
    item.invalid = false;
    vueInstance.$forceUpdate();
  }
}
const expectedCycleDurationChange = () => {
  if (workQueueType.value.expectedCycleDurationTypeId == 1) {
    workQueueType.value.schedule = daysDefaultSchedule.value;
  }
  else if (workQueueType.value.expectedCycleDurationTypeId == 2) {
    workQueueType.value.schedule = hoursDefaultSchedule.value;
  }
  else {
    workQueueType.value.schedule = noScheduleDefault.value;
  }
}
const savePrevSchedule = () => {
  prevSchedule.value = JSON.parse(JSON.stringify(workQueueType.value.schedule));
}
const workQueueTypeHiddenSelectedEventListener = (e)=> {
  workQueueType.value.hiddenWhiteListedPositions = e;
  workQueueType.value.hiddenWhiteListedPositionsChanged = true;
}
const workQueueTypeHiddenAllowEventListener = (e)=> {
  workQueueType.value.hiddenAllow = (e === 0);
}
const workQueueTypeHiddenCheckboxEventListener = (e)=> {
  workQueueType.value.hidden = e;
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

.wqt-header-bar {
  border-bottom: 1px solid #E6E6E6;
  border-top: 1px solid #E6E6E6;
}
</style>
