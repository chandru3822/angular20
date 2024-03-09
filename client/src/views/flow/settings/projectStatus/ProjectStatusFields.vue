<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Data View Fields</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

            <AlbatrossButton
                variant="text"
                color="primary"
                v-if="!addNew && userCanAdd"
                @click="[addNew = !addNew, loadDataViews()]"
                prepend-icon="add"
                text="Add Field"
            ></AlbatrossButton>

          </v-toolbar-items>
        </v-toolbar>
        <div class="px-5" v-if="addNew">
          Add New Field to Milestone
          <v-select attach
                    class="mt-3"
                    v-model="selectedDataView"
                    :items="dataViews"
                    label="Select Data View"
                    item-value="id"
                    return-object
                    item-text="displayName"
                    @input="[availableDataViewFields = [], selectedDataViewField = {}, getDataViewFields() ]"
          ></v-select>
          <v-autocomplete
            v-model="selectedDataViewField"
            :items="availableDataViewFields"
            label="Data View Field"
            return-object
            attach
            item-text="fieldName"
          ></v-autocomplete>
          <AlbatrossButton
              v-if="userCanEdit"
              :disabled="!selectedDataViewField.id"
              color="primary"
              class="d-inline-block"
              @click="saveFieldToMilestone()"
              prepend-icon="save"
              text="Save"
          ></AlbatrossButton>

          <AlbatrossButton
              class="ml-3"
              @click="[addNew = false, selectedDataViewField = {} ]"
              text="cancel"
          ></AlbatrossButton>

        </div>
        <v-divider class="my-3" v-if="addNew"></v-divider>

        <v-data-table
          :headers="headers"
          :items="filteredAssignedFields"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          :loading="fieldsLoading"
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
                {{item.fieldName}}
              </td>
              <td class="text-right">
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
                        @confirm="deleteField"
                        @close-dialog="closeDeleteDialog"
    >
      Are you sure you want to delete this field: <strong>{{ itemToDelete?.fieldName }}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import draggable from 'vuedraggable'
import {handleHidingGlobalLoader, deleteRequest, putRequest, defineSortableTable, getRequest, postRequest} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog.vue";
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

onMounted(() => {
  defineSortableTable('tbody', assignedFields, 'displayOrder', saveOrderChanges)

  loadFields()
})




const addNew = ref( false)
const selectedDataView = ref( {})
const selectedDataViewField = ref( {})
const showDeleteDialog = ref( false)
const itemToDelete = ref( null)
const dataViews = ref( [])
const fieldsLoading = ref( true)
const assignedFields = ref( [])
const availableDataViewFields = ref( [])
const headers = ref( [
  { text: null, value: 'draggable', width: '50px', show: true },
  {text: 'Field Name', value: 'fieldName', show: true},
  {text: '', value: 'icons', show: true},
])

const statusId = computed(() => {
  return route.params.id
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
const filteredAssignedFields = computed(() => {
  return assignedFields.value.filter(s => { return !s.archived})
})


    const saveOrderChanges = async (fields) => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/projectStatus/company/${statusId.value}/fields`, fields)
        snackbar('SUCCESS', 'Field Order Updated')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving Field Order')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const closeDeleteDialog = () => {
      showDeleteDialog.value = false
      itemToDelete.value = null
    }
    const loadDataViews = async() => {
      //dont reload the list every time
      if(dataViews.value.length === 0) {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/dataView`, null, [])
          dataViews.value = data
          store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Data')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
    const getDataViewFields = async() => {
      //dont reload the list every time
      if(availableDataViewFields.value.length === 0) {
        store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customField/getByDataView/${selectedDataView.value.id}`)
          availableDataViewFields.value = data
          store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Data')
          store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
    const deleteField = async() => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        let id = itemToDelete.value.id
        const {status} = await deleteRequest(`/projectStatus/field/${id}`)
        assignedFields.value = assignedFields.value.filter(af => af.id !== id)
        snackbar('SUCCESS', 'Field Removed')
        handleHidingGlobalLoader(vueInstance, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Removing Field')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const saveFieldToMilestone = async() => {
      store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          dataViewFieldConfigId: !selectedDataViewField.value.dataViewChildFieldConfigId ? selectedDataViewField.value.dataViewFieldConfigId : null,
          dataViewChildFieldConfigId: selectedDataViewField.value.dataViewChildFieldConfigId
        }
        const {data, status} = await postRequest(`/projectStatus/company/${statusId.value}/field`, params)
        assignedFields.value.push(data)
        selectedDataViewField.value = {}
        addNew.value = false
        store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        store.commit(AppMutations.SET_LOADING, false)
      }
    }
    const loadFields = async() => {
      fieldsLoading.value = true
      try {
        const {data} = await getRequest(`/projectStatus/company/${statusId.value}/fields`, null, [])
        assignedFields.value = data
        fieldsLoading.value = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        fieldsLoading.value = false
      }
    }

</script>

<style scoped lang="scss">

</style>
