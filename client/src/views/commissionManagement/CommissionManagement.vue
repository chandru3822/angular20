<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Commission Management</v-toolbar-title>
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
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Commissions',
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
          label: 'Closers',
          path: '/commissionManagement/closers',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Commissions',
          path: '/commissionManagement/commissions',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Overrides',
          path: '/commissionManagement/overrides',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Accounting Review',
          path: '/commissionManagement/accounting/current',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Payroll Search',
          path: '/commissionManagement/payroll',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Residuals',
          path: '/commissionManagement/residuals',
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }]
      }
    },
    methods: {}
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

