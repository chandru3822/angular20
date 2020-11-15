<template>
  <v-container id="work-queue-drilldown-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-btn text small :to="`/workQueue`" class="mr-3" color="primaryCustom">
            <v-icon>mdi-arrow-left</v-icon>
          </v-btn>
          <v-toolbar-title class="app-title" v-if="results.length > 0">{{results[0].workQueueType}}</v-toolbar-title>
        </v-toolbar>
        <v-data-table
            :headers="headers"
            :items="results"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            :options.sync="options"
            :server-items-length="totalItems"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left underline" @click="clickRow(item)">{{item.projectName}}</td>
              <td class="text-left">{{item.processStepName}}</td>
              <td class="text-left">{{item.daysInQueue}}</td>
              <td class="text-left">{{item.stateAbbreviation}}</td>
              <td class="text-left">
                <div v-if="item.owner">{{item.owner}}</div>
                <v-btn v-else-if="userCanOwnProcessStep(item)">
                  <a @click="assignToUser(item)">Assign to me</a>
                </v-btn>
              </td>
              <td class="text-left">
                <div v-for="aps in item.activeProcessSteps">
                  {{ aps.processStepName }}
                </div>
              </td>
              <td class="notes-column">
                <div class="flex-display align-center" >
                  <pre class="app-pre-wrapper"  v-if="item.notes && item.notes.length > 0">
                    {{item.notes[0].note}}
                  </pre>
                  <v-spacer></v-spacer>
                  <v-btn small fab text @click="item.showNotesModal = true">
                    <v-icon>mdi-comment-text-multiple</v-icon>
                  </v-btn>
                </div>
                <v-dialog
                  v-model="item.showNotesModal"
                >
                  <v-card class="wqt-notes-container">
                    <v-card-title class="primary-custom-bg white--text">{{ item.projectName }} - {{item.processStepName}}</v-card-title>
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
                        @click="item.showNotesModal = false"
                      >
                        Close
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
              <td class="text-left" v-if="showPropCustom">{{item.proposalDueDate  | formatDate('timestamp')}}</td>
            </tr>
          </template>
        </v-data-table>

      </v-col>
    </v-row>

  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'

  import NotesAndActivity from '@/views/flow/components/NotesAndActivity'
  import constants from '@/helpers/constants'
  import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

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
        showPropCustom: false,
        dataLoading: true,
        workQueueTypeId: this.$route.params.id,
        userPositionId: this.$route.query.upId,
        unassigned: this.$route.query.unassigned,
        results: [],
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
          { text: 'Project', value: 'projectName', show: true },
          { text: 'Process Step', value: 'processStepName', show: true },
          { text: 'Days In Queue', value: 'daysInQueue', show: true },
          { text: 'State', value: 'stateAbbreviation', show: true },
          { text: 'Owner', value: 'owner', show: true },
          { text: 'Active Process Steps', value: 'activeProcessSteps', show: true },
          { text: 'Notes', value: 'notes', show: true },
        ],
      }
    },
    watch: {
      options: {
        handler () {
          this.getWorkDetails()
        },
        deep: true,
      },
    },
    computed: {},
    async created() {
      if([98,99,106].includes(parseInt(this.workQueueTypeId))){
        console.log('high')
        this.showPropCustom = true
        this.headers.push({ text: 'Proposal Due Date', value: 'proposalDueDate', show: true },)
      }
    },
    methods: {
      async getWorkDetails() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const { page, itemsPerPage } = this.options
        try {
          const {data} = await getRequestWithParams(`/workQueue/${this.workQueueTypeId}`, { params: {
              userPositionId: this.userPositionId,
              unassigned: this.unassigned,
              page: page - 1,
              size: itemsPerPage
            }})
          this.results = data.content
          this.totalItems = data.totalElements
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
        item?.owningPositions?.forEach(op => {
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
</style>
