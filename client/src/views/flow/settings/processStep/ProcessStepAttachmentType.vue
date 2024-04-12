<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="title-large">{{ selectedAttachment.attachmentType }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Ancillary Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                color="primary"
                v-if="!createNew && userCanAdd"
                @click="createNew = !createNew"
                prepend-icon="add"
                :text="!constants.IS_MOBILE ? 'Create Group' : ''"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="rowShadeCustom">
          <div>
            <a-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
            ></a-text-field>
          </div>
          <a-btn
              color="primary"
              class="mr-2"
              :disabled="!newGroup.groupName"
              @click="saveFieldGroup()"
              text="Save"
          ></a-btn>
          <a-btn
              color="primary"
              variant="text"
              @click="[newGroup = {}, createNew = false]"
              text="Cancel"
          ></a-btn>
        </v-card>
        <v-row>
          <v-col cols="12">
            <v-data-table
                id="psAttachmentTypeCFGTable"
              :key="componentKey"
              :headers="headers"
              :items="filterCustomFieldGroups"
              :items-per-page="-1"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              hide-default-header
              :sort-desc="[false]"
              :sort-by="['groupOrder']"
              class="elevation-1 attachment-cfg-table square-card"
                :class="{'clear-display': isMobile}"
            >
              <template #no-data>
                No custom field groups for this process step attachment type
              </template>

              <template #no-results>
                No custom field groups for this process step attachment type
              </template>

              <template #item="{ item, index }">
                <tr  :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <a-btn
                        variant="text"
                        icon
                        size="small"
                        class="handle"
                        v-if="userCanEdit"
                        color="unset"
                        prepend-icon="drag_handle"
                    ></a-btn>
                  </td>
                  <td class="text-left">
                    <div v-if="userCanEdit">
                      <a-text-field
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon @click="item.edit = false">clear</v-icon>
                        </template>
                      </a-text-field>
                      <a style="text-decoration: underline;" v-else @click="item.edit = true">
                        {{ item.groupName }}
                      </a>
                    </div>
                    <span v-else>{{ item.groupName }}</span>
                  </td>
                  <td class="text-right">
                    <div class="item-icons d-flex justify-end">
                      <a-btn
                          v-if="userCanAdd"
                          size="small"
                          variant="text"
                          @click="[addField = !addField, selectedIndex = index, expanded = [item], loadFieldsByParent()]"
                          color="unset"
                          :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                      ></a-btn>
                      <a-btn
                          size="small"
                          variant="text"
                          @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                          color="unset"
                          :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                      ></a-btn>
                      <a-btn
                          size="small"
                          color="primary"
                          variant="text"
                          @click="cfGroupToDelete = item"
                          prepend-icon="delete"
                      ></a-btn>
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add Ancillary Field</h3>
                    <a-autocomplete v-model="selectedAncillaryField"
                                    :items="ancillaryCustomFields"
                                    label="Ancillary Custom Field"
                                    item-title="fieldName"
                                    return-object
                                    autocomplete="off"
                                    @input="assignAncillaryCustomField(item)">
                    </a-autocomplete>
                    <a-btn
                        variant="text"
                        color="primary"
                        @click="addField = false"
                        text="Cancel"
                    ></a-btn>
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 pt-2 justify"
                         v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 justify"
                         v-if="item.customFields && item.customFields.length > 0">
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               :disabled="!userCanEdit"
                               group="customFields" @start="drag=true" @end="drag=false"
                               @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in item.customFields.filter(a => !a.archived)"
                              :key="index" class="pa-0" color="transparent">
                        <v-list-item :class="{grab: !item.attachmentTypeId}">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{ cf.fieldName }}
                            (Ancillary)
                          </v-list-item-content>
                          <v-menu offset-y
                                  v-if="localCustomFieldGroups.length > 1 && userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in localCustomFieldGroups.filter((g) => { return g.id !== cf.customFieldGroupId && !g.attachmentTypeId })"
                                :key="index">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <v-list-item-action v-if="userCanEdit" class="clickable" @click="customFieldToDelete = cf">
                            <v-icon color="primary">delete</v-icon>
                          </v-list-item-action>
                        </v-list-item>
                        <v-divider v-if="cf.edit"></v-divider>
                      </v-list>
                    </draggable>
                  </v-col>
                </td>
              </template>
            </v-data-table>
          </v-col>
        </v-row>

      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!cfGroupToDelete" @confirm="deleteWithChecks"
                        @close-dialog="cfGroupToDelete = null">
      <span class="error--text">WARNING:</span>
      By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/>
      Are you sure you want to delete this Custom Field Group: <strong>{{ groupToDeleteName }}</strong>?<br/>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!customFieldToDelete"
                        @confirm="[deleteWithChecks(), addField=false]"
                        @close-dialog="customFieldToDelete=null">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to
      "move" the field to another group please cancel and move the field. <br/>
      Are you sure you want to delete <strong>{{ fieldToDeleteName }}</strong> from <strong>{{
        fieldToDeleteGroupName
      }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>

import {
  getRequest,
  getRequestWithParams,
  defineSortableTable,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import orderBy from 'lodash.orderby'
import draggable from 'vuedraggable'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { useUserStore } from '@/stores/UserStore.js'
import { useAppStore } from '@/stores/AppStore.js'

import {ref, onMounted, getCurrentInstance, computed, defineProps, onUpdated} from "vue";
import {useRouter, useRoute} from "vue-router/composables"

const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const addField = ref(false)
const createNew = ref(false)
const selectedAttachment = ref({})
const attachmentLoading = ref(true)
// selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet.
const selectedIndex = ref(null)
const componentKey = ref(0)
const newGroup = ref({})
const expanded = ref([])
const selectedAncillaryField = ref({})
const ancillaryCustomFields = ref([])
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Name', value: 'groupName', show: true},
  {text: null, value: 'icons', show: true}
])
const cfGroupToDelete = ref(null)
const customFieldToDelete = ref(null)

