<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Event Status Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newType = {}]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :text="!addNew ? 'Add New Field' : 'Cancel'"
              :prepend-icon="addNew ? 'close' : 'add'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat v-if="addNew" class="px-5 py-2 square-card" color="primary lighten-9">
          <h3>Add Event Status</h3>
          <v-text-field label="Event Status" v-model="newType.eventStatusType">
          </v-text-field>
          <v-autocomplete single-line
                          :items="rootStatusTypes"
                          v-model="newType.eventStatusTypeId"
                          item-value="id"
                          label="Select a Category"
                          item-text="eventStatusType"></v-autocomplete>
          <a-btn
            color="primary"
            :disabled="!newType.eventStatusTypeId || !newType.eventStatusType"
            @click="saveType(newType, true)"
            text="Save"
          />

        </v-card>
        <v-card class="square-card">
          <v-card-title class="pt-0">
            <v-text-field
              v-model="search"
              prepend-inner-icon="search"
              label="Search"
              single-line
              hide-details
            ></v-text-field>
          </v-card-title>
          <v-data-table
            :headers="headers"
            :items="filteredEventStatuses"
            :fixed-header="true"
            :expanded.sync="expanded"
            single-expand
            :search="search"
            :items-per-page="-1"
            hide-default-footer
            :sort-by="['displayOrder']"
            :sort-desc="[false]"
            class="elevation-1"
          >
            <template #expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4 text-left"
                  :class="{'shaded-row': statusTypes.indexOf(item) % 2}">
                <h3 class="mb-3">Edit Status Type</h3>
                <v-text-field v-model="item.eventStatusType"
                              label="Status Type"
                              :readonly="!userCanEdit"
                              :disabled="!userCanEdit"
                ></v-text-field>
                <v-autocomplete
                  :items="rootStatusTypes"
                  v-model="item.eventStatusTypeId"
                  item-value="id"
                  :readonly="!userCanEdit"
                  :disabled="!userCanEdit"
                  label="Select a Category"
                  item-text="eventStatusType"></v-autocomplete>
                <a-btn
                  color="primary"
                  dark
                  class="white--text"
                  v-if="userCanEdit"
                  :disabled="!item.eventStatusType || !item.eventStatusTypeId"
                  @click="saveType(item, false)"
                  text="Save"
                />
              </td>
            </template>
            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td style="width: 50px">
                  <a-btn
                    variant="text"
                    color="primary"
                    size="small"
                    class="handle"
                    v-if="userCanEdit"
                    prepend-icon="drag_handle"
                  />
                </td>
                <td class="text-left">
                  {{ item.eventStatusType }}
                </td>
                <td class="text-left">
                  {{ item.rootEventStatusType }}
                </td>
                <td class="text-right">
                  <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    @click="getUsesForStatus(item.id, item.eventStatusType)"
                    prepend-icon="mdi-clipboard-list-outline"/>
                  <v-tooltip left>
                    <template v-slot:activator="{ on, attrs }">
                      <a-btn
                        color="primary"
                        @click="copyToClipBoard(item.id)" v-bind="attrs"
                        :activation-handler="on"
                        prepend-icon="mdi-information"
                        icon
                      />
                    </template>
                    <span>Event Status Id: {{item.id}}</span>
                    <div class="text-center">(click to copy)</div>
                  </v-tooltip>
                  <a-btn
                    icon
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="!expanded.includes(item)" @click="expanded = [item]"
                    prepend-icon="edit"
                  />
                  <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="expanded.includes(item)" @click="expanded = []"
                    text="cancel"
                  />
                  <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                    @click="[itemToDelete=item, showDeleteDialog=true]"
                    prepend-icon="delete"
                  />
                </td>

              </tr>
            </template>
          </v-data-table>
        </v-card>
      </v-col>

    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog"
                                 @confirm="deleteType"
                                 @close-dialog="closeDeleteDialog">
      Are you sure you want to delete this status type: <strong>{{itemToDeleteEventStatusType}}</strong>?

    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="showInfoDialog"
                        hideConfirm
                        @close-dialog="showInfoDialog=false"
                        :width="700"
    >
      <template v-slot:title>Event Status Usages: {{!!objectsUsingStatus ? objectsUsingStatus.fieldName : ''}}</template>
        <span v-if="deleteError" class="error-text">* Error deleting status</span>
        <span v-if="!objectsUsingStatus || (objectsUsingStatus.events && objectsUsingStatus.events.length === 0 && objectsUsingStatus.processStepEventActions && objectsUsingStatus.processStepEventActions.length === 0 && objectsUsingStatus.processStepEventRequirements && objectsUsingStatus.processStepEventRequirements.length === 0)">
          Nothing using this event status.
        </span>

      <div v-else id="event-status-uses-table">
        <div v-if="objectsUsingStatus.events && objectsUsingStatus.events.length > 0" class="label-large mt-6">Events</div>
      <v-simple-table v-if="objectsUsingStatus.events && objectsUsingStatus.events.length > 0">
        <tbody>
        <tr v-for="(item, index) in objectsUsingStatus.events" :key="index" :class="{'shaded-row': !(index % 2)}">
          <td>{{item.eventName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
      <div v-if="objectsUsingStatus.processStepEventRequirements && objectsUsingStatus.processStepEventRequirements.length > 0" class="label-large mt-6">Process Step Event Requirements</div>
      <v-simple-table v-if="objectsUsingStatus.processStepEventRequirements && objectsUsingStatus.processStepEventRequirements.length > 0">
        <thead>
        <tr>
          <th>Event</th>
          <th>Process Step</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(item, index) in objectsUsingStatus.processStepEventRequirements" :key="index" :class="{'shaded-row': !(index % 2)}">
          <td>{{item.eventName}}</td>
          <td>{{item.processStepName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
        <div v-if="objectsUsingStatus.processStepEventActions && objectsUsingStatus.processStepEventActions.length > 0" class="label-large mt-6">Process Step Event Actions</div>
      <v-simple-table v-if="objectsUsingStatus.processStepEventActions && objectsUsingStatus.processStepEventActions.length > 0">
        <thead>
        <tr>
          <th>Event</th>
          <th>Process Step</th>
          <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <tr v-for="(item, index) in objectsUsingStatus.processStepEventActions" :key="index" :class="{'shaded-row': !(index % 2)}">
          <td>{{item.eventName}}</td>
          <td>{{item.processStepName}}</td>
          <td>{{item.actionName}}</td>
        </tr>
        </tbody>
      </v-simple-table>
      </div>
      <template v-slot:no>Close</template>
    </ConfirmationDialog>
  </v-container>
</template>


<script setup>
import draggable from 'vuedraggable'

import orderBy from 'lodash.orderby'
import {getCompanyEventStatusTypes, getEventStatusTypes} from '@/services/eventStatusTypeService'
import {getRequest, deleteRequest, putRequest, defineSortableTable} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {computed, getCurrentInstance, ref, onMounted} from "vue";

import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import { useFileStore } from '@/stores/FileStore.js'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
const fileStore = useFileStore()

const search = ref('')
const statusTypes = ref([])
const expanded = ref([])
const rootStatusTypes = ref([])
const acceptedFileTypes = ref(constants.STANDARD_IMAGES_ONLY)
const savingTypeLogo = ref(false)
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true},
  {text: 'Event Status', value: 'eventStatusType', show: true},
  {text: 'Status', value: 'rootEventStatusType', show: true},
  {text: '', value: 'icons', show: true},
])
const addNew = ref(false)
const newType = ref({})
const selectedStatusTypeId = ref(null)
const fieldsInUse = ref([])
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const showInfoDialog = ref(false)
const objectsUsingStatus = ref([])
const deleteError = ref(false)

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})

