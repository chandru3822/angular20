<template>
  <v-card id="score-drilldown" class="square-card" v-if="!headersLoading">
    <v-data-table
      :headers="headers"
      :items="results"
      :fixed-header="true"
      :items-per-page="-1"
      single-expand
      :loading="resultsLoading"
      :mobile-breakpoint="0"
      hide-default-header
      hide-default-footer
      class="elevation-1 org-type-table"
    >
      <template #no-data>
        NO RESULTS
      </template>

      <template #header="{ props: { headers } }">
        <thead class="v-data-table-header">
          <tr>
            <th v-for="(header, idx) in headers" :key="idx" class="py-2">
              {{ header }}
            </th>
          </tr>
        </thead>
      </template>

      <template #no-results>
        NO RESULTS
      </template>

      <template #item="{ item, index }">
        <tr class="text-left" :class="{'shaded-row': index % 2}">
          <td class="text-left" v-for="[key, value] in Object.entries(item)">{{ value }}</td>
        </tr>
      </template>

    </v-data-table>
  </v-card>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getRequestWithParams} from "@/helpers/helpers";

  export default {
    name: 'ScoreDrilldown',
    props: {
      tournamentId: Number,
      userId: Number,
      startDate: String,
      endDate: String,
    },
    data() {
      return {
        constants,
        snackbar: {},
        results: [],
        headers: [],
        headersLoading: true,
        resultsLoading: true,
      }
    },
    async created() {
      this.getResults()
      await this.getHeaders()
      this.dataLoading = false
    },
    methods: {
      async getHeaders() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/headers`, 'blueraven')
          this.headers = data.headers
          this.headersLoading = false
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching headers')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getResults() {
        try {
          let params = {
            startDate: this.startDate,
            endDate: this.endDate,
            userId: this.userId
          }
          const {data} = await getRequestWithParams(`/tournament/${this.tournamentId}/scores`, { params }, 'blueraven')
          this.results = data
          this.resultsLoading = false
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching scores')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
    }
  }
</script>

<style lang="scss">
  #score-drilldown .v-data-table__wrapper {
    height: calc(100vh - 250px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>

</style>

