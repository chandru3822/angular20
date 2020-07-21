<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Installation Agreements</v-toolbar-title>
          <v-tabs :optional="false" color="primaryCustom"
                  slot="extension"
                  background-color="white" v-model="model" slider-color="primaryCustom">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view></router-view>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import Snackbar from '@/components/Snackbar.vue'

  export default {
    name: 'installationAgreements',
    components: {
      Snackbar
    },
    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      }
    },
    data() {
      return {
        snackbar: {},
        model: '',
        tabs: [ {
          label: 'Installation Agreement Request',
          path: '/installation-agreements/request',
          display: this.$store.getters.userHasFeature('INSTALLATION_AGREEMENT')
        }]
      }
    },
    methods: {
    }
  }
</script>
