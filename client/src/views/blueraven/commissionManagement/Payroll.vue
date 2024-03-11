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
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  import {useRoute} from "vue-router/composables";
  const route = useRoute()
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const model = ref('')

  const tabs = computed(() => {
    return [ {
      label: 'Payroll Review',
      path: `/commissionManagement/payroll/${route.params.id}/review`,
      display: userStore.userHasFeature('COMMISSIONS')
    }, {
      label: 'Summary',
      path: `/commissionManagement/payroll/${route.params.id}/summary`,
      display: userStore.userHasFeature('COMMISSIONS')
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

