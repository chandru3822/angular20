<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="attach-header-bar">
          <v-toolbar-title class="title-large">Attachment Types</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                             color="primary"
                             @click="getAvailableAttachmentTypes" v-if="userCanAdd"
                             :prepend-icon="addNewType ? 'close' : 'add'"
                             :text="vuetify.breakpoint.smAndUp ? (addNewType ? 'CANCEL' : 'ADD TYPE') : ''"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card pa-2" color="primary lighten-9" v-if="addNewType">
          <v-autocomplete v-model="newType.attachmentTypeId"
                          :items="availableAttachmentTypes"
                          label="Select Attachment Type"
                          item-text="attachmentType"
                          item-value="id"
                          @input="assignNewType"
                          attach
          ></v-autocomplete>
        </v-card>

          <v-data-table
            :headers="visibleHeaders"
            :items="filteredTypes"
            :items-per-page="-1"
            :sort-desc="[false]"
            :sort-by="['displayOrder']"
            hide-default-footer
            disable-sort
            class="attachment-type-table elevation-1 square-card table-striped"
          >
            <template #no-data>
              No attachment types found
            </template>

            <template #no-results>
              No attachment types found
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
                             :to="getAttachmentTypeUrl(item.id)">
                  <a-btn
                    size="small"
                    variant="text"
                    color="primary"
                    prepend-icon="edit"
                  />
                </router-link>
                <a-btn
                  v-if="userCanEdit"
                  size="small"
                  variant="text"
                  color="primary"
                  class="clickable"
                  @click="attachmentTypeToDelete=item"
                  prepend-icon="delete"
                />
              </div>
            </template>
          </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!attachmentTypeToDelete"
                        @confirm="[attachmentTypeToDelete.archived = true, deleteTypeFromObject()]"
                        @close-dialog="attachmentTypeToDelete=null">
      Are you sure you want to delete this attachment type: <strong>{{attachmentTypeToDeleteName}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from "@/stores/AppStore";
import {handleHidingGlobalLoader, deleteRequest, getRequest, getSnackbar, postRequest, putRequest} from "@/helpers/helpers";
import orderBy from 'lodash.orderby'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { useUserStore } from '@/stores/UserStorePinia.js'
import {ref, onMounted, getCurrentInstance, computed, defineProps, onUpdated} from "vue";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

  const props = defineProps({
    objectTypeValue: String,
    showReadOnly: Boolean,
    showLinkable: Boolean,
    showUploadable: {
      type: Boolean,
      default: false
    },
    showFocused: { //pretty sure that all types will be "focusable"
      type: Boolean,
      default: true
    },
    primaryId: Number //used to load objects types that have more than one value
  })
  // mounted() {
  //   let table = document.querySelector('.attachment-type-table tbody')
  //   const _self = this
  //   Sortable.create(table, {
  //     handle: '.handle',
  //     onEnd({newIndex, oldIndex}) {
  //       const rowSelected = _self.attachmentTypes.splice(oldIndex, 1)[0]
  //       _self.attachmentTypes.splice(newIndex, 0, rowSelected)
  //       let rowsClone = cloneDeep(_self.attachmentTypes)
  //
  //       let rowsToSave = []
  //       rowsClone.forEach((r, idx) => {
  //         //check if the row needs to be saved before updating display order
  //         //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
  //         let save = r.newDisplayOrder === undefined ? r.displayOrder !== idx : r.newDisplayOrder !== idx
  //         //update display order
  //         r.displayOrder = idx
  //         //save only rows that changed
  //         if (save) {
  //           _self.attachmentTypes[idx].newDisplayOrder = idx
  //           rowsToSave.push(r)
  //         }
  //       })
  //       _self.saveAttachmentTypeOrder(rowsToSave)
  //     }
  //   })
  // },
  const userCanEdit = computed(() =>{
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })
  const userCanAdd = computed(() =>{
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
  })
  const attachmentTypeToDeleteName = computed(() =>{
    return attachmentTypeToDelete.value ? attachmentTypeToDelete.value.attachmentType : ''
  })
  const filteredTypes = computed(() =>{
    return orderBy(attachmentTypes.value.filter(e => { return !e.archived}), [e => e.attachmentType])
  })
  const headers = computed(() =>{
    return [
      // {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
      {text: 'Attachment Type', value: 'attachmentType', show: true},
      {text: 'Allow Upload', value: 'allowUpload', show: props.showUploadable, width: 100},
      {text: 'Linkable', value: 'linkable', show: props.showLinkable, width: 100},
      {text: 'Focused', value: 'focused', show: props.showFocused, width: 100},
      {text: null, value: 'icons', show: true, width: 150}
    ]
  })

  const addNewType = ref(false)
  const objectType = ref(props.objectTypeValue || route?.query?.objectType?.toLowerCase())
  const newType = ref({})
  const availableAttachmentTypes = ref([])
  const attachmentTypes = ref([])
  const attachmentTypeToDelete = ref(null)

const companyObjectTypeId = computed(() => {
  return route.query.companyObjectTypeId
})


  onMounted (() => {
    getAssignedAttachmentTypes()
  })
  const updateType = async (item) => {
    try {
      appStore.loading = true
      const {status} = await putRequest(`/attachmentType/${objectType.value}/update`, item)
      snackbar('SUCCESS', 'Attachment Type Updated')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Attachment Type')
      appStore.loading = false
    }
  }
  const visibleHeaders = computed(() => {
    return headers.value.filter(header => header.show === true)
  })
  const getAttachmentTypeUrl = (attachmentTypeId) => {
    switch(props.objectTypeValue) {
      case 'project':
        return `/settings/project/attachmentType/${attachmentTypeId}?companyObjectTypeId=${companyObjectTypeId.value}`
      case 'event':
        return `/settings/event/${props.primaryId}/attachmentType/${attachmentTypeId}`
      default:
        return `/settings/objectType/${route.params.id}/attachmentType/${attachmentTypeId}?objectType=${objectType.value}`
    }
  }
  const assignNewType = async () => {
    appStore.loading = true
    try {
      if(null != props.primaryId) {
        newType.value.primaryId = props.primaryId
      }
      const {data, status} = await postRequest(`/attachmentType/${objectType.value}`, newType.value)
      attachmentTypes.value.push(data)
      // reset fields
      addNewType.value = false
      newType.value = {}
      snackbar('SUCCESS', 'Attachment Type Added')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Adding Attachment Type')

      appStore.loading = false
    }
  }
  const getAvailableAttachmentTypes = async () => {
    appStore.loading = true
    try {
      addNewType.value = !addNewType.value
      if (addNewType.value) {
        let url = props.primaryId ? `/attachmentType/${objectType.value}/${props.primaryId}/available` : `/attachmentType/${objectType.value}/available`
        const {data} = await getRequest(url)
        availableAttachmentTypes.value = data
      }
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      handleHidingGlobalLoader(status)
    }
  }
  const getAssignedAttachmentTypes = async () => {
    appStore.loading = true
    try {
      let url = props.primaryId ? `/attachmentType/${objectType.value}/${props.primaryId}` : `/attachmentType/${objectType.value}`
      const {data, status} = await getRequest(url)
      attachmentTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
  const saveAttachmentTypeOrder = async (rows) => {
    if(rows?.length > 0) {
      try {
        appStore.loading = true
        const {status} = await putRequest(`/attachmentType/${objectType.value}/order`, rows)
        snackbar('SUCCESS', 'Attachment Type Order Saved')

        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving Attachment Type Order')

        appStore.loading = false
      }
    }
  }
  const deleteTypeFromObject = async () => {
    const id = attachmentTypeToDelete.value.id
    appStore.loading = true
    try {
      addNewType.value = false
      const {status} = await deleteRequest(`/attachmentType/${objectType.value}/${id}`)
      snackbar('SUCCESS', 'Attachment Type Deleted')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Deleting Attachment Type')

      appStore.loading = false
    }
    attachmentTypeToDelete.value = null
  }
</script>
