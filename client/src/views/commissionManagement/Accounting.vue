<template>
  <v-container class="pa-0">
    <v-toolbar flat color="transparent">
      <v-toolbar-title class="app-title">
        This payroll is {{currentPayroll.status}}.
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text color="primaryCustom" dark>
          Submit for Approval
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-form ref="accountingForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-text-field text readonly label="Payroll ID #" v-model="currentPayroll.id"></v-text-field>
            <DatetimePickerInput
                v-model="accountingSearch.endDate"
                :timezone="this.timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Period Ending"
            />
            <v-text-field text
                          label="Description"
                          v-model="accountingSearch.description"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <v-text-field text
                          label="Deal ID"
                          v-model="accountingSearch.dealId"></v-text-field>
            <v-text-field text
                          label="Customer"
                          v-model="accountingSearch.customer"></v-text-field>
            <v-text-field text
                          label="Sales Rep"
                          v-model="accountingSearch.salesRep"></v-text-field>
            <div class="text-left">
              <v-btn color="primaryCustom" dark>Search</v-btn>
              <v-btn class="ml-3" @click="payrollSearch = {}">Reset</v-btn>
            </div>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-data-table
            :headers="headers"
            :items="accountingData"
            :fixed-header="true"
            disable-sort
            :loading="dataLoading"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available accounting data
          </template>

          <template #no-results>
            No available accounting data
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
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Accounting',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      this.getAccountingData()
      this.getCurrentPayroll()
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        timezone: this.$store.state.user.details.timezone.value,
        headers: [
          {text: 'Project ID', value: 'id', show: true},
          {text: 'Customer Name', value: 'customerName', show: true},
          {text: 'System Size (kW)', value: 'systemSize', show: true},
          {text: 'Sales Rep', value: 'salesRep', show: true},
          {text: 'Current Pay', value: 'currentPay', show: true},
          {text: '', value: 'icons', show: true},
        ],
        accountingData: [],
        // currentPayroll: {},
        currentPayroll: {
          status: 'pending',
          id: 47
        },
        accountingSearch: {}
      }
    },
    methods: {
      async getCurrentPayroll () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/payroll/current`, 'blueraven')
          this.currentPayroll = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Current Payroll')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAccountingData () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/accountReview/search`, 'blueraven')
          this.accountingData = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Accounting Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
  .v-data-table {
    border-radius: 0;
  }
</style>

