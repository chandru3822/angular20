<template>
  <v-card id="score-drilldown" class="square-card" v-if="!columnsLoading">
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">
        {{user}}
        <div class="toolbar-subtitle">{{startDate | formatDate('date', 'M/D/YYYY')}} - {{ endDate | formatDate('date', 'M/D/YYYY')}}</div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="$emit('scoreDialogClosed')">
          Close
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-data-table
      :headers="columns"
      :items="results"
      :fixed-header="true"
      :items-per-page="-1"
      single-expand
      :loading="resultsLoading"
      :mobile-breakpoint="0"
      hide-default-header
      hide-default-footer
      class="elevation-0"
    >
      <template #no-data>
        NO RESULTS
      </template>

      <template #header="{ props: { headers } }">
        <thead class="v-data-table-header">
          <tr>
            <th v-for="(column, idx) in headers" :key="idx" class="py-2">
              {{ column.header }}
            </th>
          </tr>
        </thead>
      </template>

      <template #no-results>
        NO RESULTS
      </template>

      <template #item="{ item, index }">
        <tr class="text-left" :class="{'shaded-row': index % 2}">
          <td class="text-left" v-for="([key, value], idx) in Object.entries(item)">
            <span v-if="columns[idx].dataTypeId === 1">{{ value | formatDate('date', 'M/D/YYYY')}}</span>
            <span v-else-if="columns[idx].dataTypeId === 2">{{ value | formatDate('timestamp', 'M/D/YYYY h:mm a')}}</span>
            <span v-else>{{ value }}</span>
          </td>
        </tr>
      </template>

      <template v-slot:body.append="{headers}">
        <tr>
          <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

            <div v-if="i === columns.length - 2" class="text-right">
              Total Score:
            </div>
            <div v-if="header.header === 'Score'">
              {{totalScore}}
            </div>
<!--            <div v-if="header.value === 'current_pay'">-->
<!--              {{ totalPay | currency('$', 2) }}-->
<!--            </div>-->

          </td>
        </tr>
      </template>

    </v-data-table>
  </v-card>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, logError, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import sumBy from 'lodash.sumby'
  import {getRequestWithParams} from "@/helpers/helpers";

  export default {
    name: 'ScoreDrilldown',
    props: {
      tournamentId: Number,
      userId: Number,
      user: String,
      startDate: String,
      endDate: String,
    },
    watch: {
      //this is all dumb. i cant figure out how to make a dialog reload the "created" function when it is opened for a second time
      'userId': async function () {
        this.onLoad()
      },
      'tournamentId': async function () {
        this.onLoad()
      },
      'endDate': async function () {
        this.onLoad()
      },
      'startDate': async function () {
        this.onLoad()
      }
    },
    data() {
      return {
        constants,
        snackbar: {},
        totalScore: 0,
        results: [],
        columns: [],
        columnsLoading: true,
        resultsLoading: true,
      }
    },
    async created() {
      this.onLoad()
    },
    methods: {
      async onLoad () {
        this.totalScore = 0
        this.columnsLoading = true
        this.results = []
        this.columns = []
        this.dataLoading = true
        this.getResults()
        await this.getColumns()
        this.dataLoading = false
      },
      async getColumns() {
        try {
          const {data} = await getRequest(`/tournament/${this.tournamentId}/columns`, 'blueraven')
          this.columns = data
          this.columnsLoading = false
        } catch (e) {
          logError(e)
          this.snackbar = getSnackbar('ERROR', 'Error fetching columns')
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
          this.results = data.length > 0 ? data : []
          this.totalScore = sumBy(this.results,  function(o) { return o.score || 0 })
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
    height: calc(100vh - 325px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #score-drilldown {
    height: calc(100vh - 250px);
    min-height: 300px;
  }
</style>

