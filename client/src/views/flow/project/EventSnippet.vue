<template>
  <v-row>
    <v-col cols="12">
      <v-card class="square-card">
        <v-data-table
          :headers="headers"
          :items="events"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          disable-sort
          class="elevation-0"
        >
          <template #no-data>
            No active events
          </template>

          <template #no-results>
            No active events
          </template>

          <template #item="{ item, index }">
            <tr>
              <td class="text-left">
                {{ item.id }}
              </td>
              <td class="text-left">{{item.eventName}}</td>
              <td class="text-left">{{ item.startTime | formatDate('timestamp') }}</td>
              <td class="text-left">{{item.resource}}</td>
              <td class="text-left">{{ item.eventStatusType }}</td>
            </tr>
          </template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
  export default {
    name: 'EventSnippet',
    props: {
      projectId: Number,
      events: Array
    },
    data () {
      return {
        headers: [
          {text: 'ID', value: 'id', show: true, width: 80},
          {text: 'Type', value: 'processStepName', show: true},
          {text: 'Start', value: 'start', show: true},
          {text: 'Resource', value: 'resourceName', show: true},
          {text: 'Status', value: 'eventStatusType', show: true},
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

.primary-row{
  background-color: #ebf5ff !important;
}
</style>
