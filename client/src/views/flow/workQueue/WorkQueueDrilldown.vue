<template>
  <v-container id="work-queue-drilldown-container">
    <v-row v-if="!dataLoading && !errorLoading">
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <a-btn
              variant="text"
              size="small"
              :to="`/workQueue`"
              class="mr-3"
              color="primary"
              prepend-icon="mdi-arrow-left"
          ></a-btn>
          <v-toolbar-title class="app-title" v-if="workQueue && workQueue.workQueueType">{{ workQueue.workQueueType }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-switch
                v-if="masterResults.length > 0"
                v-model="hideFutureFollowUps"
                class="mx-2 mt-5 wq-follow-up-switch fix-switch-color"
                label="Hide work with a next follow-up date in the future"
                @change="filterFutureFollowUps()"
            />
            <v-switch
                v-if="masterResults.length > 0 && workQueue.useEventData"
                v-model="hideFutureEvents"
                class="mx-2 mt-5 wq-follow-up-switch fix-switch-color"
                label="Hide events with a start time in the future"
                @change="filterFutureFollowUps()"
            />
            <a-btn
                variant="text"
                color="primary"
                @click="exportCsv"
                v-if="results.length > 0"
                prepend-icon="mdi-cloud-download"
            > Export </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div v-if="noResults && !dataLoading" class="one-hunned text-center mt-5">
          No results found
        </div>
        <v-data-table
            v-else
            :headers="filteredHeaders"
            :items="results"
            :fixed-header="true"
            ref="pageableTable"
            :page.sync="page"
            :loading="dataLoading"
            :options.sync="options"
            item-key="projectProcessStepEventId"
            :footer-props="footerProps"
            class="elevation-1 mt-1"
            id="wq-drilldown-table"
        >
          <template #no-data>
            <span class="default-text-color">No available results</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available results</span>
          </template>

          <template #header="{ props: { headers } }">
            <tr class="v-data-table-header">
              <th v-for="header in headers" :key="header.text" class="pa-2"
                  :style="{width: header.width ? header.width : 'auto',
                  'border-bottom': 'solid 1px #D8D9DA'}">
                <a-text-field variant="outlined"
                              hide-details
                              class="filter-input"
                              v-model="filters[header.value]"
                              @input="filterResults()">
                </a-text-field>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable v-data-table-row" :class="{'shaded-row': index % 2}">
              <td class="text-left pl-1" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Project Name')" :class="{'pt-2': item.tags && item.tags.length > 0}">
                <!--                <router-link class="router-link-td elevation-0 square-card"-->
                <!--                             :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">-->
                <!--                  {{ item['Project Name'] }}-->
                <!--                </router-link>-->
                <a >
                  <a-btn
                      variant="text"
                      small
                      :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`"
                      color="unset"
                      :text="item['Project Name']"
                  ></a-btn>
                </a>
                <div class="chip-container">
                  <v-chip v-for="(tag, idx) in item.tags"
                          small
                          class="mt-1 tag-chip"
                          :color="tag.bgColor"
                          :text-color="tag.fontColor"
                          :close="tag.removable"
                          :class="{'mb-4': idx === item.tags.length - 1,
                                   'mb-2': idx !== item.tags.length - 1}">
                    {{tag.tagName}}
                  </v-chip>
                </div>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Project ID')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Project ID'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Process Step Name')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Process Step Name'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Process Step Status Type')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Process Step Status Type'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Days In Queue')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Days In Queue'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('State Abbreviation')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['State Abbreviation'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders && !hiddenHeaders.includes('Owner')">
                <router-link  v-if="item['Owner']" class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Owner'] }}
                </router-link>
                <a-btn
                    @click="assignToUser(item)"
                    variant="outlined"
                    border
                    v-else-if="userCanOwnProcessStep(item)"
                    class="text-capitalize primary--text"
                    color="unset"
                    text="Assign to me"
                ></a-btn>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders  && !hiddenHeaders.includes('Active Process Steps')">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Active Process Steps'] }}
                </router-link>
              </td>
              <template v-for="c in customColumns">
                <td v-if="!hiddenHeaders.includes(c.name) || customHeaders.includes(c.name)">
                  <div v-if="!useProcessStepHeaders && c.name === 'Project Name'"
                       class="remove-left-margin"
                       :class="{'pt-2': item.tags && item.tags.length > 0}">
                    <a >
                      <a-btn
                          variant="text"
                          small
                          :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}/event/${item.projectProcessStepEventId}`"
                          color="unset"
                          :text="item['Project Name']"
                      ></a-btn>
                    </a>
                    <div class="chip-container">
                      <v-chip v-for="(tag, idx) in item.tags"
                              small
                              class="mt-1 tag-chip"
                              :color="tag.bgColor"
                              :text-color="tag.fontColor"
                              :close="tag.removable"
                              :class="{'mb-2': idx === item.tags.length - 1}">
                        {{tag.tagName}}
                      </v-chip>
                    </div>
                  </div>
                  <router-link v-else class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                    {{ getColumnValue(item, c) }}
                  </router-link>
                </td>
              </template>
              <td class="note-created-at" v-if="queueHasNotes">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item.firstNoteCreatedAt | formatDate('timestamp') }}
                </router-link>
              </td>
              <td class="notes-follow-up" v-if="queueHasNotes">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item.followUpDate | formatDate('date') }}
                </router-link>
              </td>
              <td class="notes-column" v-if="queueHasNotes">
                <div class="flex-display align-center">
                  <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  <pre class="app-pre-wrapper">
                      {{ item.firstNoteContent }}
                  </pre>
                    <v-spacer></v-spacer>
                    {{ item.id }}
                  </router-link>
                  <a-btn
                      size="small"
                      fab
                      variant="text"
                      color="primary"
                      @click="[showNotesModal = true, notesPpsIndex = index, itemToUpdate = item]"
                      prepend-icon="mdi-comment-text-multiple"
                  ></a-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>

      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showNotesModal" hide-confirm @confirm="updateRowNotes" @close-dialog="showNotesModal = false" :width="1800" :primary-header="true">
      <template v-slot:title >{{ itemToUpdate ? itemToUpdate['Project Name'] : ''}} - {{ itemToUpdate ? itemToUpdate['Process Step Name'] : '' }}</template>
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title>Notes</v-toolbar-title>
      </v-toolbar>
      <NotesAndActivityContent
          :showNotes="true"
          :showActivity="false"
          :bordered="true"
          :key="damnKeyThing"
          :notes="itemToUpdate ? itemToUpdate.notes : []"
          :is-ps-wqt-note="!workQueue.useEventData"
          :is-event-wqt-note="!!workQueue.useEventData"
          :primary-id="itemToUpdate ? (workQueue.useEventData ? itemToUpdate.projectProcessStepEventId : itemToUpdate.projectProcessStepId) : null"
          :secondary-id="itemToUpdate ? (workQueue.useEventData ? itemToUpdate.processStepEventWorkQueueTypeId : itemToUpdate.processStepWorkQueueTypeId): null"
          type="ProjectProcessStep"
          :callback="(item, isNew) => updateRowNotes(item, isNew)"
      />
      <template v-slot:no>Close</template>
    </ConfirmationDialog>

  </v-container>
