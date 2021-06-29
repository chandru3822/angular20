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
            <v-btn text @click="exportCsv" v-if="results.length > 0">
              <v-icon class="mr-2">mdi-cloud-download</v-icon>
              Export
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-text-field
          v-model="search"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-data-table
            :headers="filterHeaders()"
            :items="results"
            :search="search"
            :fixed-header="true"
            :loading="dataLoading"
            :options.sync="options"
            :footer-props="footerProps"
            class="elevation-1 mt-1"
            @click:row="clickRow"
        >
          <template #no-data>
            No available results
          </template>

          <template #no-results>
            No available results
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
              <td class="text-left" v-if="[98,99,106].includes(parseInt(workQueueTypeId))">{{item['Proposal Due Date']  | formatDate('timestamp')}}</td>
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
                {{item[c.name]}}
              </td>
              <td class="notes-column">
                <div class="flex-display align-center" >
                  <pre class="app-pre-wrapper"  v-if="item.notes && item.notes.length > 0">
                     {{item.notes[0].note}}
                  </pre>
                  <v-spacer></v-spacer>
                  <v-btn small fab text @click="[item.showNotesModal = true, ytfDoWeNeedThis++]">
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
  import constants from '@/helpers/constants'
  import {
    getRequest,
    getRequestWithParams,
    deleteRequest,
    putRequest,
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
        selectedPps: {},
        constants,
        search: '',
        ytfDoWeNeedThis: 0,
        showPropCustom: false,
        dataLoading: true,
        workQueueTypeId: this.$route.params.id,
        userPositionId: this.$route.query.upId,
        smartlistId: this.$route.query.smartlistId,
        unassigned: this.$route.query.unassigned,
        results: [],
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
          { text: 'Proposal Due Date', value: 'proposalDueDate', show: [98,99,106].includes(parseInt(this.$route.params.id)), width: 175 },
          { text: 'Owner', value: 'Owner', show: true },
          { text: 'Active Process Steps', value: 'activeProcessSteps', show: true },
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
      await this.getWorkDetails()
    },
    methods: {
      async exportCsv () {
        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data} = await getRequest(`/smartlist/${this.smartlistId}/csv`)
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { page, itemsPerPage } = this.options
        try {
          const {data} = await getRequestWithParams(`/workQueue/${this.workQueueTypeId}`, { params: {
              smartlistId: this.smartlistId,
              userPositionId: this.userPositionId,
              unassigned: this.unassigned,
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
            // r.activeProcessSteps = JSON.parse(r['Active Process Steps'])
            r.owningPositions = JSON.parse(r['Owning Positions'])
          })

          this.customColumns = data.headers
          this.customColumns.forEach(c => {
            this.headers.push( { text: c.name, value: c.name, show: true })
          })
          //add the notes column to the end
          this.headers.push({ text: 'Notes', value: 'notes', show: true, width: 250 })
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Results')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignToUser(item) {
        try {
          let userPosition = this.userPositions.find(up => up.canAssign)
          await postRequest(`/projectProcessStep/${item.projectProcessStepId}/owner/checkExisting`, {userPositionId: userPosition.id})
          this.snackbar = getSnackbar('SUCCESS', 'You are now assigned as the owner.')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          item.owner = this.$store.state.user.details.fullName
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = e.data.includes('already assigned') ? e.data : 'Error Saving Owner'
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
      }
    },

  }
</script>

<style lang="scss">
  #work-queue-drilldown-container .v-data-table__wrapper {
    height: calc(100vh - 200px);
    min-height: 300px;
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
