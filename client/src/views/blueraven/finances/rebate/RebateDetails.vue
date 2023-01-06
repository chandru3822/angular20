<template>
  <div class="pt-6">
    <dl class="dl-horizontal row pl-4">
      <dt class="left-align">Project Name:</dt>
      <dd>{{rebateDetails.project_name}}</dd>

      <dt class="left-align">Project ID:</dt>
      <dd>
        <router-link :to="`/project/${rebateDetails.project_id}/details`">{{rebateDetails.project_id}}</router-link>
        <br/>
      </dd>
      <dt class="left-align">Customer Address:</dt>
      <dd>
        {{rebateDetails.street1}} {{rebateDetails.street2}}
      </dd>
      <dt class="left-align">&nbsp;</dt>
      <dd class="pb-1">
        {{rebateDetails.city}}, {{rebateDetails.state}} {{rebateDetails.postal_code}}
      </dd>
      <dt class="left-align">Mailing Address:</dt>
      <!-- if all mailing address fields are null then show the add button -->
      <dd v-if="!editMailing && rebateDetails.mailing_street1 == null && rebateDetails.mailing_city == null && rebateDetails.mailing_state == null && rebateDetails.mailing_postal_code == null">
        <v-btn text color="primary" small v-if="userCanEdit"  @click="editMailing = true" class="mt-n1 px-1">
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
          <v-autocomplete attach v-model="rebateDetails.mailing_state_id"
                    :readonly="!userCanEdit"
                    :disabled="!userCanEdit"
                    :items="states"
                    label="State"
                    item-text="state"
                    item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        type="text"
                        label="Postal Code:"
                        v-model="rebateDetails.mailing_postal_code">
          </v-text-field>
          <div class="d-flex justify-end">
            <v-btn class="my-2" text color="primary" small @click="cancelMailingEdit()">
            Cancel
          </v-btn>
            <v-btn class="my-2" text color="error" small @click="saveMailingAddress(true)"
                   v-if="mailingDetails.mailingStreet1 != null && userCanEdit">
              Remove
            </v-btn>
            <v-btn class="my-2 ml-2" color="primary" small @click="saveMailingAddress(false)"
                   v-if="userCanEdit"
                   :disabled="!rebateDetails.mailing_street1 || !rebateDetails.mailing_city || !rebateDetails.mailing_state_id || !rebateDetails.mailing_postal_code">
              Save
            </v-btn>
          </div>
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
          <a x-small text v-if="userCanEdit" class="primary--text clickable" @click="editMailing = true">click to edit</a>
        </dd>

      </div>
    </dl>

    <table class="rebate-table left-align pl-4 pt-2">
      <thead>
      <tr>
        <th colspan="4">Customer Details</th>
      </tr>
      </thead>
      <tbody>
      <tr>
        <td>Substantial Completion</td>
        <td>{{rebateDetails.sc}}</td>
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
            <v-icon small color="primary" class="mr-3" @click="editTotalPromotionAmount = true">
              edit
            </v-icon>
          </div>
          <div v-if="editTotalPromotionAmount" class="flex-display" style="width: 100px">
            <v-text-field style="width: 80px" type="number" v-model="rebateDetails.total_promotion_amount">
            </v-text-field>
            <v-icon color="primary" @click="updateTotalPromotionAmount()">
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
              <span class="default-text-color">No available payment history</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available payment history</span>
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
                  <a v-if="item.id != null && userCanEdit" class="primary--text" @click="openNotesDialog(item)"><v-icon x-small color="primary">{{item.void_note ? 'edit' : 'add'}}</v-icon> Note</a><br/>
                  {{item.void_note}}
                </td>
                <td class="text-left" style="color: red">
                  <a v-if="item.payment_state_id === 3 && userCanEdit" class="primary--text" @click="openVoidDialog(item)">Void</a>
                  <a v-if="item.payment_state_id === 5 && userCanEdit" class="primary--text" @click="openUnvoidDialog(item)">Unvoid</a>
                </td>
                  <td>
                      <v-btn v-if="item.payment_state_id != 3 && item.payment_state_id != 2 && $store.getters.userHasFeatureAccessLevel('REBATES', 'DELETE')"
                          @click="openDeleteDialog(item)" text color="primary"><v-icon>delete</v-icon></v-btn>
                  </td>
              </tr>
            </template>
          </v-data-table>

          <ConfirmationDialog :open-dialog="deleteConfirm"
                              @confirm="deletePayment"
                              @close-dialog="deleteConfirm=false">
            Are you sure you want to delete this payment?
          </ConfirmationDialog>

          <ConfirmationDialog :open-dialog="notesDialog"
                              @confirm="updatePaymentNote"
                              @close-dialog="cancelNotesDialog"
                              :disable-confirm="!userCanEdit">
            <template v-slot:title>Notes</template>
            <v-text-field v-model="notesItem.void_note" outlined auto-grow rows="5">
            </v-text-field>
            <template v-slot:no>cancel</template>
            <template v-slot:yes>save</template>
          </ConfirmationDialog>

          <ConfirmationDialog
              :open-dialog="voidDialog"
              @confirm="voidPayment"
              @close-dialog="cancelVoidDialog"
          >
            <template v-slot:title>Confirm</template>
            Are you sure you want to void this payment?
            <v-text-field v-model="notesItem.void_note" outlined auto-grow>
            </v-text-field>
            <template v-slot:no>cancel</template>
            <template v-slot:yes>void</template>
          </ConfirmationDialog>
          <ConfirmationDialog
              :open-dialog="unvoidDialog"
              @confirm="unvoidPayment"
              @close-dialog="cancelUnvoidDialog"
          >
            <template v-slot:title>Confirm</template>
            Are you sure you want to unvoid this payment?
            <template v-slot:no>cancel</template>
            <template v-slot:yes>Unvoid</template>
          </ConfirmationDialog>

        </v-col>
      </v-row>

      <v-row>
        <v-col>
          <div>
          <tr>
            <td class="left-align">
              <v-icon color="primary" v-if="userCanAdd" :disabled="rebateDetails.sumOfNonCanceledPayments >= rebateDetails.total_promotion_amount"
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
              <v-icon v-if="userCanEdit" color="primary" :disabled="rebateDetails.sumOfNonCanceledPayments > rebateDetails.total_promotion_amount"
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
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import moment from "moment";
  import {getCompanyStates} from '@/services/stateService'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'RebateDetails',
    components: {ConfirmationDialog},
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
          { text: 'Notes', value: 'void_note', show: true },
          { text: '', value: 'status', show: true },
          { text: '', value: 'delete', show: true }
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
        unvoidDialog: false,
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
          const {data, status} = await getRequest(`/rebate/details/` + this.projectIdIn, 'blueraven')
          this.rebateDetails = data[0];
          this.rebateDetails.sc = moment(this.rebateDetails.sc).format('MM/DD/YYYY')

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
          handleHidingGlobalLoader(this, status)
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
          await putRequest(`/contact/updateMailingAddress`, contact)
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
      openUnvoidDialog(item) {
        this.notesItem = item
        this.unvoidDialog = true;
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
      cancelUnvoidDialog() {
        this.unvoidDialog = false
      },
      async updateTotalPromotionAmount() {
        this.editTotalPromotionAmount = false

        const params = {
          totalPromotionAmount: this.rebateDetails.total_promotion_amount,
          projectId: this.rebateDetails.project_id
        }
        try {
          await postRequest(`/rebate/updateTotalPromotionAmount`, params, 'blueraven')
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
            await deleteRequest('/rebate/deletePayment/' + this.deleteItem.id, 'blueraven')
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
              await postRequest(`/rebate/updatePayment`, params, 'blueraven')
            } else {
              let params = {
                projectId: this.rebateDetails.project_id,
                paymentAmount: ph.payment_amount
              }
              await postRequest(`/rebate/addExtraPayment`, params, 'blueraven')
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

          await postRequest(`/rebate/updateNote`, params, 'blueraven')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving payment note')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        this.notesDialog = false
      },
      async voidPayment() {
        const item = this.notesItem
        try {
          let params = {
            paymentId: item.id,
            voidNote: item.void_note
          }

          await postRequest(`/rebate/voidPayment`, params, 'blueraven')
          item.void_note = '';
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error voiding payment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        this.voidDialog = false;
        await this.fetchPayments();
      },
      async unvoidPayment() {
        const item = this.notesItem
        try {
          let params = {
            paymentId: item.id
          }

          await postRequest(`/rebate/unvoidPayment`, params, 'blueraven')
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error unvoiding payment')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

        this.unvoidDialog = false;
        await this.fetchPayments();
      },
      async getStates () {
          try {
            const {data, status} = await getCompanyStates()
            this.states = data
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
      }
    }
  }
</script>

<style lang="scss" scoped>
  @media (min-width: 768px) {

    dt {
      float: left; width: 100px;
      font-size: 14px;
    }

    dd {
      margin-left: 100px;
      text-align: left;
      font-size: 14px;
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
  }

  th {
    font-size: 14px;
  }

  .error-message {
    color: var(--v-error-base);
    font-weight: 600;
  }
</style>