</template>


<script setup>

import {saveAs} from 'file-saver'
import NotesAndActivityContent from '@/views/flow/components/NotesAndActivityContent'
import {DateTime} from 'luxon'
import cloneDeep from 'lodash.clonedeep'
import constants from '@/helpers/constants'
import moment from 'moment'

import {
  handleHidingGlobalLoader,
  getRequestWithParams,
  postRequest,

  logError, getRequest
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const vuetify = vueInstance.$vuetify

const damnKeyThing = ref(0)
const showNotesModal = ref(false)
const itemToUpdate = ref(null)
const hideFutureFollowUps = ref(false)
const hideFutureEvents = ref(false)
const selectedPps = ref({})
const filters = ref({})
const notesPpsIndex = ref(null)
const cachedFilters = ref({})
const initialPageLoad = ref(true)
const search = ref('')
const ytfDoWeNeedThis = ref(0)
const showPropCustom = ref(false)
const dataLoading = ref(true)
const errorLoading = ref(false)
const workQueue = ref({})
const workQueueTypeId = ref(route.params.id)
const userPositionId = ref(route.query.upId)
const smartlistId = ref(route.query.smartlistId)
const unassigned = ref(route.query.unassigned)
const installationCrewIds = ref(route.query.installationCrewIds)
const results = ref([])
const filteredResults = ref([])
const masterResults = ref([])
const customColumns = ref([])
const useProcessStepHeaders = ref(false)
const queueHasNotes = ref(false)
const queueHasOwningPositions = ref(false)
const noResults = ref(true)
const totalItems = ref(0)
const page = ref(1)
const footerProps = ref({
  'items-per-page-options': [25, 50, 100, 1000],
  'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
})
const options = ref({itemsPerPage: 100})
const headers = ref([])
const pageableTable = ref(null)

watch(page, async() => {
  let table = pageableTable.value
  let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

  vuetify.goTo(table); // to table
  vuetify.goTo(table, {container: wrapper}); // to header
})

const timezone = computed(() => {
  return userStore.timezone.value
})
const userFullName = computed(() => {
  return userStore.details.fullName
})
const userPositions = computed(() => {
  return userStore.details.userPositions
})
const filteredHeaders = computed(() => {
  return headers.value.filter(header => header.show === true)
})
const hiddenHeaders = computed(() => {
  return headers.value.filter(h => h.show !== true).map(h => h.value)
})

const customHeaders = computed(() => {
  console.log("Custom Headers", headers.value.filter(h => h?.isDefault === false))
  return headers.value.filter(h => h?.isDefault === false).map(h => h?.value)
})

onMounted(async() => {
  cachedFilters.value = JSON.parse(localStorage.getItem('wqDrilldownFilters')) || {}
  hideFutureFollowUps.value = JSON.parse(localStorage.getItem('hideFutureWqFollowUps')) || false
  hideFutureEvents.value = JSON.parse(localStorage.getItem('hideFutureWqEvents')) || false
  await getWorkQueueName()
  await getWorkDetails()
})

const getWorkQueueName = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/workQueueType/${workQueueTypeId.value}`)
    workQueue.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Results')

    appStore.loading = false
  }
}
const filterFutureFollowUps = () => {
  localStorage.setItem('hideFutureWqFollowUps', JSON.stringify(hideFutureFollowUps.value))
  localStorage.setItem('hideFutureWqEvents', JSON.stringify(hideFutureEvents.value))
  //master results = all results loaded at start
  //filtered results = the filters from the column headers
  if (!workQueue.value.useEventData && hideFutureFollowUps.value) {
    results.value = filteredResults.value.filter(r => {
      if(r.notes && r.notes.length > 0) {
        let firstNoteFollowUp = r.notes[0]?.followUpDate
        let noFollowUp = firstNoteFollowUp === null || firstNoteFollowUp === undefined
        //holy crap, why is this so hard.
        //just trying to compare a date in YYYY-MM-DD to now() was so stinking hard for me
        return noFollowUp || (!noFollowUp && (moment().isAfter(moment.utc(firstNoteFollowUp, 'YYYY-MM-DD').format('YYYY-MM-DD'))))
      } else {
        return true
      }
    })
  } else if (workQueue.value.useEventData && (hideFutureEvents.value || hideFutureFollowUps.value)) {
    results.value = filteredResults.value.filter(r => {
      let noteFilter = true
      if(r.notes && r.notes.length > 0) {
        let firstNoteFollowUp = r.notes[0]?.followUpDate
        let noFollowUp = firstNoteFollowUp === null || firstNoteFollowUp === undefined
        //holy crap, why is this so hard.
        //just trying to compare a date in YYYY-MM-DD to now() was so stinking hard for me
        noteFilter = noFollowUp || (!noFollowUp && (moment().isAfter(moment.utc(firstNoteFollowUp, 'YYYY-MM-DD').format('YYYY-MM-DD'))))
      }

      return (!hideFutureFollowUps.value || (hideFutureFollowUps.value && noteFilter)) && (!hideFutureEvents.value || (hideFutureEvents.value && moment(r['Event Start Time'], 'MM/DD/YYYY hh:mm a').isBefore(moment())))
    })
  } else {
    results.value = cloneDeep(filteredResults.value)
  }
}
const getColumnValue = (item, c) => {
  return item[c.name]
}
const exportCsv = async() => {
  try {
    appStore.loading = true
    const {data, status} = await getRequestWithParams(`/smartlistv1/${smartlistId.value}/csv`, {
      params: {
        timezone: timezone.value
      }
    })
    let blob = new Blob([data], {
      type: 'text/csv;charset=utf-8'
    });
    saveAs(blob, `${workQueue.value.workQueueType} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
    handleHidingGlobalLoader( status)
  } catch (e) {
    appStore.showSnack('ERROR', e.message)

    logError(e)
    appStore.loading = false
  }
}
const getWorkDetails = async() => {
  dataLoading.value = true
  errorLoading.value = false
  appStore.loading = true
  try {
    let path = ''
    if (typeof installationCrewIds.value !== 'undefined') {
      path = `/workQueue/${workQueueTypeId.value}/${installationCrewIds.value}`;
    } else {
      path = `/workQueue/${workQueueTypeId.value}`;
    }

    const {data, status} = await getRequestWithParams(path, {
      params: {
        smartlistId: smartlistId.value,
        userPositionId: userPositionId.value,
        unassigned: unassigned.value,
        timezone: timezone.value
        // page: page - 1,
        // size: itemsPerPage
      }
    })
    // results.value = data.content
    // totalItems.value = data.totalElements
    results.value = data?.data || []

    noResults.value = results.value?.length === 0
    useProcessStepHeaders.value = results.value?.length > 0 && 'Owning Positions' in results.value[0]


    //due to the way smartlist loads and exports arrays we have to parse these for use on the frontend
    //for PS both Notes and Owning positions should exist,
    //for PSE only notes will exist
    if(results.value?.length > 0 && 'Notes' in results.value[0]) {
      queueHasNotes.value = true
      results.value.forEach(r => {
        r.showNotesModal = false
        r.notes = JSON.parse(r['Notes'])
        r.followUpDate = null != r.notes[0]?.followUpDate && undefined !== r.notes[0]?.followUpDate ? moment.utc(r.notes[0]?.followUpDate, 'YYYY-MM-DD').format('M/D/YYYY') : null,
            r.firstNoteCreatedAt = r.notes[0]?.dateCreated,
            r.firstNoteCreatedAtFormatted = null != r.notes[0]?.dateCreated && undefined !== r.notes[0]?.dateCreated ? moment.utc(r.notes[0]?.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(timezone.value).format('M/D/YYYY h:mm a') : null,
            r.firstNoteContent = r.notes[0]?.note
        // r.activeProcessSteps = JSON.parse(r['Active Process Steps'])
        if('Owning Positions' in results.value[0]) {
          queueHasOwningPositions.value = true
          r.owningPositions = JSON.parse(r['Owning Positions'])
        }
        if('tags' in results.value[0]) {
          r.tags = JSON.parse(r['tags'])
        }
      })
    }


    masterResults.value = cloneDeep(results.value)
    filteredResults.value = cloneDeep(results.value)
    if (useProcessStepHeaders.value) {
      headers.value = [
        {text: 'Project', value: 'Project Name', show: true, isDefault: true},
        {text: 'Project ID', value: 'Project ID', show: true, isDefault: true},
        {text: 'Process Step', value: 'Process Step Name', show: true, isDefault: true},
        {text: 'Status', value: 'Process Step Status Type', show: true, isDefault: true},
        {text: 'Days In Queue', value: 'Days In Queue', show: true, isDefault: true},
        {text: 'State', value: 'State Abbreviation', show: true, isDefault: true},
        {text: 'Owner', value: 'Owner', show: true, isDefault: true},
        {text: 'Active Process Steps', value: 'Active Process Steps', show: true, isDefault: true},
      ]
    }

    //all custom fields from smartlists already had a dataTypeId, I changed the event default fields to pass back dataTypeId on the necessary columns
    //process step default fields dont need it as they are treated differently
    // 1 = date, 2 = timestamp, 4 = numeric, 6 = int

    customColumns.value = data?.headers || []
    customColumns.value.forEach(c => {
      headers.value.push({
        text: c.name,
        value: c.name,
        sort: (a, b) => {
          //dataTypeId = 6 is an int
          if ([4,6].includes(c.dataTypeId) ) {
            return (a === null) - (b === null) || a - b
          }
              //if it is a date, format the string as a date and sort by that value
              //without the .toString() this fails for numeric values
          //this does a lot of extra checking we probably dont need now that we know the data type id of the column, but i am keeping it cuz i am not sure what it all does
          else if ( [1,2].includes(c.dataTypeId) && ((null != a && a.toString().match(/^\d{4}-\d{2}-\d{2}/)) || (null != b && b.toString().match(/^\d{4}-\d{2}-\d{2}/))
              || ((null != a && !isNaN(Date.parse(a)) || (null != b && !isNaN(Date.parse(b))))))) {
            //todo: keep an eye on if Date.parse returns false for regular numbers and such
            //note: firefox doesn't support date formats with hyphens. only with /

            return ( null != a ? new Date(a.replace(/-/g, '/')) : a) - ( null != b ? new Date(b.replace(/-/g, '/')) : b )
          } else {
            //otherwise sort normally
            //nulls were sorting super weird when the normal options had special characters in them, like '#BQ-1234', setting nulls to '' before sorting seems to fix that, plus saves some null checks for localeCompare
            let newA = null == a ? '' : a.trim().toLowerCase()
            let newB = null == b ? '' : b.trim().toLowerCase()
            return newA.localeCompare(newB)
          }
        },
        show: true,
        isDefault: c?.objectType === null
      })
    })
    if (queueHasNotes.value) {

      //add the notes column to the end
      headers.value.push({
        text: 'Note Created At',
        value: 'firstNoteCreatedAtFormatted',
        width: 200,
        sort: (a, b) => {
          // return (a.length === 0 || a[0]?.followUpDate === null) - (b.length === 0 || b[0]?.followUpDate === null) || new Date(a[0]?.followUpDate) - new Date(b[0]?.followUpDate)
          // return new Date(a) - new Date(b)
          if (null != a || null != b) {
            return new Date(a) - new Date(b)
          } else {
            return (a === null) - (b === null) || a - b
          }
        },
        show: true
      })
      headers.value.push({
        text: 'Next Follow-up Date',
        value: 'followUpDate',
        sort: (a, b) => {
          // return (a.length === 0 || a[0]?.followUpDate === null) - (b.length === 0 || b[0]?.followUpDate === null) || new Date(a[0]?.followUpDate) - new Date(b[0]?.followUpDate)
          return new Date(a) - new Date(b)
        },
        show: true
      })
      headers.value.push({text: 'Note Content', value: 'firstNoteContent', sortable: true, show: true, width: 250})
    }

    //hide default columns based on backend
    workQueue.value.defaultColumnDisplay.forEach(c => {

      if (!c.show) {
        const index = headers.value.findIndex((h) => h.text === c.text)
        headers.value[index].show = false
      }
    })

    //check for a cached search and filter results accordingly
    if (cachedFilters.value[workQueueTypeId.value]) {
      Object.keys(cachedFilters.value[workQueueTypeId.value]).forEach(key => {
        filters.value[key] = cachedFilters.value[workQueueTypeId.value][key]
      })
      filterResults()
    }

    if (hideFutureFollowUps.value || hideFutureEvents.value) {
      filterFutureFollowUps()
    }

    dataLoading.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    errorLoading.value = true
    let msg = e?.data?.message || 'Error Retrieving Results'
    appStore.showSnack('ERROR', msg)

    appStore.loading = false
  }
}
const assignToUser = async(item) => {
  try {
    let userPosition = userPositions.value.find(up => up.canAssign)
    const {status} = await postRequest(`/projectProcessStep/${item.projectProcessStepId}/owner/checkExisting`, {userPositionId: userPosition.id})
    item['Owner'] = userFullName.value
    appStore.showSnack('SUCCESS', 'You are now assigned as the owner.')

    item.owner = userStore.details.fullName
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let alreadyAssigned = e.data.includes('already assigned')
    let msg = alreadyAssigned ? e.data : 'Error Saving Owner'
    if (alreadyAssigned) {
      item['Owner'] = 'Already Assigned. Please Refresh.'
    }
    appStore.showSnack('ERROR', msg)

    appStore.loading = false
  }
}
const userCanOwnProcessStep = (item) => {
  let canAssign = false
  item.owningPositions?.forEach(op => {
    let positionMatch = userPositions.value.find(up => up.positionId === op.positionId)
    if (positionMatch !== null && positionMatch !== undefined) {
      canAssign = true
      userPositions.value.find(up => up.positionId === op.positionId).canAssign = true
    }
  })
  return canAssign
}
const clickRow = (row) => {
  router.push({path: `/project/${row.projectId}/processStep/${row.projectProcessStepId}`})
}
const filterResults = () => {
  results.value = masterResults.value.filter(r => {
    let matchCount = 0
    let numFiltersUsed = 0
    Object.keys(filters.value).forEach(key => {
      //trim the value to see if they just searched for a bunch of space characters
      let value = filters.value[key].trim().length === 0 ? '' : filters.value[key]

      //populate the cached filters with the user's search
      //if there is no cached search for this wqt then add a blank object for it
      if (null == cachedFilters.value[workQueueTypeId.value]) {
        cachedFilters.value[workQueueTypeId.value] = {}
      }

      //then add the value
      cachedFilters.value[workQueueTypeId.value][key] = value

      if (null != value && value !== '') {
        numFiltersUsed++
        if (r[key]?.toString().toLowerCase().includes(value?.toLowerCase())) {
          matchCount++
        }
      }
    })
    localStorage.setItem('wqDrilldownFilters', JSON.stringify(cachedFilters.value))
    return matchCount === numFiltersUsed
  })
  //we populate this so that if they hide/unhide future after doing some filtering we can get back to the filtered state
  filteredResults.value = cloneDeep(results.value)
}
const updateRowNotes = (item, isNew) => {
  //have to set the matching value in filteredResults...cuz we do and it is dumb
  let matchInFilteredResults = filteredResults.value.find(fr => fr.projectProcessStepEventId === results.value[notesPpsIndex.value].projectProcessStepEventId && fr.processStepEventWorkQueueTypeId === results.value[notesPpsIndex.value].processStepEventWorkQueueTypeId)

  let followUpDate = null != item.followUpDate ? moment.utc(item.followUpDate, 'YYYY-MM-DD').format('M/D/YYYY') : null
  results.value[notesPpsIndex.value].followUpDate = followUpDate
  matchInFilteredResults.followUpDate = followUpDate

  results.value[notesPpsIndex.value].firstNoteCreatedAt = item.dateCreated
  matchInFilteredResults.firstNoteCreatedAt = item.dateCreated

  let dateFormatted = null != item.dateCreated ? moment.utc(item.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(timezone.value).format('M/D/YYYY h:mm a') : null
  results.value[notesPpsIndex.value].firstNoteCreatedAtFormatted = dateFormatted
  matchInFilteredResults.firstNoteCreatedAtFormatted = dateFormatted

  results.value[notesPpsIndex.value].firstNoteContent = item.note
  matchInFilteredResults.firstNoteContent = item.note

  //also re-populate the entire notes array
  matchInFilteredResults.notes = results.value[notesPpsIndex.value].notes

  if(isNew) {
    itemToUpdate.value.notes = [ item, ...itemToUpdate.value.notes ]
    damnKeyThing.value++
  }
}
const closeNotesModal = () => {
  //this is dumb.  if you update the results before the modal closes things get weird
  //if you update after then you have to catch all the ways that the modal can close
  results.value[notesPpsIndex.value].showNotesModal = false
  if(hideFutureFollowUps.value) {
    filterFutureFollowUps()
  }
}

</script>

<style lang="scss">
#work-queue-drilldown-container .v-data-table__wrapper {
  height: calc(100vh - 200px);
  min-height: 300px;
}

#wq-drilldown-table .v-data-table-header {
  vertical-align: bottom;
}


