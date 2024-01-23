<template>
  <v-container id="monthly-budget-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Monthly Budgets</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[showPastBudgets = !showPastBudgets]">
              {{showPastBudgets ? 'Hide Past Budgets' : 'Show Past Budgets'}}
            </v-btn>
            <v-btn text color="primary" @click="[createNew = !createNew, newBudget = {}, expanded = [], getAvailableUsers()]">
              <v-icon v-if="!createNew">add</v-icon>
              {{createNew ? 'cancel' : 'Add Budget'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Budget</h3>
          <v-autocomplete v-model="newBudget.userId"
                          :items="availableUsers"
                          label="Assign to User"
                          item-text="fullName"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        type="number"
                        prepend-icon="mdi-currency-usd"
                        label="Amount"
                        v-model.number="newBudget.amount">
          </v-text-field>
          <v-select v-model="selectedMonth"
                    :items="months"
                    class="mr-3 reimbursement-range-selector"
                    label="Month"
                    item-text="name"
                    item-value="id"
          ></v-select>
          <v-select v-model="selectedYear"
                    :items="years"
                    class="reimbursement-range-selector"
                    label="Year"
                    item-text="name"
                    item-value="id"
          ></v-select>
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newBudget.notes">
          </v-textarea>
          <v-btn color="primary" class="white--text"
                 :disabled="!newBudget.userId
                    || !newBudget.amount || !selectedYear || !selectedMonth"
                 @click="saveBudget(newBudget, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterBudgets()"
          :items-per-page="100"
          :mobile-breakpoint="0"
          single-expand
          fixed-header
          :expanded.sync="expanded"
          :footer-props="footerProps"
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Budgets</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Budgets</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': budgets.indexOf(item) % 2}">
              <v-card flat color="transparent" class="pa-4">
                <v-text-field text
                              label="Assign to User"
                              disabled
                              v-model="item.userFullName">
                </v-text-field>
                <v-text-field text
                              type="number"
                              label="Amount"
                              prepend-icon="mdi-currency-usd"
                              v-model.number="item.amount">
                </v-text-field>
                <v-select v-model="selectedMonth"
                          :items="months"
                          class="mr-3 reimbursement-range-selector"
                          label="Month"
                          item-text="name"
                          item-value="id"
                ></v-select>
                <v-select v-model="selectedYear"
                          :items="years"
                          class="reimbursement-range-selector"
                          label="Year"
                          item-text="name"
                          item-value="id"
                ></v-select>
                <v-textarea class="py-2" hide-details
                            auto-grow filled
                            rows="4"
                            background-color="#F2F6F8"
                            v-model="item.notes">
                </v-textarea>
                <v-btn :disabled="false"
                       color="primary" class="white--text mr-2"
                       @click="saveBudget(item, false)">
                  Save
                </v-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.userFullName }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.startDate | formatDate('date', 'MMMM YYYY')}}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="[handleItemClick(item), expanded = [item]]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                  <v-btn small text color="primary" @click="[deleteConfirm=true, itemToDelete = item]"><v-icon>delete</v-icon></v-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-dialog = deleteConfirm
        @confirm="[itemToDelete.archived=true,deleteBudget(itemToDeleteId)]"
        @close-dialog="closeDeleteDialog">
      There may already be expenses assigned to this budget. Are you sure you want to delete?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, deleteRequest} from '@/helpers/helpers'
import moment from 'moment'
import constants from "@/helpers/constants"
import DatetimePickerInput from "@/components/DatetimePickerInput"
import ConfirmationDialog from "@/components/ConfirmationDialog";

export default {
  name: 'MonthlyBudgets',
  components: {
    ConfirmationDialog,
    DatetimePickerInput
  },
  computed: {
    itemToDeleteId(){
      return this.itemToDelete ? this.itemToDelete.id : ''
    }
  },
  data() {
    return {
      snackbar: {},
      constants,
      years: [],
      selectedMonth: parseInt(moment().format('M')),
      selectedYear: parseInt(moment().format('YYYY')),
      yearStart: 2017,
      yearEnd: parseInt(moment().format('YYYY')),
      months: [
        {id: 1, name: 'January'},
        {id: 2, name: 'February'},
        {id: 3, name: 'March'},
        {id: 4, name: 'April'},
        {id: 5, name: 'May'},
        {id: 6, name: 'June'},
        {id: 7, name: 'July'},
        {id: 8, name: 'August'},
        {id: 9, name: 'September'},
        {id: 10, name: 'October'},
        {id: 11, name: 'November'},
        {id: 12, name: 'December'}
      ],
      createNew: false,
      newBudget: {},
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      showPastBudgets: false,
      availableUsers: [],
      timezone: this.$store.state.user.details.timezone.value,
      budgets: [],
      expanded: [],
      headers: [
        {text: 'User', value: 'userFullName', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Budget Month', value: 'startDate', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      deleteConfirm: false,
      itemToDelete: null

    }
  },
  created() {
    for (let i = this.yearStart; i <= this.yearEnd; i++) {
      this.years.push(i)
    }

    this.getBudgets()
  },
  methods: {
    handleItemClick(item) {
      this.createNew = false
      this.selectedMonth = parseInt(moment(item.startDate).format('M'))
      this.selectedYear = parseInt(moment(item.endDate).format('YYYY'))
    },
    filterBudgets() {
      if(this.showPastBudgets) {
        return this.budgets.filter(b => !b.archived)
      } else {
        return this.budgets.filter(b => {
          return moment(b.endDate).isSameOrAfter(moment().startOf('day')) && !b.archived
        })
      }
    },
    async getBudgets() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/expenseBudgets/list`, 'blueraven')
        this.budgets = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAvailableUsers() {
      if(this.createNew) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/expenseBudgets/availableUsers`, 'blueraven')
          this.availableUsers = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async deleteBudget (id) {
      this.$store.commit(AppMutations.SET_LOADING, true)

      try {
        const {status} = await deleteRequest(`/expenseBudgets/${id}`, 'blueraven')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Error Deleting Budget')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveBudget(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let startDate = moment([this.selectedYear, this.selectedMonth - 1]).format("YYYY-MM-DD")
        let endDate = moment(startDate).endOf('month').format("YYYY-MM-DD")
        item.startDate = startDate
        item.endDate = endDate

        const {data, status} = await postRequest(`/expenseBudgets`, item, 'blueraven')
        if(isNew) {
          this.budgets.push(data)
          this.newBudget = {}
          this.createNew = false
        } else {
          this.expanded = []
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', e?.data?.message || 'Error Saving Budget')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeDeleteDialog() {
      this.deleteConfirm = false
      this.itemToDelete = null
    }
  }
}
</script>

<style lang="scss">
#monthly-budget-container .v-data-table__wrapper {
  height: calc(100vh - 290px);
  min-height: 300px;
}
</style>

<style lang="scss" scoped>
#monthly-budget-container {
  margin-top: -15px;
  padding-left: 0;
  padding-right: 0;
  padding-top: 0;
}
</style>
