<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Installation Agreements</v-toolbar-title>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
                  background-color="white" v-model="model" slider-color="primary">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{ tab.label }}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import { mapStores } from 'pinia'
import { useUserStore } from '@/stores/UserStorePinia.js'

export default {
  name: 'installationAgreements',
  computed: {
    ...mapStores(useUserStore),
    tabs() {
      return [{
        label: 'Installation Agreement Request',
        path: '/installation-agreements/request',
        display: this.userStore.userHasFeature('INSTALLATION_AGREEMENT')
      }]
    },
    displayedTabs() {
      return this.tabs.filter(tab => tab.display)
    }
  },
  data() {
    return {
      snackbar: {},
      model: ''
    }
  },
  methods: {}
}
</script>
