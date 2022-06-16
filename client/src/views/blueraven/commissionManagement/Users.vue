<template>
  <v-container class="pa-0" id="commission-closers-container">
    <v-row>
      <v-col>
        <v-card>
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-divider></v-divider>
          <v-data-table
              :headers="headers"
              :items="users"
              :fixed-header="true"
              :items-per-page="50"
              :loading="dataLoading"
              :search="search"
              :footer-props="footerProps"
              class="elevation-1"
          >
            <template #no-data>
              <div class="black--text">No available users</div>
            </template>

            <template #no-results>
              <div class="black--text">No available users</div>
            </template>

            <template #item="{ item, index }">
              <tr class="vertical-top" :class="{'shaded-row': index % 2}">
                <td class="text-left pt-1" >
                  <v-btn text color="primary" :to="{ name: 'commissionUser', params: {id: item.id} }">
                    {{item.name}}
                  </v-btn>
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.commissionPlan !== null" @click="goToDetails(item, 1)">
                    {{item.commissionPlan}}:<br/>
                    {{item.commissionDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <a v-if="item.overridePlan !== null" @click="goToDetails(item, 2)">
                    {{item.overridePlan}}:<br/>
                    {{item.overrideDescription}}
                  </a>
                  <div v-else class="pt-2">--</div>
                </td>
                <td class="text-left pt-1">
                  <span v-if="item.receivingPlans && item.receivingPlans.length > 0">
                    <div v-for="rp in item.receivingPlans">
                      <a @click="goToDetails(rp, 3)">
                        {{rp.receivingPlan}}:<br/>
                        {{rp.receivingDescription}}
                      </a>
                    </div>
                  </span>
                  <div v-else  class="pt-2">--</div>
                </td>
                <td class="text-left pt-3">{{item.hasCommissionPlanGap ? 'Yes' : 'No'}}</td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>
    </v-row>


  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Users',

    created() {
      this.getUsers()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        search: '',
        positionId: this.$store.state.brs.commissionPositionId,
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000]
        },
        headers: [
          {text: 'User', value: 'name', show: true},
          {text: 'Commissions Assigned To', value: 'commissionPlan', show: true},
          {text: 'Overrides Assigned To', value: 'overridePlan', show: true},
          {text: 'Receiving Overrides From', value: 'receivingPlan', show: true},
          {text: 'Has Commission Plan Gap', value: 'hasCommissionPlanGap', show: true},
        ],
        users: []
      }
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        this.positionId = this.$store.state.brs.commissionPositionId
        this.getUsers()
      }
    },
    methods: {
      async getUsers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let url = this.positionId === 1 ? '/commissionManagement/closers' : '/commissionManagement/setters'
          const {data, status} = await getRequest(url, 'blueraven', [])
          this.users = data.filter(d => d.isActiveUser)
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails(item, planType) {
        // 1 = commission, 2 = override, 3 = receiving
        let name = planType === 1 ? 'commission' : 'override'
        let id = planType === 1 ? item.commissionPlanId : planType === 2 ? item.overridePlanId : item.receivingPlanId
        this.$router.push({name, params: {id}})
      }
    }
  }
</script>

<style lang="scss">
#commission-closers-container .v-data-table__wrapper {
  height: calc(100vh - 350px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

