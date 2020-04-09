<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
          :headers="headers"
          :items="payrollSummary"
          :fixed-header="true"
          disable-sort
          :loading="dataLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available summary data
          </template>

          <template #no-results>
            No available summary data
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.closer_user}}</td>
              <td class="text-left">{{item.total_commission | currency('$', 2)}}</td>
              <td class="text-left">{{item.total_overrides | currency('$', 2)}}</td>
              <td class="text-left">{{item.commission_adjustments | currency('$', 2)}}</td>
              <td class="text-left">{{item.current_pay | currency('$', 2)}}</td>
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
    name: 'Summary',
    components: {
      Snackbar
    },
    created() {
      this.viewSummary()
    },
    data() {
      return {
        snackbar: {},
        payrollSummary: [],
        dataLoading: false,
        headers: [
          { text: 'Sales Rep', value: 'closer_user', show: true },
          { text: 'Total Commission', value: 'total_commission', show: true },
          { text: 'Total Overrides', value: 'total_overrides', show: true },
          { text: 'Adjustments', value: 'commission_adjustments', show: true },
          { text: 'Current Pay', value: 'current_pay', show: true },
        ],
      }
    },
    methods: {
      async viewSummary() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.dataLoading = true
        try {
          const {data} = await getRequest(`/payroll/${this.$route.params.id}/summary`, 'blueraven')
          this.payrollSummary = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Payroll Summary')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

