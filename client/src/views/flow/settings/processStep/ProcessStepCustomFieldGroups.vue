<template>
  <v-container class="pt-0 px-0">
    <v-dialog
        v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          {{ deleteHeader }}
        </v-card-title>

        <v-card-text>
          {{ deleteText }}
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              <div v-if="item.objectType">{{ item.objectType }}</div>
              <div v-if="item.processStepName">{{ item.processStepName }}</div>
              <div v-if="item.groupName">{{ item.groupName }}<span v-if="item.fieldName"> - {{ item.fieldName }}</span>
              </div>
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>
          <AlbatrossButton
              color="primary"
              variant="text"
              class=""
              @click="deleteError = false"
              text="OK"
          ></AlbatrossButton>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="title-large">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
                variant="text"
                color="primary"
                v-if="!createNew && userCanAdd"
                @click="createNew = !createNew"
                prepend-icon="add"
                text="Create Group"
            ></AlbatrossButton>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="primary lighten-9">
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
              text="Save"
          ></AlbatrossButton>
          <AlbatrossButton
              variant="text"
              color="primary"
              @click="[newGroup = {}, createNew = false]"
              text="Cancel"
          ></AlbatrossButton>
        </v-card>
        <v-row>
          <v-col cols="12">
            <v-data-table

                :key="componentKey"
                :headers="headers"
                :items="filteredCustomFieldGroups"
                :items-per-page="-1"
                single-expand
                :expanded.sync="expanded"
                hide-default-footer
                hide-default-header
                :sort-desc="[false]"
                :sort-by="['groupOrder']"
                class="elevation-1 fix-column-width-bug process-step-cfg-table square-card"
            >
              <template #no-data>
                <span class="default-text-color">No field groups for this process step</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No actions for this process step</span>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
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
                    <div v-if="userCanEdit">
                      <v-text-field text
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon color="primary" @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon color="primary" @click="item.edit = false">clear</v-icon>
                        </template>
                      </v-text-field>
                      <a style="text-decoration: underline;" v-else @click="item.edit = true"
                         class="default-text-color">
                        {{ item.groupName }}
                      </a>
                    </div>
                    <span v-else>{{ item.groupName }}</span>
                  </td>
                  <td>
                    <div class="item-icons">
                      <v-tooltip left>
                        <template v-slot:activator="{ on, attrs }">
                          <AlbatrossButton
                              size="small"
                              icon
                              color="primary"
                              @click="copyToClipBoard(item.id)"
                              v-bind="attrs"
                              :activation-handler="on"
                              prepend-icon="mdi-information"
                          ></AlbatrossButton>
                        </template>
                        <span>Custom Field Group Id: {{ item.id }}</span>
                        <div class="text-center">(click to copy)</div>
                      </v-tooltip>
                      <AlbatrossButton
                          v-if="userCanAdd"
                          size="small"
                          variant="text"
                          color="primary"
                          @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]"
                          :prepend-icon="addField && expanded.includes(item) ? 'remove' : 'add'"
                      ></AlbatrossButton>
                      <AlbatrossButton
                          size="small"
                          variant="text"
                          color="primary"
                          @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]"
                          :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                      ></AlbatrossButton>
                      <AlbatrossButton
                          v-if="userCanEdit"
                          size="small"
                          variant="text"
                          color="primary"
                          @click="customFieldGroupToDelete=item"
                          prepend-icon="delete"
                      ></AlbatrossButton>
                      <span v-if="item.showGroupId" class="flex-align-items-center">id: {{ item.id }}</span>
                    </div>
                  </td>
                  <ConfirmationDialog :open-dialog="customFieldGroupToDelete && !assignmentToDelete"
                                      @confirm="deleteWithChecks" @close-dialog="customFieldGroupToDelete=null">
                    <span class="error--text">WARNING:</span>
                    By deleting a Custom Field Group you will lose all data associated with fields in the
                    group.<br/><br/>
                    Are you sure you want to delete this Custom Field Group: <strong>{{
                      itemToDeleteGroupName
                    }}</strong>?
                  </ConfirmationDialog>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <v-radio-group v-model="newFieldType"
                                   @change="fetchAvailableCustomFields(item.companyObjectTypeId, item.id)">
                      <v-radio label="Native Field"
                               value="native"></v-radio>
                      <v-radio label="Reference Field: viewed only from other process steps or objects"
                               value="ancillary"></v-radio>
                    </v-radio-group>

                    <v-autocomplete v-if="newFieldType === 'native'"
                                    v-model="newField"
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
                    <v-autocomplete v-if="newFieldType === 'ancillary'"
                                    v-model="parent"
                                    :items="parentObjects"
                                    label="Parent Object"
                                    item-text="name"
                                    return-object
                                    autocomplete="off"
                                    @input="loadFieldsByParent"
                    >
                      <template slot='item' slot-scope='{ item }'>
                        {{ item.name }}
                      </template>
                    </v-autocomplete>
                    <v-autocomplete v-if="newFieldType === 'ancillary'"
                                    v-model="selectedAncillaryField"
                                    :items="ancillaryCustomFields"
                                    label="Custom Field"
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
                        color="primary"
                        @click="addField = false"
                        text="Cancel"
                    ></AlbatrossButton>
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 pt-2 justify"
                         v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 justify "
                         v-if="item.customFields && item.customFields.length > 0">
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               :disabled="!userCanEdit"
                               group="customFields" @start="drag=true" @end="drag=false"
                               @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in item.customFields?.filter(cf => !cf.archived)"
                              :key="index" class="pa-0" color="transparent"
                              @mouseover.native="hoverIndex = index" @mouseleave.native="hoverIndex = null"
                              :class="{'custom-field-hover': hoverIndex === index && !cf.edit}"
                      >
                        <v-list-item class="grab">
                          <v-list-item-action>
                            <v-icon color="primary" v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <div
                                v-if="cf.ancillaryCustomFieldGroupAssignmentId == null && cf.dataViewFieldConfigId == null && cf.dataViewChildFieldConfigId == null">
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{ cf.fieldName }}</a>
                              <span v-if="cf.customFieldGroupAssignmentReadOnly || cf.systemReadonly">(Read Only)</span>
                              <span v-if="cf.customFieldGroupAssignmentHidden">(Hidden)</span>
                              <span v-if="cf.showId">id: {{ cf.customFieldId }}</span>
                              <div class="text-left mt-3" v-if="cf.edit">
                                <v-row>
                                  <v-col cols="6">
                                    <v-card flat
                                            :color="localCustomFieldGroups.indexOf(item) % 2 ? undefined : 'primary lighten-9'"
                                            class="square-card">
                                      <v-card-text v-if="cf.systemReadonly" class="mt-2">
                                        System Readonly Cannot Change
                                      </v-card-text>
                                      <v-card-text v-else>
                                        <MultiSelectGroup
                                            v-if="!positionsLoading"
                                            :userCanEdit="userCanEdit"
                                            :returnObject="cf"
                                            :content="positions"
                                            :dropdownEnabled="cf.customFieldGroupAssignmentReadOnly"
                                            :selectedContent="cf.whiteListedPositions"
                                            :title="'Read Only'"
                                            :label="'Allowed Positions'"
                                            :alternateLabel="'Denied Positions'"
                                            :allow="cf.customFieldGroupAssignmentReadOnlyAllow"
                                            :contentLoading="positionsLoading"
                                            background-color="transparent"
                                            @selected-changed="cf.whiteListedPositions = $event; cf.positionsChanged = true"
                                            @allow-changed="cf.customFieldGroupAssignmentReadOnlyAllow = ($event === 0); cf.positionsChanged = true"
                                            @checkbox-changed="cf.customFieldGroupAssignmentReadOnly = $event; cf.positionsChanged = true"></MultiSelectGroup>
                                        <br/>
                                        <AlbatrossButton
                                            color="primary"
                                            class="d-inline-block"
                                            @click="saveReadOnlyAndWhiteList(cf)"
                                            prepend-icon="save"
                                            text="Save Read Only"
                                        ></AlbatrossButton>
                                      </v-card-text>
                                    </v-card>
                                  </v-col>
                                  <v-col cols="6">
                                    <v-card flat
                                            :color="localCustomFieldGroups.indexOf(item) % 2 ? 'white' : 'primary lighten-9'"
                                            class="square-card">
                                      <!--                                      <v-card-title style="height: 40px" class="py-0">-->
                                      <!--                                        Hidden-->
                                      <!--                                        <v-checkbox type="checkbox" class="ml-2"-->
                                      <!--                                                    v-model="cf.customFieldGroupAssignmentHidden"></v-checkbox>-->
                                      <!--                                      </v-card-title>-->
                                      <v-card-text>

                                        <MultiSelectGroup
                                            v-if="!positionsLoading"
                                            :userCanEdit="userCanEdit"
                                            :returnObject="cf"
                                            :content="positions"
                                            :dropdownEnabled="cf.customFieldGroupAssignmentHidden"
                                            :selectedContent="cf.hiddenWhiteListedPositions"
                                            :title="'Hidden'"
                                            :label="'Allowed Positions'"
                                            :alternateLabel="'Denied Positions'"
                                            :allow="cf.customFieldGroupAssignmentHiddenAllow"
                                            :contentLoading="positionsLoading"
                                            background-color="transparent"
                                            @selected-changed="cf.hiddenWhiteListedPositions = $event; cf.hiddenPositionsChanged = true"
                                            @allow-changed="cf.customFieldGroupAssignmentHiddenAllow = ($event === 0); cf.hiddenPositionsChanged = true"
                                            @checkbox-changed="cf.customFieldGroupAssignmentHidden = $event; cf.hiddenPositionsChanged = true"></MultiSelectGroup>
                                        <br/>
                                        <AlbatrossButton
                                            color="primary"
                                            class="d-inline-block"
                                            @click="saveHiddenAndWhiteList(cf)"
                                            prepend-icon="save"
                                            text="Save Hidden"
                                        ></AlbatrossButton>
                                      </v-card-text>
                                    </v-card>
                                  </v-col>
                                </v-row>
                              </div>
                            </div>
                            <div v-else>
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{
                                  cf.processStepName || cf.objectType
                                }}: {{ cf.groupName }} - {{ cf.fieldName }}
                                (Ancillary)</a>
                              <div v-if="cf.edit && !cf.dataViewFieldConfigId && !cf.dataViewChildFieldConfigId"
                                   class="mt-3">
                                <label>Use Parent Data: </label>
                                <input type="checkbox" class="ml-3 mb-4" v-model="cf.useParentData"
                                       @change="saveUseParentData(cf)"
                                       :readonly="!userCanEdit" :disabled="!userCanEdit">
                              </div>
                              <v-row v-if="cf.edit">
                                <v-col cols="6">
                                  <v-card flat
                                          :color="localCustomFieldGroups.indexOf(item) % 2 ? undefined : 'primary lighten-9'"
                                          class="square-card">
                                    <!--                                      <v-card-title style="height: 40px" class="py-0">-->
                                    <!--                                        Hidden-->
                                    <!--                                        <v-checkbox type="checkbox" class="ml-2"-->
                                    <!--                                                    v-model="cf.customFieldGroupAssignmentHidden"></v-checkbox>-->
                                    <!--                                      </v-card-title>-->
                                    <v-card-text>

                                      <MultiSelectGroup
                                          v-if="!positionsLoading"
                                          :userCanEdit="userCanEdit"
                                          :returnObject="cf"
                                          :content="positions"
                                          :dropdownEnabled="cf.customFieldGroupAssignmentHidden"
                                          :selectedContent="cf.hiddenWhiteListedPositions"
                                          :title="'Hidden'"
                                          :label="'Allowed Positions'"
                                          :alternateLabel="'Denied Positions'"
                                          :allow="cf.customFieldGroupAssignmentHiddenAllow"
                                          :contentLoading="positionsLoading"
                                          background-color="transparent"
                                          @selected-changed="cf.hiddenWhiteListedPositions = $event; cf.hiddenPositionsChanged = true"
                                          @allow-changed="cf.customFieldGroupAssignmentHiddenAllow = ($event === 0); cf.hiddenPositionsChanged = true"
                                          @checkbox-changed="cf.customFieldGroupAssignmentHidden = $event; cf.hiddenPositionsChanged = true"></MultiSelectGroup>
                                      <br/>
                                      <AlbatrossButton
                                          color="primary"
                                          class="d-inline-block"
                                          @click="saveHiddenAndWhiteList(cf)"
                                          prepend-icon="save"
                                          text="Save Hidden"
                                      ></AlbatrossButton>
                                    </v-card-text>
                                  </v-card>
                                </v-col>
                              </v-row>
                            </div>
                          </v-list-item-content>
                          <v-tooltip left>
                            <template v-slot:activator="{ on, attrs }">
                              <AlbatrossButton
                                  icon
                                  color="primary"
                                  @click="copyToClipBoard(cf.customFieldGroupAssignmentId)"
                                  v-bind="attrs"
                                  :activation-handler="on"
                                  prepend-icon="mdi-information"
                              ></AlbatrossButton>
                            </template>
                            <span>Custom Field Group Assignment Id: {{ cf.customFieldGroupAssignmentId }}</span>
                            <div class="text-center">(click to copy)</div>
                          </v-tooltip>
                          <v-menu offset-y
                                  v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <AlbatrossButton
                                      variant="text"
                                      size="small"
                                      color="primary"
                                      :activation-handler="{...tooltip, ...menu}"
                                      v-if="!cf.ancillaryCustomFieldGroupAssignmentId"
                                      prepend-icon="mdi-cursor-move"
                                  ></AlbatrossButton>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                  v-for="(cfg, index) in localCustomFieldGroups.filter(g => { return g.id !== cf.customFieldGroupId })"
                                  :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <AlbatrossButton
                              variant="text"
                              color="primary"
                              size="small"
                              @click="[$set(cf, 'edit', !cf.edit), getPositions()]"
                              v-if="userCanEdit && !cf.dataViewFieldConfigId && !cf.dataViewChildFieldConfigId"
                              :prepend-icon="!cf.edit ? 'edit' : 'close'"
                          ></AlbatrossButton>
                          <AlbatrossButton
                              v-if="userCanEdit"
                              variant="text"
                              color="primary"
                              small
                              @click="[assignmentToDelete=cf, customFieldGroupToDelete=item]"
                              prepend-icon="delete"
                          ></AlbatrossButton>
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
    <ConfirmationDialog :open-dialog="!!assignmentToDelete" @confirm="[addField=false, newField={}, deleteWithChecks()]"
                        @close-dialog="[customFieldGroupToDelete = null, assignmentToDelete = null]">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to
      "move" the field to another group please cancel and move the field. <br/><br/>

      Are you sure you want to delete <strong>{{ assignmentToDeleteFieldName }}</strong> from
      <strong>{{ itemToDeleteGroupName }}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import draggable from 'vuedraggable'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton"
