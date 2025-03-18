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
              <a-select
                class="d-inline-block ml-3"
                v-model="commissionPositionId"
                :items="availablePositions"
                label=""
                hide-details
                item-title="label"
                item-value="id"
              />
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
  import { useUserStore } from '@/stores/UserStore.js'
  import { useBrsStore } from '@/stores/BrsStore.js'
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import { storeToRefs } from 'pinia'

  const userStore = useUserStore()
  const brsStore = useBrsStore()
  const { commissionPositionId } = storeToRefs(brsStore)

  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  const isDealerTab = computed(() => {
    return [743,828].includes(commissionPositionId.value)
  })

  const userCanCommission = computed(() => {
    return userStore.userHasFeature('COMMISSIONS_CLOSER') ||
      userStore.userHasFeature('COMMISSIONS_DEALER') ||
      userStore.userHasFeature('COMMISSIONS_INSTALLATION_PARTNER')
  })

  const userIsAdmin = computed(() => {
    return userStore.userHasFeatureAccessLevel('COMMISSIONS_CLOSER', 'ADMIN') ||
      userStore.userHasFeatureAccessLevel('COMMISSIONS_DEALER', 'ADMIN') ||
      userStore.userHasFeatureAccessLevel('COMMISSIONS_INSTALLATION_PARTNER', 'ADMIN')
  })

  const tabs = computed(() => {
    return [{
      label: 'Users',
      path: `/commissionManagement/users`,
      display: userCanCommission.value && !isDealerTab.value,
    }, {
      label: 'Commissions',
      path: `/commissionManagement/commissions`,
      display: userCanCommission.value
    }, {
      label: 'Overrides',
      path: `/commissionManagement/overrides`,
      display: userCanCommission.value && !isDealerTab.value
    }, {
      label: 'Accounting Review',
      path: `/commissionManagement/accounting`,
      display: userCanCommission.value
    }, {
      label: 'Payroll Search',
      path: `/commissionManagement/payroll`,
      display: userCanCommission.value
    }, {
      label: 'Residual Plans',
      path: '/commissionManagement/residualPlans',
      display: userCanCommission.value && !isDealerTab.value
    }, {
      label: 'Residuals',
      path: '/commissionManagement/residuals',
      display: userIsAdmin.value && !isDealerTab.value
    }, {
      label: 'Closer Residuals',
      path: '/commissionManagement/closerResiduals',
      display: userCanCommission.value && !isDealerTab.value
    }, {
      label: 'Residual Search',
      path: `/commissionManagement/residualSearch`,
      display: userCanCommission.value && !isDealerTab.value
    }]
  })

  const displayedTabs = computed(() => {
    return tabs.value.filter(tab => tab.display)
  })

  onMounted(() => {
  })

  const model = ref('')
  const positions = ref([
    {id: 1, label: 'Closer'},
    {id: 4, label: 'Setter'},
    {id: 743, label: 'Dealer'},
    {id: 828, label: 'Installation Partner'}
  ])

  const availablePositions = computed(() => {
    return positions.value.filter(position => {
      switch (position.id) {
        case 1: // Closer
          return userStore.userHasFeature('COMMISSIONS_CLOSER')
        case 4: // Setter
          return userStore.userHasFeature('COMMISSIONS_SETTER')
        case 743: // Dealer
          return userStore.userHasFeature('COMMISSIONS_DEALER')
        case 828: // Installation Partner
          return userStore.userHasFeature('COMMISSIONS_INSTALLATION_PARTNER')
        default:
          return userStore.userHasFeature('COMMISSIONS_CLOSER')
      }
    })
  })

</script>

<style lang="scss" scoped>
  .position-selector {
    display: flex;
    align-items: center;
  }
</style>
