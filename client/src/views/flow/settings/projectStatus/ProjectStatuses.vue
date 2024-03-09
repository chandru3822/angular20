<template>
  <v-container class="custom-field-group-container">
    <v-dialog
        v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          Error Deleting Project Status
        </v-card-title>

        <v-card-text>
          You cannot delete a project status that is currently in use.
          <v-list>
            <v-list-item-content v-if="fieldsInUse.statusInUseByProjects">
              Status is in use by various Projects
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByActions">
              Status is in use by various Process Step Actions
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByProcessStepRequirements">
              Status is in use by various Process Step Requirements
            </v-list-item-content>
            <v-list-item-content v-if="fieldsInUse.statusInUseByEventRequirements">
              Status is in use by various Process Step Event Requirements
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <AlbatrossButton
              color="primary"
              variant="text"
              dark
              class=""
              @click="deleteError = false"
              text="OK"
          ></AlbatrossButton>

        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Project Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
                variant="text"
                color="primary"
                @click="[addNew = !addNew, newType = {}]"
                v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
                prepend-icon="add"
                :text="addNew ? 'Cancel' : 'Add New'"
            ></AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="primary lighten-9">
          <h3>Add Project Status</h3>
          <v-text-field label="Project Status" v-model="newType.projectStatusType">
          </v-text-field>
          <v-autocomplete single-line
                          :items="rootStatusTypes"
                          v-model="newType.projectStatusTypeId"
                          item-value="id"
                          label="Select a Category"
                          item-text="projectStatusType"
                          attach></v-autocomplete>
          <AlbatrossButton
              color="primary"
              :disabled="!newType.projectStatusTypeId || !newType.projectStatusType"
              @click="saveNewType(newType)"
              text="Save"
          ></AlbatrossButton>

        </v-card>
        <v-data-table
            :headers="headers"
            :items="filteredProjectStatuses"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            :loading="companyStatusesLoading"
            :sort-by="['displayOrder']"
            :sort-desc="[false]"
            class="elevation-1"
        >
          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td style="width: 50px">
                <AlbatrossButton
                    variant="text"
                    color="primary"
                    icon
                    size="small"
                    class="handle"
                    v-if="userCanEdit"
                    prepend-icon="drag_handle"
                ></AlbatrossButton>
              </td>
              <td class="text-left">
                {{ item.projectStatusType }}
              </td>
              <td class="text-left">
                {{ item.rootProjectStatusType }}
              </td>
              <td class="text-left">
                <input v-if="item.isDefault" type="checkbox" v-model="item.isDefault" disabled readonly>
              </td>
              <td class="text-left">
                <v-icon v-if="item.iconTag != null">{{ item.iconTag }}</v-icon>
              </td>
              <td class="text-right">
                <v-tooltip left>
                  <template v-slot:activator="{ on, attrs }">
                    <AlbatrossButton
                        icon
                        color="primary"
                        @click="copyToClipBoard(item.id)"
                        v-bind="attrs"
                        :activation-handler="on"
                        prepend-icon="mdi-information"
                    ></AlbatrossButton>
                  </template>
                  <span>Project Status ID: {{ item.id }}</span>
                  <div class="text-center">(click to copy)</div>
                </v-tooltip>
                <AlbatrossButton
                    size="small"
                    variant="text"
                    color="primary"
                    :to="`/settings/projectStatus/${item.id}/components`"
                    prepend-icon="edit"
                ></AlbatrossButton>
                <AlbatrossButton
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                    @click.native.stop="[itemToDelete=item, showDeleteDialog=true]"
                    prepend-icon="delete"
                ></AlbatrossButton>

              </td>

            </tr>
          </template>
        </v-data-table>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                        @confirm="deleteType"
                        @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this status type: <strong>{{ toDeleteStatusType }}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {AppMutations} from '@/stores/AppStore'
import draggable from 'vuedraggable'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'
import ConfirmationDialog from '@/components/ConfirmationDialog'

import orderBy from 'lodash.orderby'
import {getCompanyProjectStatusTypes, getProjectStatusTypes} from '@/services/projectStatusTypeService'
import {handleHidingGlobalLoader, deleteRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'

const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const filteredProjectStatuses = computed(() => {
  return statusTypes.value.filter(s => {
    return !s.archived
  })
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
const toDeleteStatusType = computed(() => {
  return itemToDelete.value ? itemToDelete.value.projectStatusType : ''
})

onMounted(() => {
  let table = document.querySelector('tbody')
  const _self = vueInstance
  Sortable.create(table, {
    handle: '.handle',
    onEnd({newIndex, oldIndex}) {
      const rowSelected = _self.statusTypes.splice(oldIndex, 1)[0]
      _self.statusTypes.splice(newIndex, 0, rowSelected)
      let statusTypesClone = cloneDeep(_self.statusTypes)
      statusTypesClone.forEach((g, idx) => {
        g.displayOrder = idx
      })
      _self.saveOrderChanges(statusTypesClone)
    }
  })

  getCompanyStatusTypes()
  getTheseProjectStatusTypes()
})

const statusTypes = ref([])
const rootStatusTypes = ref([])
const companyStatusesLoading = ref(true)
const addNew = ref(false)
const newType = ref({})
const fieldsInUse = ref([])
const deleteError = ref(false)
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true},
  {text: 'Project Stage', value: 'projectStatusType', show: true},
  {text: 'Status', value: 'rootProjectStatusType', show: true},
  {text: 'Initial', value: 'initial', show: true},
  {text: 'Icon', value: 'icon', show: true},
  {text: '', value: 'icons', show: true},
])


const saveOrderChanges = async (types) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/projectStatus/companyStatuses`, types)
    getSnackbar('SUCCESS', 'Status Types Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Saving Status Type Changes')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getCompanyStatusTypes = async () => {
  companyStatusesLoading.value = true
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getCompanyProjectStatusTypes()
    statusTypes.value = data
    companyStatusesLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveNewType = async (type) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await putRequest(`/projectStatus/company`, type)

    // add it to the records already on the screen
    statusTypes.value.push(data)
    statusTypes.value = orderBy(statusTypes.value, [s => s.projectStatusType.toLowerCase()])

    // reset the new process fields
    addNew.value = false
    newType.value = {}

    getSnackbar('SUCCESS', 'Project Status Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Saving Project Status')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getTheseProjectStatusTypes = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getProjectStatusTypes()
    rootStatusTypes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteType = async () => {
  const item = itemToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/projectStatus/companyStatus/${item.id}`)
    item.archived = true
    getSnackbar('SUCCESS', 'Status Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    if (e.status === 400) {
      deleteError.value = true;
      fieldsInUse.value = e.data;
      getSnackbar("ERROR", "Error Deleting Status");
      store.commit(AppMutations.SET_LOADING, false)
    } else {
      console.error('*** ERROR ***', e)
      getSnackbar('ERROR', 'Error Deleting Status')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  closeDeleteDialog()
}

const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue);
  getSnackbar('SUCCESS', 'Copied text to clipboard')
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
</script>

<style scoped lang="scss">
.status-icon {
  margin-top: 15px;
  max-width: 50px;
  height: auto;
}

.status-icon-grid {
  margin-top: 5px;
  max-width: 40px;
  height: auto;
}
</style>
