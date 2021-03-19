<template>
  <v-container id="pool-container">

    <v-toolbar flat class="app-toolbar">
      Last Chance Pool <br/>
      {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn v-if="userCanEdit && !dataLoading && selectedUsers.length > 0"
               color="primary" class="white--text" @click="moveUsersToWinnersPool()">
          <span>Advance Users To Winner Pool</span>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-data-table
      :headers="headers"
      :items="pool.users"
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
        dataLoading: true,
        selectRerender: 1,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('TOURNAMENTS', 'EDIT'),
        tournamentId: this.$route.params.id,
        pool: {},
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
    }
  }
</script>

<style lang="scss">
  #pool-container .v-data-table__wrapper {
    height: calc(100vh - 250px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>

</style>

