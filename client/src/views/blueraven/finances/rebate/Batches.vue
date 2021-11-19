<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider></v-divider>
    <v-toolbar class="mt-3" flat color="white">
      <v-select attach v-model="batchId"
                class="batches-select"
                label="Select a Batch"
                :items="batches"
                no-data-text="No Batches Available"
                item-value="id"
                @change="getBatchDetails(batchId)"
      >
        <template slot='selection' slot-scope='{ item }'>
          #{{ item.displayName }}
        </template>
        <template slot='item' slot-scope='{ item }'>
          #{{ item.displayName }}
        </template>
      </v-select>
      <v-text-field
          class="mt-5 pay-search"
          prepend-inner-icon="search"
          text
          label="Search payments..."
          v-model="searchQuery"
          v-show="batchLoaded"
          @input="debounceFilterPayments"
      ></v-text-field>
      <span class="pl-4" v-show="batchLoaded">Payment Amount Total: <b>{{ paymentSum || 0 | currency('$', 2) }}</b></span>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn style="margin-right: 40px" v-show="batchLoaded" @click="exportChase">Download Chase CSV</v-btn>
        <v-btn v-show="batchLoaded" @click="exportPayments">Export</v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>

    <v-col cols="12" v-show="batchLoaded">

      <v-data-table
        :headers="visibleHeaders"
        :items="filteredPayments"
        :footer-props="footerProps"
        :search="paymentsSearch"
        :options="pagination"
        :items-per-page="-1"
        :mobile-breakpoint="0"
        fixed-header
        dense
        class="elevation-1 pay-table"
      >

        <template #body="{ items }" class="table-body">
          <tr
            v-for="(it, index) in items"
            :key="it.id"
            :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
          >
            <td class="text-left"><a href="" @click="goToDetails(it)"> {{ it.projectName ? it.projectName : '' }}</a></td>
            <td class="text-left">{{ it.projectId ? it.projectId : '' }}</td>
            <td class="text-left">{{ it.paymentNbr ? it.paymentNbr : '' }}</td>
            <td class="text-left">{{ it.paymentAmount || 0 | currency('$', 2) }}</td>
            <td class="text-left">{{ it.checkNumber ? it.checkNumber : '' }}</td>
          </tr>
        </template>
      </v-data-table>

    </v-col>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {handleHidingGlobalLoader, getRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import moment from 'moment'
  import { saveAs } from 'file-saver'
  import {mapState} from "vuex";
  import debounce from "lodash.debounce";

  const FILTER_TYPE = {
    TEXT: 'text',
    SELECT: 'select'
  }

  const FILTER_DEFAULTS = {
    projectName: {value: [], type: FILTER_TYPE.TEXT, model: 'projectName'},
    projectId: {value: [], type: FILTER_TYPE.TEXT, model: 'projectId'}
  }

  export default {
    name: 'Batches',

    created() {
      this.getAllBatches()
    },
    data() {
      return {
        snackbar: {},
        footerProps: {
            'items-per-page-options': [25, 50, 100, 500],
            'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
        },
        headers: [
          {text: 'Project Name', value: 'projectName', show: true},
          {text: 'Project ID', value: 'projectId', show: true},
          {text: 'Payment #', value: 'paymentNbr', show: true},
          {text: 'Payment Amount', value: 'paymentAmount', show: true},
          {text: 'Check #', value: 'checkNumber', show: true},
        ],
        batches: [],
        payments: [],
        batchId: '',
        batchLoaded: false,
        paymentSearchFilters: {
          projectName: [],
          projectId: []
        },
        paymentsSearch: '',
        pagination: {},
        paymentSum: 0,
        batchDisplayName: '',
        newPayDialog: false,
        searchQuery: '',
        filteredPayments: []
      }
    },
    computed: {
      visibleHeaders () {
        return this.headers.filter(header => header.show === true)
      },
      ...mapState({
        loading: state => state.app.loading
      })
    },
    watch: {
      'payments': function () {
        let paymentAmountSum = 0;
        this.filteredPayments.forEach(p => {
          paymentAmountSum += p.paymentAmount;
        });
        this.paymentSum = paymentAmountSum;
      }
    },
    methods: {
      async getAllBatches () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/rebate/getBatches/', 'blueraven')
          this.batches = data

          this.batches.forEach(b => {
            b.displayName  = b.id + ' - ' + this.formatDate(b.batchDate) + ' - ' + b.updatedByUser;
          });

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Batches')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getBatchDetails(batchId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/rebate/getBatchDetails/' + batchId, 'blueraven')
          this.payments = data.rebatePayments;
          this.filteredPayments = data.rebatePayments;
          this.batchDisplayName = data.id + ' - ' + this.formatDate(data.batchDate) + ' - ' + data.updatedByUser;
          this.batchLoaded = true;
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Batch Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async exportPayments () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let csvData = 'Project Name,Project ID,Payment #,Payment Amount,Check #\n';
          this.filteredPayments.forEach(p => {
            csvData += p.projectName + ',' + p.projectId + ',' + p.paymentNbr + ',' + p.paymentAmount
              + ',' + p.checkNumber + '\n';
          })
          let blob = new Blob([csvData], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, this.batchDisplayName+".csv");
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Batch')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async exportChase () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest('/rebate/getBatchDetails/' + this.batchId + '/chase-csv', 'blueraven')
          let blob = new Blob([data], {
            type: 'text/csv;charset=utf-8'
          });
          saveAs(blob, 'ChaseCSV_Batch_'+this.batchId+".csv");
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Exporting Chase CSV')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      debounceFilterPayments: debounce( function () {
          this.filteredPayments = this.payments && this.payments.filter(pay => {

              return (pay['projectName'].toLowerCase().includes(this.searchQuery.toLowerCase()) ||
                  pay['projectId'].toString().includes(this.searchQuery.toLowerCase()) ||
                  pay['paymentNbr'].toString().includes(this.searchQuery.toLowerCase()) ||
                  (pay['checkNumber'] == null ? false : pay['checkNumber'].toString().includes(this.searchQuery.toLowerCase()))
              )
          })
      }, 500),
      formatDate(value){
        if (value) {
          return moment(String(value)).format('MM/DD/YYYY')
        }
      },
      goToDetails (item) {
        this.$router.push({name: 'rebateDetails', params: {id: item.projectId}})
      },
      addItem () {
        this.newPayDialog = true
      },
      changeSort (column) {
        if (this.pagination.sortBy === column) {
          this.pagination.descending = !this.pagination.descending
        } else {
          this.pagination.sortBy = column
          this.pagination.descending = false
        }
      }
    }
  }
</script>

<style lang="scss">
  #commissions-container .v-data-table__wrapper {
    height: calc(100vh - 350px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  .v-data-table {
    border-radius: 0;
  }
  .batches-select {
    max-width: 500px;
  }
  .pay-search {
      margin-left: 30px;
  }
</style>
