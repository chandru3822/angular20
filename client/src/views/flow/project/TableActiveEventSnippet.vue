<template>
  <v-row>
    <v-col cols="12" class="pt-0">
      <v-card class="square-card">
        <v-data-table
          :headers="headers"
          :items="events"
          :fixed-header="true"
          :items-per-page="-1"
          @click:row="goToEvent"
          id="qa-process-step-table"
          hide-default-footer
          disable-sort
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No upcoming or past due events</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No upcoming or past due events</span>
          </template>

          <template #item.id="{item}" class="text-left" id="qa-event-link">
            {{ item.id }}
          </template>
          <template #item.eventName="{item}" class="text-left" id="qa-event-name">{{item.eventName}}</template>
          <template #item.startTime="{item}" class="text-left" id="qa-event-start">{{ item.startTime | formatDate('timestamp') }}</template>
          <template #item.resource="{item}" class="text-left">{{item.resource}}</template>
          <template #item.companyEventStatusType="{item}" class="text-left" id="qa-event-status">{{item.eventStatusType}}</template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
export default {
  name: 'TableActiveEventSnippet',
  props: {
    projectId: Number,
    events: Array
  },
  data () {
    return {
      headers: [
        {text: 'ID', value: 'id', show: true},
        {text: 'Name', value: 'eventName', show: true},
        {text: 'Start', value: 'startTime', show: true},
        {text: 'Resource', value: 'resource', show: true},
        {text: 'Status', value: 'companyEventStatusType', show: true},
      ]
    }
  },
  methods: {
    goToPath(path) {
      this.$router.push(path)
    },
    goToEvent(item) {
      this.goToPath(`/project/${this.projectId}/processStep/${item.projectProcessStepId}/event/${item.id}`)
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
