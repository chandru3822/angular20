<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1 mb-1" id="expense-management-header">
          <v-toolbar-title>
            <v-btn fab text v-if="userIsAdmin || userCanManage"
                   small color="primary" class="mr-2" @click="goToPath('')">
              <v-icon v-if="manage">mdi-view-list</v-icon>
              <v-icon v-else>settings</v-icon>
            </v-btn>
            Expense Management
          </v-toolbar-title>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
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
    name: 'Expenses',
    computed: {
      ...mapStores(useUserStore),
      userCanManage() {
        return this.userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
      },
      userIsAdmin() {
        return this.userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')
      },
      tabs() {
        return [
          {
            label: 'Monthly Budgets',
            path: '/expenses/manage/monthlyBudgets',
            manage: true,
            display: this.userStore.userHasFeature('EXPENSES')
          },
          {
            label: 'Budget Templates',
            path: '/expenses/manage/budgetTemplates',
            manage: true,
            display: this.userStore.userHasFeature('EXPENSES')
          },
          {
            label: 'Budget Types',
            path: '/expenses/manage/budgetTypes',
            manage: true,
            display: this.userStore.userHasFeature('EXPENSES')
          },
          {
            label: 'GL Codes',
            path: '/expenses/manage/glCodes',
            manage: true,
            display: this.userStore.userHasFeature('EXPENSES')
          },
          {
            label: 'Reimbursement Requests',
            path: '/expenses/reimbursementRequests',
            manage: false,
            display: this.userStore.userHasFeature('EXPENSES')
          }, {
            label: 'Submitted Expenses',
            path: '/expenses/submittedExpenses',
            manage: false,
            display: this.userStore.userHasFeature('EXPENSES')
          }]
      },
      displayedTabs () {
        return this.tabs.filter(tab => tab.display && tab.manage === this.manage)
      },
      manage() {
        return this.$route.path.includes('manage')
      }
    },
    created() {
    },
    data() {
      return {
        snackbar: {},
        model: '',
      }
    },
    methods: {
      goToPath() {
        if(this.manage) {
          this.$router.push('/expenses/reimbursementRequests')
        } else {
          this.$router.push('/expenses/manage/monthlyBudgets')
        }
      },
    }
  }
</script>

<style lang="scss">
#expense-management-header .v-slide-group__prev {
  display: none !important;
}
</style>
