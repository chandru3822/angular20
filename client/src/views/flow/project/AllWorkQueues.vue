<template>
  <v-row no-gutters id="project-details-wq-container" class="py-0 relative overflow-y-auto">
    <v-col cols="12" lg="12" class="pa-3">
      <v-toolbar color="transparent" class="elevation-0 project-wq-toolbar">
        <v-toolbar-title class="albatross-header-3">Current Work Queues</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn color="primary" text @click="expandCurrent = !expandCurrent">
            <v-icon v-if="!expandCurrent">mdi-chevron-down</v-icon>
            <v-icon v-else>mdi-chevron-up</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>

      <v-card class="square-card" v-if="expandCurrent">
        <v-data-table
          :headers="headers"
          :items="currentWorkQueues"
          :fixed-header="true"
          disable-sort
          hide-default-footer
          :items-per-page="-1"
          :loading="dataLoading"
          dense
          class="elevation-1 table-striped"
        >

          <template #no-data>
            No current work queues
          </template>

          <template #no-results>
            No current work queues
          </template>

          <template #item.workQueueCategory="{item}" class="text-left">{{ item.workQueueCategory }}</template>
          <template #item.workQueueType="{item}" class="text-left">{{ item.workQueueType }}</template>
          <template #item.daysInQueue="{item}" class="text-left">{{ item.daysInQueue }}</template>
          <template #item.processStepName="{item}" class="text-left">{{ item.processStepName }}</template>
          <template #item.eventName="{item}" class="text-left">{{ item.eventName }}</template>

        </v-data-table>
      </v-card>

      <v-toolbar color="transparent" class="elevation-0 mt-6 project-wq-toolbar">
        <v-toolbar-title class="albatross-header-3">Historic Work Queues</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn color="primary" text @click="expandHistoric = !expandHistoric">
            <v-icon v-if="!expandHistoric">mdi-chevron-down</v-icon>
            <v-icon v-else>mdi-chevron-up</v-icon>
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-card class="square-card" v-if="expandHistoric">
        <v-data-table
          :headers="headers"
          :items="historicWorkQueues"
          :fixed-header="true"
          disable-sort
          :items-per-page="-1"
          hide-default-footer
          :loading="dataLoading"
          dense
          class="elevation-1 table-striped"
        >

          <template #no-data>
            No current work queues
          </template>

          <template #no-results>
            No current work queues
          </template>

          <template #item.workQueueCategory="{item}" class="text-left">{{ item.workQueueCategory }}</template>
          <template #item.workQueueType="{item}" class="text-left">{{ item.workQueueType }}</template>
          <template #item.daysInQueue="{item}" class="text-left">{{ item.daysInQueue }}</template>
          <template #item.processStepName="{item}" class="text-left">{{ item.processStepName }}</template>
          <template #item.eventName="{item}" class="text-left">{{ item.eventName }}</template>

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
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

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
      expandHistoric: true,
      expandCurrent: true,
      dataLoading: false,
      snackbar: {},
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
  computed: {
    ...mapStores(useUserStore),
    userCanEdit() {
      return this.userStore.userHasFeatureAccessLevel('PROJECTS', 'EDIT')
    },
    companyId() {
      return this.userStore.details.companyId
    },
    currentWorkQueues() {
      return this.workQueueHistory.filter(wqh => wqh.status === 'Currently in Queue')
    },
    historicWorkQueues() {
      return this.workQueueHistory.filter(wqh => wqh.status === 'Work Queue History')
    },
  },
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
  height: calc(100vh - 192px);

  @media (min-width: 960px) {
    height: 100%;
  }
}
</style>

<style lang="scss">
//#project-details-wq-container .v-data-table__wrapper {
//  max-height: calc(100vh - 270px);
//  min-height: 300px;
//}

.project-wq-toolbar .v-toolbar__content {
  padding: 4px 0 !important;
}
</style>
