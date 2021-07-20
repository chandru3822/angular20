<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card class="square-card">
      <v-data-table
        :headers="headers"
        :items="events"
        :fixed-header="true"
        :items-per-page="-1"
        id="qa-process-step-table"
        hide-default-footer
        disable-sort
        class="elevation-0"
      >
        <template #no-data>
          No upcoming events
        </template>

        <template #no-results>
          No upcoming events
        </template>

        <template #item="{ item, index }">
          <tr>
            <td class="text-left" id="qa-event-link">
              {{ item.projectProcessStepEventId }}
            </td>
            <td class="text-left" id="qa-event-name">{{item.eventName}}</td>
            <td class="text-left" id="qa-event-start">{{ item.start | formatDate('timestamp') }}</td>
            <td class="text-left" id="qa-event-status">{{item.eventStatusType}}</td>
          </tr>
        </template>

      </v-data-table>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
export default {
  name: 'UpcomingEventSnippet',
  props: {
    projectId: Number,
    events: Array
  },
  data () {
    return {
      headers: [
      {text: 'ID', value: 'id', show: true},
      {text: 'Name', value: 'eventName', show: true},
      {text: 'Start', value: 'start', show: true},
      {text: 'Status', value: 'companyEventStatusType', show: true},
    ]
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