const attachmentTypeId = computed(() => {
  return parseInt(route.params.attachmentTypeId)
})
const processStepId = computed(() => {
  return route.params.id
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const localCustomFieldGroups = computed({
  get() {
    return selectedAttachment.value?.customFieldGroups
  },
  set(val) {
    val.forEach(v => {
      v.groupOrder = v.newGroupOrder ?? v.groupOrder
    })
    return orderBy(val, v => v.groupOrder)
  }
})
const groupToDeleteName = computed(() => {
  return cfGroupToDelete.value ? cfGroupToDelete.value.groupName : ''
})
const fieldToDeleteName = computed(() => {
  return customFieldToDelete.value ? customFieldToDelete.value.fieldName : ''
})
const fieldToDeleteGroupName = computed(() => {
  return customFieldToDelete.value ? customFieldToDelete.value.groupName : ''
})
const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
onMounted(async () => {
  await getTypeDetails()
})
onUpdated(() => {
  defineSortableTable('.attachment-cfg-table tbody', localCustomFieldGroups, 'groupOrder', saveRowChanges)
})

const getTypeDetails = async () => {
  try {
    attachmentLoading.value = true
    const {data} = await getRequest(`/processStep/${processStepId.value}/attachmentType/${attachmentTypeId.value}`)
    selectedAttachment.value = data
    attachmentLoading.value = false
  } catch (e) {
    attachmentLoading.value = true
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Attachment Type Details')
    companyStatusesLoading.value = false
  }
}
const saveFieldGroup = async () => {
  appStore.loading = true
  try {
    newGroup.value.processStepAttachmentTypeId = route.params.attachmentTypeId
    const {data} = await postRequest(`/customFieldGroup/addAttachmentCustomFieldGroup`, newGroup.value)
    localCustomFieldGroups.value.push(data)
    newGroup.value = {}
    createNew.value = false
    snackbar('SUCCESS', 'Group Saved')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group')
    appStore.loading = false
  }
}
const saveFieldChanges = async (fields) => {
  appStore.loading = true
  try {
    // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
    // pull those needing to be saved out of list
    let fieldsToSave = []
    fields.forEach((f, idx) => {
      let order = idx + 1
      if (f.fieldOrder !== order) {
        f.fieldOrder = order
        fieldsToSave.push(f)
      }
    })
    // save them here
    if (fieldsToSave.length > 0) {
      await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
    }
    snackbar('SUCCESS', 'Fields Updated')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Fields')

    appStore.loading = false
  }

}
const saveGroupName = async (group) => {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
    snackbar('SUCCESS', 'Group Name Updated')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Change')

    appStore.loading = false
  }
}
const fetchAvailableCustomFields = async (objectTypeId, groupId) => {
  appStore.loading = true
  try {
    availableCustomFields.value = []
    const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
    selectedAncillaryField.value = {}
    parentObjects.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const deleteWithChecks = async () => {
  appStore.loading = true
  let item = cfGroupToDelete.value ? cfGroupToDelete.value : customFieldToDelete.value ? customFieldToDelete.value : null
  let customFieldGroupId = cfGroupToDelete.value ? cfGroupToDelete.value.id : null
  let customFieldGroupAssignmentId = customFieldToDelete.value ? customFieldToDelete.value.id : null
  try {
    let params = {
      customFieldGroupId, customFieldGroupAssignmentId
    }
    const {data} = await putRequest(`/customFieldGroup/deleteWithRequirementChecks`, params)
    if (data?.length > 0) {
      deleteError.value = true
      item.deleteConfirm = false
      let errorMsg = 'Group Cannot Be Deleted'
      deleteHeader.value = 'Error Deleting Custom Field Group'
      deleteText.value = 'You cannot delete a group that has a field in use by other groups or requirements.'
      if (null !== customFieldGroupAssignmentId) {
        errorMsg = 'Field Cannot Be Deleted'
        deleteHeader.value = 'Error Deleting Custom Field from Group'
        deleteText.value = 'You cannot delete a field from a group that is in use by other groups or requirements.'
      }
      snackbar('ERROR', errorMsg)

    } else {
      item.archived = true
      snackbar('SUCCESS', 'Item Deleted')

      appStore.loading = false
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

    appStore.loading = false
  }
}
const loadFieldsByParent = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/customField/getByParentProcessStep/${processStepId.value}`)
    ancillaryCustomFields.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const assignAncillaryCustomField = async (item) => {
  appStore.loading = true
  try {
    const params = {
      customFieldGroupId: item.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId
    }
    const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
    item.customFields.push(data)
    selectedAncillaryField.value = {}
    parent.value = {}
    addField.value = false
    snackbar('SUCCESS', 'Field Added to Group')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Field to Group')

    appStore.loading = false
  }
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    appStore.loading = true
    try {
      await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
      localCustomFieldGroups.value = orderBy(localCustomFieldGroups.value, 'groupOrder')
      snackbar('SUCCESS', 'Group Order Saved')

      // this componentKey forces the data-table component to re-render
      componentKey.value += 1
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Group Order')

      appStore.loading = false
    }
  }
}
const filterCustomFieldGroups = computed(() => {
  return localCustomFieldGroups.value?.filter(cfg => {
    return !cfg.archived
  })
})
</script>

<style lang="scss">
#psAttachmentTypeCFGTable.clear-display > div > table > tbody{
  display:inline-table !important;
  width:100%;
}

</style>

<style scoped lang="scss">

</style>
