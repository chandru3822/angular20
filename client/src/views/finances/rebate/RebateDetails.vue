<template>
  <div>
    <dl class="dl-horizontal row">
      <dt class="left-align">Project Name:</dt>
      <dd>{{rebateDetails.project_name}}</dd>

      <dt class="left-align">Project ID:</dt>
      <dd>
        <a target="_blank" :href="'https://app.futuresimple.com/sales/deals/' + rebateDetails.project_id">
          {{rebateDetails.project_id}}
        </a>
        <br/>
      </dd>
      <dt class="left-align">Customer Address:</dt>
      <dd>
        {{rebateDetails.street1}} {{rebateDetails.street2}}
      </dd>
      <dt class="left-align">&nbsp;</dt>
      <dd>
        {{rebateDetails.city}}, {{rebateDetails.state}} {{rebateDetails.postal_code}}
      </dd>
      <dt class="left-align">Mailing Address:</dt>
      <!-- if all mailing address fields are null then show the add button -->
      <dd v-if="!editMailing && rebateDetails.mailing_street1 == null && rebateDetails.mailing_city == null && rebateDetails.mailing_state == null && rebateDetails.mailing_postal_code == null">
        <v-btn text v-if="userCanEdit"  @click="editMailing = true"><!-- :disabled="!hasPermission('HR_ADMIN','REBATE_ADMIN')"-->
          <v-icon>add</v-icon>
          Add
        </v-btn>
      </dd>

      <!-- if edit mode enabled then show inputs -->
      <dd v-if="editMailing" class="edit-mail-div">
        <v-text-field text
                      :readonly="!userCanEdit"
                      :disabled="!userCanEdit"
                      type="text"
                      label="Street 1:"
                      v-model="rebateDetails.mailing_street1">
        </v-text-field>
        <div class="addr-inputs">
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="Street 2:"
                        v-model="rebateDetails.mailing_street2">
          </v-text-field>
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="City:"
                        v-model="rebateDetails.mailing_city">
          </v-text-field>
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="State:"
                        maxlength="2"
                        v-model="rebateDetails.mailing_state">
          </v-text-field>
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="Postal Code:"
                        v-model="rebateDetails.mailing_postal_code">
          </v-text-field>
          <v-btn class="ma-2" @click="saveMailingAddress(false)"
                 v-if="userCanEdit"
                  :disabled="!rebateDetails.mailing_street1 || !rebateDetails.mailing_city || !rebateDetails.mailing_state || !rebateDetails.mailing_postal_code">
            Save
          </v-btn>
          <v-btn class="ma-2" @click="saveMailingAddress(true)"
                  v-if="mailingDetails.mailingStreet1 != null && userCanEdit">
            Remove
          </v-btn>
          <v-btn class="ma-2" @click="cancelMailingEdit()">
            Cancel
          </v-btn>
        </div>
      </dd>

      <div v-if="!editMailing && (rebateDetails.mailing_street1 != null || rebateDetails.mailing_city != null || rebateDetails.mailing_state != null || rebateDetails.mailing_postal_code != null)">
        <dd>
          {{rebateDetails.mailing_street1}} {{rebateDetails.mailing_street2}}<br/>
        </dd>
        <dt class="left-align">&nbsp;</dt>
        <dd>
          {{rebateDetails.mailing_city}}, {{rebateDetails.mailing_state}} {{rebateDetails.mailing_postal_code}}<br/>
        </dd>
        <dt class="left-align">&nbsp;</dt>
        <dd>
          {{rebateDetails.city}}, {{rebateDetails.state}} {{rebateDetails.postal_code}}
        </dd>

        <dt class="left-align">&nbsp;</dt>
        <dd>
          <a @click="editMailing = true">click to edit</a> <!-- :disabled="!hasPermission('HR_ADMIN','REBATE_ADMIN')"-->
        </dd>

      </div>
    </dl>

    <table class="rebate-table left-align">
      <thead>
      <tr>
        <th colspan="4">Customer Details</th>
      </tr>
      </thead>
      <tbody>
      <tr>
        <td>Substantial Completion</td>
        <td>{{rebateDetails.sc}}</td>
        <td>Entered Into Payment System</td>
        <td>{{rebateDetails.entered_into_system_date}}</td>
      </tr>
      <tr>
        <td>Financier</td>
        <td>{{rebateDetails.financier}}</td>
        <td>Total Paid</td>
        <td>{{rebateDetails.total_paid || 0 | currency('$', 2) }}</td>
      </tr>
      <tr>
        <td>Product</td>
        <td>{{rebateDetails.product}}</td>
        <td>Balance Owed</td>
        <td :class="rebateDetails.red_balanced_owed ? 'error-message' : ''">{{rebateDetails.balance_owed || 0 | currency('$', 2) }}</td>
      </tr>
      <tr>
        <td>Total Promotion Amount</td>
        <td>
          <div v-if="editTotalPromotionAmount == false">
            {{rebateDetails.totalpromotionamount || 0 | currency('$', 2) }}
            <v-icon small class="mr-3" @click="editTotalPromotionAmount = true">
              edit
            </v-icon>
          </div>
          <div v-if="editTotalPromotionAmount" class="flex-display" style="width: 100px">
            <v-text-field style="width: 80px" type="number" v-model="rebateDetails.totalpromotionamount">
            </v-text-field>
            <v-icon @click="updateTotalPromotionAmount()">
                save
            </v-icon>
          </div>
        </td>
        <td>$ / Promotion Payment</td>
        <td>{{rebateDetails.payment_amount || 0 | currency('$', 2) }}</td>
      </tr>
      <tr>
        <td># of Promotion Payments</td>
        <td>{{rebateDetails.numberofpromotionpayments}}</td>
        <td></td>
        <td></td>
      </tr>
      </tbody>
    </table>

    <v-container>
      <v-row>
        <v-col>
          <v-data-table
            :headers="headers"
            :items="rebateDetails.payment_history"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            class="elevation-1"
          >
            <template #no-data>
              No available payment history
            </template>

            <template #no-results>
              No available payment history
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left">{{item.payment_nbr}}</td>
                <td class="text-left">{{item.batch_id}}</td>
                <td class="text-left">{{item.batch_date | formatDate('date')}}</td>
                <td class="text-left">
                  <v-text-field type="number" v-model="item.payment_amount"
                                @change="getTotals()" :disabled="canEditPayment(item)">
                  </v-text-field>
                </td>
                <td class="text-left">{{item.name}}</td>
                <td class="text-left">{{item.check_number}}</td>
                <td class="text-left">
                  <a v-if="item.id != null && userCanEdit" @click="openNotesDialog(item)">+ Note</a><br/>
                  {{item.void_note}}
                </td>
                <td class="text-left" style="color: red">
                  <a v-if="item.payment_state_id === 3" @click="voidDialog = true">Void</a>
                </td>
                <td>
                  <v-dialog v-model="voidDialog" max-width="600px" v-if="userCanEdit">
                    <v-card class="pt-4 pb-2">
                      <v-card-title class="flex-display justify-space-between pt-0 px-4">
                        <span class="font-weight-bold">Confirm</span>
                      </v-card-title>

                      <template>
                        <v-card-text>
                          <v-row>
                            <v-col>
                              Are you sure you want to void this payment?
                              <v-text-field v-model="item.void_note" outlined auto-grow>
                              </v-text-field>
                            </v-col>
                          </v-row>
                        </v-card-text>
                      </template>

                      <v-card-actions class="flex-display justify-end px-4 pt-0">
                        <v-btn @click="voidPayment(item)">Yes</v-btn>
                        <v-btn @click="voidDialog = false">Close</v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>

                  <v-dialog
                    v-model="item.deleteConfirm"
                    v-if="item.payment_state_id != 3 && item.payment_state_id != 2 && $store.getters.userHasFeatureAccessLevel('REBATES', 'DELETE')"
                    width="500">
                    <template v-slot:activator="{ on }">
                      <v-btn small text class="clickable" v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="headline grey lighten-2"
                        primary-title
                      >
                        Confirm
                      </v-card-title>

                      <v-card-text>
                        Are you sure you want to delete this payment?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primary"
                          text
                          @click="deletePayment(item)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </td>
              </tr>

              <v-dialog v-model="notesDialog" max-width="600px">
                <v-card class="pt-4 pb-2">
                  <v-card-title class="flex-display justify-space-between pt-0 px-4">
                    <span class="font-weight-bold">Notes</span>
                  </v-card-title>

                  <template>
                  <v-card-text>
                    <v-row>
                      <v-col>
                        <v-text-field v-model="item.void_note" outlined auto-grow rows="5">
                        </v-text-field>
                      </v-col>
                    </v-row>
                  </v-card-text>
                  </template>

                  <v-card-actions class="flex-display justify-end px-4 pt-0">
                    <v-btn v-if="userCanEdit" @click="updatePaymentNote(item)">Confirm</v-btn>
                    <v-btn v-if="userCanEdit" @click="cancelNotesDialog(item)">Close</v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </template>
          </v-data-table>
        </v-col>
      </v-row>

      <v-row>
        <v-col>
          <div>
          <tr>
            <td class="left-align">
              <v-icon v-if="userCanAdd" :disabled="rebateDetails.sumOfNonCanceledPayments >= rebateDetails.totalpromotionamount"
                      @click="addNewRow()">
                add
              </v-icon>
            </td>
            <td></td>
            <td></td>
            <td class="text-center font-weight-bold" :class="{'error-message': rebateDetails.sumOfNonCanceledPayments > rebateDetails.totalpromotionamount}">
              {{rebateDetails.sumOfNonCanceledPayments || 0 | currency('$', 2)  }} <br>
              <span class="error-message" v-if="remainingBalance < 0">({{remainingBalance || 0 | currency('$', 2) }})<br></span>
              (Non-Canceled)
            </td>
            <td>
              <v-icon v-if="userCanEdit" :disabled="rebateDetails.sumOfNonCanceledPayments > rebateDetails.totalpromotionamount"
                      @click="savePaymentHistoryChanges()">
                save
              </v-icon>
            </td>
            <td></td>
          </tr>
          </div>
        </v-col>
      </v-row>
    </v-container>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </div>
