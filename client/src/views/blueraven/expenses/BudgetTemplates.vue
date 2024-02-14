<template>
  <v-container id="monthly-budget-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Budget Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[createNew = !createNew, newTemplate = {}, expanded = [], getAvailableUsers()]">
              <v-icon v-if="!createNew">add</v-icon>
              <v-icon v-else>close</v-icon>
              <span v-if="!isMobile">
                {{createNew ? 'cancel' : 'Add Template'}}
              </span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Template</h3>
          <v-autocomplete v-model="newTemplate.userId"
                          :items="availableUsers"
                          label="Assign to User"
                          item-text="fullName"
                          item-value="id"
          ></v-autocomplete>
          <v-text-field text
                        type="number"
                        prepend-icon="mdi-currency-usd"
                        label="Amount"
                        v-model.number="newTemplate.amount">
          </v-text-field>
          <v-btn color="primary" class="white--text"
                 :disabled="!newTemplate.userId
                    || !newTemplate.amount"
                 @click="saveTemplate(newTemplate, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterTemplates()"
          :items-per-page="100"
          :mobile-breakpoint="0"
          single-expand
          :loading="dataLoading"
          fixed-header
          :expanded.sync="expanded"
          :footer-props="footerProps"
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            <span class="default-text-color">No Templates</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No Templates</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': templates.indexOf(item) % 2}">
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
                <v-btn :disabled="false"
                       color="primary" class="white--text mr-2"
                       @click="saveTemplate(item, false)">
                  Save
                </v-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{ item.userFullName }}</td>
              <td class="text-left">{{ item.amount | currency('$', 2) }}</td>
              <td class="text-left">
                <div v-if="item.currentMonthBudgetId">
                  Already Exists
                </div>
                <v-btn v-else color="primary" @click="generateCurrentMonthBudget(item)">
                  Generate
                </v-btn>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="[createNew = false, expanded = [item]]">
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
        @confirm="[itemToDelete.archived=true,deleteTemplate(itemToDeleteId)]"
        @close-dialog="closeDeleteDialog">
      Are you sure you want to this template for {{itemToDelete.userFullName}}: {{ itemToDelete.amount | currency('$', 0)}}?

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
  name: 'BudgetTemplates',
  components: {
    ConfirmationDialog,
    DatetimePickerInput
  },
  computed: {
    itemToDeleteId(){
      return this.itemToDelete ? this.itemToDelete.id : ''
    },
    isMobile(){
      return this.$vuetify.breakpoint.smAndDown
    }
  },
  data() {
    return {
      snackbar: {},
      constants,
      dataLoading: true,
      createNew: false,
      newTemplate: {},
      footerProps: {
        'items-per-page-options': [25, 50, 100, 500],
        'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:'
      },
      availableUsers: [],
      timezone: this.$store.state.user.details.timezone.value,
      templates: [],
      expanded: [],
      headers: [
        {text: 'User', value: 'userFullName', show: true, width: '125px'},
        {text: 'Amount', value: 'amount', show: true, width: '75px'},
        {text: 'Current Month Budget', value: 'amount', show: true, width: '125px'},
        {text: null, value: 'icons', show: true, sortable: false, width: '125px'}
      ],
      deleteConfirm: false,
      itemToDelete: {}

    }
  },
  created() {
    this.getTemplates()
  },
  methods: {
    async generateCurrentMonthBudget(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //try to add a new budget
        let params = {
          userId: item.userId,
          amount: item.amount,
          startDate: moment().startOf('month').format('YYYY-MM-DD'),
          endDate: moment().endOf('month').format('YYYY-MM-DD')
        }
        const {data, status} = await postRequest(`/expenseBudgets`, params, 'blueraven')
        item.currentMonthBudgetId = data.id
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = e?.data?.detail || 'Error Generating a Budget for this User'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterTemplates() {
      return this.templates.filter(b => !b.archived)
    },
    async getTemplates() {
      this.dataLoading = true
      try {
        const {data, status} = await getRequest(`/expenseBudgets/templates`, 'blueraven')
        this.templates = data
        this.dataLoading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
    async deleteTemplate (id) {
      this.$store.commit(AppMutations.SET_LOADING, true)

      try {
        const {status} = await deleteRequest(`/expenseBudgets/templates/${id}`, 'blueraven')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Error Deleting Budget')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveTemplate(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/expenseBudgets/templates`, item, 'blueraven')
        if(isNew) {
          this.templates.push(data)
          this.newTemplate = {}
          this.createNew = false
        } else {
          this.expanded = []
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', e?.data?.detail || 'Error Saving Template')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    closeDeleteDialog() {
      this.deleteConfirm = false
      this.itemToDelete = {}
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
