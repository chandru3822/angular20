<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-app-bar dense tabs color="white" class="elevation-1">
          <v-toolbar-title>Commission Management</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <div class="position-selector">
              <span class="d-inline-block">Position: </span>
              <v-select
                  class="d-inline-block ml-3"
                  v-model="commissionPositionId"
                  :items="positions"
                  label=""
                  hide-details
                  item-text="label"
                  item-value="id"
              ></v-select>
            </div>
          </v-toolbar-items>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
                  show-arrows
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

<script setup>
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useBrsStore} from '@/stores/BrsStorePinia.js'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import { storeToRefs } from 'pinia'
import {useRoute} from "vue-router/composables";

const route = useRoute()
const userStore = useUserStore()
const brsStore = useBrsStore()
const { commissionPositionId } = storeToRefs(brsStore)

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const userCanCommission = computed(() => {
  return userStore.userHasFeature('COMMISSIONS')
})
const userIsAdmin = computed(() => {
  return userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')
})

const tabs = computed(() => {
  return [{
    label: 'Users',
    path: `/commissionManagement/users`,
    display: userCanCommission.value
  }, {
    label: 'Commissions',
    path: `/commissionManagement/commissions`,
    display: userCanCommission.value
  }, {
    label: 'Overrides',
    path: `/commissionManagement/overrides`,
    display: userCanCommission.value
  }, {
    label: 'Accounting Review',
    path: `/commissionManagement/accounting/current`,
    display: userCanCommission.value
  }, {
    label: 'Payroll Search',
    path: `/commissionManagement/payroll`,
    display: userCanCommission.value
  }, {
    label: 'Residual Plans',
    path: '/commissionManagement/residualPlans',
    display: userCanCommission.value
  }, {
    label: 'Residuals',
    path: '/commissionManagement/residuals',
    display: userIsAdmin.value
  }, {
    label: 'Closer Residuals',
    path: '/commissionManagement/closerResiduals',
    display: userCanCommission.value
  }, {
    label: 'Residual Search',
    path: `/commissionManagement/residualSearch`,
    display: userCanCommission.value
  }
  ]
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})
onMounted(() => {
})

const model = ref('')
const positions = ref([
  {id: 1, label: 'Closer'},
  {id: 4, label: 'Setter'}
])

</script>

<style lang="scss" scoped>
.position-selector {
  display: flex;
  align-items: center;
}
</style>

