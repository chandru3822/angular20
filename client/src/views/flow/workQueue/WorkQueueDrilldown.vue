<template>
  <v-container id="work-queue-drilldown-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-btn text small :to="`/workQueue`" class="mr-3" color="primaryCustom">
            <v-icon>mdi-arrow-left</v-icon>
          </v-btn>
          <v-toolbar-title class="app-title" v-if="results.length > 0">{{results[0].workQueueType}}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-switch
              v-if="results.length > 0"
              v-model="hideFutureFollowUps"
              class="mx-2 mt-5 wq-follow-up-switch"
              label="Hide work with a next follow-up date in the future"
              @change="filterFutureFollowUps()"
            />
            <v-btn text @click="exportCsv" v-if="results.length > 0">
              <v-icon class="mr-2">mdi-cloud-download</v-icon>
              Export
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-data-table
            :headers="filterHeaders()"
            :items="results"
            :fixed-header="true"
            :loading="dataLoading"
            :options.sync="options"
            :footer-props="footerProps"
            class="elevation-1 mt-1"
            id="wq-drilldown-table"
            @click:row="clickRow"
        >
          <template #no-data>
            No available results
          </template>

          <template #no-results>
            No available results
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
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left underline">
                <v-btn text small :to="`/project/${item.projectId}/processStep/${item.projectProcessStepId}?processStepId=${item.processStepId}&contactId=${item.contactId}`">
                  {{item['Project Name']}}
                </v-btn>
              </td>
              <td class="text-left">{{item['Process Step Name']}}</td>
              <td class="text-left">{{item['Process Step Status Type']}}</td>
              <td class="text-left">{{item['Days In Queue']}}</td>
              <td class="text-left">{{item['State Abbreviation']}}</td>
              <td class="text-left">
                <div v-if="item['Owner']">{{item['Owner']}}</div>
                <v-btn v-else-if="userCanOwnProcessStep(item)">
                  <a @click="assignToUser(item)">Assign to me</a>
                </v-btn>
              </td>
              <td class="text-left">
                {{item['Active Process Steps']}}
              </td>
              <td v-for="c in customColumns">
                {{ getColumnValue(item, c)}}
              </td>
              <td class="note-created-at">
                {{item.firstNoteCreatedAt | formatDate('timestamp')}}
              </td>
              <td class="notes-follow-up">
                  {{item.followUpDate | formatDate('date')}}
              </td>
              <td class="notes-column">
                <div class="flex-display align-center" >
                  <pre class="app-pre-wrapper">
                     {{item.firstNoteContent}}
                  </pre>
                  <v-spacer></v-spacer>
                  {{item.id}}
                  <v-btn small fab text @click="[item.showNotesModal = true, notesPpsIndex = index, ytfDoWeNeedThis++]">
                    <v-icon>mdi-comment-text-multiple</v-icon>
                  </v-btn>
                </div>
                <v-dialog
                  :key="ytfDoWeNeedThis"
                  v-model="item.showNotesModal"
                >
                  <v-card class="wqt-notes-container">
                    <v-card-title class="primary-custom-bg white--text">{{ item['Project Name'] }} - {{item['Process Step Name']}}</v-card-title>
                    <v-card-text class="py-3">
                      <NotesAndActivity
                        :showNotes="true"
                        :showActivity="false"
                        :notes="item.notes"
                        :is-wqt-note="true"
                        :primary-id="item.projectProcessStepId"
                        :secondary-id="item.processStepWorkQueueTypeId"
                        type="ProjectProcessStep"
                        :callback="(item) => updateRowNotes(item)"

                      />
                    </v-card-text>

                    <v-card-actions>
                      <v-spacer></v-spacer>

                      <v-btn
                        color="primaryCustom"
                        class="white--text mr-2 mb-3"
                        @click="[item.showNotesModal = false, ytfDoWeNeedThis++]"
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
  import { saveAs } from 'file-saver'
  import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
  import {DateTime} from 'luxon'
  import cloneDeep from 'lodash.clonedeep'
  import constants from '@/helpers/constants'
  import moment from 'moment'

  import {
    getRequestWithParams,
    postRequest,
    getSnackbar,
    logError
  } from '@/helpers/helpers'

  export default {
    name: 'WorkQueueDrilldown',
    components: {
      NotesAndActivity
    },
    data() {
      return {
        snackbar: {},
        showNotesModal: false,
        hideFutureFollowUps: false,
        selectedPps: {},
        filters: {},
        notesPpsIndex: null, //this is used to know which row to update after a note is changed
        cachedFilters: {},
        constants,
        search: '',
        ytfDoWeNeedThis: 0,
        timezone: this.$store.state.user.details.timezone.value,
        userFullName: this.$store.state.user.details.fullName,
        showPropCustom: false,
        dataLoading: true,
        workQueueTypeId: this.$route.params.id,
        userPositionId: this.$route.query.upId,
        smartlistId: this.$route.query.smartlistId,
        unassigned: this.$route.query.unassigned,
        installationCrewIds: this.$route.query.installationCrewIds,
        results: [],
        filteredResults: [],
        masterResults: [],
        customColumns: [],
        totalItems: 0,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000],
          'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        options: {
          itemsPerPage: 100
        },
        userPositions: this.$store.state.user.details.userPositions,
        headers: [
          { text: 'Project', value: 'Project Name', show: true },
          { text: 'Process Step', value: 'Process Step Name', show: true },
          { text: 'Status', value: 'Process Step Status Type', show: true },
          { text: 'Days In Queue', value: 'Days In Queue', show: true },
          { text: 'State', value: 'State Abbreviation', show: true },
          { text: 'Owner', value: 'Owner', show: true },
          { text: 'Active Process Steps', value: 'Active Process Steps', show: true },
        ],
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
    },
    computed: {},
    async created() {
      this.cachedFilters = JSON.parse(localStorage.getItem('wqDrilldownFilters')) || {}
      this.hideFutureFollowUps = JSON.parse(localStorage.getItem('hideFutureWqDrilldownFollowUps')) || false
      await this.getWorkDetails()
    },
    methods: {
      filterFutureFollowUps() {
        localStorage.setItem('hideFutureWqDrilldownFollowUps', JSON.stringify(this.hideFutureFollowUps))
        if(this.hideFutureFollowUps) {
          this.filteredResults = cloneDeep(this.results)
          this.results = this.results.filter(r => {
            let firstNoteFollowUp = r.notes[0]?.followUpDate
            return firstNoteFollowUp === null || firstNoteFollowUp === undefined || new Date(firstNoteFollowUp) <= new Date()
          })
        } else {
          this.results = cloneDeep(this.filteredResults)
        }
      },
      getColumnValue (item, c) {
        if(c.processStepName == null) {
          return item[c.name]
        } else {
          let columnName = c.processStepName + ' - ' + c.name
          return item[columnName.substring(0,63)]
        }
      },
      async exportCsv () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequestWithParams(`/smartlist/${this.smartlistId}/csv`, { params: {
              timezone: this.timezone
            }})
          let blob = new Blob([data], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, `${this.results[0].workQueueType} ${DateTime.local().toFormat('yyyy-MM-dd h_mm a')}.csv`);
        } catch (e) {
          this.snackbar = getSnackbar('ERROR', e.message)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          logError(e)
        } finally {
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      async getWorkDetails() {
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { page, itemsPerPage } = this.options
        try {
          let path = ''
          if (typeof this.installationCrewIds !== 'undefined') {
            path = `/workQueue/${this.workQueueTypeId}/${this.installationCrewIds}`;
          }
          else {
            path = `/workQueue/${this.workQueueTypeId}`;
          }

          const {data} = await getRequestWithParams(path, { params: {
              smartlistId: this.smartlistId,
              userPositionId: this.userPositionId,
              unassigned: this.unassigned,
              timezone: this.timezone
              // page: page - 1,
              // size: itemsPerPage
            }})
          // this.results = data.content
          // this.totalItems = data.totalElements
          this.results = data.data

          //due to the way smartlist loads and exports arrays we have to parse these for use on the frontend
          this.results.forEach(r => {
            r.showNotesModal = false
            r.notes = JSON.parse(r['Notes'])
            r.followUpDate = null != r.notes[0]?.followUpDate && undefined !== r.notes[0]?.followUpDate ? moment.utc(r.notes[0]?.followUpDate, 'YYYY-MM-DD').format('MM/DD/YYYY') : null,
            r.firstNoteCreatedAt = r.notes[0]?.dateCreated,
            r.firstNoteCreatedAtFormatted = null != r.notes[0]?.dateCreated && undefined !== r.notes[0]?.dateCreated ? moment.utc(r.notes[0]?.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(this.timezone).format('MM/DD/YYYY h:mm a') : null,
            r.firstNoteContent = r.notes[0]?.note,
            // r.activeProcessSteps = JSON.parse(r['Active Process Steps'])
            r.owningPositions = JSON.parse(r['Owning Positions'])
          })

          this.masterResults = cloneDeep(this.results)

          if(this.hideFutureFollowUps) {
            this.filterFutureFollowUps()
          }

          this.customColumns = data.headers
          this.customColumns.forEach(c => {
            let textValue = c.processStepName == null ? c.name : c.processStepName + ' - ' + c.name
            this.headers.push( {
              // text: textValue,
              text: textValue,
              value: textValue.substring(0,63),
              sort: (a, b) => {
                //if it is a date, format the string as a date and sort by that value
                //without the .toString() this fails for numeric values
                if((null != a && a.toString().match(/^\d{4}-\d{2}-\d{2}/)) || (null != b && b.toString().match(/^\d{4}-\d{2}-\d{2}/))) {
                  return new Date(a) - new Date(b)
                } else {
                  //otherwise sort normally
                  if(typeof a === 'number' || typeof b === 'number') {
                    return (a === null) - (b === null) || a - b
                  } else {
                    return null != a ? a.localeCompare(b) : a - b
                  }
                }
              },
              show: true })
          })
          //add the notes column to the end
          this.headers.push({
            text: 'Note Created At',
            value: 'firstNoteCreatedAtFormatted',
            width: 200,
            sort: (a,b) => {
              // return (a.length === 0 || a[0]?.followUpDate === null) - (b.length === 0 || b[0]?.followUpDate === null) || new Date(a[0]?.followUpDate) - new Date(b[0]?.followUpDate)
              // return new Date(a) - new Date(b)
              if(null != a || null != b) {
                return new Date(a) - new Date(b)
              } else {
                return (a === null) - (b === null) || a - b
              }
            },
            show: true })
          this.headers.push({
            text: 'Next Follow-up Date',
            value: 'followUpDate',
            sort: (a,b) => {
              // return (a.length === 0 || a[0]?.followUpDate === null) - (b.length === 0 || b[0]?.followUpDate === null) || new Date(a[0]?.followUpDate) - new Date(b[0]?.followUpDate)
              return new Date(a) - new Date(b)
            },
            show: true })
          this.headers.push({ text: 'Note Content', value: 'firstNoteContent', sortable: true, show: true, width: 250 })

          //check for a cached search and filter results accordingly
          if(this.cachedFilters[this.workQueueTypeId]) {
            Object.keys(this.cachedFilters[this.workQueueTypeId]).forEach(key => {
              this.filters[key] = this.cachedFilters[this.workQueueTypeId][key]
            })
            this.filterResults()
          }

          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.dataLoading = false
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Results')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignToUser(item) {
        try {
          let userPosition = this.userPositions.find(up => up.canAssign)
          await postRequest(`/projectProcessStep/${item.projectProcessStepId}/owner/checkExisting`, {userPositionId: userPosition.id})
          item['Owner'] = this.userFullName
          this.snackbar = getSnackbar('SUCCESS', 'You are now assigned as the owner.')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          item.owner = this.$store.state.user.details.fullName
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let alreadyAssigned = e.data.includes('already assigned')
          let msg = alreadyAssigned ? e.data : 'Error Saving Owner'
          if(alreadyAssigned) {
            item['Owner'] = 'Already Assigned. Please Refresh.'
          }
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      userCanOwnProcessStep(item) {
        let canAssign = false
        item.owningPositions.forEach(op => {
          let positionMatch = this.userPositions.find(up => up.positionId === op.positionId)
          if(positionMatch !== null && positionMatch !== undefined) {
            canAssign = true
            this.userPositions.find(up => up.positionId === op.positionId).canAssign = true
          }
        })
        return canAssign
      },
      clickRow(row) {
        this.$router.push({path: `/project/${row.projectId}/processStep/${row.projectProcessStepId}?processStepId=${row.processStepId}&contactId=${row.contactId}`})
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
            if(null == this.cachedFilters[this.workQueueTypeId]) {
              this.cachedFilters[this.workQueueTypeId] = {}
            }

            //then add the value
            this.cachedFilters[this.workQueueTypeId][key] = value

            if(null != value && value !== '') {
              numFiltersUsed++
              if(r[key]?.toString().toLowerCase().includes(value?.toLowerCase())){
                matchCount++
              }
            }
          })
          localStorage.setItem('wqDrilldownFilters', JSON.stringify(this.cachedFilters))
          return matchCount === numFiltersUsed
        })
      },
      updateRowNotes(item) {
        this.results[this.notesPpsIndex].followUpDate = null != item.followUpDate ? moment.utc(item.followUpDate, 'YYYY-MM-DD').format('MM/DD/YYYY') : null
        this.results[this.notesPpsIndex].firstNoteCreatedAt = item.dateCreated
        this.results[this.notesPpsIndex].firstNoteCreatedAtFormatted = null != item.dateCreated ? moment.utc(item.dateCreated, 'YYYY-MM-DDTHH:mm:ssZ').tz(this.timezone).format('MM/DD/YYYY h:mm a') : null
        this.results[this.notesPpsIndex].firstNoteContent = item.note
      }
    },

  }
</script>

<style lang="scss">
  #work-queue-drilldown-container .v-data-table__wrapper {
    height: calc(100vh - 200px);
    min-height: 300px;
  }

  #wq-drilldown-table  .v-data-table-header {
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
  /*border-radius: 4px 0 0 4px !important;*/
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
