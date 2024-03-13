<template>
  <div class="pt-6">
    <dl class="dl-horizontal row pl-4">
      <dt class="left-align">Project Name:</dt>
      <dd>{{rebateDetails.project_name}}</dd>

      <dt class="left-align">Project ID:</dt>
      <dd>
        <router-link :to="`/project/${rebateDetails.project_id}/status`">{{rebateDetails.project_id}}</router-link>
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
        <AlbatrossButton
            variant="text"
            color="primary"
            size="small"
            v-if="userCanEdit"
            @click="editMailing = true"
            class="mt-n1 px-1"
            prepend-icon="add"
            text="Add"
        ></AlbatrossButton>
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
            <AlbatrossButton
                class="my-2"
                variant="text"
                color="primary"
                size="small"
                @click="cancelMailingEdit()"
                text="Cancel"
            ></AlbatrossButton>
            <AlbatrossButton
                class="my-2"
                variant="text"
                color="error"
                size="small"
                @click="saveMailingAddress(true)"
                v-if="mailingDetails.mailingStreet1 != null && userCanEdit"
                text="Remove"
            ></AlbatrossButton>
            <AlbatrossButton
                class="my-2 ml-2"
                color="primary"
                size="small"
                @click="saveMailingAddress(false)"
                v-if="userCanEdit"
                :disabled="!rebateDetails.mailing_street1 || !rebateDetails.mailing_city || !rebateDetails.mailing_state_id || !rebateDetails.mailing_postal_code"
                text="Save"
            ></AlbatrossButton>
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
                  <AlbatrossButton
                      v-if="item.payment_state_id !== 3 && item.payment_state_id !== 2 && userStore.userHasFeatureAccessLevel('REBATES', 'DELETE')"
                      @click="openDeleteDialog(item)"
                      variant="text"
                      color="primary"
                      prepend-icon="delete"
                  ></AlbatrossButton>
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
<script setup>

import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, } from '@/helpers/helpers'
import moment from "moment";
import {getCompanyStates} from '@/services/stateService'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('REBATES', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('REBATES', 'EDIT')
})
const displayedTabs = computed(() => {
  return tabs.value.filter(tab => tab.display)
})

const model = ref('')
const projectIdIn = ref(parseInt(route.params.id))
const headers = ref([
  { text: 'Payment Number', value: 'payment_nbr', show: true },
  { text: 'Batch ID', value: 'batch_id', show: true },
  { text: 'Batch Date', value: 'batch_date', show: true },
  { text: 'Amount', value: 'payment_amount', show: true },
  { text: 'Status', value: 'name', show: true },
  { text: 'Check Number', value: 'check_number', show: true },
  { text: 'Notes', value: 'void_note', show: true },
  { text: '', value: 'status', show: true },
  { text: '', value: 'delete', show: true }
])
const rebateDetails = ref({})
const mailingDetails = ref({mailingStreet1: null,mailingStreet2: null,mailingCity: null,mailingStateAbbr: null,mailingStateId: null,mailingPostalCode: null})
const states = ref([])
const editMailing = ref(false)
const notesDialog = ref(false)
const voidDialog = ref(false)
const unvoidDialog = ref(false)
const deleteConfirm = ref(false)
const deleteItem = ref({})
const notesItem = ref({void_note: ''
})
const voidConfirmMsg = ref('')
const notesValue = ref('')
const editTotalPromotionAmount = ref(false)
const sumOfNonCanceledPayments = ref(0)
const maxPaymentNumber = ref(0)
const maxPayment = ref(0)
const remainingBalance = ref(0)

onMounted(() => {
  fetchPayments();
})

