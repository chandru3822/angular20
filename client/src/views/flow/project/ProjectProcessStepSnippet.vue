<template>
  <v-row>
    <v-col cols="12">
      <v-card class="square-card">
        <v-data-table
          :headers="headers"
          :items="steps"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          disable-sort
          class="elevation-0"
        >
          <template #no-data>
            No active process steps
          </template>

          <template #no-results>
            No active process steps
          </template>

          <template #item="{ item, index }">
            <tr :class="{'primary-row': item.main}">
              <td class="text-left">
                <router-link :to="`/project/${projectId}/processStep/${item.projectProcessStepId}`">{{ item.projectProcessStepId }}</router-link>
              </td>
              <td class="text-left">{{item.processStepName}}</td>
              <td class="text-left">{{ item.dateCreated | formatDate('timestamp') }}</td>
              <td class="text-left">{{ item.owner && item.owner.fullName }}</td>
              <td class="text-left">{{ item.processStepStatusType }}</td>
            </tr>
          </template>

        </v-data-table>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
  export default {
    name: 'ProjectProcessStepSnippet',
    props: {
      projectId: Number,
      steps: Array,
      contactId: Number
    },
    data () {
      return {
        headers: [
          {text: 'ID', value: 'id', show: true, width: 80},
          {text: 'Type', value: 'processStepName', show: true},
          {text: 'Created', value: 'dateCreated', show: true},
          {text: 'Owner', value: 'owner', show: true},
          {text: 'Status', value: 'processStepStatusType', show: true},
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
