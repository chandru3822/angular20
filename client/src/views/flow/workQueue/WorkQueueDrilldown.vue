<template>
  <v-container id="work-queue-drilldown-container">
    <v-row v-if="!dataLoading && !errorLoading">
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-btn text small :to="`/workQueue`" class="mr-3" color="primary">
            <v-icon>mdi-arrow-left</v-icon>
          </v-btn>
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
            <v-btn text color="primary" @click="exportCsv" v-if="results.length > 0">
              <v-icon class="mr-2">mdi-cloud-download</v-icon>
              Export
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <div v-if="noResults && !dataLoading" class="one-hunned text-center mt-5">
          No results found
        </div>
        <v-data-table
          v-else
          :headers="filterHeaders()"
          :items="results"
          :fixed-header="true"
          ref="pageable-table"
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
                <v-text-field outlined
                              hide-details
                              class="filter-input"
                              v-model="filters[header.value]"
                              @input="filterResults()">
                </v-text-field>
              </th>
            </tr>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card"
                             :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Project Name'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Process Step Name'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Process Step Status Type'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Days In Queue'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['State Abbreviation'] }}
                </router-link>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link  v-if="item['Owner']" class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Owner'] }}
                </router-link>
                <v-btn text v-else-if="userCanOwnProcessStep(item)" class="px-0">
                  <a @click="assignToUser(item)">Assign to me</a>
                </v-btn>
              </td>
              <td class="text-left" v-if="useProcessStepHeaders">
                <router-link class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                  {{ item['Active Process Steps'] }}
                </router-link>
              </td>
              <td v-for="c in customColumns">
                <a v-if="!useProcessStepHeaders && c.name === 'Project Name'">
                  <v-btn text small
                         :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}/event/${item.projectProcessStepEventId}`">
                    {{ item['Project Name'] }}
                  </v-btn>
                </a>
                  <router-link v-else class="router-link-td elevation-0 square-card" :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}`">
                    {{ getColumnValue(item, c) }}
                  </router-link>
              </td>
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
                  <v-btn small fab text color="primary" @click="[item.showNotesModal = true, notesPpsIndex = index, ytfDoWeNeedThis++]">
                    <v-icon>mdi-comment-text-multiple</v-icon>
                  </v-btn>
                </div>
                <v-dialog
                  @click:outside="closeNotesModal()"
                  :key="ytfDoWeNeedThis"
                  v-model="item.showNotesModal"
                >
                  <v-card class="wqt-notes-container">
                    <v-card-title class="primary-custom-bg white--text">{{ item['Project Name'] }} -
                      {{ item['Process Step Name'] }}
                    </v-card-title>
                    <v-card-text class="py-3">
                      <v-toolbar color="transparent" class="elevation-0">
                        <v-toolbar-title>Notes</v-toolbar-title>
                      </v-toolbar>
                      <NotesAndActivityContent
                        :showNotes="true"
                        :showActivity="false"
                        :bordered="true"
                        :notes="item.notes"
                        :is-ps-wqt-note="!workQueue.useEventData"
                        :is-event-wqt-note="workQueue.useEventData"
                        :primary-id="workQueue.useEventData ? item.projectProcessStepEventId : item.projectProcessStepId"
                        :secondary-id="workQueue.useEventData ? item.processStepEventWorkQueueTypeId : item.processStepWorkQueueTypeId"
                        type="ProjectProcessStep"
                        :callback="(item) => updateRowNotes(item)"
                      />
                    </v-card-text>

                    <v-card-actions>
                      <v-spacer></v-spacer>

                      <v-btn
                        color="primary"
                        class="white--text mr-2 mb-3"
                        @click="[ytfDoWeNeedThis++, closeNotesModal()]"
                      >
                        Close
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>
        </v-data-table>

      </v-col>
    </v-row>

  </v-container>
</template>


<script>
import {AppMutations} from '@/stores/AppStore'
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
  getSnackbar,
  logError, getRequest
} from '@/helpers/helpers'

