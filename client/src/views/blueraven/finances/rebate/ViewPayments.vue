<template>
  <v-container class="pa-0">
    <v-card flat color="white" class="px-3 mt-3 square-card">
      <div class="pay-header">
        <v-select v-model="status"
                  class="status-select pt-3 pl-1"
                  :items="statuses"
                  no-data-text="No Status Available"
                  label="Status: "
                  item-text="text"
                  item-value="value"
                  v-bind:class="status"
                  @change="fetchPayments()"
        ></v-select>
        <v-spacer></v-spacer>
        <div v-if="status === 'approval'" class="pl-4">Payment Amount Total: <b>{{
            paymentSum || 0 | currency('$', 2)
          }}</b></div>
        <div v-if="showApproval" class="approvalDiv">
<!--          not sure why they need to see this. it just shows them their own name -->
<!--          <label><b>Approved By:</b></label>-->
<!--          {{ userName }}-->
<!--          <br/>-->
          <v-btn color="primaryCustom" dark @click="approveDialog = true" class="ml-3">Approve and Create Batch</v-btn>
        </div>

        <v-spacer></v-spacer>
        <v-btn color="primaryCustom" class="white--text" @click="exportPayments">Export</v-btn>
      </div>
      <div>
        <v-text-field
          prepend-inner-icon="search"
          text
          label="Search payments..."
          v-model="searchQuery"
          @input="debounceFilterPayments"
        ></v-text-field>
      </div>
    </v-card>

    <v-col cols="12" class="px-0 pt-0">
      <v-data-table
        :headers="visibleHeaders"
        :items="filteredPayments"
        :search="paymentsSearch"
        :options="pagination"
        :footer-props="footerProps"
        :items-per-page="itemsPerPage"
        :show-select="showSelect"
        fixed-header
        dense
        class="elevation-1 pay-table"
      >

        <template #no-data>
          No payments found
        </template>

        <template #no-results>
          No payments found
        </template>

        <template v-slot:header.data-table-select="{ on, props }">
          <v-checkbox :disabled="!userCanEdit" color="primaryCustom" class="mx-2" v-model="selectAll"
                      @change="toggleSelectAll()"></v-checkbox>
        </template>

        <template #body="{ items }">
          <tr
            v-for="(it, index) in items"
            :key="it.id"
            :class="['text-sm-left', 'row-hover', { 'shaded-row': !(index % 2) }]"
          >
            <td v-if="status === 'approval'" class="flex-display justify-center">
              <v-checkbox color="primaryCustom" :readonly="!userCanEdit"
                          :disabled="!userCanEdit" v-model="it.selected"></v-checkbox>
            </td>
            <td class="text-left" v-if="status === 'invalid' || status === 'approval'"><a v href=""
                                                                                          @click="goToDetails(it)">
              {{ it.projectName ? it.projectName : '' }}</a></td>
            <td class="text-left" v-else>{{ it.projectName ? it.projectName : '' }}</td>
            <td class="text-left">
              <router-link :to="`/project/${it.projectId}/details`">{{ it.projectId }}</router-link>
            </td>
            <td class="text-left">{{ it.substantialCompletionDate | formatDate('date') }}</td>
            <td class="text-left">{{ it.financier ? it.financier : '' }}</td>
            <td class="text-left">{{ it.product ? it.product : '' }}</td>
            <td class="text-center">{{ it.totalPromotionAmount || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-center">{{ it.numberOfPromotionPayments }}</td>
            <td v-show="status === 'approval'" class="text-center">{{ it.paymentAmount || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-center">{{ it.totalPaid || 0 | currency('$', 2) }}</td>
            <td v-show="status === 'approval'" class="text-left">{{ it.lastPaymentDate | formatDate('date') }}</td>
            <td v-show="status === 'invalid' || status === 'approval'" class="text-left">
              {{ it.balanceOwed || 0 | currency('$', 2) }}
            </td>
            <td v-show="status === 'pending'" class="text-left"><a v-if="userCanEdit" @click="enterPayment(it)"
                                                                   class="mr-3 pay-link">Enter Now</a></td>
          </tr>
        </template>
      </v-data-table>

      <v-dialog v-model="newPayDialog" max-width="1000px">
        <v-card>
          <v-card-title>
            <span class="text-h5">New Recurring Payment</span>
          </v-card-title>
          <v-card-text>
            <v-row>
              <v-col>
                <v-text-field label="Project Name"
                              v-model="newPayItem.projectName"
                              disabled
                ></v-text-field>
                <v-text-field label="Project ID"
                              v-model="newPayItem.projectId"
                              disabled
                ></v-text-field>
                <v-text-field label="Substantial Completion"
                              v-model="newPayItem.sc"
                              disabled
                ></v-text-field>
                <v-text-field label="Financier"
                              v-model="newPayItem.financier"
                              disabled
                ></v-text-field>
                <v-text-field label="Product"
                              v-model="newPayItem.product"
                              disabled
                ></v-text-field>
              </v-col>
              <v-col>
                <v-text-field label="Total Promotion Amount"
                              v-model="newPayItem.totalPromotionAmount"
                ></v-text-field>
                <v-text-field label="# of Promotion Payments"
                              v-model="newPayItem.numberOfPromotionPayments"
                ></v-text-field>
                <v-text-field label="$ / Promotion Payment"
                              v-model="perPromotionPayment"
                              disabled>
                </v-text-field>
                <v-text-field label="Verified By"
                              v-model="newPayItem.createdBy"
                              disabled
                ></v-text-field>
              </v-col>
            </v-row>
          </v-card-text>

          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn color="secondaryButton" text @click="close">Cancel</v-btn>
            <v-btn color="primaryButton" raised @click="submitPay" class="white--text">
              Submit
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-col>
    <v-dialog v-model="approveDialog" max-width="600px">
      <v-card>
        <v-card-title
          class="text-h5 grey lighten-2"
          primary-title
        >
          Confirm
        </v-card-title>

        <v-card-text>
          This will approve and create a batch for the selected payments, would you like to proceed?
        </v-card-text>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="approveDialog = false">
            Cancel
          </v-btn>
          <v-btn
            color="primaryButton"
            text
            @click="passwordDialog = true">
            Confirm
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="passwordDialog" max-width="600px">
      <v-card>
        <v-card-title
          class="text-h5 grey lighten-2"
          primary-title
        >
          Please confirm payment approval
        </v-card-title>

        <v-text-field class="passwordTextfield"
                      label="Please confirm your password:"
                      v-model="passwordInput"
                      type="password"
                      required
        ></v-text-field>

        <v-divider></v-divider>

        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            @click="passwordDialog = false, approveDialog = false">
            Cancel
          </v-btn>
          <v-btn
            color="primaryButton"
            text
            @click="confirmPassword()">
            Confirm
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import Snackbar from '@/components/Snackbar.vue'
import constants from '@/helpers/constants'
import {AppMutations} from '@/stores/AppStore'
import {saveAs} from 'file-saver'
import moment from "moment";
import debounce from "lodash.debounce";

export default {
  name: 'Payments',
  components: {Snackbar},
  data() {
    return {
      snackbar: {},
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      payments: [],
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('REBATES', 'EDIT'),
      headers: [
        {text: 'Project Name', value: 'projectName', show: true},
        {text: 'Project ID', value: 'projectId', show: true},
        {text: 'Substantial Completion', value: 'substantialCompletionDate', show: true},
        {text: 'Financier', value: 'financier', show: true},
        {text: 'Product', value: 'product', show: true},
        {text: 'Total Promotion Amount', value: 'totalPromotionAmount', show: true},
        {text: '# Payments', value: 'numberOfPromotionPayments', show: false},
        {text: 'Payment Amount', value: 'paymentAmount', show: false},
        {text: 'Total Paid', value: 'totalPaid', show: false},
        {text: 'Last Payment Date', value: 'lastPaymentDate', show: false},
        {text: 'Balance Owed', value: 'balanceOwed', show: false}
      ],
      statuses: [
        {
          text: 'New Pending',
          value: 'pending'
        },
        {
          text: 'Needs Approval',
          value: 'approval'
        },
        {
          text: 'Invalid',
          value: 'invalid'
        }
      ],
      status: 'approval',
      newPayItem: {
        projectName: '',
        projectId: 0,
        sc: '',
        financier: '',
        product: '',
        totalPromotionAmount: 0,
        numberOfPromotionPayments: 0,
        paymentAmount: 0,
        verifiedBy: '',
        createdByUserId: '',
        paymentStartDate: '',
        selected: false,
      },
      paymentsSearch: '',
      pagination: {},
      selectAll: false,
      showSelect: false,
      itemsPerPage: 50,
      userName: '',
      approveDialog: false,
      passwordDialog: false,
      newPayDialog: false,
      passwordInput: '',
      searchQuery: '',
      filteredPayments: []
    }
  },
  computed: {
    visibleHeaders() {
      return this.headers.filter(header => header.show === true)
    },
    perPromotionPayment() {
      return this.newPayItem.numberOfPromotionPayments == 0 ? 0 : (this.newPayItem.totalPromotionAmount / this.newPayItem.numberOfPromotionPayments).toFixed(2);
    },
    showApproval() {
      return this.payments.filter(p => p.selected === true).length > 0
    },
    paymentIdsToApprove() {
      return this.payments.filter(p => p.selected === true).map(p => p.paymentId)
    },
    paymentSum() {
      let sum = 0;
      let selectedPayments = this.filteredPayments.filter(p => p.selected === true);
      if (selectedPayments.length > 0) {
        selectedPayments.forEach(p => sum += p.paymentAmount)
      } else {
        this.filteredPayments.forEach(p => sum += p.paymentAmount)
      }

      return sum;
    }
  },
  watch: {},
  created() {
    this.$store.commit(AppMutations.SET_LOADING, true)
    Promise.all([
      this.fetchPayments()
    ]).then(() => this.$store.commit(AppMutations.SET_LOADING, false))
  },
  methods: {
    async fetchPayments() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.status === 'approval') {
          const {data, status} = await getRequest('/rebate/needsApproval', 'blueraven')
          this.showSelect = true;
          // # Of Payments
          this.headers[6].show = true;
          //Payment Amount
          this.headers[7].show = true;
          // Total Paid
          this.headers[8].show = true;
          // Last Payment Date
          this.headers[9].show = true;
          // Balance Owed
          this.headers[10].show = true;

          this.payments = data;
          this.filteredPayments = data;

          let userData = await getRequest('/user/current')
          this.userName = userData.data.fullName;
          handleHidingGlobalLoader(this, status)
        } else if (this.status === 'pending') {
          const {data, status} = await getRequest('/rebate/pending', 'blueraven')
          this.payments = data;
          this.filteredPayments = data;

          this.showSelect = false;
          // # Of Payments
          this.headers[6].show = false;
          //Payment Amount
          this.headers[7].show = false;
          // Total Paid
          this.headers[8].show = false;
          // Last Payment Date
          this.headers[9].show = false;
          // Balance Owed
          this.headers[10].show = false;

          handleHidingGlobalLoader(this, status)
        } else if (this.status === 'invalid') {
          const {data, status} = await getRequest('/rebate/unbalancedPayments', 'blueraven')
          this.payments = data;
          this.filteredPayments = data;

          this.showSelect = false;
          // # Of Payments
          this.headers[6].show = false;
          //Payment Amount
          this.headers[7].show = false;
          // Total Paid
          this.headers[8].show = false;
          // Last Payment Date
          this.headers[9].show = false;
          // Balance Owed
          this.headers[10].show = false;
          // Balance Owed
          this.headers[10].show = true;
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error retrieving rebate payments')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    debounceFilterPayments: debounce(function () {
      this.filteredPayments = this.payments.filter(pay => {
        return (pay['projectName'].toLowerCase().includes(this.searchQuery.toLowerCase()) ||
          pay['projectId'].toString().toLowerCase().includes(this.searchQuery.toLowerCase())
        )
      })

      if (this.itemsPerPage > this.filteredPayments.length) {
        this.itemsPerPage = this.filteredPayments.length;
      }
    }, 500),
    async exportPayments() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let filename = '';
        let csvData = 'Project Name,Project ID,Substantial Completion,Financier,Product,Total Promotion Amount';
        if (this.status === 'approval') {
          filename = 'Needs Approval Payments.csv';
          csvData += ',# of Payments,$ / Promotion Payment,' +
            'Total Paid,Last Payment Date,Balance Owed';
        } else if (this.status === 'invalid') {
          filename = 'Invalid Payments.csv';
          csvData += ',Balance Owed';
        } else if (this.status === 'pending') {
          filename = 'New Pending Payments.csv';
        }

        csvData += '\n';

        this.filteredPayments.forEach(p => {
          csvData += p.projectName + ',' + p.projectId + ',' +
            (p.substantialCompletionDate != null ? moment(p.substantialCompletionDate).format('MM/DD/YYYY') : '') +
            ',' + p.financier + ',' + p.product + ',' + p.totalPromotionAmount;

          if (this.status === 'approval') {
            csvData += ',' + p.numberOfPromotionPayments + ',' + p.paymentAmount + ',' + p.totalPaid + ',' +
              (p.lastPaymentDate != null ? moment(p.lastPaymentDate).format('MM/DD/YYYY') : '');
          }

          if (this.status === 'approval' || this.status === 'invalid') {
            csvData += ',' + p.balanceOwed;
          }

          csvData += '\n';
        })

        let blob = new Blob([csvData], {
          type: 'text/csv;charset=utf-8'
        });

        saveAs(blob, filename);
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Exporting Proposal Logs')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    enterPayment(item) {
      if (item.substantialCompletionDate != null) {
        item.sc = moment(item.substantialCompletionDate).format('MM/DD/YYYY')
      }

      this.newPayItem = Object.assign({}, item)
      this.newPayDialog = true
    },
    close() {
      this.newPayDialog = false
      this.newPayItem = {}
    },
    async submitPay() {
      try {
        const {status} = await postRequest('/rebate/recurringPayment', this.newPayItem, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Recurring Payment Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
        await this.fetchPayments();
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Failed to save Recurring Payment')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.newPayDialog = false;
    },
    changeSort(column) {
      if (this.pagination.sortBy === column) {
        this.pagination.descending = !this.pagination.descending
      } else {
        this.pagination.sortBy = column
        this.pagination.descending = false
      }
    },
    goToDetails(item) {
      this.$router.push({name: 'rebateDetails', params: {id: item.projectId}})
    },
    toggleSelectAll() {
      this.filteredPayments.forEach(p => {
        p.selected = this.selectAll
      })
    },
    async confirmPassword() {
      try {
        const params = {password: this.passwordInput}
        const resp = await postRequest('/user/validate', params)
        const {status} = resp

        if (status === 200) {
          let param = {paymentIds: this.paymentIdsToApprove}
          await postRequest('/rebate/approve', param, 'blueraven')
          window.location.reload()
        }

        this.passwordDialog = false;
        this.approveDialog = false;
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Failed to approve payment')
        this.passwordDialog = false;
        this.approveDialog = false;
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.pay-link {
  color: var(--v-brBlue-base);
  text-decoration: none;

  &:hover {
    text-decoration: underline;
    color: var(--v-primaryText-base);
  }
}

.pay-table {
  margin-top: 2px;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 390px);
}

.v-data-table ::v-deep .v-data-table-header th {
  padding: 0;
  white-space: nowrap;
}

.status-select {
  max-width: 200px;
}

.pending {
  outline: 2px solid orange;
}

.approval {
  outline: 2px solid blue;
}

.invalid {
  outline: 2px solid red;
}

.approvalDiv {
  color: black;
  font-size: 14px
}

.passwordTextfield {
  width: 500px;
  margin-left: 40px;
}

.pay-header {
  display: flex;
  align-items: center;
}
</style>
