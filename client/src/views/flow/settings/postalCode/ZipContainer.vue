<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-tabs class="tabs-bar" id="default-settings-tabs">
          <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0 label-medium"
                 :style="{'margin-left': (index === 0 && $vuetify.breakpoint.smAndDown) ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>
        <router-view></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const tabs = computed(() => {
  return [
    {
      label: 'Postal Codes',
      path: `/settings/zip/postalCodes`,
      display: userStore.userHasFeature('POSTAL_CODE')
    },
    {
      label: 'Postal Code Zones',
      path: `/settings/zip/zones`,
      display: userStore.userHasFeature('POSTAL_CODE')
    },
  ]
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})

</script>
<style lang="scss">
@media (max-width: 959px) {
  #default-settings-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #default-settings-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>