export default {
  name: 'WorkQueueDrilldown',
  components: {
    NotesAndActivityContent
  },
  data() {
    return {
      snackbar: {},
      showNotesModal: false,
      hideFutureFollowUps: false,
      hideFutureEvents: false,
      selectedPps: {},
      filters: {},
      notesPpsIndex: null, //this is used to know which row to update after a note is changed
      cachedFilters: {},
      constants,
      initialPageLoad: true,
      search: '',
      ytfDoWeNeedThis: 0,
      timezone: this.$store.state.user.details.timezone.value,
      userFullName: this.$store.state.user.details.fullName,
      showPropCustom: false,
      dataLoading: true,
      errorLoading: false,
      workQueue: {},
      workQueueTypeId: this.$route.params.id,
      userPositionId: this.$route.query.upId,
      smartlistId: this.$route.query.smartlistId,
      unassigned: this.$route.query.unassigned,
      installationCrewIds: this.$route.query.installationCrewIds,
      results: [],
      filteredResults: [],
      masterResults: [],
      customColumns: [],
      useProcessStepHeaders: false,
      queueHasNotes: false,
      queueHasOwningPositions: false,
      noResults: true,
      totalItems: 0,
      page: 1,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 1000],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        itemsPerPage: 100
      },
      userPositions: this.$store.state.user.details.userPositions,
      headers: [],
    }
  },
  watch: {
    //this is used if you are calling paginated results. which doesn't happen with smartlists, they just return the entire data set
    // options: {
    //   handler () {
    //     this.getWorkDetails()
    //   },
    //   deep: true,
    // },
    page() {
      let table = this.$refs['pageable-table'];
      let wrapper = table.$el.querySelector('div.v-data-table__wrapper');

      this.$vuetify.goTo(table); // to table
      this.$vuetify.goTo(table, {container: wrapper}); // to header
    }
  },
  computed: {},
  async created() {
    this.cachedFilters = JSON.parse(localStorage.getItem('wqDrilldownFilters')) || {}
    this.hideFutureFollowUps = JSON.parse(localStorage.getItem('hideFutureWqFollowUps')) || false
    this.hideFutureEvents = JSON.parse(localStorage.getItem('hideFutureWqEvents')) || false
    await this.getWorkQueueName()
    await this.getWorkDetails()
  },
  methods: {
    async getWorkQueueName () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/workQueueType/${this.workQueueTypeId}`)
        this.workQueue = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Results')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterFutureFollowUps() {
      localStorage.setItem('hideFutureWqFollowUps', JSON.stringify(this.hideFutureFollowUps))
      localStorage.setItem('hideFutureWqEvents', JSON.stringify(this.hideFutureEvents))
      //master results = all results loaded at start
      //filtered results = the filters from the column headers
      if (!this.workQueue.useEventData && this.hideFutureFollowUps) {
        this.results = this.filteredResults.filter(r => {
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
      } else if (this.workQueue.useEventData && (this.hideFutureEvents || this.hideFutureFollowUps)) {
        this.results = this.filteredResults.filter(r => {
          let noteFilter = true
          if(r.notes && r.notes.length > 0) {
            let firstNoteFollowUp = r.notes[0]?.followUpDate
            let noFollowUp = firstNoteFollowUp === null || firstNoteFollowUp === undefined
            //holy crap, why is this so hard.
            //just trying to compare a date in YYYY-MM-DD to now() was so stinking hard for me
            noteFilter = noFollowUp || (!noFollowUp && (moment().isAfter(moment.utc(firstNoteFollowUp, 'YYYY-MM-DD').format('YYYY-MM-DD'))))
          }

          return (!this.hideFutureFollowUps || (this.hideFutureFollowUps && noteFilter)) && (!this.hideFutureEvents || (this.hideFutureEvents && moment(r['Event Start Time'], 'MM/DD/YYYY hh:mm a').isBefore(moment())))
        })
      } else {
        console.log('non onono')
        this.results = cloneDeep(this.filteredResults)
      }
    },
    getColumnValue(item, c) {
        return item[c.name]
    },
    async exportCsv() {
      try {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data, status} = await getRequestWithParams(`/smartlist/${this.smartlistId}/csv`, {
          params: {
            timezone: this.timezone
          }
        })
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, `${this.workQueue.workQueueType} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        this.snackbar = getSnackbar('ERROR', e.message)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        logError(e)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterHeaders() {
      return this.headers.filter(header => header.show === true)
    },
    async getWorkDetails() {
      this.dataLoading = true
      this.errorLoading = false
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let path = ''
        if (typeof this.installationCrewIds !== 'undefined') {
          path = `/workQueue/${this.workQueueTypeId}/${this.installationCrewIds}`;
        } else {
          path = `/workQueue/${this.workQueueTypeId}`;
        }

        const {data, status} = await getRequestWithParams(path, {
          params: {
            smartlistId: this.smartlistId,
            userPositionId: this.userPositionId,
            unassigned: this.unassigned,
            timezone: this.timezone
            // page: page - 1,
            // size: itemsPerPage
          }
        })
        // this.results = data.content
        // this.totalItems = data.totalElements
        this.results = data?.data || []

        this.noResults = this.results?.length === 0
        this.useProcessStepHeaders = this.results?.length > 0 && 'Owning Positions' in this.results[0]


        //due to the way smartlist loads and exports arrays we have to parse these for use on the frontend
        //for PS both Notes and Owning positions should exist,
        //for PSE only notes will exist
        if(this.results?.length > 0 && 'Notes' in this.results[0]) {
          this.queueHasNotes = true
          this.results.forEach(r => {
            r.showNotesModal = false
            r.notes = JSON.parse(r['Notes'])
            r.followUpDate = null != r.notes[0]?.followUpDate && undefined !== r.notes[0]?.followUpDate ? moment.utc(r.notes[0]?.followUpDate, 'YYYY-MM-DD').format('M/D/YYYY') : null,
            r.firstNoteCreatedAt = r.notes[0]?.dateCreated,
            r.firstNoteCreatedAtFormatted = null != r.notes[0]?.dateCreated && undefined !== r.notes[0]?.dateCreated ? moment.utc(r.notes[0]?.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(this.timezone).format('M/D/YYYY h:mm a') : null,
            r.firstNoteContent = r.notes[0]?.note
            // r.activeProcessSteps = JSON.parse(r['Active Process Steps'])
            if('Owning Positions' in this.results[0]) {
              this.queueHasOwningPositions = true
              r.owningPositions = JSON.parse(r['Owning Positions'])
            }
          })
        }

        this.masterResults = cloneDeep(this.results)
        this.filteredResults = cloneDeep(this.results)
        if (this.useProcessStepHeaders) {
          this.headers = [
            {text: 'Project', value: 'Project Name', show: true},
            {text: 'Process Step', value: 'Process Step Name', show: true},
            {text: 'Status', value: 'Process Step Status Type', show: true},
            {text: 'Days In Queue', value: 'Days In Queue', show: true},
            {text: 'State', value: 'State Abbreviation', show: true},
            {text: 'Owner', value: 'Owner', show: true},
            {text: 'Active Process Steps', value: 'Active Process Steps', show: true},
          ]
        }

        this.customColumns = data?.headers || []
        this.customColumns.forEach(c => {
          this.headers.push({
            text: c.name,
            value: c.name,
            sort: (a, b) => {
              //if it is a date, format the string as a date and sort by that value
              //without the .toString() this fails for numeric values
              if ((null != a && a.toString().match(/^\d{4}-\d{2}-\d{2}/)) || (null != b && b.toString().match(/^\d{4}-\d{2}-\d{2}/))
                  || ((null != a && !isNaN(Date.parse(a)) || (null != b && !isNaN(Date.parse(b)))))) {
                //todo: keep an eye on if Date.parse returns false for regular numbers and such
                return new Date(a) - new Date(b)
              } else {
                //otherwise sort normally
                if (typeof a === 'number' || typeof b === 'number') {
                  return (a === null) - (b === null) || a - b
                } else {
                  return null != a ? a.localeCompare(b) : a - b
                }
              }
            },
            show: true
          })
        })
        if (this.queueHasNotes) {

          //add the notes column to the end
          this.headers.push({
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
          this.headers.push({
            text: 'Next Follow-up Date',
            value: 'followUpDate',
            sort: (a, b) => {
              // return (a.length === 0 || a[0]?.followUpDate === null) - (b.length === 0 || b[0]?.followUpDate === null) || new Date(a[0]?.followUpDate) - new Date(b[0]?.followUpDate)
              return new Date(a) - new Date(b)
            },
            show: true
          })
          this.headers.push({text: 'Note Content', value: 'firstNoteContent', sortable: true, show: true, width: 250})
        }

        //check for a cached search and filter results accordingly
        if (this.cachedFilters[this.workQueueTypeId]) {
          Object.keys(this.cachedFilters[this.workQueueTypeId]).forEach(key => {
            this.filters[key] = this.cachedFilters[this.workQueueTypeId][key]
          })
          this.filterResults()
        }

        if (this.hideFutureFollowUps || this.hideFutureEvents) {
          this.filterFutureFollowUps()
        }

        this.dataLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.dataLoading = false
        this.errorLoading = true
        let msg = e?.data?.message || 'Error Retrieving Results'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignToUser(item) {
      try {
        let userPosition = this.userPositions.find(up => up.canAssign)
        const {status} = await postRequest(`/projectProcessStep/${item.projectProcessStepId}/owner/checkExisting`, {userPositionId: userPosition.id})
        item['Owner'] = this.userFullName
        this.snackbar = getSnackbar('SUCCESS', 'You are now assigned as the owner.')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        item.owner = this.$store.state.user.details.fullName
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let alreadyAssigned = e.data.includes('already assigned')
        let msg = alreadyAssigned ? e.data : 'Error Saving Owner'
        if (alreadyAssigned) {
          item['Owner'] = 'Already Assigned. Please Refresh.'
        }
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    userCanOwnProcessStep(item) {
      let canAssign = false
      item.owningPositions?.forEach(op => {
        let positionMatch = this.userPositions.find(up => up.positionId === op.positionId)
        if (positionMatch !== null && positionMatch !== undefined) {
          canAssign = true
          this.userPositions.find(up => up.positionId === op.positionId).canAssign = true
        }
      })
      return canAssign
    },
    clickRow(row) {
      this.$router.push({path: `/project/${row.projectId}/processStep/${row.projectProcessStepId}`})
    },
    filterResults() {
      this.results = this.masterResults.filter(r => {
        let matchCount = 0
        let numFiltersUsed = 0
        Object.keys(this.filters).forEach(key => {
          //trim the value to see if they just searched for a bunch of space characters
          let value = this.filters[key].trim().length === 0 ? '' : this.filters[key]

          //populate the cached filters with the user's search
          //if there is no cached search for this wqt then add a blank object for it
          if (null == this.cachedFilters[this.workQueueTypeId]) {
            this.cachedFilters[this.workQueueTypeId] = {}
          }

          //then add the value
          this.cachedFilters[this.workQueueTypeId][key] = value

          if (null != value && value !== '') {
            numFiltersUsed++
            if (r[key]?.toString().toLowerCase().includes(value?.toLowerCase())) {
              matchCount++
            }
          }
        })
        localStorage.setItem('wqDrilldownFilters', JSON.stringify(this.cachedFilters))
        return matchCount === numFiltersUsed
      })
      //we populate this so that if they hide/unhide future after doing some filtering we can get back to the filtered state
      this.filteredResults = cloneDeep(this.results)
    },
    updateRowNotes(item) {
      //have to set the matching value in filteredResults...cuz we do and it is dumb
      let matchInFilteredResults = this.filteredResults.find(fr => fr.projectProcessStepEventId === this.results[this.notesPpsIndex].projectProcessStepEventId && fr.processStepEventWorkQueueTypeId === this.results[this.notesPpsIndex].processStepEventWorkQueueTypeId)

      let followUpDate = null != item.followUpDate ? moment.utc(item.followUpDate, 'YYYY-MM-DD').format('M/D/YYYY') : null
      this.results[this.notesPpsIndex].followUpDate = followUpDate
      matchInFilteredResults.followUpDate = followUpDate

      this.results[this.notesPpsIndex].firstNoteCreatedAt = item.dateCreated
      matchInFilteredResults.firstNoteCreatedAt = item.dateCreated

      let dateFormatted = null != item.dateCreated ? moment.utc(item.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(this.timezone).format('M/D/YYYY h:mm a') : null
      this.results[this.notesPpsIndex].firstNoteCreatedAtFormatted = dateFormatted
      matchInFilteredResults.firstNoteCreatedAtFormatted = dateFormatted

      this.results[this.notesPpsIndex].firstNoteContent = item.note
      matchInFilteredResults.firstNoteContent = item.note

      //also re-populate the entire notes array
      matchInFilteredResults.notes = this.results[this.notesPpsIndex].notes

    },
    closeNotesModal() {
      //this is dumb.  if you update the results before the modal closes things get weird
      //if you update after then you have to catch all the ways that the modal can close
      this.results[this.notesPpsIndex].showNotesModal = false
      if(this.hideFutureFollowUps) {
        this.filterFutureFollowUps()
      }
    }
  },

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

#wq-drilldown-table .v-data-table-header th {
  white-space: nowrap;
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

.wqt-notes-container {
  min-height: 400px;
}

.active-ps-container {
  list-style-type: none;
  padding-left: 0;
}

</style>
