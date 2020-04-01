<template>
  <v-container class="pa-0">
    <v-form ref="payrollForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <DatetimePickerInput
                v-model="payrollSearch.startDate"
                :timezone="this.timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Start Date"
            />
            <v-text-field text
                          label="Customer"
                          v-model="payrollSearch.customerName"></v-text-field>
            <v-text-field text
                          label="Project ID"
                          v-model="payrollSearch.projectId"></v-text-field>
          </v-col>
          <v-col cols="12" sm="6">
            <DatetimePickerInput
                v-model="payrollSearch.endDate"
                :timezone="this.timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="End Date"
            />
            <v-text-field text
                          label="Sales Rep"
                          v-model="payrollSearch.salesRep"></v-text-field>
            <div class="text-left">
              <v-btn color="primaryCustom" dark @click="getPayrollData">Search</v-btn>
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
              <td class="text-left">{{item.periodEnd | formatDate('date')}}</td>
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
    name: 'Payroll',
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      this.getPayrollData()
    },
    data() {
      return {
        snackbar: {},
        payrollSearch: {},
        dataLoading: false,
        timezone: this.$store.state.user.details.timezone.value,
        headers: [
          {text: 'ID', value: 'id', show: true},
          {text: 'Period End', value: 'periodEnd', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: 'Current Pay', value: 'currentPay', show: true},
          {text: '', value: 'icons', show: true},
        ],
        payrollData: []
      }
    },
    methods: {
      async getPayrollData () {
        console.log('getPayrollData', this.payrollSearch)
        this.dataLoading = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = this.payrollSearch
          const {data} = await postRequest(`/payroll/search`, params, 'blueraven')
          this.payrollData = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Payroll Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async viewDetails (item) {
        console.log('randaLogger', item)
        this.$router.push({name: 'payroll', params: { id: item.id }})
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

