<template>
  <v-container class="pt-0 px-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton variant="text"
                             color="primary"
                             v-if="!createNew && userCanAdd"
                             @click="createNew = !createNew"
                             prepend-icon="add"
                             :text="vuetify.breakpoint.mdAndUp ? 'Create Group' : ''"
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
              :key="componentKey"
              :headers="headers"
              :items="filterCustomFieldGroups()"
              :items-per-page="-1"
              single-expand
              :expanded.sync="expanded"
              hide-default-footer
              hide-default-header
              :sort-desc="[false]"
              :sort-by="['groupOrder']"
              class="elevation-1 attachment-cfg-table square-card"
            >
              <template #no-data>
                No custom field groups for this attachment type
              </template>

              <template #no-results>
                No custom field groups for this attachment type
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <AlbatrossButton variant="text"
                                     icon
                                     size="small"
                                     class="handle"
                                     v-if="userCanEdit"
                                     prepend-icon="drag_handle"
                    />
                  </td>
                  <td class="text-left" :class="{'one-hunned':vuetify.breakpoint.mdAndDown}">
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
                  <td>
                    <div class="item-icons" :class="{'d-flex flex-column align-end': vuetify.breakpoint.xsOnly}">
                      <AlbatrossButton v-if="userCanAdd"
                                       size="small"
                                       variant="text"
                                       color="primary"
                                       @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]"
                                       :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                      />
                      <AlbatrossButton
                        size="small"
                        variant="text"
                        color="primary"
                        @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                        :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                      />
                      <AlbatrossButton
                        size="small"
                        color="primary"
                        variant="text"
                        @click="cfGroupToDelete = item"
                        prepend-icon="delete"
                      />
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <!--                    <v-radio-group v-model="newFieldType"-->
                    <!--                                   @change="fetchAvailableCustomFields(item.companyObjectTypeId, item.id)">-->
                    <!--                      <v-radio label="Native Field"-->
                    <!--                               value="native"></v-radio>-->
                    <!--                      <v-radio label="Reference Field: viewed only from process steps or other object types"-->
                    <!--                               value="ancillary"></v-radio>-->
                    <!--                    </v-radio-group>-->

                    <v-autocomplete v-model="newField"
                                    :items="availableCustomFields"
                                    label="New Custom Field"
                                    item-text="fieldName"
                                    return-object
                                    autocomplete="off"
                                    @input="assignCustomField(item)"
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
                      <v-list v-for="(cf, index) in filterCustomFields(item.customFields)"
                              :key="index" class="pa-0" color="transparent">
                        <v-list-item :class="{grab: !item.attachmentTypeId}">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <div>
                              {{ cf.fieldName }}
                            </div>
                            <div class="text-left">
                              <div>
                                <input type="checkbox" v-model="cf.required" :readonly="!userCanEdit"
                                       :disabled="!userCanEdit" @change="updateRequired(cf)">
                                Required
                              </div>
                            </div>
                          </v-list-item-content>
                          <v-menu offset-y
                                  v-if="localCustomFieldGroups.length > 1 && userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <AlbatrossButton
                                    variant="text"
                                    size="small"
                                    color="primary"
                                    v-on="{...tooltip, ...menu}"
                                    v-if="!cf.ancillaryCustomFieldGroupAssignmentId"
                                    prepend-icon="mdi-cursor-move"
                                  />
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in localCustomFieldGroups.filter((g) => { return g.id !== cf.customFieldGroupId && !g.attachmentTypeId })"
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
    <ConfirmationDialog :open-dialog="!!cfGroupToDelete" @confirm="deleteWithChecks" @close-dialog="cfGroupToDelete = null">
      <span class="error--text">WARNING:</span>
      By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/>
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
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams, handleHidingGlobalLoader, defineSortableTable
} from '@/helpers/helpers'
import cloneDeep from 'lodash.clonedeep'
import orderBy from "lodash.orderby"
import ConfirmationDialog from "@/components/ConfirmationDialog";

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {getCurrentInstance, onMounted, ref, computed} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
const route = useRoute()
const vuetify = vueInstance.$vuetify

const componentKey = ref(0)
const deleteError = ref(false)
const deleteHeader = ref(null)
const deleteText = ref(null)
const fieldsInUse = ref([])
const positions = ref([])
const positionsLoading = ref(false)
const resourceFieldChanged = ref(false)
const newGroup = ref({})
const attachmentType = ref({})
const newField = ref({})
// selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet
const selectedIndex = ref(null)
const createNew = ref(false)
const newFieldType = ref('native')
const addField = ref(false)
const selectedGroupId = ref(null)
const availableCustomFields = ref([])
const parent = ref({})
const parentObjects = ref([])
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Name', value: 'groupName', show: true},
  {text: null, value: 'icons', show: true}
])
const expanded = ref([])
const cfGroupToDelete = ref(null)
const customFieldToDelete = ref(null)
const ancillaryCustomFields = ref([])

