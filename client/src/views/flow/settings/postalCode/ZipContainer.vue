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

<script>
import constants from '@/helpers/constants'
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

  export default {
    name: 'ZipContainer',

    computed: {
      ...mapStores(useUserStore),
      tabs() {
        return [
          {
            label: 'Postal Codes',
            path: `/settings/zip/postalCodes`,
            display: this.userStore.userHasFeature('POSTAL_CODE')
          },
          {
            label: 'Postal Code Zones',
            path: `/settings/zip/zones`,
            display: this.userStore.userHasFeature('POSTAL_CODE')
          },
        ]
      },
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
    },
    data() {
      return {
        constants
      }
    },
    created() {},
    methods: {}
  }
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
