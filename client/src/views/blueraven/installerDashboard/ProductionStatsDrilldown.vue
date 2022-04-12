<template>
  <v-card id="stats-drilldown" class="square-card">
    <v-toolbar flat class="app-toolbar">
      <v-toolbar-title class="app-title">
        <h3>{{ title }}</h3>
        <div class="toolbar-subtitle">{{ startDate | formatDate('date', 'M/D/YYYY') }} -
          {{ endDate | formatDate('date', 'M/D/YYYY') }}
        </div>
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
          <td v-if="title === 'Same-week Closeout %' || title === 'On-time Closeout %'" class="text-left">
            <router-link :to="`/project/${item.project_id}/processStep/${item.processstepid}`"
                         target="_blank">{{ item.project_id }}
            </router-link>
          </td>
          <td v-else-if="title === 'Inspection Pass Rate' || title === 'Substantial Completions'" class="text-left">
            <router-link :to="`/project/${item.project_id}`" target="_blank">{{ item.project_id }}</router-link>
          </td>
          <td v-else class="text-left">{{ item.project_id }}</td>
          <td class="text-left">{{ item.project_name }}</td>
          <td class="text-left">{{ item.crewname }}</td>
          <td v-if="title === 'On-time Closeout %'" class="text-left">
            {{ item.installation_closeout_start_time | formatDate('date') }}
          </td>
          <td class="text-left">{{ item.installation_end_time | formatDate('date') }}</td>
          <td class="text-left">{{ item.substantial_completion_date | formatDate('date') }}</td>
          <td v-show="title === 'Inspection Pass Rate'" class="text-left">
            {{ item.ahj_inspection_start_time | formatDate('date') }}
          </td>
          <td v-show="title === 'Inspection Pass Rate'" class="text-left">{{ item.ahj_inspection_outcome_name }}</td>
          <td v-show="title === 'Inspection Pass Rate'" class="text-left inspection-fail-col-td">
            {{ item.ahj_inspection_fail_reason }}
          </td>
          <td v-show="title === 'Inspection Pass Rate'" class="text-left inspection-fail-col-td">
            {{ item.inspection_fail_feedback }}
          </td>
          <td class="notes-column">
            <div class="flex-display align-center">
                  <pre class="app-pre-wrapper" v-if="item.notes && item.notes.length > 0">
                     {{ item.notes[0].note }}
                  </pre>
              <v-spacer></v-spacer>
              <v-btn small fab text @click="[item.showNotesModal = true, ytfDoWeNeedThis++]">
                <v-icon>mdi-comment-text-multiple</v-icon>
              </v-btn>
            </div>
            <v-dialog
              :key="ytfDoWeNeedThis"
              v-model="item.showNotesModal"
            >
              <v-card class="wqt-notes-container">
                <v-card-title class="primary-custom-bg white--text">{{ item.project_name }} - {{ title }}</v-card-title>
                <v-card-text class="py-3">
                  <v-toolbar color="transparent" class="elevation-0">
                    <v-toolbar-title>Notes</v-toolbar-title>
                  </v-toolbar>
                  <v-card class="square-card mx-4">
                    <NotesAndActivityContent
                      :showNotes="true"
                      :showActivity="false"
                      :notes="item.notes"
                      :primary-id="item.project_id"
                      :install-dash-tile="title"
                      type="ProjectProductionStats"
                    />
                  </v-card>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>

                  <v-btn
                    color="primaryCustom"
                    class="white--text mr-2 mb-3"
                    @click="[item.showNotesModal = false, ytfDoWeNeedThis++]"
                  >
                    Close
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </td>
        </tr>
      </template>
    </v-data-table>
  </v-card>
</template>

<script>
import constants from '@/helpers/constants'
import NotesAndActivityContent from '@/views/flow/components/NotesAndActivityContent'

export default {
  name: 'ProductionStatsDrilldown',
  components: {
    NotesAndActivityContent
  },
  props: {
    startDate: String,
    endDate: String,
    title: String,
    drilldownData: Array
  },
  watch: {
    title: {
      handler() {
        this.setHeaders();
      }
    }
  },
  data() {
    return {
      constants,
      snackbar: {},
      results: [],
      headers: [
        {text: 'Project ID', value: 'project_id', show: true},
        {text: 'Project Name', value: 'project_name', show: true},
        {text: 'Installation Crew', value: 'crewname', show: true},
        {text: 'Installation Closeout Start Time', value: 'installation_closeout_start_time', show: true},
        {text: 'Installation Date', value: 'installation_end_time', show: true},
        {text: 'Substantial Completion Date', value: 'substantial_completion_date', show: true},
        {text: 'AHJ Inspection Date', value: 'ahj_inspection_start_time', show: true},
        {text: 'AHJ Inspection Outcome', value: 'ahj_inspection_outcome_name', show: true},
        {text: 'AHJ Inspection Fail Reason', value: 'ahj_inspection_fail_reason', show: true},
        {text: 'Inspection Fail Feedback', value: 'inspection_fail_feedback', show: true},
        {text: 'Notes', value: 'notes', show: true}
      ],
      ytfDoWeNeedThis: 0,
    }
  },
  computed: {
    visibleHeaders() {
      return this.headers.filter(header => header.show === true)
    },
  },
  async created() {
    this.setHeaders();
  },
  methods: {
    setHeaders() {
      if (this.title === 'Inspection Pass Rate') {
        // Installation Closeout Start Time
        this.headers[3].show = false;
        // AHJ Inspection Date
        this.headers[6].show = true;
        // AHJ Inspection Outcome
        this.headers[7].show = true;
        // AHJ Inspection Fail Reason
        this.headers[8].show = true;
        // Inspection Fail Feedback
        this.headers[9].show = true;
      } else if (this.title === 'On-time Closeout %') {
        // Installation Closeout Start Time
        this.headers[3].show = true;
        // AHJ Inspection Date
        this.headers[6].show = false;
        // AHJ Inspection Outcome
        this.headers[7].show = false;
        // AHJ Inspection Fail Reason
        this.headers[8].show = false;
        // Inspection Fail Feedback
        this.headers[9].show = false;
      } else {
        // Installation Closeout Start Time
        this.headers[3].show = false;
        // AHJ Inspection Date
        this.headers[6].show = false;
        // AHJ Inspection Outcome
        this.headers[7].show = false;
        // AHJ Inspection Fail Reason
        this.headers[8].show = false;
        // Inspection Fail Feedback
        this.headers[9].show = false;
      }
    }
  }
}
</script>

<style lang="scss">
#stats-drilldown .v-data-table__wrapper {
  height: calc(100vh - 325px);
  width: 1600px;
  min-height: 350px;
}

.green-row {
  background-color: #c3fad2;
}

.inspection-fail-col-td {
  width: 175px;
}
</style>

<style lang="scss" scoped>
#stats-drilldown {
  height: calc(100vh - 150px);
  width: 1600px;
  min-height: 300px;
}
</style>

