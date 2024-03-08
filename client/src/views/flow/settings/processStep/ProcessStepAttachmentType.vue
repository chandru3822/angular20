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
            <v-btn text color="primary" v-if="!createNew && userCanAdd" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Create Group</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="rowShadeCustom">
          <div>
            <v-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
            ></v-text-field>
          </div>
          <v-btn
            color="primary"
            class="mr-2"
            :disabled="!newGroup.groupName"
            @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
              color="primary" text
            @click="[newGroup = {}, createNew = false]">
            Cancel
          </v-btn>
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
                    <v-btn text icon small class="handle" v-if="userCanEdit">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">
                    <div v-if="userCanEdit">
                      <v-text-field text
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon @click="item.edit = false">clear</v-icon>
                        </template>
                      </v-text-field>
                      <a style="text-decoration: underline;" v-else @click="item.edit = true">
                        {{ item.groupName }}
                      </a>
                    </div>
                    <span v-else>{{ item.groupName }}</span>
                  </td>
                  <td class="text-right">
                    <div class="item-icons d-flex justify-end">
                      <v-btn v-if="userCanAdd" small text
                             @click="[addField = !addField, selectedIndex = index, expanded = [item], loadFieldsByParent()]">
                        <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                        <v-icon v-else>add</v-icon>
                      </v-btn>
                      <v-btn small text
                             @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                        <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                        <v-icon v-else>expand_more</v-icon>
                      </v-btn>
                      <v-btn small color="primary" text @click="cfGroupToDelete = item">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add Ancillary Field</h3>
                    <v-autocomplete v-model="selectedAncillaryField"
                                    :items="ancillaryCustomFields"
                                    label="Ancillary Custom Field"
                                    item-text="fieldName"
                                    return-object
                                    autocomplete="off"
                                    @input="assignAncillaryCustomField(item)"
                    >
                      <template slot='item' slot-scope='{ item }'>
                        {{ item.fieldName }}
                      </template>
                    </v-autocomplete>
                    <v-btn text color="primary" @click="addField = false">Cancel</v-btn>
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
                      <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
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
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <v-btn text small v-on="{...tooltip, ...menu}"
                                         v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                                    <v-icon>mdi-cursor-move</v-icon>
                                  </v-btn>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in filterBy(localCustomFieldGroups, (g) => { return g.id !== cf.customFieldGroupId && !g.attachmentTypeId })"
                                :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
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
                        @confirm="[deleteWithChecks(), addField=false, newField={}]"
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
import {AppMutations} from '@/stores/AppStore'
import {
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import draggable from 'vuedraggable'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import { useUserStore } from '@/stores/UserStorePinia.js'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {ref, onMounted, getCurrentInstance, computed, defineProps, onUpdated} from "vue";

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const route = vueInstance.$route
const router = vueInstance.$router
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const addField = ref(false)
const createNew = ref(false)
const selectedAttachment = ref({})
const attachmentLoading = ref(true)
// selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet.
const selectedIndex = ref(null)
const processStepId = ref(route.params.id)
const attachmentTypeId = ref(parseInt(route.params.attachmentTypeId))
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
  // this had to be in updated vs mounted so that after the re-render the dragging still works
  let table = document.querySelector('.attachment-cfg-table tbody')
  Sortable.create(table, {
    handle: '.handle',
    onEnd({newIndex, oldIndex}) {
      if (vueInstance.localCustomFieldGroups?.length > 0) {
        const rowSelected = vueInstance.localCustomFieldGroups.splice(oldIndex, 1)[0]
        vueInstance.localCustomFieldGroups.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(vueInstance.localCustomFieldGroups)

        let rowsToSave = []
        rowsClone.forEach((r, idx) => {
          //check if the row needs to be saved before updating display order
          //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
          let save = r.newGroupOrder === undefined ? r.groupOrder !== idx : r.newGroupOrder !== idx
          //update display order
          r.groupOrder = idx
          //save only rows that changed
          if (save) {
            vueInstance.localCustomFieldGroups[idx].newGroupOrder = idx
            rowsToSave.push(r)
          }
        })
        vueInstance.saveRowChanges(rowsToSave)
      }
    }
  })
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
  store.commit(AppMutations.SET_LOADING, true)
  try {
    newGroup.value.processStepAttachmentTypeId = route.params.attachmentTypeId
    const {data} = await postRequest(`/customFieldGroup/addAttachmentCustomFieldGroup`, newGroup.value)
    localCustomFieldGroups.value.push(data)
    newGroup.value = {}
    createNew.value = false
    snackbar('SUCCESS', 'Group Saved')
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveFieldChanges = async (fields) => {
  store.commit(AppMutations.SET_LOADING, true)
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

    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Fields')

    store.commit(AppMutations.SET_LOADING, false)
  }

}
const saveGroupName = async (group) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
    snackbar('SUCCESS', 'Group Name Updated')

    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Change')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const fetchAvailableCustomFields = async (objectTypeId, groupId) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    availableCustomFields.value = []
    const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
    selectedAncillaryField.value = {}
    parentObjects.value = data
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteWithChecks = async () => {
  store.commit(AppMutations.SET_LOADING, true)
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
      fieldsInUse.value = data
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
      fieldsInUse.value = []
      item.archived = true
      snackbar('SUCCESS', 'Item Deleted')

      store.commit(AppMutations.SET_LOADING, false)
    }
    store.commit(AppMutations.SET_LOADING, false)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const loadFieldsByParent = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/customField/getByParentProcessStep/${processStepId.value}`)
    ancillaryCustomFields.value = data
    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const assignAncillaryCustomField = async (item) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const params = {
      customFieldGroupId: item.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId
    }
    const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
    item.customFields.push(data)
    newField.value = {}
    selectedAncillaryField.value = {}
    parent.value = {}
    addField.value = false
    snackbar('SUCCESS', 'Field Added to Group')

    handleHidingGlobalLoader(this, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Field to Group')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
      localCustomFieldGroups.value = orderBy(localCustomFieldGroups.value, 'groupOrder')
      snackbar('SUCCESS', 'Group Order Saved')

      // this componentKey forces the data-table component to re-render
      componentKey.value += 1
      store.commit(AppMutations.SET_LOADING, false)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Group Order')

      store.commit(AppMutations.SET_LOADING, false)
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