const attachmentTypeId = computed(() => {
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
const localCustomFieldGroups = computed({
  get() {
    return attachmentType.value?.customFieldGroups
  },
  set(val) {
    val.forEach(v => {
      v.groupOrder = v.newGroupOrder ?? v.groupOrder
    })
    return orderBy(val, v => v.groupOrder)
  },
})

onMounted(async () => {
  defineSortableTable('.attachment-cfg-table tbody', localCustomFieldGroups, 'groupOrder', saveRowChanges)

  await getAttachment()
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
const getAttachment = async () => {
  appStore.loading = true
  try {
    const {data} = await getRequest(`/attachmentType/type/${attachmentTypeId.value}`)
    attachmentType.value = data
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const saveFieldGroup = async () => {
  appStore.loading = true
  try {
    newGroup.value.attachmentTypeId = route.params.id

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

      appStore.loading = false
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

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
const moveFieldToOtherGroup = async (field, newGroup) => {
  appStore.loading = true
  try {
    await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
    snackbar('SUCCESS', 'Field Moved')

    //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
    window.location.reload()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Moving Field')

    appStore.loading = false
  }
}

const filterCustomFields = (customFields) => {
  return customFields.filter((cf) => cf.archived === false)
}
const fetchAvailableCustomFields = async (objectTypeId, groupId) => {
  appStore.loading = true
  try {
    if (addField.value && newFieldType.value === 'native') {
      const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
        params: {
          companyObjectTypeId: objectTypeId,
          groupId,
          attachmentTypeId: attachmentTypeId.value
        }
      })
      availableCustomFields.value = data
      parentObjects.value = []
      ancillaryCustomFields.value = []
    } else if (addField.value && newFieldType.value === 'ancillary') {
      availableCustomFields.value = []
      const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
      selectedAncillaryField.value = {}
      parentObjects.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const loadFieldsByParent = async () => {
  appStore.loading = true
  try {
    if (parent.value.isProcessStep) {
      const {data} = await getRequest(`/customField/getByParentProcessStep/${parent.value.id}`)
      ancillaryCustomFields.value = data
    } else {
      const {data} = await getRequest(`/customField/getByParentType/${parent.value.id}`)
      ancillaryCustomFields.value = data
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    appStore.loading = false
  }
}
const saveUseParentData = async (field) => {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveUseParentData`, field)
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const saveReadOnlyAndWhiteList = async (field) => {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
    field.positionsChanged = false
    if (!field.customFieldGroupAssignmentReadOnly) {
      vueInstance.$set(field, 'whiteListedPositions', [])
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const saveHiddenAndWhiteList = async (field) => {
  appStore.loading = true
  try {
    await putRequest(`/customFieldGroup/saveHiddenAndWhiteList?savePositions=${field.hiddenPositionsChanged ?? false}`, field)
    field.hiddenPositionsChanged = false
    if (!field.customFieldGroupAssignmentHidden) {
      vueInstance.$set(field, 'hiddenWhiteListedPositions', [])
    }
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    appStore.loading = false
  }
}
const updateRequired = async (cf) => {
  try {
    const objectType = {
      customFieldGroupAssignmentId: cf.customFieldGroupAssignmentId,
      required: cf.required || false
    }
    const {status} = await putRequest(`/customFieldGroup/updateFieldShowOrRequire`, objectType)
    snackbar('SUCCESS', 'Updated Field')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Data')

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
const assignCustomField = async (cfg) => {
  appStore.loading = true
  try {
    addField.value = false
    newField.value.customFieldGroupId = cfg.id
    //this line makes pushing it to the list work
    newField.value.archived = false

    const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, newField.value)
    cfg.customFields.push(data)
    newField.value = {}
    snackbar('SUCCESS', 'Custom Field Assigned')

    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Custom Field')

    appStore.loading = false
  }
}
const assignAncillaryCustomField = async (cfg) => {
  appStore.loading = true
  try {
    const params = {
      customFieldGroupId: cfg.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId,
      fieldOrder: 0
    }
    const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
    cfg.customFields.push(data)
    selectedAncillaryField.value = {}
    addField.value = false
    parent.value = {}
    snackbar('SUCCESS', 'Reference Field Assigned')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Reference Field')

    appStore.loading = false
  }
}
const filterCustomFieldGroups = () => {
  //i tried making this a computed property and stuff broke. so test if changing again
  return localCustomFieldGroups.value?.filter(cfg => {
    return !cfg.archived
  })
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
const getPositions = async () => {
  if (positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
      appStore.loading = false
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')

      appStore.loading = false
    }
  }
}
const toggleHiddenSelectAllPositions = (field) => {
  vueInstance.$nextTick(() => {
    if (selectAll.value(field)) {
      field.hiddenWhiteListedPositions = []
      field.hiddenPositionsChanged = true
    } else {
      field.hiddenWhiteListedPositions = cloneDeep(positions.value)
      field.hiddenPositionsChanged = true
    }
  })
}
const toggleSelectAllPositions = (item, wlpField) => {
  vueInstance.$nextTick(() => {
    if (selectAll(item, wlpField)) {
      item[wlpField] = []
      item.positionsChanged = true
    } else {
      item[wlpField] = cloneDeep(positions)
      item.positionsChanged = true
    }
  })
}
</script>

<style scoped lang="scss">
.custom-field-group {
  border: solid 1px var(--v-rowShadeCustom-base) !important;
}

.custom-field-group-border {
  border-bottom: solid 1px var(--v-rowShadeCustom-base) !important;
}

.item-icons {
  display: flex;
  float: right;
}

.color-swatch {
  height: 30px;
  width: 30px;
  border-radius: 5px;
}

.cfg-header-bar {
  border-bottom: 1px solid #E6E6E6;
}

.add-new {
  border-bottom: 1px solid #E6E6E6;
}
</style>
