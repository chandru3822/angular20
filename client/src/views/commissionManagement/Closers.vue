<template>
  <v-container class="pa-0" id="commission-closers-container">
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="closers"
            :fixed-header="true"
            :items-per-page="100"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available closers
          </template>

          <template #no-results>
            No available closers
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-btn text :to="{ name: 'closer', params: {id: item.id} }">
                  {{item.name}}
                </v-btn>
              </td>
              <td class="text-left">
                <v-btn text v-if="item.commissionPlan !== null" @click="goToDetails(item, false)">
                  {{item.commissionPlan}}:<br/>
                  {{item.commissionDescription}}
                </v-btn>
                <v-btn v-else color="primaryCustom" dark @click="selectPlan(item, 1)">Add to Commission</v-btn>
              </td>
              <td class="text-left">
                <v-btn text v-if="item.overridePlan !== null" @click="goToDetails(item, true)">
                  {{item.overridePlan}}:<br/>
                  {{item.overrideDescription}}
                </v-btn>
                <v-btn v-else color="primaryCustom" dark @click="selectPlan(item, 2)">Assign to Override</v-btn>
              </td>
              <td class="text-left">
                <span v-if="item.receivingPlans && item.receivingPlans.length > 0">
                  <v-btn v-for="rp in item.receivingPlans" text @click="goToDetails(rp, true)">
                    {{rp.receivingPlan}}:<br/>
                    {{rp.receivingDescription}}
                  </v-btn>
                </span>
                <v-btn v-else color="primaryCustom" dark @click="selectPlan(item, 3)">Clone/Create New Plan</v-btn>
              </td>
              <td class="text-left">{{item.hasCommissionPlanGap ? 'Yes' : 'No'}}</td>
            </tr>
          </template>
        </v-data-table>
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
        headers: [
          {text: 'Closer Name', value: 'name', show: true},
          {text: 'Commissions Assigned To', value: 'assignedTo', show: true},
          {text: 'Overrides Assigned To', value: 'overridesAssignedTo', show: true},
          {text: 'Receiving Overrides From', value: 'receivingOverridesFrom', show: true},
          {text: 'Has Commission Plan Gap', value: 'planGap', show: true},
        ],
        closers: []
      }
    },
    methods: {
      async getClosers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
          this.closers = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Closers')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      selectPlan(item) {
        console.log('HANDLE SELECTING A PLAN: ', item)
      },
      goToDetails(item, isOverride) {
        let name = isOverride ? 'override' : 'commission'
        let id = item.commissionPlanId ?? item.receivingPlanId
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

