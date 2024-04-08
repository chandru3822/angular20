<template>
  <v-card id="stats-drilldown" class="square-card">
    <v-card-title class="albatross-header-4">
      History
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
        <a-btn
          variant="text"
          icon
          color="primary"
          class="text-capitalize"
          @click="emit('historyDialogClosed')"
          prepend-icon="mdi-close"
        />
      </v-card-title>
    <v-data-table
      :headers="headers"
      :items="conversationHistory"
      :items-per-page="10"
      disable-sort
      class="elevation-0 height-one-hunned table-striped"
    >
      <template #no-data>
        <span class="default-text-color">No history available</span>
      </template>

      <template #no-results>
        <span class="default-text-color">No history available</span>
      </template>

      <template v-slot:header.team_name="{ header }"><th class="pl-2">{{header.text}}</th></template>

      <template #item.team_name="{ item }" class="text-left pl-6">{{item.team_name }}</template>
      <template #item.userName="{ item }" class="text-left">{{item.userName }}</template>
      <template #item.date_created="{ item }" class="text-left">{{item.date_created | formatDate('timestamp', 'M/D/YYYY h:mm a')}}
        <br/> <span class="performed-span">performed by {{item.addedBy }}</span>
      </template>
      <template #item.date_removed="{ item }" class="text-left">{{item.date_removed | formatDate('timestamp', 'M/D/YYYY h:mm a')}}
        <div v-if="item.date_removed"><span class="performed-span">performed by {{item.removedBy }}</span></div>
      </template>
    </v-data-table>
  </v-card>
</template>

<script setup>

  import { ref } from "vue"

  const props = defineProps({
    conversationHistory: Array
  })
  const results = ref([])
  const headers = ref([
    {text: 'Team', value: 'team_name', name: 'team'},
    {text: 'Team Member', value: 'userName'},
    {text: 'Joined Conversation', value: 'date_created'},
    {text: 'Left Conversation', value: 'date_removed'},
  ])
  const emit = defineEmits(['historyDialogClosed'])

</script>

<style lang="scss">
@media (max-width: 770px) {
  #stats-drilldown > div.v-card__title.albatross-header-4 {
    position: sticky;
    top: 0;
    z-index: 1;
    background-color: white;
    border-bottom: var(--v-grey-lighten3) 1px;

  }
  #stats-drilldown {
    overflow-y: clip !important;

    div.v-data-footer {
      display: inline-flex;
      width: 100%;
      justify-content: center;
      height: fit-content;

      div.v-data-footer__select {
        justify-content: center;
        margin-left: 0;
        margin-right: 0;
      }

      div.v-data-footer__pagination {
        margin: 0 16px 0 16px !important;
      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: 16px;


      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}
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