</template>
<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import moment from "moment";

  export default {
    name: 'RebateDetails',
    components: {
      Snackbar
    },
    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      }
    },
    data() {
      return {
        snackbar: {},
        model: '',
        projectIdIn: parseInt(this.$route.params.id),
        headers: [
          { text: 'Payment Number', value: 'payment_nbr', show: true },
          { text: 'Batch ID', value: 'batch_id', show: true },
          { text: 'Batch Date', value: 'batch_date', show: true },
          { text: 'Amount', value: 'payment_amount', show: true },
          { text: 'Status', value: 'name', show: true },
          { text: 'Check Number', value: 'check_number', show: true },
          { text: 'Notes', value: 'void_note', show: true }
        ],
        rebateDetails: {},
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('REBATES', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('REBATES', 'EDIT'),
        mailingDetails: {},
        editMailing: false,
        notesDialog: false,
        voidDialog: false,
        voidConfirmMsg: '',
        notesValue: '',
        editTotalPromotionAmount: false,
        sumOfNonCanceledPayments: 0,
        maxPaymentNumber: 0,
        maxPayment: 0,
        remainingBalance: 0
      }
    },
    created () {
      this.fetchPayments();
    },
    methods: {
      async fetchPayments() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/rebate/details/` + this.projectIdIn, 'blueraven')
          this.rebateDetails = data[0];
          this.rebateDetails.sc = moment(this.rebateDetails.sc).format('MM/DD/YYYY')
          this.rebateDetails.entered_into_system_date = moment(this.rebateDetails.entered_into_system_date).format('MM/DD/YYYY')

          let payment_amount = 0;
          if (this.rebateDetails.numberofpromotionpayments > 0) {
            payment_amount = parseFloat(this.rebateDetails.totalpromotionamount) / parseFloat(this.rebateDetails.numberofpromotionpayments)
          }
          this.rebateDetails.payment_amount = payment_amount;
          this.mailingDetails = {
            mailingStreet1: this.rebateDetails.mailing_street1,
            mailingStreet2: this.rebateDetails.mailing_street2,
            mailingCity: this.rebateDetails.mailing_city,
            mailingState: this.rebateDetails.mailing_state,
            mailingPostalCode: this.rebateDetails.mailing_postal_code
          }

          this.maxPayment = this.rebateDetails.payment_history.reduce((a,b) => Number(a.payment_nbr) > Number(b.payment_nbr) ? a : b)
          this.maxPaymentNumber = this.maxPayment && this.maxPayment.payment_nbr ? this.maxPayment.payment_nbr + 1 : 1
          this.getTotals();
          this.$store.commit(AppMutations.SET_LOADING, false)

        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving rebate details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      canEditPayment(p) {
        let disabled = false
        if (p.payment_state_id === 3 || p.payment_state_id === 5) {
          //if processed or voided don't allow editing
          disabled = true
        }
        return disabled || !this.userCanEdit
      },
      async saveMailingAddress(removeAddress) {
        if (removeAddress) {
          this.editMailing = false
          //reset original and copy back to null
          this.rebateDetails.mailing_street1 = null
          this.rebateDetails.mailing_street2 = null
          this.rebateDetails.mailing_city = null
          this.rebateDetails.mailing_state = null
          this.rebateDetails.mailing_postal_code = null
          this.mailingDetails = {
            mailingStreet1: null,
            mailingStreet2: null,
            mailingCity: null,
            mailingState: null,
            mailingPostalCode: null
          }
        }

        let contact = {
          id: this.rebateDetails.contact_id,
          mailingStreet1: this.rebateDetails.mailing_street1,
          mailingStreet2: this.rebateDetails.mailing_street2,
          mailingCity: this.rebateDetails.mailing_city,
          state: this.rebateDetails.mailing_state,
          mailingPostalCode: this.rebateDetails.mailing_postal_code,
        }

        this.mailingDetails = {
          mailingStreet1: this.rebateDetails.mailing_street1,
          mailingStreet2: this.rebateDetails.mailing_street2,
          mailingCity: this.rebateDetails.mailing_city,
          mailingState: this.rebateDetails.mailing_state,
          mailingPostalCode: this.rebateDetails.mailing_postal_code
        }

        try {
          const {data} = await putRequest(`/contact/updateMailingAddress`, contact)
          this.snackbar = getSnackbar('SUCCESS', 'Mailing address saved')
          this.editMailing = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving mailing address')
        }
      },
      cancelMailingEdit () {
        //reset the values back to the copied ones
        this.rebateDetails.mailing_street1= this.mailingDetails.mailingStreet1
        this.rebateDetails.mailing_street2 = this.mailingDetails.mailingStreet2
        this.rebateDetails.mailing_city = this.mailingDetails.mailingCity
        this.rebateDetails.mailing_state = this.mailingDetails.mailingState
        this.rebateDetails.mailing_postal_code = this.mailingDetails.mailingPostalCode
        this.editMailing = false;
      },
      openNotesDialog(item) {
        this.notesDialog = true
        this.notesValue = item.void_note
      },
      cancelNotesDialog(item){
        this.notesDialog = false
        item.void_note = this.notesValue
        this.notesValue = ''
      },
      async updateTotalPromotionAmount() {
        this.editTotalPromotionAmount = false

        const params = {
          totalPromotionAmount: this.rebateDetails.totalpromotionamount,
          projectId: this.rebateDetails.project_id
        }
        try {
          const {data} = await postRequest(`/rebate/updateTotalPromotionAmount`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Total Promotion Amount saved!')
          this.editMailing = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving Total Promotion Amount')
        }
      },
      addNewRow() {
        this.rebateDetails.payment_history.push({
          id: null,
          payment_amount: 0,
          payment_nbr: this.maxPaymentNumber,
          originalPaymentStateId: 1,
          payment_state_id: 1,
          name: 'Needs approval'
        })
        this.getTotals()
        this.maxPaymentNumber++
      },
      async deletePayment(item) {
        // If row already existed
        if (item.id) {
          try {
            const {data} = await deleteRequest('/rebate/deletePayment' + item.id, 'blueraven')
            this.rebateDetails.payment_history = this.rebateDetails.payment_history.filter(ph => ph.payment_nbr !== item.payment_nbr)
            this.editMailing = false;
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error deleting payment')
          }
        } else {
          this.rebateDetails.payment_history = this.rebateDetails.payment_history.filter(ph => ph.payment_nbr !== item.payment_nbr)
        }

        this.getTotals()
        item.deleteConfirm = false
      },
      async savePaymentHistoryChanges() {
        for (const ph of this.rebateDetails.payment_history) {
          try {
            if (ph.id) {
              let params = {
                paymentId: ph.id,
                paymentAmount: ph.payment_amount,
                paymentStateId: ph.payment_state_id
              }
              const {data} = await postRequest(`/rebate/updatePayment`, params, 'blueraven')
            } else {
              let params = {
                projectId: this.rebateDetails.project_id,
                paymentAmount: ph.payment_amount
              }
              const {data} = await postRequest(`/rebate/addExtraPayment`, params, 'blueraven')
            }
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error saving payments')
          }
        }

        this.getTotals()
      },
      getTotals() {
        this.sumOfNonCanceledPayments = 0;
        this.rebateDetails.payment_history.forEach(ph => {
          if (ph.payment_state_id !== 4 && ph.payment_state_id !== 5) {
            this.sumOfNonCanceledPayments += parseFloat(ph.payment_amount)
          }
        })
        this.remainingBalance = this.sumOfNonCanceledPayments - parseFloat(this.rebateDetails.totalpromotionamount)
      },
      async updatePaymentNote(item) {
        try {
          let params = {
            paymentId: item.id,
            voidNote: item.void_note
          }

          const {data} = await postRequest(`/rebate/updateNote`, params, 'blueraven')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving payment note')
        }

        this.notesDialog = false
      },
      async voidPayment(item) {
        try {
          let params = {
            paymentId: item.id,
            voidNote: item.void_note
          }

          const {data} = await postRequest(`/rebate/voidPayment`, params, 'blueraven')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error voiding payment')
        }

        this.voidDialog = false;
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
  @media (min-width: 768px) {

    dt {
      float: left; width: 100px;
      font-size: 14px;
      color: black;
    }

    dd {
      margin-left: 100px;
      text-align: left;
      color: black;
      font-size: 14px;
      color: black;
    }

    dl {
      display: block;
      margin-block-start: 1em;
      margin-block-end: 1em;
      margin-inline-start: 0px;
      margin-inline-end: 0px;
    }

    .dl-horizontal dt {
      width: 150px;
      font-weight: bold;
      line-height: 1.42857143;
    }

    .dl-horizontal dd {
      margin-left: 165px;
      line-height: 1.42857143;
      display: block;
      margin-inline-start: 40px;
    }
  }

  .auto-width {
    width: auto !important;
  }

  .left-align {
    text-align: left !important;
  }

  .addr-inputs {
    margin-left: 110px;
  }

  .edit-mail-div {
    width: 350px;
    padding-top: 0px !important;
    margin-top: 0px !important;
  }

  .rebate-table {
    width: 100%;
    max-width: 100%;
    margin-bottom: 20px;
  }

  .rebate-table > thead > tr > th {
    vertical-align: bottom;
    border-bottom: 2px solid #ddd;
  }

  .rebate-table > tbody > tr > td {
    padding: 5px;
    line-height: 1.42857143;
    vertical-align: top;
    /* border-top: 1px solid #ddd; */
  }

  .rebate-table > tr {
    display: table-row;
    vertical-align: inherit;
    border-color: inherit;
  }

  td {
    width: 200px;
    font-size: 14px;
    color: black;
  }

  th {
    font-size: 14px;
    color: black;
  }

  .error-message {
    color: red;
    font-weight: 600;
  }
</style>