#wq-drilldown-table .v-data-table-header th{
  max-width: 175px;
}

#wq-drilldown-table .v-data-table-row td{
  min-height: 3em;
  height: inherit;
}

#wq-drilldown-table > div.v-data-table__wrapper > table > tbody > tr > td > button.primary--text.v-btn--outlined{
  border-color: var(--v-primary-base) !important;
}

.router-link-td {
  min-width: 50px;
}

.wq-follow-up-switch label {
  font-size: 14px;
}

.wq-follow-up-switch .v-input--selection-controls__input {
  transform: scale(0.775);
  transform-origin: center;
}
</style>

<style scoped lang="scss">


.card-main {
  /* @click adds the pointer but i didnt want the pointer on count == 0 */
  cursor: default;
}

.card-accent {
  height: 100%;
  width: 5px;
}

.card-count {
  line-height: 2;
  font-size: 30px;
  font-weight: 600;
  position: absolute;
  bottom: 0;
  right: 0;
  left: 0;
}

.notes-column {
  max-width: 300px;
  min-width: 250px;
}

#work-queue-drilldown-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

.chip-container {
  //display: flex;
  //flex-direction: column;
  display: block;
  margin-left: 10px;
}

.tag-chip {
  display: table;
  font-weight: 600;
}

.remove-left-margin {
  margin-left: -10px;
}

.wqt-notes-container {
  min-height: 400px;
}

.active-ps-container {
  list-style-type: none;
  padding-left: 0;
}

</style>
