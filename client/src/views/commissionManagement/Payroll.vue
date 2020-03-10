<template>
  <v-container>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="payrollData"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available payroll data
          </template>

          <template #no-results>
            No available payroll data
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.id}}</td>
              <td class="text-left">{{item.periodEndDate | formatDate('date')}}</td>
              <td class="text-left">{{item.description}}</td>
              <td class="text-left">{{item.currentPay || 0 | currency('$', 2)}}</td>
              <td class="text-left">
                <v-btn class="clickable" small text @click="viewDetails(item)">
                  <v-icon >mdi-dots-horizontal-circle</v-icon>
                </v-btn>
              </td>
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
    name: 'Payroll',
    components: {
      Snackbar
    },
    created() {
      this.getPayrollData()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        headers: [
          {text: 'ID', value: 'id', show: true},
          {text: 'Period End', value: 'periodEndDate', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Current Pay', value: 'currentPay', show: true},
          {text: '', value: 'icons', show: true},
        ],
        payrollData: []
      }
    },
    methods: {
      async getPayrollData () {
        this.payrollData = [
          {
            id: 1,
            periodEndDate: '2020-03-31',
            description: 'this is here',
            currentPay: 1234.12,
          }
        ]
        // this.$store.commit(AppMutations.SET_LOADING, true)
        // try {
        //   const {data} = await getRequest(`/commissionManagement/closers`, 'blueraven')
        //   this.payrollData = data
        //   this.dataLoading = false
        //   this.$store.commit(AppMutations.SET_LOADING, false)
        // } catch (e) {
        //   console.error('*** ERROR ***', e)
        //   this.snackbar = getSnackbar('ERROR', 'Error Loading Payroll Data')
        //   this.$store.commit(AppMutations.SET_LOADING, false)
        // }
      },
      async viewDetails (item) {
        console.log('randaLogger', item)
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

