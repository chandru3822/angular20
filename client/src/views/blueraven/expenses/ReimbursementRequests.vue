<template>
  <v-container id="reimbursement-requests-container">
    <v-row v-if="!selectedRequest || !selectedRequest.id">
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Reimbursement Requests</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[createNew = !createNew, newReimbursementRequest = {expenseBudgetId: null}, getDataForNewRequest()]">
              <v-icon v-if="!createNew">add</v-icon>
              {{createNew ? 'cancel' : 'Add Reimbursement Request'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>Add Expense Item</h3>
          <v-autocomplete v-model="newReimbursementRequest.userId"
                          :items="users"
                          :loading="usersLoading"
                          :search-input.sync="userSearchText"
                          label="Purchaser"
                          clearable
                          item-text="fullName"
                          item-value="id"
                          autocomplete="off"
                          type="search"
                          @click:clear="users = []"
          ></v-autocomplete>
          <DatetimePickerInput
            v-model="newReimbursementRequest.expenseDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="Expense Date"
            :change-callback="getBudgetTypesForUser"
          />
          <v-autocomplete v-model="newReimbursementRequest.glCodeId"
                          :items="glCodes"
                          label="GL Code"
                          item-text="code"
                          item-value="id"
          >
            <template slot='item' slot-scope='{ item }'>
              {{ item.code }} - {{ item.description }}
            </template>
          </v-autocomplete>
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetUserId"
                          :items="usersWithBudget"
                          label="Budget User"
                          item-text="fullName"
                          item-value="id"
                          @input="getBudgetTypesForUser()"
          ></v-autocomplete>
          <v-autocomplete v-model="newReimbursementRequest.expenseBudgetId"
                          :items="budgetTypesForUser"
                          label="Budget Type"
                          item-text="budgetType"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        type="number"
                        label="Amount"
                        v-model.number="newReimbursementRequest.expenseAmount">
          </v-text-field>
          <label>Notes:</label>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newReimbursementRequest.notes">
          </v-textarea>
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!newReimbursementRequest.userId || !newReimbursementRequest.expenseDate || !newReimbursementRequest.glCodeId
                            || !newReimbursementRequest.expenseBudgetUserId || !newReimbursementRequest.expenseBudgetId || !newReimbursementRequest.expenseAmount"
                 @click="saveReimbursementRequest(newReimbursementRequest, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterReimbursementRequests()"
          :items-per-page="100"
          :mobile-breakpoint="0"
          fixed-header
          :footer-props="footerProps"
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No Reimbursement Requests
          </template>

          <template #no-results>
            No Reimbursement Requests
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.createdBy }}</td>
              <td class="text-left">{{ item.positionName }}</td>
              <td class="text-left">{{ item.dateCreated | formatDate('date') }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.budgetType }}</td>
              <td class="text-left">{{ item.expenseBudgetUser }}</td>
              <td class="text-left">{{ item.expenseDate | formatDate('date') }}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text @click="selectedRequest = item">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text @click="saveReimbursementRequest(item, false)" v-if="index === editIndex">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-btn small text @click="editIndex = null" v-if="index === editIndex">
                    cancel
                  </v-btn>
                  <v-dialog
                    v-model="item.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="headline grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete this Reimbursement Request for <strong>{{item.createdBy}}: {{item.amount | currency('$', 2)}}</strong>?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                          @click="item.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                          color="primaryCustom"
                          text
                          @click="deleteReimbursementRequest(item)">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {getRequest, deleteRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from "@/helpers/constants";
import {getGlCodes, getUsersWithBudget} from './expenseService'
import DatetimePickerInput from "@/components/DatetimePickerInput"

export default {
  name: 'ReimbursementRequests',
  components: {
    DatetimePickerInput
  },
  computed: {},
  data() {
    return {
      snackbar: {},
      createNew: false,
      newReimbursementRequest: {
        expenseBudgetId: null
      },
      timezone: this.$store.state.user.details.timezone.value,
      selectedRequest: {},
      editIndex: null,
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      reimbursementRequests: [],
      usersWithBudget: [],
      users: [],
      userId: this.$store.state.user.details.id,
      usersLoading: false,
      userSearchText: null,
      budgetTypesForUser: [],
      glCodes: [],
      headers: [
        {text: 'Rep', value: 'createdBy', show: true},
        {text: 'Position', value: 'positionName', show: true},
        {text: 'Submitted Date', value: 'dateCreated', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Budget User', value: 'expenseBudgetUser', show: true},
        {text: 'Expense Date', value: 'expenseDate', show: true},
        {text: null, value: 'icons', show: true}
      ],
    }
  },
  created() {
    this.getReimbursementRequests()
  },
  watch: {
    userSearchText (val) {
      if(!val) {
        this.users = []
        this.newReimbursementRequest.userId = null
        return
      }
      this.userIds = []
      this.getReimbursementUsersDebounced(val)
    },
  },
  methods: {
    filterReimbursementRequests() {
      return this.reimbursementRequests.filter(glc => !glc.archived)
    },
    async getReimbursementRequests() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/reimbursement/requests/pending`, 'blueraven')
        this.reimbursementRequests = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteReimbursementRequest(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/reimbursement/${item.id}`, 'blueraven')
        item.archived = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveReimbursementRequest(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //not sure what this is yet
        // item.skipApproval = self.skipApproval;
        //there is already an endpoint for lists of these so just sending up as a list
        let listOfItem = [item]
        const {data} = await postRequest(`/expenses/addExpenseItems`, listOfItem, 'blueraven')
        if(isNew) {
          //do not add the new one to the list cuz it already got approved
          this.newReimbursementRequest = {}
          this.createNew = false
        } else {
          this.editIndex = null
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Reimbursement Request')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getBudgetTypesForUser() {
      //reset the budget id every time a user or expense date changes
      this.newReimbursementRequest.expenseBudgetId = null
      if(null != this.newReimbursementRequest.expenseBudgetUserId && null != this.newReimbursementRequest.expenseDate) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: this.newReimbursementRequest.expenseBudgetUserId,
            expenseDate: this.newReimbursementRequest.expenseDate
          }
          const {data} = await getRequestWithParams(`/expenseBudgets/availableForUser`, {params}, 'blueraven')
          this.budgetTypesForUser = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    getDataForNewRequest() {
      if(this.createNew) {
        this.getGlCodes()
        this.getUsersWithBudget()
      }
    },
    getReimbursementUsersDebounced(val) {
      clearTimeout(this._searchTimerId)
      this._searchTimerId = setTimeout(() => {
        this.getReimbursementUsers(val)
      }, 500) /* 500ms throttle */
    },
    async getReimbursementUsers() {
      this.usersLoading = true
      try {
        let body = {
          query: this.userSearchText
        }
        const {data} = await postRequest(`/reimbursement/users`, body, 'blueraven')
        this.users = data
        this.usersLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.usersLoading = false
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    async getGlCodes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getGlCodes()
        this.glCodes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUsersWithBudget() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getUsersWithBudget()
        this.usersWithBudget = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style lang="scss">
#reimbursement-requests-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#reimbursement-requests-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>
