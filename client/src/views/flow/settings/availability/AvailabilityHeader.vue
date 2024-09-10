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
import { useUserStore } from '@/stores/UserStore.js'

const vueInstance = getCurrentInstance().proxy
 const store = vueInstance.$store
const userStore = useUserStore()

const tabs = ref([
  {
    label: 'Availability',
    path: `/settings/availability/main/schedule`,
    display: userStore.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW')
  },
  {
    label: 'Slot Schedules',
    path: `/settings/availability/slots`,
    display: userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN')
  },
  {
    label: 'Holidays',
    path: `/settings/availability/holidays`,
    display: userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN')
  }
])

const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})

</script>
