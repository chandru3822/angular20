<template>
  <v-container class="pa-0">
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-tabs :optional="true" color="primary"
                  background-color="white" v-model="model" slider-color="primary">
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
  import { mapStores } from 'pinia'
  import { useUserStore } from '@/stores/UserStorePinia.js'

  export default {
    name: 'PayrollReview',

    computed: {
      ...mapStores(useUserStore),
      tabs() {
        return [ {
          label: 'Payroll Review',
          path: `/commissionManagement/payroll/${this.$route.params.id}/review`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Summary',
          path: `/commissionManagement/payroll/${this.$route.params.id}/summary`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }]
      },
      displayedTabs () {
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

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>

