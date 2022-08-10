<template>
  <v-card id="stats-drilldown" class="square-card">
      <v-card-title class="albatross-header-4">
        History
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
        <v-btn icon color="primary" class="text-capitalize" @click="$emit('historyDialogClosed')">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-card-title>
    <v-data-table
      :headers="headers"
      :items="projectHistory"
      :items-per-page="10"
      disable-sort
      class="elevation-0 height-one-hunned"
    >
      <template #no-data>
        No history available
      </template>

      <template #no-results>
        No history available
      </template>

      <template v-slot:header.team_name="{ header }"><th class="pl-2">{{header.text}}</th></template>
      <template #item="{ item, index }">
        <tr>
          <td class="text-left pl-6">{{item.team_name }}</td>
          <td class="text-left">{{item.userName }}</td>
          <td class="text-left">{{item.date_created | formatDate('timestamp', 'M/D/YYYY h:mm a')}}
            <br/> <span class="performed-span">performed by {{item.addedBy }}</span>
          </td>
          <td class="text-left">{{item.date_removed | formatDate('timestamp', 'M/D/YYYY h:mm a')}}
            <div v-if="item.date_removed"><span class="performed-span">performed by {{item.removedBy }}</span></div>
          </td>
        </tr>
      </template>
    </v-data-table>
  </v-card>
</template>

<script>
  import constants from '@/helpers/constants'
  import {getRequest, getSnackbar, putRequest} from "@/helpers/helpers";
  import {AppMutations} from "@/stores/AppStore";

  export default {
    name: 'OwnershipHistoryDrilldown',
    components: {
    },
    props: {
      projectHistory: Array
    },
    watch: {
    },
    data() {
      return {
        constants,
        snackbar: {},
        results: [],
        headers: [
          {text: 'Team', value: 'team_name', name: 'team'},
          {text: 'Team Member', value: 'userName'},
          {text: 'Joined Conversation', value: 'date_created'},
          {text: 'Left Conversation', value: 'date_removed'},
        ]
      }
    },
    computed: {
    },
    async created() {
    },
    methods: {
    }
  }
</script>

<style lang="scss">

</style>

<style lang="scss" scoped>
  #stats-drilldown {
    width: 800px;
    min-height: 300px;
  }
  .performed-span {
    font-size: 0.70rem;
    color: var(--v-grey-darken1);
  }
</style>

