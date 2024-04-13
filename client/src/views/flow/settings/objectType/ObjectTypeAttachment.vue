<template>
    <v-container class="pt-0" v-if="!attachmentLoading">
      <v-row>
        <v-col cols="12" class="pt-0 px-0">
          <v-toolbar flat>
            <v-toolbar-title class="title-large">{{ selectedAttachment.attachmentType }}</v-toolbar-title>
          </v-toolbar>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="pt-0 px-0">
          <v-toolbar flat class="cfg-header-bar">
            <v-toolbar-title class="title-large text-wrap">Ancillary Custom Field Groups</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <a-btn variant="text"
                               color="primary"
                               v-if="!createNew && userCanAdd"
                               @click="createNew = !createNew"
                               prepend-icon="add"
                               :text="!isMobile ? 'Create Group' : ''"
              />
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
              text="SAVE"
            />
            <a-btn variant="text" color="primary"
              @click="[newGroup = {}, createNew = false]"
              text="CANCEL"
            />
          </v-card>
          <v-row>
            <v-col cols="12">
              <v-data-table
                  id="attachment-cfg-table"
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
                class="elevation-1 attachment-cfg-table square-card striped"
                :class="{'table-striped': isMobile}"
              >
                <template #no-data>
                  No custom field groups assigned
                </template>

                <template #no-results>
                  No custom field groups assigned
                </template>

                    <template #item.draggable="{ item, index }">
                      <td class="draggable-handle-col" :class="{'shaded-row': index % 2 && !isMobile}">
                      <a-btn variant="text"
                                       icon size="small"
                                       color="primary" class="handle"
                                       v-if="userCanEdit"
                                       prepend-icon="drag_handle"
                      />
                      </td>
                    </template>
                    <template #item.groupName="{ item, index }" class="text-left" :class="{'mb-4': vuetify.breakpoint.xsOnly && item.edit}">
                      <td :class="{'shaded-row': index % 2 && !isMobile}">
                      <div v-if="userCanEdit" :class="{'shaded-row': index % 2}">
                        <a-text-field
                                      v-if="item.edit"
                                      v-model="item.groupName">
                          <template v-slot:append-outer>
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
                    </template>
                    <template #item.icons="{item, index}">
                      <td :class="{'shaded-row': index % 2 && !isMobile}">
                        <div class="item-icons text-right">
                          <a-btn
                            v-if="userCanAdd"
                            size="small"
                            variant="text"
                            color="primary"
                            @click="[addField = !addField, selectedIndex = index, expanded = [item], loadFieldsByParent()]"
                            :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                          />
                          <a-btn
                            size="small"
                            variant="text"
                            color="primary"
                            @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                            :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                          />
                          <a-btn size="small"
                                           color="primary"
                                           variant="text"
                                           @click="cfGroupToDelete = item"
                                           prepend-icon="delete"
                          />
                        </div>
                      </td>
                    </template>

                <template #expanded-item="{ headers, item, index }">
                  <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2,'mobile-tr': vuetify.breakpoint.xsOnly}">
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
                        text="CANCEL"
                      />
                    </v-col>
                    <v-col cols="12" class="px-3 justify"
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
                              <div v-if="null != cf.defaultFieldId">
                                {{ cf.objectType }}: {{ cf.fieldName }}
                              </div>
                              <div v-else>
                                {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                              </div>
                            </v-list-item-content>
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
      <ConfirmationDialog :open-dialog="!!cfGroupToDelete" @confirm="deleteWithChecks" @close-dialog="cfGroupToDelete = null">
        <span class="error--text">WARNING:</span>
        By deleting a Custom Field Group you will lose all data associated with native fields in the group.<br/>
        Are you sure you want to delete this Custom Field Group: <strong>{{groupToDeleteName}}</strong>?<br/>
      </ConfirmationDialog>
      <ConfirmationDialog :open-dialog="!!customFieldToDelete" @confirm="[deleteWithChecks(), addField=false, newField={}]" @close-dialog="customFieldToDelete=null">
        <span class="error--text">WARNING:</span>
        By deleting a field you will lose all data associated with the field. If you meant to
        "move" the field to another group please cancel and move the field. <br/>
        Are you sure you want to delete <strong>{{ fieldToDeleteName }}</strong> from <strong>{{fieldToDeleteGroupName }}</strong>?
      </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import draggable from 'vuedraggable'
import {
  handleHidingGlobalLoader,
  getRequest,
  defineSortableTable,
  postRequest,
  putRequest,
  getRequestWithParams
} from "@/helpers/helpers";
import orderBy from 'lodash.orderby'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import { useUserStore } from '@/stores/UserStore.js'

import {ref, onMounted, getCurrentInstance, computed, defineProps, onUpdated} from "vue";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
 const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const props = defineProps({
  objectTypeValue: String,
  showReadOnly: Boolean,
  primaryKey: Number //used for getting attachments for events
})

  const addField = ref(false)
  const createNew = ref(false)
  const newField = ref({})
  const ancillaryCustomFields = ref([])
  const selectedAncillaryField = ref({})
  const selectedAttachment = ref({})
  const attachmentLoading = ref(true)
  const selectedIndex = ref(null)
  const companyObjectTypeId = ref(parseInt(route.query.companyObjectTypeId) || parseInt(route.params.id))
  const attachmentTypeId = ref(parseInt(route.params.attachmentTypeId))
  const componentKey = ref(0)
  const newGroup = ref({})
  const expanded = ref([])
  const headers = ref([
    {text: null, value: 'draggable', width: 50, show: true, sortable: false},
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
  const objectType = computed(() => {
    if(null != props.objectTypeValue) {
      return props.objectTypeValue
    } else {
      switch(companyObjectTypeId.value) {
        case 3: return 'user'
        case 2: return 'contact'
        case 5: return 'organization'
      }
    }
  })
  const isMobile = computed(()=> {
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
      const {data} = await getRequest(`/attachmentType/${attachmentTypeId.value}/${objectType.value}`)
      selectedAttachment.value = data
      attachmentLoading.value = false
    } catch (e) {
      attachmentLoading.value = true
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Attachment Type Details')

      companyStatusesLoading.value = false
    }
  }
  const saveFieldGroup = async () => {
    appStore.loading = true
    try {
      switch(objectType.value) {
        case 'project':
          newGroup.value.projectAttachmentTypeId = attachmentTypeId.value
          break
        case 'contact':
          newGroup.value.contactAttachmentTypeId = attachmentTypeId.value
          break
        case 'user':
          newGroup.value.userAttachmentTypeId = attachmentTypeId.value
          break
        case 'organization':
          newGroup.value.orgAttachmentTypeId = attachmentTypeId.value
          break
        case 'event':
          newGroup.value.eventAttachmentTypeId = attachmentTypeId.value
          break
      }

      const {data} = await postRequest(`/customFieldGroup/addAttachmentCustomFieldGroup`, newGroup.value)
      localCustomFieldGroups.value.push(data)
      newGroup.value = {}
      createNew.value = false
      appStore.showSnack('SUCCESS', 'Group Saved')

      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Group')

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
      appStore.showSnack('SUCCESS', 'Fields Updated')

      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Updating Fields')

      appStore.loading = false
    }

  }
  const saveGroupName = async (group) => {
    appStore.loading = true
    try {
      await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
      appStore.showSnack('SUCCESS', 'Group Name Updated')

      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Change')

      appStore.loading = false
    }
  }
  const fetchAvailableCustomFields = async () => {
    appStore.loading = true
    try {
      availableCustomFields.value = []
      const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
      selectedAncillaryField.value = {}
      parentObjects.value = data
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
  const deleteWithChecks = async () => {
    let item = cfGroupToDelete.value ? cfGroupToDelete.value : customFieldToDelete.value ? customFieldToDelete.value : null
    let customFieldGroupId = cfGroupToDelete.value ? cfGroupToDelete.value.id : null
    let customFieldGroupAssignmentId = customFieldToDelete.value ? customFieldToDelete.value.id : null
    appStore.loading = true
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
        appStore.showSnack('ERROR', errorMsg)

      } else {
        fieldsInUse.value = []
        item.archived = true
        appStore.showSnack('SUCCESS', 'Item Deleted')

        appStore.loading = false
      }
      expanded.value = []
      appStore.loading = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Deleting')

      appStore.loading = false
    }
  }
  const loadFieldsByParent = async () => {
    appStore.loading = true
    try {
      let url = `/customField/getByParentType/${companyObjectTypeId.value}`
      if(props.objectTypeValue === 'event') {
        url = `/customField/getByEvent/${props.primaryKey}`
      }
      const {data, status} = await getRequest(url)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Data')

      appStore.loading = false
    }
  }
  const assignAncillaryCustomField = async  (item) => {
    appStore.loading = true
    try {
      const params = {
        customFieldGroupId: item.id,
        id: null,
        defaultFieldId: selectedAncillaryField.value.defaultFieldId,
        ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId
      }
      const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
      item.customFields.push(data)
      newField.value = {}
      selectedAncillaryField.value = {}
      parent = {}
      addField.value = false
      appStore.showSnack('SUCCESS', 'Field Added to Group')
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Adding Field to Group')

      appStore.loading = false
    }
  }
  const saveRowChanges = async (rows) => {
    if (rows?.length > 0) {
      appStore.loading = true
      try {
        await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
        localCustomFieldGroups.value = orderBy(localCustomFieldGroups.value, 'groupOrder')
        appStore.showSnack('SUCCESS', 'Group Order Saved')
        // this componentKey forces the data-table component to re-render
        componentKey.value += 1
        appStore.loading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        appStore.showSnack('ERROR', 'Error Saving Group Order')
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

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">


</style>
<style lang="scss">
#attachment-cfg-table > div > table > tbody > tr.v-data-table__expanded.v-data-table__expanded__content {
  box-shadow: none;
}
td.draggable-handle-col {
  width: 50px !important;
}
@media (max-width: 960px) {
  #attachment-cfg-table > div > table > tbody > tr > td {
    justify-content: center !important;
  }
}

</style>
