<template>
  <div>
    <dl class="dl-horizontal row">
      <dt class="left-align">Project Name:</dt>
      <dd>{{rebateDetails.project_name}}</dd>

      <dt class="left-align">Project ID:</dt>
      <dd>
        <router-link :to="`/project/${rebateDetails.project_id}/details`">{{rebateDetails.project_id}}</router-link>
        <br/>
      </dd>
      <dt class="left-align">Customer Address:</dt>
        <br/>
      <dd>
        {{rebateDetails.street1}} {{rebateDetails.street2}}
      </dd>
      <dt class="left-align">&nbsp;</dt>
      <dd>
        {{rebateDetails.city}}, {{rebateDetails.state}} {{rebateDetails.postal_code}}
      </dd>
      <dt class="left-align">Mailing Address:</dt>
      <br/>
      <!-- if all mailing address fields are null then show the add button -->
      <dd v-if="!editMailing && rebateDetails.mailing_street1 == null && rebateDetails.mailing_city == null && rebateDetails.mailing_state == null && rebateDetails.mailing_postal_code == null">
        <v-btn text v-if="userCanEdit"  @click="editMailing = true">
          <v-icon>add</v-icon>
          Add
        </v-btn>
      </dd>

      <!-- if edit mode enabled then show inputs -->
      <dd v-if="editMailing" class="edit-mail-div">
        <div class="addr-inputs">
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="Street 1:"
                        v-model="rebateDetails.mailing_street1">
          </v-text-field>
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
          <v-select v-model="rebateDetails.mailing_state_id"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit"
                    :items="states"
                    label="State"
                    item-text="state"
                    item-value="id"
          ></v-select>
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="Postal Code:"
                        v-model="rebateDetails.mailing_postal_code">
          </v-text-field>
          <v-btn class="ma-2" @click="saveMailingAddress(false)"
                 v-if="userCanEdit"
                  :disabled="!rebateDetails.mailing_street1 || !rebateDetails.mailing_city || !rebateDetails.mailing_state_id || !rebateDetails.mailing_postal_code">
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
          {{rebateDetails.mailing_city}}, {{mailingDetails.mailingStateAbbr}} {{rebateDetails.mailing_postal_code}}<br/>
        </dd>

        <dt class="left-align">&nbsp;</dt>
        <dd>
          <a v-if="userCanEdit" @click="editMailing = true">click to edit</a>
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
            {{rebateDetails.total_promotion_amount || 0 | currency('$', 2) }}
            <v-icon small class="mr-3" @click="editTotalPromotionAmount = true">
              edit
            </v-icon>
          </div>
          <div v-if="editTotalPromotionAmount" class="flex-display" style="width: 100px">
            <v-text-field style="width: 80px" type="number" v-model="rebateDetails.total_promotion_amount">
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
                  <a v-if="item.payment_state_id === 3" @click="openVoidDialog(item)">Void</a>
                </td>
                  <td>
                      <v-btn v-if="item.payment_state_id != 3 && item.payment_state_id != 2 && $store.getters.userHasFeatureAccessLevel('REBATES', 'DELETE')"
                          @click="openDeleteDialog(item)" text><v-icon>delete</v-icon></v-btn>
                  </td>
              </tr>
            </template>
          </v-data-table>

          <v-dialog v-model="deleteConfirm" width="500">
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
                      @click="deleteConfirm = false">
                      No
                    </v-btn>
                    <v-btn
                      color="primaryCustom"
                      text
                      @click="deletePayment()">
                      Yes
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

              <v-dialog v-model="notesDialog" max-width="600px">
                <v-card class="pt-4 pb-2">
                  <v-card-title class="flex-display justify-space-between pt-0 px-4">
                    <span class="font-weight-bold">Notes</span>
                  </v-card-title>

                  <template>
                  <v-card-text>
                    <v-row>
                      <v-col>
                        <v-text-field v-model="notesItem.void_note" outlined auto-grow rows="5">
                        </v-text-field>
                      </v-col>
                    </v-row>
                  </v-card-text>
                  </template>

                  <v-card-actions class="flex-display justify-end px-4 pt-0">
                    <v-btn v-if="userCanEdit" @click="updatePaymentNote()">Confirm</v-btn>
                    <v-btn v-if="userCanEdit" @click="cancelNotesDialog()">Close</v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

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
                          <v-text-field v-model="notesItem.void_note" outlined auto-grow>
                          </v-text-field>
                        </v-col>
                      </v-row>
                    </v-card-text>
                  </template>

                  <v-card-actions class="flex-display justify-end px-4 pt-0">
                    <v-btn @click="voidPayment(notesItem)">Yes</v-btn>
                    <v-btn @click="cancelVoidDialog()">Close</v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>

        </v-col>
      </v-row>

      <v-row>
        <v-col>
          <div>
          <tr>
            <td class="left-align">
              <v-icon v-if="userCanAdd" :disabled="rebateDetails.sumOfNonCanceledPayments >= rebateDetails.total_promotion_amount"
                      @click="addNewRow()">
                add
              </v-icon>
            </td>
            <td></td>
            <td></td>
            <td class="text-center font-weight-bold" :class="{'error-message': rebateDetails.sumOfNonCanceledPayments > rebateDetails.total_promotion_amount}">
              {{rebateDetails.sumOfNonCanceledPayments || 0 | currency('$', 2)  }} <br>
              <span class="error-message" v-if="remainingBalance < 0">({{remainingBalance || 0 | currency('$', 2) }})<br></span>
              (Non-Canceled)
            </td>
            <td>
              <v-icon v-if="userCanEdit" :disabled="rebateDetails.sumOfNonCanceledPayments > rebateDetails.total_promotion_amount"
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

  </div>
