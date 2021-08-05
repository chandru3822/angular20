<template>
  <v-container class="pa-0">
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-tabs :optional="true" color="primaryCustom"
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
    name: 'PayrollReview',

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
          label: 'Payroll Review',
          path: `/commissionManagement/payroll/${this.$route.params.id}/review`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Summary',
          path: `/commissionManagement/payroll/${this.$route.params.id}/summary`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }]
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