import {AppMutations} from '@/stores/AppStore'

import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import Sortable from "sortablejs";
import cloneDeep from 'lodash.clonedeep'
import orderBy from "lodash.orderby"
import ConfirmationDialog from "@/components/ConfirmationDialog";
import {getCurrentInstance, toRefs, computed, ref, onMounted} from 'vue'
import {useRoute} from "vue-router/composables";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {defineProps} from 'vue'
import MultiSelectGroup from "@/components/MultiSelectGroup.vue"


const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
import {useAppStore} from '@/stores/AppStorePinia.js'

const appStore = useAppStore()

const props = defineProps({
  customFieldGroups: Array
})
// const {customFieldGroups} = props
const { customFieldGroups } = toRefs(props)


onMounted(() => {
  let table = document.querySelector('.process-step-cfg-table tbody')
  const _self = vueInstance
  Sortable.create(table, {
    handle: '.handle',
    onEnd({newIndex, oldIndex}) {
      if (_self.localCustomFieldGroups?.length > 0) {
        const rowSelected = _self.localCustomFieldGroups.splice(oldIndex, 1)[0]
        _self.localCustomFieldGroups.splice(newIndex, 0, rowSelected)
        let rowsClone = cloneDeep(_self.localCustomFieldGroups)

        let rowsToSave = []
        rowsClone.forEach((r, idx) => {
          //check if the row needs to be saved before updating display order
          //todo: vuetify table sorting is doing something weird where it won't sort right if i update the actual display order. hacked around it for now _rn
          let save = r.newGroupOrder === undefined ? r.groupOrder !== idx : r.newGroupOrder !== idx
          //update display order
          r.groupOrder = idx
          //save only rows that changed
          if (save) {
            _self.localCustomFieldGroups[idx].newGroupOrder = idx
            rowsToSave.push(r)
          }
        })
        _self.saveRowChanges(rowsToSave)
      }
    }
  })
})


