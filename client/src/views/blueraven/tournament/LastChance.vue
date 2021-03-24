<template>
  <v-container id="last-chance-pool-container">
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
        <template #item="{ item, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td :key="selectRerender">
              <input type="checkbox" v-if="!item.qualified" v-model="item.selected" @change="toggleSingleSelect(item)">
              <v-icon v-else color="green" size="15">mdi-check-decagram</v-icon>
            </td>
            <td class="text-left">
              {{item.fullName}}
            </td>
            <td>{{item.score || 0}}</td>
          </tr>
        </template>
      </v-data-table>
    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'LastChance',
    data() {
      return {
        constants,
        snackbar: {},
        poolTypeId: 2,
        search: '',
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
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.dataLoading = false
          this.pool = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          await postRequest(`/tournament/${this.tournamentId}/pool/${this.pool.id}/advanceUsersToWinnerPool`, this.selectedUsers, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Selected Users Advanced')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'tournamentWinners', params: { id: this.tournamentId }})
          this.$store.commit(AppMutations.SET_LOADING, false)
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
    height: calc(100vh - 300px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>

</style>

