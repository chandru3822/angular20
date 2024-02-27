<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-tabs class="tabs-bar">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

import {getCurrentInstance, ref, computed} from "vue";

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store

const tabs = ref([
  {
    label: 'Availability',
    path: `/settings/availability/main/schedule`,
    display: store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW')
  },
  {
    label: 'Slot Schedules',
    path: `/settings/availability/slots`,
    display: store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN')
  }
])

const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})

</script>
