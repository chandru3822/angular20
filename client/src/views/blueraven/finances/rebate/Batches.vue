<template>
  <v-container class="pa-0" id="commissions-container">
    <v-divider></v-divider>
    <v-card flat color="white" class="px-3 mt-3 square-card">
      <div class="pay-header pb-3">
        <v-select v-model="batchId"
                  class="batches-select"
                  label="Select a Batch"
                  hide-details
                  :items="batches"
                  no-data-text="No Batches Available"
                  item-value="id"
                  @change="getBatchDetails(batchId)"
        >
          <template slot='selection' slot-scope='{ item }'>
            <span v-if="item.voidedBatch" class="error--text mr-2">VOIDED</span>
            #{{ item.displayName }}
          </template>
          <template slot='item' slot-scope='{ item }'>
            <span v-if="item.voidedBatch" class="error--text mr-2">VOIDED</span>
            #{{ item.displayName }}
          </template>
        </v-select>
        <v-spacer></v-spacer>
        <span class="pl-4"
              v-show="batchLoaded && !voidedBatch">Payment Amount Total: <b>{{ paymentSum || 0 | currency('$', 2) }}</b></span>


        <v-dialog
          v-model="showVoidDialog"
          v-if="batchLoaded && batchId === maxBatchId && userIsAdmin && !voidedBatch"
          width="500">
          <template #activator="{ on }">
            <v-btn color="red" class="white--text ml-3" v-on="on"
                   :disabled="disableVoidButton()">
              VOID BATCH
            </v-btn>
          </template>
          <v-card>
            <v-card-title
              class="text-h5 grey lighten-2"
              primary-title>
              Confirm
            </v-card-title>

            <v-card-text class="pt-4">
              Are you sure you want to void this batch? This will reset each approved payment in this batch and cannot be undone.
            </v-card-text>

            <v-divider></v-divider>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn
                @click="showVoidDialog = false">
                No
              </v-btn>
              <v-btn
                color="primary"
                text
                @click="voidBatch()"
              >
                Yes
              </v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
        <v-spacer></v-spacer>
        <div class="btn-container">
          <v-btn class="mr-3" text color="primary" v-show="batchLoaded && !voidedBatch" @click="exportChase">Download Chase CSV</v-btn>
          <v-btn color="primary" class="white--text" v-show="batchLoaded && !voidedBatch"
                 @click="exportPayments">Export
          </v-btn>
        </div>
      </div>
      <div>
        <v-text-field
          prepend-inner-icon="search"
          text
          label="Search payments..."
          v-model="searchQuery"
          v-show="batchLoaded && !voidedBatch"
          @input="debounceFilterPayments"
        ></v-text-field>
      </div>
    </v-card>
    <v-divider></v-divider>

    <v-col cols="12" class="px-0" v-show="batchLoaded">

      <div v-if="voidedBatch" class="error--text">
        Voided Batch: No Payment Details Available
      </div>

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
        v-else
        class="elevation-1 pay-table"
      >


        <template #item="{ item: it, index }">
          <tr :class="{'shaded-row': index % 2}">
            <td class="text-left"><a href="" @click="goToDetails(it)"> {{ it.projectName ? it.projectName : '' }}</a>
            </td>
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

import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import moment from 'moment'
import {saveAs} from 'file-saver'
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
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('REBATES', 'ADMIN'),
      batchLoaded: false,
      paymentSearchFilters: {
        projectName: [],
        projectId: []
      },
      paymentsSearch: '',
      voidedBatch: false,
      pagination: {},
      paymentSum: 0,
      showVoidDialog: false,
      batchDisplayName: '',
      maxBatchId: null,
      newPayDialog: false,
      searchQuery: '',
      filteredPayments: []
    }
  },
  computed: {
    visibleHeaders() {
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
    async getAllBatches() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/rebate/getBatches/', 'blueraven')
        this.batches = data

        this.batches.forEach(b => {
          b.displayName = b.id + ' - ' + this.formatDate(b.batchDate) + ' - ' + b.updatedByUser;
        });

        this.maxBatchId = Math.max(...this.batches.map(b => b.id))

        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Batches')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    disableVoidButton() {
      //dont allow voiding batch if not the most recent batch OR if any payment in the batch has a check number
      return this.batchId !== this.maxBatchId || this.payments.some(p => p.checkNumber != null)
    },
    async voidBatch() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest('/rebate/voidBatch/' + this.batchId, {},'blueraven')
        this.voidedBatch = true
        this.showVoidDialog = false
        handleHidingGlobalLoader(this, status)
        this.snackbar = getSnackbar('SUCCESS', 'Batch Voided')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Voiding Batch')
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
        this.voidedBatch = data.voidedBatch
        this.batchLoaded = true;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Batch Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportPayments() {
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
        saveAs(blob, this.batchDisplayName + ".csv");
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Batch')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async exportChase() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest('/rebate/getBatchDetails/' + this.batchId + '/chase-csv', 'blueraven')
        let blob = new Blob([data], {
          type: 'text/csv;charset=utf-8'
        });
        saveAs(blob, 'ChaseCSV_Batch_' + this.batchId + ".csv");
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Chase CSV')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    debounceFilterPayments: debounce(function () {
      this.filteredPayments = this.payments && this.payments.filter(pay => {

        return (pay['projectName'].toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          pay['projectId'].toString().includes(this.searchQuery.toLowerCase()) ||
          pay['paymentNbr'].toString().includes(this.searchQuery.toLowerCase()) ||
          (pay['checkNumber'] == null ? false : pay['checkNumber'].toString().includes(this.searchQuery.toLowerCase()))
        )
      })
    }, 500),
    formatDate(value) {
      if (value) {
        return moment(String(value)).format('MM/DD/YYYY')
      }
    },
    goToDetails(item) {
      this.$router.push({name: 'rebateDetails', params: {id: item.projectId}})
    },
    addItem() {
      this.newPayDialog = true
    },
    changeSort(column) {
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
  height: calc(100vh - 375px);
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

.btn-container {
  display: flex;
  align-items: center;
}

.pay-header {
  display: flex;
  align-items: center;
}
</style>
