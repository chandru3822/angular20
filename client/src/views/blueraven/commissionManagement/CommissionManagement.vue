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
  import {BrsMutations} from '@/stores/BrsStore'

  export default {
    name: 'Commissions',

    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
    },
    created() {
      if(!this.$store.state.brs.commissionPositionId) {
        this.changeSelectedPosition(1)
      }
    },
    data() {
      return {
        snackbar: {},
        model: '',
        selectedPositionId: this.$store.state.brs.commissionPositionId,
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ],
        tabs: [ {
          label: 'Users',
          path: `/commissionManagement/users`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Commissions',
          path: `/commissionManagement/commissions`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Overrides',
          path: `/commissionManagement/overrides`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Accounting Review',
          path: `/commissionManagement/accounting/current`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        }, {
          label: 'Payroll Search',
          path: `/commissionManagement/payroll`,
          display: this.$store.getters.userHasFeature('COMMISSIONS')
        },
        //   {
        //   label: 'Residual Plans',
        //   path: '/commissionManagement/residualPlans',
        //   display: this.$store.getters.userHasFeature('COMMISSIONS')
        // }, {
        //   label: 'Residuals',
        //   path: '/commissionManagement/residuals',
        //   display: this.$store.getters.userHasFeature('COMMISSIONS')
        // }
        ]
      }
    },
    methods: {
      changeSelectedPosition(positionId) {
        this.$store.commit(BrsMutations.SET_COMMISSION_POSITION_ID, positionId)
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

