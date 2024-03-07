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
                v-model="selectedPositionId"
                :items="positions"
                label=""
                hide-details
                item-text="label"
                item-value="id"
                @change="changeSelectedPosition(selectedPositionId)"
              ></v-select>
            </div>
          </v-toolbar-items>
          <v-tabs :optional="false" color="primary"
                  slot="extension"
                  show-arrows
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
  import { useBrsStore } from '@/stores/BrsStorePinia.js'

  export default {
    name: 'Commissions',

    computed: {
      ...mapStores(useUserStore, useBrsStore),
      selectedPositionId() {
        return this.brsStore.commissionPositionId
      },
      tabs() {
        return [ {
          label: 'Users',
          path: `/commissionManagement/users`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Commissions',
          path: `/commissionManagement/commissions`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Overrides',
          path: `/commissionManagement/overrides`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Accounting Review',
          path: `/commissionManagement/accounting/current`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Payroll Search',
          path: `/commissionManagement/payroll`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Residual Plans',
          path: '/commissionManagement/residualPlans',
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Residuals',
          path: '/commissionManagement/residuals',
          display: this.userStore.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN')
        }, {
          label: 'Closer Residuals',
          path: '/commissionManagement/closerResiduals',
          display: this.userStore.userHasFeature('COMMISSIONS')
        }, {
          label: 'Residual Search',
          path: `/commissionManagement/residualSearch`,
          display: this.userStore.userHasFeature('COMMISSIONS')
        }
        ]
      },
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
    },
    created() {
      if(!this.brsStore.commissionPositionId) {
        this.changeSelectedPosition(1)
      }
    },
    data() {
      return {
        snackbar: {},
        model: '',
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ]
      }
    },
    methods: {
      changeSelectedPosition(positionId) {
        this.brsStore.commissionPositionId = positionId
        // this.$router.push(`/commissionManagement/${this.selectedPositionId}/users`)
      }
    }
  }
</script>

<style lang="scss" scoped>
.position-selector {
  display: flex;
  align-items: center;
}
</style>