//todo: figure out if this is still necessary
//   updated() {
// this had to be in updated vs mounted so that after the re-render the dragging still works
//was the table code from mounted
// },


const componentKey = ref(0)
const deleteError = ref(false)
const deleteHeader = ref(null)
const deleteText = ref(null)
const fieldsInUse = ref([])
const positions = ref([])
const positionsLoading = ref(false)
const newGroup = ref({})
const newField = ref({})
// = selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet)
const selectedIndex = ref(null)
const createNew = ref(false)
const newFieldType = ref('native')
const addField = ref(false)
const selectedGroupId = ref(null)
const availableCustomFields = ref([])
const parent = ref({})
const parentObjects = ref([])
const selectedAncillaryField = ref({})
const ancillaryCustomFields = ref([])
const expanded = ref([])
const eventTypes = ref([])
const customFieldGroupToDelete = ref(null)
const assignmentToDelete = ref(null)
const hoverIndex = ref(null)
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
  {text: 'Name', value: 'groupName', show: true},
  {text: null, value: 'icons', show: true}
])

const processStepId = computed(() => {
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
const itemToDeleteGroupName = computed(() => {
  return customFieldGroupToDelete.value?.groupName || ''
})
const assignmentToDeleteFieldName = computed(() => {
  return assignmentToDelete.value?.groupName || ''
})
const filteredCustomFieldGroups = computed(() => {
  return localCustomFieldGroups.value?.filter(cfg => {
    return !cfg.archived
  })
})

const localCustomFieldGroups = computed({
  get: () => customFieldGroups.value,
  set: (val) => {
    val.forEach(v => {
      v.groupOrder = v.newGroupOrder ?? v.groupOrder
    })
    return orderBy(val, v => v.groupOrder)
  }
})

const selectAll = (f) => {
  return f.whiteListedPositions?.length === positions.value?.length
}
const selectSome = (f) => {
  return f.whiteListedPositions?.length > 0 && !selectAll(f)
}
const icon = (f) => {
  if (selectAll(f)) {
    return 'check_box'
  }
  if (selectSome(f)) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const saveFieldGroup = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    newGroup.value.processStepId = processStepId.value

    const {data} = await postRequest(`/customFieldGroup/addProcessStepCustomFieldGroup`, newGroup.value)
    localCustomFieldGroups.value.push(data)
    newGroup.value = {}
    createNew.value = false
    snackbar('SUCCESS', 'Group Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteWithChecks = async () => {
  let item, customFieldGroupId, customFieldGroupAssignmentId;
  if (assignmentToDelete.value) {
    item = assignmentToDelete.value
    customFieldGroupAssignmentId = assignmentToDelete.value.id
  } else {
    item = customFieldGroupToDelete.value
    customFieldGroupId = customFieldGroupToDelete.value.id
  }
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let params = {
      customFieldGroupId, customFieldGroupAssignmentId
    }
    const {data, status} = await putRequest(`/customFieldGroup/deleteWithRequirementChecks`, params, null, [])
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
      handleHidingGlobalLoader(vueInstance, status)
    } else {
      fieldsInUse.value = []
      item.archived = true
      snackbar('SUCCESS', 'Item Deleted')
      handleHidingGlobalLoader(vueInstance, status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')
    store.commit(AppMutations.SET_LOADING, false)
  }
  assignmentToDelete.value = null
  customFieldGroupToDelete.value = null
}
const saveGroupName = async (group) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
    snackbar('SUCCESS', 'Group Name Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Change')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const moveFieldToOtherGroup = async (field, newGroup) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
    snackbar('SUCCESS', 'Field Moved')
    //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
    window.location.reload()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Moving Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const fetchAvailableCustomFields = async (objectTypeId, groupId) => {
  if (addField.value) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      if (addField.value && newFieldType.value === 'native') {
        const {data, status} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
          params: {
            companyObjectTypeId: objectTypeId,
            groupId,
            processStepId: processStepId.value
          }
        })
        availableCustomFields.value = data
        parentObjects.value = []
        ancillaryCustomFields.value = []
        handleHidingGlobalLoader(vueInstance, status)
      } else if (addField.value && newFieldType.value === 'ancillary') {
        availableCustomFields.value = []
        const {
          data,
          status
        } = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: processStepId.value}})
        selectedAncillaryField.value = {}
        parentObjects.value = data
        handleHidingGlobalLoader(vueInstance, status)
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const loadFieldsByParent = async () => {

  store.commit(AppMutations.SET_LOADING, true)
  try {
    if (parent.value.isProcessStep) {
      const {data, status} = await getRequest(`/customField/getByParentProcessStep/${parent.value.id}`)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } else if (parent.value.objectTypeId === 8) {
      const {data, status} = await getRequest(`/customField/getByDataView/${parent.value.id}`)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } else {
      const {data, status} = await getRequest(`/customField/getByParentType/${parent.value.id}`)
      ancillaryCustomFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveUseParentData = async (field) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/saveUseParentData`, field)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveReadOnlyAndWhiteList = async (field) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
    field.positionsChanged = false
    if (!field.customFieldGroupAssignmentReadOnly) {
      //todo
      vueInstance.$set(field, 'whiteListedPositions', [])
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveHiddenAndWhiteList = async (field) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/saveHiddenAndWhiteList?savePositions=${field.hiddenPositionsChanged ?? false}`, field)
    field.hiddenPositionsChanged = false
    if (!field.customFieldGroupAssignmentHidden) {
      vueInstance.$set(field, 'hiddenWhiteListedPositions', [])
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveFieldChanges = async (fields) => {
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
      store.commit(AppMutations.SET_LOADING, true)
      const {status} = await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
      handleHidingGlobalLoader(vueInstance, status)
    }
    snackbar('SUCCESS', 'Fields Updated')
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Fields')
    store.commit(AppMutations.SET_LOADING, false)
  }

}
const assignCustomField = async (cfg) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    addField.value = false
    newField.value.customFieldGroupId = cfg.id
    //this line makes pushing it to the list work
    newField.value.archived = false

    const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, newField.value)
    cfg.customFields.push(data)
    newField.value = {}
    snackbar('SUCCESS', 'Custom Field Assigned')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Custom Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const assignAncillaryCustomField = async (cfg) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const params = {
      customFieldGroupId: cfg.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId,
      dataViewFieldConfigId: selectedAncillaryField.value.dataViewChildFieldConfigId ? null : selectedAncillaryField.value.dataViewFieldConfigId,
      dataViewChildFieldConfigId: selectedAncillaryField.value.dataViewChildFieldConfigId,
      fieldOrder: 0
    }
    const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
    cfg.customFields.push(data)
    selectedAncillaryField.value = {}
    addField.value = false
    parent.value = {}
    snackbar('SUCCESS', 'Reference Field Assigned')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Reference Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveRowChanges = async (rows) => {
  if (rows?.length > 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
      localCustomFieldGroups.value = orderBy(localCustomFieldGroups.value, 'groupOrder')
      snackbar('SUCCESS', 'Group Order Saved')
      // this componentKey forces the data-table component to re-render
      componentKey.value += 1
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Group Order')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const getPositions = async () => {
  if (positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const toggleHiddenSelectAllPositions = (field) => {
  vueInstance.$nextTick(() => {
    if (selectAll(field)) {
      field.hiddenWhiteListedPositions = []
      field.hiddenPositionsChanged = true
    } else {
      field.hiddenWhiteListedPositions = cloneDeep(positions.value)
      field.hiddenPositionsChanged = true
    }
  })
}
const toggleSelectAllPositions = (field) => {
  vueInstance.$nextTick(() => {
    if (selectAll(field)) {
      field.whiteListedPositions = []
      field.positionsChanged = true
    } else {
      field.whiteListedPositions = cloneDeep(positions.value)
      field.positionsChanged = true
    }
  })
}
const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue);
  snackbar('SUCCESS', 'Copied text to clipboard')
}
</script>

<style scoped lang="scss">
.custom-field-group {
  border: solid 1px var(--v-primary-lighten9) !important;
}

.custom-field-group-border {
  border-bottom: solid 1px var(--v-primary-lighten9) !important;
}

.custom-field-border {
  border-bottom: solid 1px var(--v-grey-lighten2) !important;
}

.custom-field-hover {
  background-color: var(--v-primary-lighten8) !important;
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
