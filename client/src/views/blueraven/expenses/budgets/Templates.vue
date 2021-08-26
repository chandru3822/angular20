<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Templates</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[createNew = !createNew, newTemplate = {}, getAvailableUsers()]">
              <v-icon v-if="!createNew">add</v-icon>
              {{createNew ? 'cancel' : 'Add Template'}}
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
          <v-autocomplete v-model="newTemplate.budgetTypeId"
                          :items="budgetTypes"
                          label="Budget Type"
                          item-text="name"
                          item-value="id"
          ></v-autocomplete>
            <v-text-field text
                          type="number"
                          label="Amount"
                          v-model.number="newTemplate.amount">
          </v-text-field>
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!newTemplate.userId || !newTemplate.budgetTypeId || !newTemplate.amount"
                 @click="saveTemplate(newTemplate, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterTemplates()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          single-expand
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No Templates
          </template>

          <template #no-results>
            No Templates
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': templates.indexOf(item) % 2}">
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
                <v-btn :disabled="false"
                       color="primaryCustom" class="white--text mr-2"
                       @click="saveTemplate(item, false)">
                  Save
                </v-btn>
              </v-card>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                {{ item.userFullName }}
              </td>
              <td class="text-left">
                {{ item.budgetType }}
              </td>
              <td class="text-left">
                {{ item.amount | currency('$', 2) }}
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text v-if="!expanded.includes(item)" @click="expanded = [item]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
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
                        Are you sure you want to delete this Template <strong>{{item.code}}</strong>?
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
                          @click="deleteTemplate(item)">
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
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import {getBudgetTypes} from '../expenseService'

export default {
  name: 'ExpenseBudgetTemplates',

  computed: {},
  data() {
    return {
      snackbar: {},
      createNew: false,
      newTemplate: {},
      editIndex: null,
      templates: [],
      budgetTypes: [],
      availableUsers: [],
      expanded: [],
      headers: [
        {text: 'User', value: 'userFullName', show: true},
        {text: 'Budget Type', value: 'budgetType', show: true},
        {text: 'Amount', value: 'amount', show: true},
        {text: null, value: 'icons', show: true}
      ],
    }
  },
  created() {
    this.getTemplates()
    this.getBudgetTypes()
  },
  methods: {
    filterTemplates() {
      return this.templates.filter(glc => !glc.archived)
    },
    async getTemplates() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/expenseBudgets/templates`, 'blueraven')
        this.templates = data
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
    async deleteTemplate(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/expenseBudgets/templates/${item.id}`, 'blueraven')
        item.archived = true
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Template')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveTemplate(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await postRequest(`/expenseBudgets/templates`, item, 'blueraven')
        if(isNew) {
          this.templates.push(data)
          this.newTemplate = {}
          this.createNew = false
        } else {
          this.expanded = []
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Template')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>
