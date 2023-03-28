<template>
  <v-row no-gutters id="project-details-wq-container" class="py-0 relative height-one-hunned overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-5">
      <v-toolbar color="transparent" class="elevation-0">
        <v-toolbar-title class="albatross-header-3">Project Work Queue History</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
        </v-toolbar-items>
      </v-toolbar>

      <v-card class="square-card">
        <v-data-table
          :headers="headers"
          :items="workQueueHistory"
          :fixed-header="true"
          :options.sync="options"
          disable-sort
          :footer-props="footerProps"
          group-by="status"
          :items-per-page="50"
          :server-items-length="workQueueHistory.length"
          :loading="dataLoading"
          dense
          class="elevation-1"
        >

          <template #no-data>
            No work queue history found
          </template>

          <template #no-results>
            No work queue history found
          </template>

          <template v-slot:group.header="{items, isOpen, toggle}">
            <th :colspan="headers.length">
              <v-icon @click="toggle">
                {{ isOpen ? 'mdi-minus' : 'mdi-plus' }}
              </v-icon>
              {{ items[0].status }}
            </th>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.workQueueCategory }}</td>
              <td class="text-left">{{ item.workQueueType }}</td>
              <td class="text-left">{{ item.daysInQueue }}</td>
              <td class="text-left">{{ item.processStepName }}</td>
              <td class="text-left">{{ item.eventName }}</td>
            </tr>
          </template>
        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>

import {getRequest, logError} from '@/helpers/helpers'
import TableActiveProjectProcessStepSnippet from '@/views/flow/project/TableActiveProjectProcessStepSnippet'
import ProjectProcessStepSnippet from '@/views/flow/project/ProjectProcessStepSnippet'
import SpinnerInline from '@/components/SpinnerInline'

import AddProcessStep from '@/views/flow/components/AddProcessStep'
import constants from "@/helpers/constants";

export default {
  name: 'ActiveProcessSteps',
  components: {
    SpinnerInline,
    TableActiveProjectProcessStepSnippet,
    ProjectProcessStepSnippet,
    AddProcessStep,
  },
  props: {
    project: Object
  },
  data() {
    return {
      projectId: parseInt(this.$route.params.projectId),
      workQueueHistory: [],
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('PROJECTS', 'EDIT'),
      userHasWorkQueueFeature: this.$store.getters.userHasFeature('WORK_QUEUE'),
      dataLoading: false,
      snackbar: {},
      companyId: this.$store.state.user.details.companyId,
      headers: [
        {text: 'WQ Category', value: 'workQueueCategory', show: true},
        {text: 'WQ Type', value: 'workQueueType', show: true},
        {text: 'Days in Queue', value: 'daysInQueue', show: true},
        {text: 'Process Step Name', value: 'processStepName', show: true},
        {text: 'Event Name', value: 'eventName', show: true}
      ],
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      options: {
        itemsPerPage: 100
      },
    }
  },
  created() {
    this.getWorkQueueHistory()
  },
  computed: {},
  methods: {
    getWorkQueueHistory: async function () {
      try {
        this.dataLoading = true
        const {data} = await getRequest(`/project/${this.projectId}/workQueueHistory`)
        this.workQueueHistory = data
        window.document.title = `${this.project.projectName} - Work Queues`
      } catch (e) {
        logError(e)
      } finally {
        this.dataLoading = false
      }
    },
  }
}
</script>

<style lang="scss" scoped>
#project-details-wq-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}

</style>

<style lang="scss">
#project-details-wq-container .v-data-table__wrapper {
  max-height: calc(100vh - 190px);
  min-height: 300px;
}
</style>
