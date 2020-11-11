<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Blue Power + Payments Queue</v-toolbar-title>
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

  </v-container>
</template>

<script>


  export default {
    name: 'Rebate',

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
          label: 'View Payments',
          path: '/finances/rebate/viewPayments',
          display: this.$store.getters.userHasFeature('REBATES')
        }, {
          label: 'Batches',
          path: '/finances/rebate/batches',
          display: this.$store.getters.userHasFeature('REBATES')
        }]
      }
    },
    methods: {
    }
  }
</script>
