<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col class="shrink pt-0" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">Tabs</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
                variant="text"
                color="primary"
                @click="[addNew = !addNew, newTab ={}]"
                v-if="userCanAdd"
                prepend-icon="add"
                :text="addNew ? 'Cancel' : 'Add New'"
            ></AlbatrossButton>

          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <div v-if="addNew" class="mb-2">
            <v-text-field v-model="newTab.tabName"
                          placeholder=" "
                          label="Tab Label">
            </v-text-field>
            <AlbatrossButton
                :disabled="!newTab.tabName"
                color="primary"
                @click="saveTab(newTab)"
                text="Save"
            ></AlbatrossButton>

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
                  <AlbatrossButton
                      variant="text"
                      v-if="userCanEdit"
                      icon
                      size="small"
                      color="primary"
                      class="handle"
                      prepend-icon="drag_handle"
                  ></AlbatrossButton>
                </td>
                <td class="text-left">
                  <v-text-field class="one-hunned" v-if="selectedTabId === item.id" v-model="item.tabName"></v-text-field>
                  <span v-else>{{item.tabName}}</span>
                </td>
                <td class="text-right" :class="{'one-hunned':$vuetify.breakpoint.mdAndDown && selectedTabId !== item.id}">
                  <div class="item-icons" :class="{'d-flex flex-column align-end': $vuetify.breakpoint.xsOnly}">
                    <AlbatrossButton
                        class="clickable"
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanEdit && selectedTabId === item.id"
                        @click="saveTab(item)"
                        prepend-icon="save"
                    ></AlbatrossButton>

                    <AlbatrossButton
                        class="clickable"
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanEdit && selectedTabId !== item.id"
                        @click="selectedTabId = item.id"
                        prepend-icon="edit"
                    ></AlbatrossButton>

                    <AlbatrossButton
                        class="clickable"
                        size="small"
                        variant="text"
                        color="primary"
                        v-if="userCanEdit"
                        @click="tabToDelete=item"
                        prepend-icon="delete"
                    ></AlbatrossButton>

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
  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, defineSortableTable} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import { getCurrentInstance, computed, ref, onMounted } from 'vue'
  import {useUserStore} from '@/stores/UserStorePinia.js'
  const userStore = useUserStore()
  const vueInstance = getCurrentInstance().proxy
  const store = vueInstance.$store
  const snackbar = vueInstance.$snackbar

  onMounted(() => {
    defineSortableTable('tbody', tabs, 'displayOrder', saveRowChanges)

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
          snackbar('ERROR', 'Error Retrieving Tabs')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const deleteTab = async() => {
        const tabId= tabToDelete.value.id
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/objectTypeTab/${tabId}`)
          snackbar('SUCCESS', 'Successfully Deleted Tab')
          handleHidingGlobalLoader(vueInstance, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Deleting Tab')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const saveTab = async(tab) => {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/objectTypeTab/project`, tab)
          snackbar('SUCCESS', 'Tab Saved')
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
          snackbar('ERROR', 'Error Adding Tab')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
      const saveRowChanges = async(rows) => {
        if(rows?.length > 0) {
          store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await putRequest(`/objectTypeTab/order`, rows)
            snackbar('SUCCESS', 'Tab Order Saved')
            handleHidingGlobalLoader(vueInstance, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            snackbar('ERROR', 'Error Saving Tab Order')
            store.commit(AppMutations.SET_LOADING, false)
          }
        }
      }
</script>
