<template>
  <v-container id="monthly-budget-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Monthly Budgets</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[showPastBudgets = !showPastBudgets]">
              {{showPastBudgets ? 'Hide Past Budgets' : 'Show Past Budgets'}}
            </v-btn>
            <v-btn text @click="[createNew = !createNew, newBudget = {}, getAvailableUsers()]">
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
          <v-autocomplete v-model="newBudget.budgetTypeId"
                          :items="budgetTypes"
                          label="Budget Type"
                          item-text="name"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        type="number"
                        label="Amount"
                        v-model.number="newBudget.amount">
          </v-text-field>
          <DatetimePickerInput
            v-model="newBudget.startDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="Start Date"
          />
          <DatetimePickerInput
            v-model="newBudget.endDate"
            :timezone="timezone"
            :type="'date'"
            :format="'MM/DD/YYYY'"
            label="End Date"
          />
          <v-textarea class="py-2" hide-details
                      auto-grow filled
                      rows="4"
                      background-color="#F2F6F8"
                      v-model="newBudget.notes">
          </v-textarea>
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!newBudget.userId || !newBudget.budgetTypeId
                    || !newBudget.amount || !newBudget.startDate || !newBudget.endDate"
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
            No Budgets
          </template>

          <template #no-results>
            No Budgets
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': budgets.indexOf(item) % 2}">
              <v-card flat color="transparent" class="pa-4">
                <v-text-field text
                              label="Assign to User"
                              disabled
                              v-model="item.userFullName">
                </v-text-field>
                <v-autocomplete v-model="item.budgetTypeId"
                                :items="budgetTypes"
                                label="Budget Type"
                                item-text="name"
                                item-value="id"
                ></v-autocomplete>
                <v-text-field text
                              type="number"
                              label="Amount"
                              v-model.number="item.amount">
                </v-text-field>
                <DatetimePickerInput
                  v-model="item.startDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="Start Date"
                />
                <DatetimePickerInput
                  v-model="item.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="End Date"
                />
                <v-textarea class="py-2" hide-details
                            auto-grow filled
                            rows="4"
                            background-color="#F2F6F8"
                            v-model="item.notes">
                </v-textarea>
                <v-btn :disabled="false"
                       color="primaryCustom" class="white--text mr-2"
                       @click="saveBudget(item, false)">
                  Save
                </v-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.userFullName }}</td>
              <td class="text-left">{{ item.budgetType }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">{{ item.startDate| formatDate('date')}}</td>
              <td class="text-left">{{ item.endDate| formatDate('date')}}</td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
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
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {getBudgetTypes} from '../expenseService'
import moment from 'moment'
import constants from "@/helpers/constants"
import DatetimePickerInput from "@/components/DatetimePickerInput"

export default {
  name: 'MonthlyBudgets',
  components: {
    DatetimePickerInput
  },
  computed: {},
  data() {
    return {
      snackbar: {},
      constants,
      createNew: false,
      newBudget: {},
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      showPastBudgets: false,
      budgetTypes: [],
      availableUsers: [],
      timezone: this.$store.state.user.details.timezone.value,
      budgets: [],
      expanded: [],
      headers: [
        {text: 'User', value: 'userFullName', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: 'Start Date', value: 'startDate', show: true},
        {text: 'End Date', value: 'endDate', show: true},
        {text: null, value: 'icons', show: true}
      ],
    }
  },
  created() {
    this.getBudgets()
    this.getBudgetTypes()
  },
  methods: {
    filterBudgets() {
      if(this.showPastBudgets) {
        return this.budgets
      } else {
        return this.budgets.filter(b => {
          return moment(b.endDate).isSameOrAfter(moment().startOf('day'))
        })
      }
    },
    async getBudgets() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/expenseBudgets/list`, 'blueraven')
        this.budgets = data
        this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/expenseBudgets/availableUsers`, 'blueraven')
          this.availableUsers = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getBudgetTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getBudgetTypes()
        this.budgetTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveBudget(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/expenseBudgets`, item, 'blueraven')
        if(isNew) {
          this.budgets.push(data)
          this.newBudget = {}
          this.createNew = false
        } else {
          this.expanded = []
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', e?.data?.message || 'Error Saving Budget')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
