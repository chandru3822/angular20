<template>
  <v-container id="last-chance-pool-container">
    <v-dialog v-model="showModal" class="square-card">
      <ScoreDrilldown :tournament-id="parseInt(tournamentId)"
                      :start-date="pool.startDate"
                      :end-date="pool.endDate"
                      :user="showScoreUser.fullName"
                      :user-id="showScoreUser.userId"
                      @scoreDialogClosed="showModal = false"
      />
    </v-dialog>

    <v-card color="white" flat class="square-card">
      <v-toolbar flat class="app-toolbar">
        {{pool.customName || 'Last Chance'}} <br/>
        {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn v-if="userCanEdit && !dataLoading && selectedUsers.length > 0"
                 color="primary" class="white--text" @click="moveUsersToWinnersPool()">
            <span>Advance Users To Next Round</span>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-text-field
        v-model="search"
        class="mb-2 px-4 py-2"
        prepend-inner-icon="search"
        label="Search"
        single-line
        hide-details
      ></v-text-field>
      <v-divider></v-divider>
      <v-data-table
        :headers="headers"
        :items="poolUsers"
        :search="search"
        :fixed-header="true"
        :items-per-page="100"
        disable-sort
        class="elevation-1 square-card"
      >
        <template #no-data>
          No available users
        </template>

        <template #no-results>
          No available users
        </template>

        <template #header.score="{ header }">
          <div class="text-center">
            {{header.text}}
          </div>
        </template>

        <template #item="{ item, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td :key="selectRerender">
              <input type="checkbox" v-if="!item.qualified" v-model="item.selected" @change="toggleSingleSelect(item)">
              <v-icon v-else color="green" size="15">mdi-check-decagram</v-icon>
            </td>
            <td class="text-left">
              {{item.fullName}}
            </td>
            <td class="text-center">
              <span v-if="item.score == null">--</span>
              <span v-else>{{item.score}}</span>
            </td>
            <td class="text-right">
              <v-btn text small color="primary" class="clickable" @click="[showModal = true, showScoreUser = item]">
                <v-icon>mdi-format-list-bulleted</v-icon>
              </v-btn>
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, logError, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import ScoreDrilldown from "./component/ScoreDrilldown"

  export default {
    name: 'LastChance',
    components: {
      ScoreDrilldown
    },
    data() {
      return {
        constants,
        snackbar: {},
        poolTypeId: 2,
        search: '',
        showScoreUser: {},
        showModal: false,
        dataLoading: true,
        selectRerender: 1,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        tournamentId: this.$route.params.id,
        pool: {},
        poolUsers: [],
        selectedUsers: [],
        headers: [
          { text: '', value: 'checkbox', show: true, width: '50px' },
          { text: 'User', value: 'fullName', show: true },
          { text: 'Score', value: 'score', show: true },
          {text: '', value: 'details', show: true},
        ],
      }
    },
    async created () {
      this.getPool()
      this.getPoolUsers()
    },
    methods: {
      toggleSingleSelect(item) {
        if (item.selected) {
          this.selectedUsers.push(item.userId)
        } else {
          this.selectedUsers = this.selectedUsers.filter(u => u !== item.userId)
        }
      },
      async getPool () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data, status} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.dataLoading = false
          this.pool = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async moveUsersToWinnersPool () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/advanceUsersToWinnerPool`, this.selectedUsers, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Selected Users Advanced')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'tournamentWinners', params: { id: this.tournamentId }})
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Advancing Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPoolUsers() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/usersByType/${this.poolTypeId}`, 'blueraven')
          this.poolUsers = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool user details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
    }
  }
</script>

<style lang="scss">
  #last-chance-pool-container .v-data-table__wrapper {
    max-height: calc(100vh - 375px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
#last-chance-pool-container {
  padding: 50px;
}
</style>