</template>
<script>
  import {AppMutations} from '@/stores/AppStore'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import moment from "moment";
  import {getCompanyStates} from '@/services/stateService'

  export default {
    name: 'RebateDetails',
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
        mailingDetails: {
            mailingStreet1: null,
            mailingStreet2: null,
            mailingCity: null,
            mailingStateAbbr: null,
            mailingStateId: null,
            mailingPostalCode: null
        },
        states: [],
        editMailing: false,
        notesDialog: false,
        voidDialog: false,
        deleteConfirm: false,
        notesItem: {
            void_note: ''
        },
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
          await this.getStates();
          const {data} = await getRequest(`/rebate/details/` + this.projectIdIn, 'blueraven')
          this.rebateDetails = data[0];
          debugger;
          this.rebateDetails.sc = moment(this.rebateDetails.sc).format('MM/DD/YYYY')
          this.rebateDetails.entered_into_system_date = moment(this.rebateDetails.entered_into_system_date).format('MM/DD/YYYY')

          let payment_amount = 0;
          if (this.rebateDetails.numberofpromotionpayments > 0) {
            payment_amount = parseFloat(this.rebateDetails.total_promotion_amount) / parseFloat(this.rebateDetails.numberofpromotionpayments)
          }
          this.rebateDetails.payment_amount = payment_amount;
          this.mailingDetails = {
              mailingStreet1: this.rebateDetails.mailing_street1,
              mailingStreet2: this.rebateDetails.mailing_street2,
              mailingCity: this.rebateDetails.mailing_city,
              mailingStateAbbr: this.rebateDetails.mailing_state_abbr,
              mailingStateId: this.rebateDetails.mailing_state_id,
              mailingPostalCode: this.rebateDetails.mailing_postal_code
          }

          this.maxPayment = this.rebateDetails.payment_history.reduce((a,b) => Number(a.payment_nbr) > Number(b.payment_nbr) ? a : b)
          this.maxPaymentNumber = this.maxPayment && this.maxPayment.payment_nbr ? this.maxPayment.payment_nbr + 1 : 1
          this.getTotals();
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving rebate details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          this.rebateDetails.mailing_state_id = null
          this.rebateDetails.mailing_state_abbr = null
          this.rebateDetails.mailing_postal_code = null
          this.mailingDetails = {
            mailingStreet1: null,
            mailingStreet2: null,
            mailingCity: null,
            mailingStateAbbr: null,
            mailingStateId: null,
            mailingPostalCode: null
          }
        }

        let contact = {
          id: this.rebateDetails.contact_id,
          mailingStreet1: this.rebateDetails.mailing_street1,
          mailingStreet2: this.rebateDetails.mailing_street2,
          mailingCity: this.rebateDetails.mailing_city,
          companyStateId: this.rebateDetails.mailing_state_id,
          mailingPostalCode: this.rebateDetails.mailing_postal_code,
        }

        this.mailingDetails = {
          mailingStreet1: this.rebateDetails.mailing_street1,
          mailingStreet2: this.rebateDetails.mailing_street2,
          mailingCity: this.rebateDetails.mailing_city,
          mailingStateAbbr: this.states.filter(state => state.id === this.rebateDetails.mailing_state_id)[0].abbreviation,
          mailingStateId: this.rebateDetails.mailing_state_id,
          mailingPostalCode: this.rebateDetails.mailing_postal_code
        }

        try {
          const {data} = await putRequest(`/contact/updateMailingAddress`, contact)
          this.snackbar = getSnackbar('SUCCESS', 'Mailing address saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.editMailing = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving mailing address')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      cancelMailingEdit () {
        //reset the values back to the copied ones
        this.rebateDetails.mailing_street1= this.mailingDetails.mailingStreet1
        this.rebateDetails.mailing_street2 = this.mailingDetails.mailingStreet2
        this.rebateDetails.mailing_city = this.mailingDetails.mailingCity
        this.rebateDetails.mailing_state_abbr = this.mailingDetails.mailingStateAbbr
        this.rebateDetails.mailing_state_id = this.mailingDetails.mailingStateId
        this.rebateDetails.mailing_postal_code = this.mailingDetails.mailingPostalCode
        this.editMailing = false;
      },
      openNotesDialog(item) {
          this.notesDialog = true
          this.notesValue = item.void_note
          this.notesItem = item
      },
      openVoidDialog(item) {
          this.notesValue = item.void_note
          this.notesItem = item
          this.voidDialog = true;
      },
      openDeleteDialog(item) {
        this.deleteItem = item;
        this.deleteConfirm = true;
      },
      cancelNotesDialog(){
        this.notesDialog = false
        this.notesItem.void_note = this.notesValue
        this.notesValue = ''
      },
      cancelVoidDialog() {
        this.voidDialog = false
        this.notesItem.void_note = this.notesValue
        this.notesValue = ''
      },
      async updateTotalPromotionAmount() {
        this.editTotalPromotionAmount = false

        const params = {
          totalPromotionAmount: this.rebateDetails.total_promotion_amount,
          projectId: this.rebateDetails.project_id
        }
        try {
          const {data} = await postRequest(`/rebate/updateTotalPromotionAmount`, params, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Total Promotion Amount saved!')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.editMailing = false;
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving Total Promotion Amount')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
      async deletePayment() {
        // If row already existed
        if (this.deleteItem.id) {
          try {
            const {data} = await deleteRequest('/rebate/deletePayment/' + this.deleteItem.id, 'blueraven')
            this.rebateDetails.payment_history = this.rebateDetails.payment_history.filter(ph => ph.payment_nbr !== this.deleteItem.payment_nbr)
            this.editMailing = false;
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error deleting payment')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        } else {
          this.rebateDetails.payment_history = this.rebateDetails.payment_history.filter(ph => ph.payment_nbr !== this.deleteItem.payment_nbr)
        }

        this.getTotals()
          this.deleteConfirm = false
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
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        this.remainingBalance = this.sumOfNonCanceledPayments - parseFloat(this.rebateDetails.total_promotion_amount)
      },
      async updatePaymentNote() {
        try {
          let params = {
            paymentId: this.notesItem.id,
            voidNote: this.notesItem.void_note
          }

          const {data} = await postRequest(`/rebate/updateNote`, params, 'blueraven')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving payment note')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          item.void_note = '';
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error voiding payment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        this.voidDialog = false;
        await this.fetchPayments();
      },
      async getStates () {
          try {
            const {data} = await getCompanyStates()
            this.states = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
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
