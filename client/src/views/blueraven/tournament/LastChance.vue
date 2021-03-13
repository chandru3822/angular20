<template>
  <v-container>

    <v-toolbar flat class="app-toolbar">
      Last Chance Pool <br/>
      {{pool.startDate | formatDate('date', 'M/D/YYYY')}} - {{pool.endDate | formatDate('date', 'M/D/YYYY')}}
    </v-toolbar>

    <v-data-table
      :headers="headers"
      :items="pool.users"
      hide-default-footer
      :items-per-page="-1"
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
    name: 'LastChance',
    data() {
      return {
        constants,
        snackbar: {},
        tournamentId: this.$route.params.id,
        pool: {},
        headers: [
          { text: 'User', value: 'fullName', show: true },
          { text: 'Score', value: 'score', show: true },
        ],
      }
    },
    async created () {
      this.getPool()
    },
    methods: {
      async getPool () {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/pool/lastChance`, 'blueraven')
          this.pool = data
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching pool details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

