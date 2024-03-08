<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Tabs</v-toolbar-title>
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
              :items="filteredTabs"
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
              <span class="default-text-color">No available tabs</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available tabs</span>
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
                <td class="text-right" :class="{'one-hunned':$vuetify.breakpoint.mdAndDown && selectedTabId !== item.id}">
                  <div class="item-icons" :class="{'d-flex flex-column align-end': $vuetify.breakpoint.xsOnly}">
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

    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";
  import cloneDeep from "lodash.clonedeep";
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store

  onMounted(() => {
    let table = document.querySelector('tbody')
    const _self = vueInstance
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
    getTabs()
  })
    
        const tabs = ref( [])
        const addNew = ref( false)
        const newTab = ref( {})
        const selectedTabId = ref( null)
        const expanded = ref( [])
        const tabToDelete = ref( null)
        const headers = ref( [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Tab Label', value: 'tabName', show: true },
          { text: null, value: 'icons', show: true, sortable: false }
        ])
  const filteredTabs = computed(() => {
    return tabs.value.filter(t => { return !t.archived})
  })
  const userCanAdd = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const companyId = computed(() => {
    return userStore.details.companyId
  })
  const userId = computed(() => {
    return userStore.details.id
  })
  const tabToDeleteName = computed(() => {
    return tabToDelete.value ? tabToDelete.value.tabName : ''
  })

    
      const getTabs = async() => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/objectTypeTab/project`)
          tabs.value = data

          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Retrieving Tabs')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const deleteTab = async() => {
        const tabId= tabToDelete.value.id
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/objectTypeTab/${tabId}`)
          getSnackbar('SUCCESS', 'Successfully Deleted Tab')
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Deleting Tab')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const saveTab = async(tab) => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/objectTypeTab/project`, tab)
          getSnackbar('SUCCESS', 'Tab Saved')
          selectedTabId.value = null
          if(!tab.id) {
            // add it to the records already on the screen
            tabs.value.push(data)
          }

          // reset the new process fields
          addNew.value = false
          newTab.value = {}

          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          getSnackbar('ERROR', 'Error Adding Tab')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const saveRowChanges = async(rows) => {
        if(rows?.length > 0) {
          store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await putRequest(`/objectTypeTab/order`, rows)
            getSnackbar('SUCCESS', 'Tab Order Saved')
            handleHidingGlobalLoader(vueInstance, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            getSnackbar('ERROR', 'Error Saving Tab Order')
            store.commit(AppMutations.SET_LOADING, false)
          }
        }
      }
</script>