onMounted(() => {
  defineSortableTable('tbody', statusTypes, 'displayOrder', saveOrderChanges)

  getCompanyStatusTypes()
  getAllEventStatusTypes()
})

const itemToDeleteEventStatusType = computed(() =>{
  return itemToDelete.value ? itemToDelete.value.eventStatusType : ''
})
const filteredEventStatuses = computed(() =>{
  return statusTypes.value.filter(s => !s.archived)
})

const saveOrderChanges = async (types) => {
  appStore.loading = true
  try {
    await putRequest(`/event/companyStatuses`, types)
    snackbar('SUCCESS', 'Status Types Updated')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Status Type Changes')
    appStore.loading = false
  }
}
const uploadFile = async (item, files, attachmentTypeId, sourceId, sizeLimit) => {
  try {
    appStore.loading = true
    let file = files[0]
    await fileStore.uploadFile({
      file: file,
      sizeLimit,
      attachmentTypeId,
      sourceId,
      displayName: file.name.substr(0, file.name.lastIndexOf('.')),
      callback: async (img, error) => {
        if (error?.error) {
          snackbar('ERROR', error.errorMsg)
          appStore.loading = false
        } else {
          item.icon = img
          snackbar('SUCCESS', 'Image Uploaded')
          appStore.loading = false
        }
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Uploading File')
    appStore.loading = false
  }
}

const deleteAttachment = async (item) => {
  try {
    appStore.loading = true
    await fileStore.deleteFile({
      id: item.icon.id,
      callback: async (status) => {
        item.icon = {}
        snackbar('SUCCESS', 'Image Deleted')
        appStore.loading = false
      }
    })
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting File')
    appStore.loading = false
  }
}

const getCompanyStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data} = await getCompanyEventStatusTypes()
    statusTypes.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}

const getAllEventStatusTypes = async () => {
  appStore.loading = true
  try {
    const {data} = await getEventStatusTypes()
    rootStatusTypes.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getUsesForStatus = async (eventStatusId, eventStatusName) => {
  deleteError.value = false
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/event/companyStatusUses/${eventStatusId}`);
    objectsUsingStatus.value = data
    objectsUsingStatus.value.fieldName = eventStatusName
    showInfoDialog.value = true
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}

const deleteType = async () => {
  deleteError.value = false
  const item = itemToDelete.value
  appStore.loading = true
  try {
    await deleteRequest(`/event/companyStatus/${item.id}`)
    fieldsInUse.value = [];
    snackbar('SUCCESS', 'Status Deleted')

    appStore.loading = false
    item.archived = true
    //it makes no sense why this didn't work and why the code isn't yelling that i am editing a const variable... ? oh well
    // this.itemToDelete.archived = true
  } catch (e) {
    if (e.status === 400) {
      showInfoDialog.value = true
      deleteError.value = true
      objectsUsingStatus.value = e.data;
      objectsUsingStatus.value.fieldName = item.eventStatusType
      snackbar("ERROR", "Error Deleting Status");
      appStore.loading = false
    }
    else {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Status')
      appStore.loading = false
    }
  } finally {
    closeDeleteDialog()
  }
}

const saveType = async (type, isNew) => {
  appStore.loading = true
  try {
    const {data} = await putRequest(`/event/companyStatus`, type)

    if (isNew) {
      // add it to the records already on the screen
      statusTypes.value.push(data)
      statusTypes.value = orderBy(statusTypes.value, [s => s.eventStatusType.toLowerCase()])

      // reset the new process fields
      addNew.value = false
      newType.value = {}
    } else {
      type.eventStatusTypeId = data.eventStatusTypeId
      type.eventStatusType = data.eventStatusType
      type.rootEventStatusType = data.rootEventStatusType
    }
    expanded.value = []
    selectedStatusTypeId.value = null
    snackbar('SUCCESS', 'Event Status Saved')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Event Status')
    appStore.loading = false
  }
}

const copyToClipBoard = (textValue) =>{
  navigator.clipboard.writeText(textValue);
  snackbar('SUCCESS', 'Copied text to clipboard')

}
const closeDeleteDialog = () =>{
  showDeleteDialog.value = false
  itemToDelete.value = null
}

</script>

<style lang="scss">
#event-status-uses-table > div.v-data-table.theme--light > div.v-data-table__wrapper {
  max-height: 175px;
  overflow-y: scroll;
}
</style>


<style scoped lang="scss">

</style>
