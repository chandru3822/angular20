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
              <AlbatrossButton variant="text"
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
              <v-text-field
                label="Group Name"
                tabindex=1
                v-model="newGroup.groupName"
              ></v-text-field>
            </div>
            <AlbatrossButton
              color="primary"
              class="mr-2"
              :disabled="!newGroup.groupName"
              @click="saveFieldGroup()"
              text="SAVE"
            />
            <AlbatrossButton variant="text" color="primary"
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
                      <AlbatrossButton variant="text"
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
                    </template>
                    <template #item.icons="{item, index}">
                      <td :class="{'shaded-row': index % 2 && !isMobile}">
                        <div class="item-icons text-right">
                          <AlbatrossButton
                            v-if="userCanAdd"
                            size="small"
                            variant="text"
                            color="primary"
                            @click="[addField = !addField, selectedIndex = index, expanded = [item], loadFieldsByParent()]"
                            :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                          />
                          <AlbatrossButton
                            size="small"
                            variant="text"
                            color="primary"
                            @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                            :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                          />
                          <AlbatrossButton size="small"
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
                      <AlbatrossButton
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
                        <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
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

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {
  handleHidingGlobalLoader,
  getRequest,
  getSnackbar,
  postRequest,
  putRequest,
  getRequestWithParams
} from "@/helpers/helpers";
import constants from "@/helpers/constants";
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
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
      const {data} = await getRequest(`/attachmentType/${attachmentTypeId.value}/${objectType.value}`)
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
  const fetchAvailableCustomFields = async () => {
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
    let item = cfGroupToDelete.value ? cfGroupToDelete.value : customFieldToDelete.value ? customFieldToDelete.value : null
    let customFieldGroupId = cfGroupToDelete.value ? cfGroupToDelete.value.id : null
    let customFieldGroupAssignmentId = customFieldToDelete.value ? customFieldToDelete.value.id : null
    store.commit(AppMutations.SET_LOADING, true)
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
      expanded.value = []
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
      let url = `/customField/getByParentType/${companyObjectTypeId.value}`
      if(props.objectTypeValue === 'event') {
        url = `/customField/getByEvent/${props.primaryKey}`
      }
      const {data, status} = await getRequest(url)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const assignAncillaryCustomField = async  (item) => {
    store.commit(AppMutations.SET_LOADING, true)
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
      snackbar('SUCCESS', 'Field Added to Group')
      handleHidingGlobalLoader(vueInstance, status)
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