const fetchPayments = async() => {
  appStore.loading = true
  try {
    await getStates();
    const {data, status} = await getRequest(`/rebate/details/` + projectIdIn.value, 'blueraven')
    rebateDetails.value = data[0];
    rebateDetails.value.sc = moment(rebateDetails.value.substantialcompletiondate).format('MM/DD/YYYY')

    let payment_amount = 0;
    if (rebateDetails.value.numberofpromotionpayments > 0) {
      payment_amount = parseFloat(rebateDetails.value.total_promotion_amount) / parseFloat(rebateDetails.value.numberofpromotionpayments)
    }
    rebateDetails.value.payment_amount = payment_amount;
    mailingDetails.value = {
      mailingStreet1: rebateDetails.value.mailing_street1,
      mailingStreet2: rebateDetails.value.mailing_street2,
      mailingCity: rebateDetails.value.mailing_city,
      mailingStateAbbr: rebateDetails.value.mailing_state_abbr,
      mailingStateId: rebateDetails.value.mailing_state_id,
      mailingPostalCode: rebateDetails.value.mailing_postal_code
    }

    maxPayment.value = rebateDetails.value.payment_history.reduce((a,b) => Number(a.payment_nbr) > Number(b.payment_nbr) ? a : b)
    maxPaymentNumber.value = maxPayment.value && maxPayment.value.payment_nbr ? maxPayment.value.payment_nbr + 1 : 1
    getTotals();
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving rebate details')

    appStore.loading = false
  }
}
const canEditPayment = (p) => {
  let disabled = false
  if (p.payment_state_id === 3 || p.payment_state_id === 5) {
    //if processed or voided don't allow editing
    disabled = true
  }
  return disabled || !userCanEdit.value
}
const saveMailingAddress = async(removeAddress) => {
  if (removeAddress) {
    editMailing.value = false
    //reset original and copy back to null
    rebateDetails.value.mailing_street1 = null
    rebateDetails.value.mailing_street2 = null
    rebateDetails.value.mailing_city = null
    rebateDetails.value.mailing_state_id = null
    rebateDetails.value.mailing_state_abbr = null
    rebateDetails.value.mailing_postal_code = null
    mailingDetails.value = {
      mailingStreet1: null,
      mailingStreet2: null,
      mailingCity: null,
      mailingStateAbbr: null,
      mailingStateId: null,
      mailingPostalCode: null
    }
  }

  let contact = {
    id: rebateDetails.value.contact_id,
    mailingStreet1: rebateDetails.value.mailing_street1,
    mailingStreet2: rebateDetails.value.mailing_street2,
    mailingCity: rebateDetails.value.mailing_city,
    companyStateId: rebateDetails.value.mailing_state_id,
    mailingPostalCode: rebateDetails.value.mailing_postal_code,
  }

  mailingDetails.value = {
    mailingStreet1: rebateDetails.value.mailing_street1,
    mailingStreet2: rebateDetails.value.mailing_street2,
    mailingCity: rebateDetails.value.mailing_city,
    mailingStateAbbr: states.value.filter(state => state.id === rebateDetails.value.mailing_state_id)[0].abbreviation,
    mailingStateId: rebateDetails.value.mailing_state_id,
    mailingPostalCode: rebateDetails.value.mailing_postal_code
  }

  try {
    await putRequest(`/contact/updateMailingAddress`, contact)
    snackbar('SUCCESS', 'Mailing address saved')

    editMailing.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving mailing address')

  }
}
const cancelMailingEdit =  () => {
  //reset the values back to the copied ones
  rebateDetails.value.mailing_street1= mailingDetails.value.mailingStreet1
  rebateDetails.value.mailing_street2 = mailingDetails.value.mailingStreet2
  rebateDetails.value.mailing_city = mailingDetails.value.mailingCity
  rebateDetails.value.mailing_state_abbr = mailingDetails.value.mailingStateAbbr
  rebateDetails.value.mailing_state_id = mailingDetails.value.mailingStateId
  rebateDetails.value.mailing_postal_code = mailingDetails.value.mailingPostalCode
  editMailing.value = false;
}
const openNotesDialog = (item) => {
  notesDialog.value = true
  notesValue.value = item.void_note
  notesItem.value = item
}
const openVoidDialog = (item) => {
  notesValue.value = item.void_note
  notesItem.value = item
  voidDialog.value = true;
}
const openUnvoidDialog = (item) => {
  notesItem.value = item
  unvoidDialog.value = true;
}
const openDeleteDialog = (item) => {
  deleteItem.value = item;
  deleteConfirm.value = true;
}
const cancelNotesDialog = ()=> {
  notesDialog.value = false
  notesItem.value.void_note = notesValue.value
  notesValue.value = ''
}
const cancelVoidDialog = () => {
  voidDialog.value = false
  notesItem.value.void_note = notesValue.value
  notesValue.value = ''
}
const cancelUnvoidDialog = () => {
  unvoidDialog.value = false
}
const updateTotalPromotionAmount = async() => {
  editTotalPromotionAmount.value = false

  const params = {
    totalPromotionAmount: rebateDetails.value.total_promotion_amount,
    projectId: rebateDetails.value.project_id
  }
  try {
    await postRequest(`/rebate/updateTotalPromotionAmount`, params, 'blueraven')
    snackbar('SUCCESS', 'Total Promotion Amount saved!')

    editMailing.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving Total Promotion Amount')

  }
}
const addNewRow = () => {
  rebateDetails.value.payment_history.push({
    id: null,
    payment_amount: 0,
    payment_nbr: maxPaymentNumber.value,
    originalPaymentStateId: 1,
    payment_state_id: 1,
    name: 'Needs approval'
  })
  getTotals()
  maxPaymentNumber.value++
}
const deletePayment = async() => {
  // If row already existed
  if (deleteItem.value.id) {
    try {
      await deleteRequest('/rebate/deletePayment/' + deleteItem.value.id, 'blueraven')
      rebateDetails.value.payment_history = rebateDetails.value.payment_history.filter(ph => ph.payment_nbr !== deleteItem.value.payment_nbr)
      editMailing.value = false;
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error deleting payment')

    }
  } else {
    rebateDetails.value.payment_history = rebateDetails.value.payment_history.filter(ph => ph.payment_nbr !== deleteItem.value.payment_nbr)
  }

  getTotals()
  deleteConfirm.value = false
}
const savePaymentHistoryChanges = async() => {
  for (const ph of rebateDetails.value.payment_history) {
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
          projectId: rebateDetails.value.project_id,
          paymentAmount: ph.payment_amount
        }
        await postRequest(`/rebate/addExtraPayment`, params, 'blueraven')
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error saving payments')

    }
  }

  getTotals()
}
const getTotals = () => {
  sumOfNonCanceledPayments.value = 0;
  rebateDetails.value.payment_history.forEach(ph => {
    if (ph.payment_state_id !== 4 && ph.payment_state_id !== 5) {
      sumOfNonCanceledPayments.value += parseFloat(ph.payment_amount)
    }
  })
  remainingBalance.value = sumOfNonCanceledPayments.value - parseFloat(rebateDetails.value.total_promotion_amount)
}
const updatePaymentNote = async() => {
  try {
    let params = {
      paymentId: notesItem.value.id,
      voidNote: notesItem.value.void_note
    }

    await postRequest(`/rebate/updateNote`, params, 'blueraven')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving payment note')

  }

  notesDialog.value = false
}
const voidPayment = async() => {
  const item = notesItem.value
  try {
    let params = {
      paymentId: item.id,
      voidNote: item.void_note
    }

    await postRequest(`/rebate/voidPayment`, params, 'blueraven')
    item.void_note = '';
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error voiding payment')

  }

  voidDialog.value = false;
  await fetchPayments();
}
const unvoidPayment = async() => {
  const item = notesItem.value
  try {
    let params = {
      paymentId: item.id
    }

    await postRequest(`/rebate/unvoidPayment`, params, 'blueraven')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error unvoiding payment')

  }

  unvoidDialog.value = false;
  await fetchPayments();
}
const getStates = async () => {
  try {
    const {data, status} = await getCompanyStates()
    states.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving States')

    appStore.loading = false
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
