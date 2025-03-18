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

<script setup>
  import { getCurrentInstance, computed, ref } from 'vue'
  import {useUserStore} from '@/stores/UserStore.js'
  import {useRoute} from "vue-router/composables";
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const model = ref('')

  const userHasFeatureAccess = computed(() => {
    return userStore.userHasFeature('COMMISSIONS_CLOSER') ||
      userStore.userHasFeature('COMMISSIONS_SETTER') ||
      userStore.userHasFeature('COMMISSIONS_DEALER') ||
      userStore.userHasFeature('COMMISSIONS_INSTALLATION_PARTNER')
  })

  const tabs = computed(() => {
    return [{
      label: 'Payroll Review',
      path: `/commissionManagement/payroll/${route.params.id}/review`,
      display: userHasFeatureAccess.value,
    }, {
      label: 'Summary',
      path: `/commissionManagement/payroll/${route.params.id}/summary`,
      display: userHasFeatureAccess.value,
    }]
  })

  const displayedTabs = computed(() => {
    return tabs.value.filter(tab => tab.display)
  })

</script>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
</style>
