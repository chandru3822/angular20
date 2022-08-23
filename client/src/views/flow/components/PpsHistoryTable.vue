<template>
  <v-data-table
    :headers="historyHeaders"
    :items="selectedPpsHistory"
    disable-sort
    :fixed-header="true"
    :items-per-page="-1"
    class="elevation-1">

    <template #no-data>
      <span class="default-text-color">No available history data</span>
    </template>

    <template #no-results>
      <span class="default-text-color">No available history data</span>
    </template>

    <template #item="{ item, index }">
      <tr :class="{'shaded-row': index % 2}">
        <td class="text-left">{{item.owner}}</td>
        <td class="text-left">{{item.companyProcessStepStatusType}}</td>
        <td class="text-left">{{item.main ? 'Yes' : 'No'}}</td>
        <td class="text-left">
          <div v-if="index === 0">
            {{item.dateCreated | formatDate('timestamp', 'M/D/YYYY h:mm:ss a')}}
          </div>
        </td>
        <td class="text-left">
          <div v-if="index === 0">
            {{item.createdBy}}
          </div>
        </td>
        <td class="text-left">{{item.dateModified | formatDate('timestamp', 'M/D/YYYY h:mm:ss a')}}</td>
        <td class="text-left">{{item.modifiedBy}}</td>
      </tr>
    </template>
  </v-data-table>
</template>

<script>
export default {
  name: 'PpsHistory',
  props: {
    selectedPpsHistory: Array
  },
  data () {
    return {
      historyHeaders: [
        {text: 'Owner', value: 'owner'},
        {text: 'Status', value: 'processStepStatusType'},
        {text: 'Is Primary?', value: 'main'},
        {text: 'Date Created', value: 'dateCreated'},
        {text: 'Created By', value: 'createdBy'},
        {text: 'Date Modified', value: 'dateModified'},
        {text: 'Modified By', value: 'modifiedBy'},
      ],
    }
  },
  created () {

  },
  methods: {

  }
}
</script>

<style lang="scss">
.add-process-step-btn > .v-btn__content {
  color: white !important;
}
</style>
