<template>
  <v-card id="stats-drilldown" class="square-card">
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">
        <h3>{{ title }}</h3>
        <div class="toolbar-subtitle">{{startDate | formatDate('date', 'M/D/YYYY')}} - {{ endDate | formatDate('date', 'M/D/YYYY')}}</div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="$emit('prodStatsDrilldownDialogClosed')">
          Close
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>

    <v-data-table
      :headers="visibleHeaders"
      :items="drilldownData"
      :fixed-header="true"
      :items-per-page="-1"
      disable-sort
      class="elevation-1"
    >
      <template #no-data>
        No projects available
      </template>

      <template #no-results>
        No projects available
      </template>

      <template #item="{ item, index }">
        <tr :class="{'green-row': item.isnumerator}">
          <td class="text-left">{{item.project_id}}</td>
          <td class="text-left">{{item.crewname}}</td>
          <td class="text-left">{{item.installation_scheduled | formatDate('date')}}</td>
          <td class="text-left">{{item.substantial_completion_date | formatDate('date')}}</td>
          <td v-show="title === 'Inspection Approval %'" class="text-left">{{item.ahj_inspection_scheduled_date | formatDate('date')}}</td>
          <td v-show="title === 'Inspection Approval %'" class="text-left">{{item.ahj_inspection_outcome_name}}</td>
        </tr>
      </template>
    </v-data-table>
  </v-card>
</template>

<script>
  import constants from '@/helpers/constants'

  export default {
    name: 'ProductionStatsDrilldown',
    props: {
      startDate: String,
      endDate: String,
      title: String,
      drilldownData: Array
    },
    watch: {
      title: {
        handler () {
          if (this.title === 'Inspection Approval %') {
            // AHJ Inspection Date
            this.headers[4].show = true;
            // AHJ Inspection Outcome
            this.headers[5].show = true;
          }
          else {
            // AHJ Inspection Date
            this.headers[4].show = false;
            // AHJ Inspection Outcome
            this.headers[5].show = false;
          }
        }
      }
    },
    data() {
      return {
        constants,
        snackbar: {},
        results: [],
        headers: [
          {text: 'Project ID', value: 'project_idd', show: true},
          {text: 'Installation Crew', value: 'crewname', show: true},
          {text: 'Installation Date', value: 'installation_scheduled', show: true},
          {text: 'Substantial Completion Date', value: 'substantial_completion_date', show: true},
          {text: 'AHJ Inspection Date', value: 'ahj_inspection_scheduled_date', show: false},
          {text: 'AHJ Inspection Outcome', value: 'ahj_inspection_outcome_name', show: false}
        ]
      }
    },
    computed: {
      visibleHeaders() {
        return this.headers.filter(header => header.show === true)
      },
    },
    async created() {
    },
    methods: {
    }
  }
</script>

<style lang="scss">
  #stats-drilldown .v-data-table__wrapper {
    height: calc(100vh - 325px);
    width: 1200px;
    min-height: 350px;
  }
  .green-row {
    background-color: #c3fad2;
  }
</style>

<style lang="scss" scoped>
  #stats-drilldown {
    height: calc(100vh - 150px);
    width: 1200px;
    min-height: 300px;
  }
</style>

