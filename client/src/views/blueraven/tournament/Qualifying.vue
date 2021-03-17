<template>
  <v-container id="pool-container">

    <v-toolbar flat class="app-toolbar">
      Qualifying Pool <br/>
      {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
    </v-toolbar>

    <v-data-table
      :headers="headers"
      :items="poolUsers"
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
    </v-data-table>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'Qualifying',
    data() {
      return {
        constants,
        snackbar: {},
        tournamentId: this.$route.params.id,
        poolTypeId: 1,
        pool: {},
        poolUsers: [],
        headers: [
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
      async getPool () {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/byType/${this.poolTypeId}`, 'blueraven')
          this.pool = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getPoolUsers () {
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
  #pool-container .v-data-table__wrapper {
    height: calc(100vh - 250px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>

</style>

