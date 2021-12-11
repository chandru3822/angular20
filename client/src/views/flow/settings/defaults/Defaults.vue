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

<script>

  import store from "@/store";

  export default {
    name: 'Defaults',

    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
    },
    data() {
      return {
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
          }
        ]
      }
    },
    created() {

    },
    methods: {

    }
  }
</script>
