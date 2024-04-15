<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1 mb-1" id="expense-management-header">
          <v-toolbar-title>
            <a-btn
                fab
                variant="text"
                v-if="userIsAdmin || userCanManage"
                size="small"
                color="primary"
                class="mr-2"
                @click="goToPath()"
                :prepend-icon="manage ? 'mdi-view-list' : 'settings'"
            ></a-btn>
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

<script setup>
import { mapStores } from 'pinia'

import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const model = ref('')
const userCanManage = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'MANAGE')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('EXPENSES', 'ADMIN')
})
const tabs = computed(() => {
  return [
    {
      label: 'Monthly Budgets',
      path: '/expenses/manage/monthlyBudgets',
      manage: true,
      display: userStore.userHasFeature('EXPENSES')
    },
    {
      label: 'Budget Templates',
      path: '/expenses/manage/budgetTemplates',
      manage: true,
      display: userStore.userHasFeature('EXPENSES')
    },
    {
      label: 'Budget Types',
      path: '/expenses/manage/budgetTypes',
      manage: true,
      display: userStore.userHasFeature('EXPENSES')
    },
    {
      label: 'GL Codes',
      path: '/expenses/manage/glCodes',
      manage: true,
      display: userStore.userHasFeature('EXPENSES')
    },
    {
      label: 'Reimbursement Requests',
      path: '/expenses/reimbursementRequests',
      manage: false,
      display: userStore.userHasFeature('EXPENSES')
    }, {
      label: 'Submitted Expenses',
      path: '/expenses/submittedExpenses',
      manage: false,
      display: userStore.userHasFeature('EXPENSES')
    }]
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display && tab.manage === manage.value)
})
const manage = computed(() => {
  return route.path.includes('manage')
})

const goToPath = () => {
  if(manage.value) {
    router.push('/expenses/reimbursementRequests')
  } else {
    router.push('/expenses/manage/monthlyBudgets')
  }
}
</script>

<style lang="scss">
#expense-management-header .v-slide-group__prev {
  display: none !important;
}
</style>
