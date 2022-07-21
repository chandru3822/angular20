<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Tabs</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newTab ={}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew" class="mb-2">
            <v-text-field v-model="newTab.tabName"
                          placeholder=" "
                          label="Tab Label">
            </v-text-field>
            <v-btn :disabled="!newTab.tabName" color="primary" @click="saveTab(newTab)">Save</v-btn>
          </div>
          <v-data-table
              :headers="headers"
              :items="filterTabs()"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              hide-default-footer
              fixed-header
              single-expand
              :expanded.sync="expanded"
              class="elevation-1"
          >
            <template #no-data>
              No available tabs
            </template>

            <template #no-results>
              No available tabs
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': tabs.indexOf(item) % 2}">
                <td style="width: 50px">
                  <v-btn text v-if="userCanEdit" icon small color="primary" class="handle">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">
                  <v-text-field class="one-hunned" v-if="selectedTabId === item.id" v-model="item.tabName"></v-text-field>
                  <span v-else>{{item.tabName}}</span>
                </td>
                <td class="text-right">
                  <div class="item-icons">
                    <v-btn class="clickable" small text color="primary" v-if="userCanEdit">
                      <v-icon v-if="selectedTabId === item.id" @click="saveTab(item)">save</v-icon>
                      <v-icon v-else @click="selectedTabId = item.id">edit</v-icon>
                    </v-btn>
                    <v-btn class="clickable" small text color="primary" v-if="userCanEdit" @click="tabToDelete=item"><v-icon>delete</v-icon></v-btn>
                  </div>
                </td>
              </tr>
            </template>

          </v-data-table>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!tabToDelete"
                        @confirm="[tabToDelete.archived = true, deleteTab()]"
                        @close-dialog="tabToDelete=null">
      Are you sure you want to delete this tab: <strong>{{tabToDeleteName}}</strong>?
      <template v-slot:no>cancel</template>
      <template v-slot:yes>delete</template>
    </ConfirmationDialog>
  </v-container>
</template>


<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";
  import cloneDeep from "lodash.clonedeep";
  import ConfirmationDialog from "@/ConfirmationDialog";

  export default {
    name: 'ProjectTabs',
    components: {ConfirmationDialog},
    mixins: [Vue2Filters.mixin],

    mounted() {
      let table = document.querySelector('tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          const rowSelected = _self.tabs.splice(oldIndex, 1)[0]
          _self.tabs.splice(newIndex, 0, rowSelected)
          let rowsClone = cloneDeep(_self.tabs)

          let rowsToSave = []
          rowsClone.forEach((r, idx) => {
            //check if the row needs to be saved before updating display order
            //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
            let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
            //update display order
            r.displayOrder = idx
            //save only rows that changed
            if(save) {
              _self.tabs[idx].newDisplayOrder = idx
              rowsToSave.push(r)
            }
          })
          _self.saveRowChanges(rowsToSave)
        }
      })
    },
    data() {
      return {
        snackbar: {},
        constants,
        tabs: [],
        addNew: false,
        newTab: {},
        selectedTabId: null,
        userId: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        expanded: [],
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Tab Label', value: 'tabName', show: true },
          { text: null, value: 'icons', show: true }
        ],
        tabToDelete: null
      }
    },
    computed: {
      tabToDeleteName(){
        return this.tabToDelete ? this.tabToDelete.tabName : ''
      }
    },
    methods: {
      async getTabs() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/objectTypeTab/project`)
          this.tabs = data

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Tabs')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteTab() {
        const tabId= this.tabToDelete.id
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/objectTypeTab/${tabId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Successfully Deleted Tab')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Tab')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveTab(tab) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/objectTypeTab/project`, tab)
          this.snackbar = getSnackbar('SUCCESS', 'Tab Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          if(!tab.id) {
            // add it to the records already on the screen
            this.tabs.push(data)
          }

          // reset the new process fields
          this.addNew = false
          this.newTab = {}

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Tab')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveRowChanges(rows) {
        if(rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await putRequest(`/objectTypeTab/order`, rows)
            this.snackbar = getSnackbar('SUCCESS', 'Tab Order Saved')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Tab Order')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      filterTabs () {
        return this.tabs.filter(t => { return !t.archived})
      },
    },
    async created() {
      this.getTabs()
    }
  }
</script>
