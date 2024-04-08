<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="req-header-bar">
          <v-toolbar-title class="title-large">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                @click="[addNewType = !addNewType, getAvailableTypes()]"
                variant="text"
                v-if="userCanAdd"
                color="primary"
                :prepend-icon="!addNewType ? 'add' : 'close'"
                :text="addNewType ? 'Cancel' : 'Add Attachment Type'"
            ></a-btn>
            <a-btn
                variant="text"
                @click="expandTypes = !expandTypes"
                color="unset"
                :prepend-icon="!expandTypes ? 'mdi-chevron-down' : 'mdi-chevron-up'"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-row v-if="addNewType">
          <v-col cols="12">
            <v-autocomplete v-model="newType"
                            :items="availableTypes"
                            label="Select Attachment Type"
                            item-value="id"
                            item-text="attachmentType"
                            return-object
            ></v-autocomplete>
            <a-btn
                color="primary"
                :disabled="!newType.id"
                @click="addTypeToProcessStep"
                text="Save"
            ></a-btn>
          </v-col>
        </v-row>
        <v-row v-if="expandTypes">
          <v-col cols="12" class="pt-0">
            <v-data-table
              :headers="headers"
              :items="filteredTypes"
              :items-per-page="-1"
              :sort-desc="[false]"
              :sort-by="['displayOrder']"
              hide-default-footer
              disable-sort
              class="attachment-type-table elevation-1 square-card table-striped"
            >
              <template #no-data>
                No attachment types for this process step
              </template>

              <template #no-results>
                No attachment types for this process step
              </template>

                  <template #item.attachmentType="{item}" class="text-left">{{item.attachmentType}}</template>
                  <template #item.allowUpload="{item}">
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.allowUpload"
                                @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </template>
                  <template #item.linkable="{item}">
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.linkable"
                                @change="updateType(item)"  :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </template>
                  <template #item.focused="{item}">
                    <v-checkbox type="checkbox" class="ml-3" v-model="item.focused"
                                @change="updateType(item)" :disabled="!userCanEdit" :readonly="!userCanEdit">
                    </v-checkbox>
                  </template>
                  <template #item.icons="{item, index}">
                    <div style="display: flex; justify-content: flex-end">
                      <router-link class="no-text-decoration pr-3"
                                   :to="`/settings/processStep/${processStepId}/attachmentType/${item.id}`">
                        <a-btn
                            size="small"
                            variant="text"
                            color="primary"
                            prepend-icon="edit"
                        ></a-btn>
                      </router-link>
                      <a-btn
                          size="small"
                          color="primary"
                          variant="text"
                          @click="attachmentTypeToDelete = item"
                          prepend-icon="delete"
                      ></a-btn>
                    </div>
                  </template>

            </v-data-table>
          </v-col>
        </v-row>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!attachmentTypeToDelete" @confirm="deleteTypeFromStep" @close-dialog="attachmentTypeToDelete = null">
      Are you sure you want to delete this attachment type: <strong>{{attachmentTypeToDeleteName}}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>


import orderBy from 'lodash.orderby'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, handleHidingGlobalLoader
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

      const expandTypes = ref(true)
      const addNewType = ref(false)
      const newType = ref({})
      const attachmentTypes = ref([])
      const availableTypes = ref([])
      const attachmentTypeToDelete = ref(null)
      const headers = ref([
  // {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Attachment Type', value: 'attachmentType', show: true},
  {text: 'Allow Upload', value: 'allowUpload', show: true, width: 100},
  {text: 'Linkable', value: 'linkable', show: true, width: 100},
  {text: 'Focused', value: 'focused', show: true, width: 100},
  {text: null, value: 'icons', show: true, width: 150}
])

const processStepId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})
const attachmentTypeToDeleteName = computed(() => {
  return attachmentTypeToDelete.value?.attachmentType || ''
})
const filteredTypes = computed(() => {
  return orderBy(attachmentTypes.value?.filter(e => !e.archived), [e => e.displayOrder])
})

onMounted(async() => {
    await getAttachmentTypes()
})

    const updateType = async(item) => {
      try {
        appStore.loading = true
        const {status} = await putRequest(`/processStep/${processStepId.value}/attachmentType/update`, item)
        snackbar('SUCCESS', 'Attachment Type Updated')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving Attachment Type')
        appStore.loading = false
      }
    }
    const getAttachmentTypes = async() => {
      appStore.loading = true
      try {
        const {data} = await getRequest(`/processStep/${processStepId.value}/attachmentType`)
        attachmentTypes.value = data
        appStore.loading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      }
    }
    const getAvailableTypes = async() => {
      if(addNewType.value) {
        appStore.loading = true
        try {
          const {data} = await getRequest(`/processStep/${processStepId.value}/attachmentType/available`)
          availableTypes.value = data
          appStore.loading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Retrieving Data')
          appStore.loading = false
        }
      }
    }
    const addTypeToProcessStep = async() => {
      appStore.loading = true
      try {
        let params = {
          attachmentTypeId: newType.value.id
        }
        const {data} = await postRequest(`/processStep/${processStepId.value}/attachmentType`, params)
        attachmentTypes.value.push(data)
        newType.value = {}
        addNewType.value = false
        appStore.loading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Adding Attachment Type')
        appStore.loading = false
      }
    }
    const deleteTypeFromStep = async() => {
      let item = attachmentTypeToDelete.value
      appStore.loading = true
      try {
        await deleteRequest(`/processStep/${processStepId.value}/attachmentType/${item.id}`)
        item.archived = true
        snackbar('SUCCESS', 'Attachment Type Deleted')
        appStore.loading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Deleting Attachment Type')
        appStore.loading = false
      }
    }
    const saveRowChanges = async(rows) => {
      if (rows?.length > 0) {
        appStore.loading = true
        try {
          await putRequest(`/processStep/${processStepId.value}/attachmentType/order`, rows)
          snackbar('SUCCESS', 'Attachment Type Order Saved')
          appStore.loading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          snackbar('ERROR', 'Error Saving Attachment Type Order')
          appStore.loading = false
        }
      }
    }
</script>

<style scoped lang="scss">
.required-field-label {
  width: 100px;
}
</style>
