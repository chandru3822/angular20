<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1 mb-1">
          <v-toolbar-title>Expense Management</v-toolbar-title>
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
    name: 'Expenses',

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
          label: 'Reimbursement Requests',
          path: '/expenses/reimbursementRequests',
          display: this.$store.getters.userHasFeature('EXPENSES')
        }, {
          label: 'Submitted Expenses',
          path: '/expenses/submittedExpenses',
          display: this.$store.getters.userHasFeature('EXPENSES')
        }, {
          label: 'GL Codes',
          path: '/expenses/glCodes',
          display: this.$store.getters.userHasFeature('EXPENSES')
        }, {
          label: 'Monthly Budgets',
          path: '/expenses/monthlyBudgets',
          display: this.$store.getters.userHasFeature('EXPENSES')
        }, {
          label: 'Budget Types',
          path: '/expenses/budgetTypes',
          display: this.$store.getters.userHasFeature('EXPENSES')
        }]
      }
    },
    methods: {
    }
  }
</script>
