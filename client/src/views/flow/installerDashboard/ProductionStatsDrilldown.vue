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
      :headers="headers"
      :items="projectIds"
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
        <tr :class="{'shaded-row': index % 2}">
          <td class="text-left">{{item}}</td>
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
      crewId: Number,
      startDate: String,
      endDate: String,
      title: String,
      projectIds: Array
    },
    watch: {
    },
    data() {
      return {
        constants,
        snackbar: {},
        results: [],
        headers: [
          {text: 'Project ID', value: 'projectId', show: true}
        ]
      }
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
    width: 600px;
    min-height: 350px;
  }
</style>

<style lang="scss" scoped>
  #stats-drilldown {
    height: calc(100vh - 150px);
    width: 600px;
    min-height: 300px;
  }
</style>

