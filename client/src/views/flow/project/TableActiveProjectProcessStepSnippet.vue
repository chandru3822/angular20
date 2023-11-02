<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card class="square-card">
      <v-data-table
        :headers="headers"
        :items="sortedSteps"
        :fixed-header="true"
        :items-per-page="-1"
        @click:row="goToProjectProcessStep"
        id="qa-process-step-table"
        hide-default-footer
        disable-sort
        class="elevation-0"
      >
        <template #no-data>
          <span class="default-text-color">No active process steps</span>
        </template>

        <template #no-results>
          <span class="default-text-color">No active process steps</span>
        </template>

        <template #item.id="{item}" class="text-left" id="qa-process-link">
          {{ item.projectProcessStepId }}
        </template>
        <template #item.processStepName="{item}" class="text-left" id="qa-process-step-name">{{item.processStepName}}</template>
        <template #item.dateCreated="{item}" class="text-left" id="qa-process-date-created">{{ item.dateCreated | formatDate('timestamp') }}</template>
        <template #item.owner="{item}" class="text-left" id="qa-process-owner-name">{{ item.owner && item.owner.fullName }}</template>
        <template #item.processStepStatusType="{item}" class="text-left" id="qa-process-status">{{item.processStepStatusType}}</template>

      </v-data-table>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
import orderBy from 'lodash.orderby'
export default {
  name: 'ActiveProjectProcessStepSnippet',
  props: {
    projectId: Number,
    steps: Array,
    contactId: Number
  },
  computed: {
    sortedSteps() {
      return orderBy(this.steps, 'projectProcessStepId', 'desc')
    }
  },
  data () {
    return {
      headers: [
      {text: 'ID', value: 'id', show: true},
      {text: 'Name', value: 'processStepName', show: true},
      {text: 'Created', value: 'dateCreated', show: true},
      {text: 'Owner', value: 'owner', show: true},
      {text: 'Status', value: 'processStepStatusType', show: true},
    ]
    }
  },
  methods: {
    goToPath(path) {
      this.$router.push(path)
    },
    goToProjectProcessStep(processStep){
      this.goToPath(`/project/${this.projectId}/processStep/${processStep.projectProcessStepId}`)
    }
  }
}
</script>


<style scoped lang="scss">
.header {
  background-color: #E6E6E9;
  color: #1F3C73;
  border-bottom: 1px solid #C7C7CC;
}
</style>
