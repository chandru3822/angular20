<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Budget Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[createNew = !createNew, newBudgetType = {}]">
              <v-icon v-if="!createNew">add</v-icon>
              {{createNew ? 'cancel' : 'Add Budget Type'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card flat v-if="createNew" class="pa-4">
          <h3>New Budget Type</h3>
          <v-text-field text
                        type="text"
                        label="Budget Type"
                        v-model="newBudgetType.name">
          </v-text-field>
          <v-btn color="primary" dark class="white--text"
                 :disabled="!newBudgetType.name"
                 @click="saveBudgetType(newBudgetType, true)">
            Save
          </v-btn>
        </v-card>
        <v-divider v-if="createNew" ></v-divider>
        <v-data-table
          :headers="headers"
          :items="filterBudgetTypes()"
          :items-per-page="-1"
          :mobile-breakpoint="0"
          hide-default-footer
          class="elevation-1 fix-column-width-bug square-card"
        >
          <template #no-data>
            No Budget Types
          </template>

          <template #no-results>
            No Budget Types
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">
                <v-text-field text
                              type="text"
                              v-if="index === editIndex"
                              label="Budget Type"
                              v-model="item.name">
                </v-text-field>
                <div v-else>
                  {{ item.name }}
                </div>
              </td>
              <td>
                <div style="display: flex; justify-content: flex-end">
                  <v-btn small text color="primary" @click="editIndex = index" v-if="index !== editIndex">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" @click="saveBudgetType(item, false)" v-if="index === editIndex">
                    <v-icon>save</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" @click="editIndex = null" v-if="index === editIndex">
                    cancel
                  </v-btn>
                  <v-btn small text color="primary"  @click="[deleteConfirm=true, itemToDelete = item]">
                    <v-icon>delete</v-icon>
                  </v-btn>
                </div>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
        :open-confirm-delete-dialog = deleteConfirm
        @confirm-delete=deleteBudgetType(itemToDelete)
        @closeConfirmDeleteDialog="closeDeleteDialog">
      Are you sure you want to delete this Budget Type <strong>{{itemToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'ExpenseBudgetTypes',
  components: {ConfirmationDialog},
  computed: {
    itemToDeleteName() {
      return this.itemToDelete ? this.itemToDelete.name : ''
    }
  },
  data() {
    return {
      snackbar: {},
      createNew: false,
      newBudgetType: {},
      editIndex: null,
      budgetTypes: [],
      headers: [
        {text: 'Type', value: 'name', show: true},
        {text: null, value: 'icons', show: true}
      ],
      deleteConfirm: false,
      itemToDelete: null
    }
  },
  created() {
    this.getBudgetTypes()
  },
  methods: {
    filterBudgetTypes() {
      return this.budgetTypes.filter(bt => !bt.archived)
    },
    async getBudgetTypes() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/expenseBudgets/budgetTypes`, 'blueraven')
        this.budgetTypes = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteBudgetType(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await deleteRequest(`/expenseBudgets/budgetType/${item.id}`, 'blueraven')
        item.archived = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Budget Type')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
      this.closeDeleteDialog()
    },
    async saveBudgetType(item, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await postRequest(`/expenseBudgets/budgetType`, item, 'blueraven')
        if(isNew) {
          this.budgetTypes.push(data)
          this.newBudgetType = {}
          this.createNew = false
        } else {
          this.editIndex = null
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Budget Type')
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
