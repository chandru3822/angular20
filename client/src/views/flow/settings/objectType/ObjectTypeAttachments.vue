<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="pa-0 mt-4">
        <v-toolbar flat class="attach-header-bar">
          <v-toolbar-title class="title-large">
            Attachment Types
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-select
              v-if="hasMultipleCategories"
              v-model="selectedObjectCategory"
              :items="objectCategories"
              item-text="name"
              item-value="id"
              label="Object Category"
              solo
            >
              <template #prepend-item>
                <v-list-item ripple @click="selectedObjectCategory = -1">
                  <v-list-item-content>
                    <v-list-item-title> Select All </v-list-item-title>
                  </v-list-item-content>
                </v-list-item>
              </template>
            </v-select>

            <a-btn
              variant="text"
              color="primary"
              @click="getAvailableAttachmentTypes"
              v-if="userCanAdd"
              :prepend-icon="addNewType ? 'close' : 'add'"
              :text="
                vuetify.breakpoint.smAndUp
                  ? addNewType
                    ? 'CANCEL'
                    : 'ADD TYPE'
                  : ''
              "
            />
          </v-toolbar-items>
        </v-toolbar>

        <!--        TODO: validations-->
        <v-card class="pa-5 mb-2" v-if="addNewType">
          <a-autocomplete
            v-model="newType.attachmentTypeId"
            :items="availableAttachmentTypes"
            label="Select Attachment Type"
            item-title="attachmentType"
            item-value="id"
            attach
          ></a-autocomplete>

          <v-select
            :items="objectCategories"
            v-if="requiresObjectCategory"
            v-model="newType.objectCategoryIds"
            item-text="name"
            item-value="id"
            label="Object Category"
            aria-required="true"
            multiple
          ></v-select>

          <a-btn @click="assignNewType">Save</a-btn>
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
          <template #no-data> No attachment types found </template>

          <template #no-results> No attachment types found </template>
          <template #item.attachmentType="{ item }" class="text-left">
            {{ item.attachmentType }}
          </template>
          <template #item.allowUpload="{ item }">
            <v-checkbox
              type="checkbox"
              class="ml-3"
              v-model="item.allowUpload"
              @change="updateType(item)"
              :disabled="!userCanEdit"
              :readonly="!userCanEdit"
            >
            </v-checkbox>
          </template>
          <template #item.linkable="{ item }">
            <v-checkbox
              type="checkbox"
              class="ml-3"
              v-model="item.linkable"
              @change="updateType(item)"
              :disabled="!userCanEdit"
              :readonly="!userCanEdit"
            >
            </v-checkbox>
          </template>
          <template #item.focused="{ item }">
            <v-checkbox
              type="checkbox"
              class="ml-3"
              v-model="item.focused"
              @change="updateType(item)"
              :disabled="!userCanEdit"
              :readonly="!userCanEdit"
            >
            </v-checkbox>
          </template>
          <template #item.icons="{ item, index }">
            <div style="display: flex; justify-content: flex-end">
              <router-link
                class="no-text-decoration pr-3"
                :to="getAttachmentTypeUrl(item.id)"
              >
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
                @click="attachmentTypeToDelete = item"
                prepend-icon="delete"
              />
            </div>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog
      :open-dialog="!!attachmentTypeToDelete"
      @confirm="
        ;[(attachmentTypeToDelete.archived = true), deleteTypeFromObject()]
      "
      @close-dialog="attachmentTypeToDelete = null"
    >
      Are you sure you want to delete this attachment type:
      <strong>{{ attachmentTypeToDeleteName }}</strong
      >?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {
  handleHidingGlobalLoader,
  deleteRequest,
  getRequest,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import ConfirmationDialog from '@/components/ConfirmationDialog'

import { useUserStore } from '@/stores/UserStore.js'
import { ref, onMounted, getCurrentInstance, computed } from 'vue'
import { useRoute } from 'vue-router/composables'
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const route = useRoute()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const selectedObjectCategory = ref(-1)
const objectCategories = ref([])

const props = defineProps({
  id: String,
  objectTypeValue: String,
  showReadOnly: Boolean,
  showLinkable: Boolean,
  showUploadable: {
    type: Boolean,
    default: false
  },
  showFocused: {
    //pretty sure that all types will be "focusable"
    type: Boolean,
    default: true
  },
  primaryId: Number //used to load objects types that have more than one value
})

const userCanEdit = computed(() =>
  userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
)
const userCanAdd = computed(() =>
  userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
)
const hasMultipleCategories = computed(() => {
  const types = attachmentTypes.value
    ?.map((at) => at.objectCategoryId)
    ?.filter((at) => at !== undefined)

  return new Set(types).size > 1
})
const attachmentTypeToDeleteName = computed(() => {
  return attachmentTypeToDelete.value
    ? attachmentTypeToDelete.value.attachmentType
    : ''
})
const filteredTypes = computed(() => {
  return attachmentTypes.value
    ?.filter((a) => !a.archived)
    ?.filter((a) => {
      if (selectedObjectCategory.value === -1) {
        return true
      }
      return a.objectCategoryId === selectedObjectCategory.value
    })
    ?.sort(function (a, b) {
      return a.attachmentType.localeCompare(b.attachmentType)
    })
})
const headers = computed(() => {
  return [
    { text: 'Attachment Type', value: 'attachmentType', show: true },
    {
      text: 'Allow Upload',
      value: 'allowUpload',
      show: props.showUploadable,
      width: 100
    },
    {
      text: 'Linkable',
      value: 'linkable',
      show: props.showLinkable,
      width: 100
    },
    { text: 'Focused', value: 'focused', show: props.showFocused, width: 100 },
    { text: null, value: 'icons', show: true, width: 150 }
  ]
})

const addNewType = ref(false)
const objectType = ref(
  props.objectTypeValue || route?.query?.objectType?.toLowerCase()
)
const requiresObjectCategory = computed(() =>
  ['project', 'contact'].includes(objectType.value)
)
const newType = ref({})
const availableAttachmentTypes = ref([])
const attachmentTypes = ref([])
const attachmentTypeToDelete = ref(null)
const companyObjectTypeId = computed(() => {
  return route.query.companyObjectTypeId
})

onMounted(() => {
  Promise.allSettled([getAssignedAttachmentTypes(), getObjectCategories()])
})

const updateType = async (item) => {
  try {
    appStore.loading = true
    const { status } = await putRequest(
      `/attachmentType/${objectType.value}/update`,
      item
    )
    appStore.showSnack('SUCCESS', 'Attachment Type Updated')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Saving Attachment Type')
    appStore.loading = false
  }
}

const visibleHeaders = computed(() => {
  return headers.value.filter((header) => header.show === true)
})

const getAttachmentTypeUrl = (attachmentTypeId) => {
  switch (props.objectTypeValue) {
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
    if (null != props.primaryId) {
      newType.value.primaryId = props.primaryId
    }
    const { data, status } = await postRequest(
      `/attachmentType/${objectType.value}`,
      newType.value
    )
    attachmentTypes.value = [data, ...attachmentTypes.value]
    // reset fields
    addNewType.value = false
    newType.value = {}
    appStore.showSnack('SUCCESS', 'Attachment Type Added')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Attachment Type')

    appStore.loading = false
  }
}

const getAvailableAttachmentTypes = async () => {
  appStore.loading = true
  try {
    addNewType.value = !addNewType.value
    if (addNewType.value) {
      let url = props.primaryId
        ? `/attachmentType/${objectType.value}/${props.primaryId}/available`
        : `/attachmentType/${objectType.value}/available`
      const { data } = await getRequest(url)
      availableAttachmentTypes.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
  }
}

const getObjectCategories = async () => {
  try {
    if (requiresObjectCategory.value) {
      const { data } = await getRequest(
        `/objectCategory?objectTypeId=${companyObjectTypeId.value || props.id || props.primaryId}`
      )
      objectCategories.value = data
    } else {
      objectCategories.value = []
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Object Categories')
  }
}

const getAssignedAttachmentTypes = async () => {
  appStore.loading = true
  try {
    let url = props.primaryId
      ? `/attachmentType/${objectType.value}/${props.primaryId}`
      : `/attachmentType/${objectType.value}`
    const { data, status } = await getRequest(url)
    attachmentTypes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}

const saveAttachmentTypeOrder = async (rows) => {
  if (rows?.length > 0) {
    try {
      appStore.loading = true
      const { status } = await putRequest(
        `/attachmentType/${objectType.value}/order`,
        rows
      )
      appStore.showSnack('SUCCESS', 'Attachment Type Order Saved')

      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Attachment Type Order')

      appStore.loading = false
    }
  }
}

const deleteTypeFromObject = async () => {
  const id = attachmentTypeToDelete.value.id
  appStore.loading = true
  try {
    addNewType.value = false
    const { status } = await deleteRequest(
      `/attachmentType/${objectType.value}/${id}`
    )
    appStore.showSnack('SUCCESS', 'Attachment Type Deleted')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Attachment Type')

    appStore.loading = false
  }
  attachmentTypeToDelete.value = null
}
</script>
