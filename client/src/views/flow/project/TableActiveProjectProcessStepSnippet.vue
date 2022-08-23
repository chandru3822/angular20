<template>
<v-row>
  <v-col cols="12" class="pt-0">
    <v-card class="square-card">
      <v-data-table
        :headers="headers"
        :items="steps"
        :fixed-header="true"
        :items-per-page="-1"
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

        <template #item="{ item, index }">
          <tr class="clickable" @click="goToPath(`/project/${projectId}/processStep/${item.projectProcessStepId}`)">
            <td class="text-left" id="qa-process-link">
              {{ item.projectProcessStepId }}
            </td>
            <td class="text-left" id="qa-process-step-name">{{item.processStepName}}</td>
            <td class="text-left" id="qa-process-date-created">{{ item.dateCreated | formatDate('timestamp') }}</td>
            <td class="text-left" id="qa-process-owner-name">{{ item.owner && item.owner.fullName }}</td>
            <td class="text-left" id="qa-process-status">{{item.processStepStatusType}}</td>
          </tr>
        </template>

      </v-data-table>
    </v-card>
  </v-col>
</v-row>
</template>

<script>
export default {
  name: 'ActiveProjectProcessStepSnippet',
  props: {
    projectId: Number,
    steps: Array,
    contactId: Number
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
