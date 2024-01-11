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

  export default {
    name: 'Defaults',

    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
    },
    data() {
      return {
        constants,
        tabs: [
          {
            label: 'Settings',
            path: `/settings/company/settings`,
            display: this.$store.getters.userHasFeature('SETTINGS')
          },
          {
            label: 'Configurations',
            path: `/settings/company/configurations`,
            display: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
          },
          {
            label: 'Email',
            path: `/settings/company/email`,
            display: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
          },
          {
            label: 'Message Types',
            path: `/settings/company/messageTypes`,
            display: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADMIN')
          },
          {
            label: 'Closer Dashboard',
            path:`/settings/company/closerDashboard`,
            display: this.$store.getters.userHasFeatureAccessLevel('SETTINGS','ADMIN')
          }
        ]
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
