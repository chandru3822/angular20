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
              :items="closers"
              :fixed-header="true"
              :items-per-page="50"
              :loading="dataLoading"
              :search="search"
              :footer-props="footerProps"
              class="elevation-1"
          >
            <template #no-data>
              No available closers
            </template>

            <template #no-results>
              No available closers
            </template>

            <template #item="{ item, index }">
              <tr class="vertical-top" :class="{'shaded-row': index % 2}">
                <td class="text-left pt-1">
                  <v-btn text :to="{ name: 'closer', params: {id: item.id} }">
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
    <Snackbar :snackbar="snackbar"></Snackbar>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Closers',
    components: {
      Snackbar
    },
    created() {
      this.getClosers()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        search: '',
        footerProps: {
          'items-per-page-options': [25, 50, 100, 1000]
        },
        headers: [
          {text: 'Closer Name', value: 'name', show: true},
          {text: 'Commissions Assigned To', value: 'commissionPlan', show: true},
          {text: 'Overrides Assigned To', value: 'overridePlan', show: true},
          {text: 'Receiving Overrides From', value: 'receivingPlan', show: true},
          {text: 'Has Commission Plan Gap', value: 'hasCommissionPlanGap', show: true},
        ],
        closers: []
      }
    },
    methods: {
      async getClosers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
          this.closers = data.filter(d => d.isActiveCloser)
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Closers')
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

