<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" id="columnTables">
        <v-container v-for="n in numberOfCols" >
          <span v-if="objectType && objectType.customColumns"
                class="albatross-header-4 mb-2">Column {{ numberValues[n] }}</span>
          <v-data-table
            :id="`column${n}Table`"
            :headers="headers"
            :items="groupsByColumn[n]"
            :items-per-page="-1"
            single-expand
            :sort-by="['groupOrder']"
            :sort-desc="[false]"
            :expanded.sync="expanded[n]"
            hide-default-footer
            hide-default-header
            :class="{'fix-column-width-bug': !isMobile}"
            class="elevation-1 mb-5 draggable-table table-striped"
          >
            <template #no-data>
              <span class="default-text-color">No available field groups</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available field groups</span>
            </template>

            <!--todo: this grid still needs some work but it's giving me a hard time so I'm going to come back to it later-->
            <template #item="{ item, index }">
              <tr>
                <td style="width: 50px">
                  <AlbatrossButton variant="text" color="primary" icon size="small" class="handle" v-if="userCanEdit" prepend-icon="drag_handle"/>
                </td>
                <td class="text-left group-name-col">
                  <v-text-field text
                                v-if="item.edit"
                                v-model="item.groupName">
                  </v-text-field>
                  <span v-else>{{ item.groupName }}</span>
                </td>
                <td>
                  <div class="item-icons" v-if="!isMobile">
                    <v-tooltip left>
                      <template v-slot:activator="{ on, attrs }">
                        <AlbatrossButton variant="text" icon color="primary" @click="copyToClipBoard(item.id)" v-bind="attrs"
                               :activation-handler="on" prepend-icon="mdi-information"/>
                      </template>
                      <span>Custom Field Group Id: {{ item.id }}</span>
                      <div class="text-center">(click to copy)</div>
                    </v-tooltip>
                    <div v-if="userCanEdit" class="flex-display">
                      <AlbatrossButton size="small" variant="text" color="primary"
                             @click="item.edit = !item.edit"
                             :prepend-icon="item.edit ? 'remove' : 'edit'"
                      />
                      <AlbatrossButton size="small" variant="text" color="primary"
                             v-if="item.edit"
                             @click="[saveGroup(item), item.edit = false]"
                             prepend-icon="save"
                      />

                    </div>
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
                              v-if="objectType && objectType.customColumns"
                              prepend-icon="mdi-cursor-move"
                            />
                          </template>
                          <span>Change Column</span>
                        </v-tooltip>
                      </template>
                      <v-list>
                        <v-list-item v-for="num in numberOfCols" v-if="n !== num"
                                     @click="moveCustomFieldGroupToColumn(item, num)">
                          <v-list-item-title>{{ `Column ${numberValues[num]}` }}</v-list-item-title>
                        </v-list-item>
                      </v-list>
                    </v-menu>
                    <AlbatrossButton
                      size="small"
                      variant="text"
                      color="primary"
                      v-if="userCanAdd"
                      @click="[addField = !addField, fetchAvailableCustomFields(item.id), expanded[n] = [item], selectedIndex = index]"
                      :prepend-icon="addField && expanded[n].includes(item) ? 'remove' : 'add'"
                    />
                    <AlbatrossButton size="small" variant="text" color="primary"
                           @click="[expanded[n].includes(item) ? expanded[n] = [] : expanded[n] = [item], selectedIndex = index]"
                           :prepend-icon="expanded[n].includes(item) ? 'expand_less' : 'expand_more'"
                    />
                    <AlbatrossButton v-if="userCanEdit"
                                     size="small" variant="text" color="primary" @click="cfgToDelete=item"
                                     prepend-icon="delete"
                    />
                  </div>
                  <!--div below reorders the buttons to make more sense when columns wrap-->
                  <div class="item-icons" v-else>
                    <v-tooltip left>
                      <template v-slot:activator="{ on, attrs }">
                        <AlbatrossButton variant="text" icon color="primary" @click="copyToClipBoard(item.id)" v-bind="attrs"
                               :activation-handler="on"
                               prepend-icon="mdi-information"
                        />
                      </template>
                      <span>Custom Field Group Id: {{item.id}}</span>
                      <div class="text-center">(click to copy)</div>
                    </v-tooltip>
                    <AlbatrossButton size="small" variant="text" icon color="primary"
                           @click="[expanded[n].includes(item) ? expanded[n] = [] : expanded[n] = [item], selectedIndex = index]"
                           :prepend-icon="expanded[n].includes(item) ? 'expand_less' : 'expand_more'"
                    />
                    <AlbatrossButton size="small" variant="text" color="primary"
                                     v-if="userCanAdd"
                                     @click="[addField = !addField, fetchAvailableCustomFields(item.id), expanded[n] = [item], selectedIndex = index]"
                                     :prepend-icon="addField && expanded[n].includes(item) ? 'remove' : 'add'"
                    />
                      <div v-if="userCanEdit" class="flex-display">
                        <AlbatrossButton size="small" variant="text" color="primary"
                                         @click="item.edit = !item.edit"
                                         :prepend-icon="item.edit ? 'remove' : 'edit'"
                        />
                        <AlbatrossButton size="small" variant="text" color="primary"
                               v-if="item.edit"
                               @click="[saveGroup(item), item.edit = false]"
                               prepend-icon="save"
                        />
                      </div>
                      <v-menu offset-y
                              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                        <template v-slot:activator="{ on: menu }">
                          <v-tooltip bottom>
                            <template v-slot:activator="{ on: tooltip }">
                              <AlbatrossButton variant="text" size="small" color="primary" :activation-handler="{...tooltip, ...menu}"
                                               v-if="objectType && objectType.customColumns"
                                               prepend-icon="mdi-cursor-move"
                              />
                            </template>
                            <span>Change Column</span>
                          </v-tooltip>
                        </template>
                        <v-list>
                          <v-list-item v-for="num in numberOfCols" v-if="n !== num"
                                       @click="moveCustomFieldGroupToColumn(item, num)">
                            <v-list-item-title>{{ `Column ${numberValues[num]}` }}</v-list-item-title>
                          </v-list-item>
                        </v-list>
                      </v-menu>
                    <AlbatrossButton
                      v-if="userCanEdit"
                      size="small"
                      variant="text"
                      color="primary"
                      @click="cfgToDelete=item"
                      prepend-icon="delete"
                    />
                  </div>
                </td>
              </tr>
            </template>

            <template #expanded-item="{ headers, item, index }">
              <td :colspan="headers.length" class="pb-2" :class="{'shaded-row': selectedIndex % 2}">
                <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                  <h3 class="text-left">Add New Field</h3>
                  <v-radio-group v-if="objectType.allowAncillary"
                                 v-model="newFieldType" @change="fetchAvailableCustomFields(item.id)">
                    <v-radio label="Native Custom Field"
                             value="native"/>
                    <v-radio label="Reference Field: viewed only from other process steps or objects"
                             value="ancillary"/>
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
                    <template slot="item" slot-scope="{ item }">
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
                    <template slot="item" slot-scope="{ item }">
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
                                  @input="assignCustomField(item, true)"
                  >
                    <template slot="item" slot-scope="{ item }">
                      {{ item.fieldName }}
                    </template>
                  </v-autocomplete>
                </v-col>
                <v-col cols="12" class="pl-3 pr-3 justify" v-if="!item.customFields || item.customFields.length === 0">
                  No fields assigned to this group
                </v-col>
                <v-col cols="12" class="px-3 py-0 justify" v-else>
                  <draggable v-model="item.customFields"
                             v-if="item.customFields && item.customFields.length > 0"
                             :disabled="!userCanEdit"
                             group="customFields"
                             @start="drag=true"
                             @end="drag=false"
                             @change="saveFieldChanges(item.customFields)">
                    <v-list v-for="(cf, index) in filteredCustomFields (item.customFields)"
                            :key="index" class="pa-0" :class="{ 'shaded-row': selectedIndex % 2 }">
                      <v-list-item class="grab pr-1">
                        <v-list-item-action v-if="userCanEdit">
                          <v-icon color="primary">drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                            {{ cf.fieldName }}
                          </div>
                          <div v-else>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{ cf.fieldName }}
                            (Ancillary)<br/>
                            <div v-if="cf.processStepName">
                              <label>Use Parent Data: </label>
                              <input type="checkbox"
                                     class="ml-3 mb-4"
                                     v-model="cf.useParentData"
                                     @change="saveUseParentData(cf)"
                                     :readonly="!userCanEdit"
                                     :disabled="!userCanEdit">
                            </div>
                          </div>
                          <div v-if="objectType.allowRequired">
                            <label>
                              <input type="checkbox" v-model="cf.required" :readonly="!userCanEdit"
                                     :disabled="!userCanEdit" @change="updateRequired(cf)">
                              Required
                            </label>
                          </div>

                          <div v-if="objectType.allowConditional">
                            <label>
                              <input type="checkbox" v-model="cf.hasConditionalOnId"
                                     :disabled="!userCanEdit" @change="saveConditionalField(cf)"/>
                              Conditional On
                            </label>
                            <v-select v-model="cf.conditionalOnId"
                                      v-if="cf.hasConditionalOnId"
                                      :items="filterAvailableCustomFields(cf)"
                                      item-value="customFieldGroupAssignmentId"
                                      item-text="fieldName"
                                      placeholder="Choose a field"
                                      @change="saveConditionalField(cf)"
                            />
                          </div>

                          <div>
                            <div v-if="objectType.allowReadonly">
                              <label>
                                <input type="checkbox" v-model="cf.customFieldGroupAssignmentReadOnly"
                                       :disabled="!userCanEdit" @change="saveReadOnlyAndWhiteList(cf)"/>
                                Read Only
                              </label>
                              <div v-if="cf.customFieldGroupAssignmentReadOnly" class="d-flex align-center">
                                <v-autocomplete
                                  v-if="cf.customFieldGroupAssignmentReadOnly"
                                  v-model="cf.whiteListedPositions"
                                  :items="positions"
                                  :loading="positionsLoading"
                                  multiple
                                  clearable
                                  label="White Listed Positions"
                                  item-text="position"
                                  item-value="positionId"
                                  return-object
                                  height="35px"
                                  class="d-inline-block mr-3"
                                  @change="cf.positionsChanged = true">
                                  <v-list-item
                                    slot="prepend-item"
                                    ripple
                                    @click="toggleSelectAllPositions(cf, 'whiteListedPositions')"
                                  >
                                    <v-list-item-action>
                                      <v-icon>{{ icon(cf) }}</v-icon>
                                    </v-list-item-action>
                                    <v-list-item-title>Select All</v-list-item-title>
                                  </v-list-item>
                                  <v-divider
                                    slot="prepend-item"
                                    class="mt-2"
                                  ></v-divider>
                                  <template
                                    slot="selection"
                                    slot-scope="{ item, index }"
                                  >
                                    <v-chip small
                                            v-if="index === 0 && cf.whiteListedPositions && cf.whiteListedPositions.length < 2">
                                      <span>{{ item.position }}</span>
                                    </v-chip>
                                    <span
                                      v-if="index === 1 && cf.whiteListedPositions && cf.whiteListedPositions.length >= 2"
                                      class="primary--text text-caption"
                                    >{{ cf.whiteListedPositions.length }} selected</span>
                                  </template>
                                </v-autocomplete>

                                <AlbatrossButton
                                  color="primary"
                                  dark
                                  class="d-inline-block white--text"
                                  @click="saveReadOnlyAndWhiteList(cf)"
                                  prepend-icon="save"
                                  text="SAVE READ ONLY"
                                />
                              </div>
                            </div>
                          </div>

                          <div>
                            <div v-if="objectType.allowHidden">
                              <label>
                                <input type="checkbox" v-model="cf.customFieldGroupAssignmentHidden"
                                       :disabled="!userCanEdit" @change="saveHiddenAndWhiteList(cf)"/>
                                Hidden
                              </label>
                              <div v-if="cf.customFieldGroupAssignmentHidden" class="d-flex align-center">
                                <v-autocomplete
                                  v-model="cf.hiddenWhiteListedPositions"
                                  :items="positions"
                                  :loading="positionsLoading"
                                  multiple
                                  clearable
                                  label="White Listed Positions"
                                  item-text="position"
                                  item-value="positionId"
                                  return-object
                                  height="35px"
                                  class="d-inline-block mr-3"
                                  @change="cf.hiddenPositionsChanged = true"
                                >
                                  <v-list-item
                                    slot="prepend-item"
                                    ripple
                                    @click="toggleSelectAllPositions(cf, 'hiddenWhiteListedPositions')"
                                  >
                                    <v-list-item-action>
                                      <v-icon>{{ icon(cf, 'hiddenWhiteListedPositions') }}</v-icon>
                                    </v-list-item-action>
                                    <v-list-item-title>Select All</v-list-item-title>
                                  </v-list-item>
                                  <v-divider
                                    slot="prepend-item"
                                    class="mt-2"
                                  ></v-divider>
                                  <template
                                    slot="selection"
                                    slot-scope="{ item, index }"
                                  >
                                    <v-chip small
                                            v-if="index === 0 && cf.hiddenWhiteListedPositions && cf.hiddenWhiteListedPositions.length < 2">
                                      <span>{{ item.position }}</span>
                                    </v-chip>
                                    <span
                                      v-if="index === 1 && cf.hiddenWhiteListedPositions && cf.hiddenWhiteListedPositions.length >= 2"
                                      class="primary--text text-caption"
                                    >{{ cf.hiddenWhiteListedPositions.length }} selected</span>
                                  </template>
                                </v-autocomplete>

                                <AlbatrossButton
                                  color="primary"
                                  dark
                                  class="white--text d-inline-block"
                                  @click="saveHiddenAndWhiteList(cf)"
                                  prepend-icon="save"
                                  text="SAVE HIDDEN"
                                />
                              </div>
                            </div>
                          </div>

                          <div class="flex-display"
                               v-if="objectType.allowMinMax && [4,6].includes(cf.dataTypeId) && !cf.hasListValues">
                            <v-text-field text
                                          type="number"
                                          label="Minimum Value"
                                          @change="changedMinMax(cf)"
                                          :disabled="!userCanEdit"
                                          v-model.number="cf.minValue"/>
                            <v-spacer/>
                            <v-text-field text
                                          type="number"
                                          label="Maximum Value"
                                          @change="changedMinMax(cf)"
                                          :disabled="!userCanEdit"
                                          v-model.number="cf.maxValue"/>
                            <AlbatrossButton
                              variant="text"
                              color="primary"
                              @click="saveMinMax(cf)"
                              :disabled="!cf.minMaxValueChanged"
                              prepend-icon="save"
                            />
                          </div>
                        </v-list-item-content>
                        <v-tooltip left>
                          <template v-slot:activator="{ on, attrs }">
                            <AlbatrossButton
                              variant="text"
                              color="primary"
                              @click="copyToClipBoard(cf.customFieldGroupAssignmentId)"
                              v-bind="attrs"
                              :activation-handler="on"
                              prepend-icon="mdi-information"
                            />
                          </template>
                          <span>Custom Field Group Assignment Id: {{ cf.customFieldGroupAssignmentId }}</span>
                          <div class="text-center">(click to copy)</div>
                        </v-tooltip>
                        <AlbatrossButton
                          v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                          size="small"
                          variant="text"
                          color="primary"
                          @click="[cfgToDelete=item, cFieldToDelete = cf]"
                          prepend-icon="delete"
                        />
                      </v-list-item>
                    </v-list>
                  </draggable>
                </v-col>
              </td>
            </template>
          </v-data-table>
        </v-container>
      </v-col>
    </v-row>
    <ConfirmationDialog
      :open-dialog="cfgToDelete && !cFieldToDelete"
      @confirm="deleteGroup"
      @close-dialog="cfgToDelete=null">
      Are you sure you want to delete this Custom Field Group: <strong>{{ cfgToDeleteName }}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog
      :open-dialog="!!cFieldToDelete"
      @confirm="deleteFieldFromGroup"
      @close-dialog="[cfgToDelete = null, cFieldToDelete = null]">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to "move" the field to another
      group please cancel and move the field. <br/><br/>
      Are you sure you want to delete this field from {{ cfgToDeleteName }}: <strong>{{ cFieldToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import {useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

import {
  deleteRequest,
  getRequest,
  getRequestWithParams,
  defineSortableTable,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from '@/components/ConfirmationDialog'

import { useUserStore } from '@/stores/UserStorePinia.js'
const addNew = ref(false)
const newFieldType = ref('native')
const deleteError = ref(false)
const deleteHeader = ref(null)
const deleteText = ref(null)
const fieldsInUse = ref([])
const minMaxValueChanged = ref(false)
const selectedIndex = ref(null)
const fieldOrderChanged = ref(false)
const groupOrderChanged = ref(false)
const newGroup = ref({
  groupName: null
})
const addField = ref(false)
const newField = ref({})
const availableCustomFields = ref([])
//if you set this to a value it doesn't update when the route param changes
// objectTypeId: route.params.id
const headers = ref([
  {text: null, value: 'draggable', width: '50px', show: true},
  {text: 'Name', value: 'groupName', show: true},
  {text: null, value: 'icons', show: true}
])
const expanded = ref({
  1: [],
  2: []
})
const parent = ref({})
const parentObjects = ref([])
const selectedAncillaryField = ref({})
const ancillaryCustomFields = ref([])
const cfgToDelete = ref(null)
const cFieldToDelete = ref(null)
const groupsByColumn = ref([])
const columnChangeCount = ref(0)
const count = ref(0)
const numberValues = ref([
  undefined, 'One', 'Two', 'Three', 'Four'
])
const positions = ref([])
const positionsLoading = ref(false)

const emit = defineEmits(['group-deleted'])
const props = defineProps({
  objectType: Object,
  customFieldGroups: Array
})
watch(props.objectType, () => {
  groupsByColumn.value = [undefined, getGroupsByCol(1), getGroupsByCol(2)]
})
watch(props.customFieldGroups, () => {
  groupsByColumn.value = [undefined, getGroupsByCol(1), getGroupsByCol(2)]
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
const cfgToDeleteName = computed(() => {
  return cfgToDelete.value ? cfgToDelete.value.groupName : ''
})
const cFieldToDeleteName = computed(() => {
  return cFieldToDelete.value ? cFieldToDelete.value.fieldName : ''
})
const numberOfCols = computed(() => {
  if (props.objectType && props.objectType.customColumns) {
    return 2
  }
  return 1
})
const isMobile = computed(()=> {
  return vuetify.breakpoint.xsOnly
})


const changedMinMax = (cf) =>{
  vueInstance.$set(cf, 'minMaxValueChanged', true)
}
const fetchAvailableCustomFields = async (groupId) => {
  try {
    if (addField.value && newFieldType.value === 'native') {
      store.commit(AppMutations.SET_LOADING, true)
      const {data, status} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
        params: {
          objectTypeId: parseInt(route.params.id),
          groupId
        }
      }, 'blueraven')
      availableCustomFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } else if (addField.value && newFieldType.value === 'ancillary') {
      store.commit(AppMutations.SET_LOADING, true)
      availableCustomFields.value = []
      const {
        data,
        status
      } = await getRequest(`/objectType/${route.params.id}/getParentObjectsWithTypes`, 'blueraven')
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
const updateRequired = async (cf) => {
  try {
    const field = {
      customFieldGroupAssignmentId: cf.customFieldGroupAssignmentId,
      required: cf.required || false
    }
    const {status} = await putRequest(`/customFieldGroup/updateRequired`, field, 'blueraven')
    snackbar('SUCCESS', 'Updated Field')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveMinMax = async (cf) => {
  try {
    const {status} = await putRequest(`/customFieldGroup/saveMinMax`, cf, 'blueraven')
    cf.minMaxValueChanged = false
    snackbar('SUCCESS', 'Updated Field')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveConditionalField = async (cf) => {
  try {
    if (cf.hasConditionalOnId && !cf.conditionalOnId) {
      return
    }

    if (!cf.hasConditionalOnId) {
      // if this has been cleared out make sure to unset it
      cf.conditionalOnId = undefined
    }

    const {status} = await putRequest(`/customFieldGroup/updateConditionalId`, cf, 'blueraven')
    snackbar('SUCCESS', 'Updated Field')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Data')
    store.commit(AppMutations.SHOW_SNACK, snackbar)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const assignCustomField = async (cfg, isAncillary) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    addField.value = false
    newField.value.customFieldGroupId = cfg.id
    let params = !isAncillary ? newField.value : {
      customFieldGroupId: cfg.id,
      id: null,
      ancillaryCustomFieldGroupAssignmentId: selectedAncillaryField.value.customFieldGroupAssignmentId,
      fieldOrder: 0
    }
    const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params, 'blueraven')
    cfg.customFields.push(data)
    newField.value = {}
    selectedAncillaryField.value = {}
    ancillaryCustomFields.value = []
    addField.value = false
    parent.value = {}
    snackbar('SUCCESS', 'Field Added to Group')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Field to Group')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveGroupChanges = async (groups) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups, 'blueraven')
    snackbar('SUCCESS', 'Groups Updated')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group Changes')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const moveCustomFieldGroupToColumn = async (group, columnNumber) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    let fromColumn = group.columnNumber
    group.columnNumber = columnNumber
    const {data, status} = await putRequest(`/customFieldGroup/moveGroupToColumn`, group, 'blueraven')
    groupsByColumn.value[fromColumn] = groupsByColumn.value[fromColumn].filter(f => f.id !== group.id)
    groupsByColumn.value[columnNumber].push(data)
    snackbar('SUCCESS', 'Group Updated')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Group Changes')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveGroup = async (group) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group, 'blueraven')
    group.tabName = data.tabName
    group.companyObjectTypeTabDisplayOrder = data.companyObjectTypeTabDisplayOrder
    snackbar('SUCCESS', 'Custom Field Group Updated')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Change')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteGroup = async () => {
  const item = cfgToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/customFieldGroup/${item.id}`, 'blueraven')
    item.archived = true
    snackbar('SUCCESS', 'Group Deleted')

    emit('group-deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Group')

    store.commit(AppMutations.SET_LOADING, false)
  }
  cfgToDelete.value = null
}
const deleteFieldFromGroup = async () => {
  const item = cFieldToDelete.value
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/customFieldGroup/assignment/${item.id}`, 'blueraven')
    fieldsInUse.value = []
    item.archived = true
    snackbar('SUCCESS', 'Item Deleted')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

    store.commit(AppMutations.SET_LOADING, false)
  }
  cFieldToDelete.value = null
  cfgToDelete.value = null
}
const deleteField = async (item, customFieldGroupId) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/customFieldGroup/${customFieldGroupId}`, 'blueraven')
    fieldsInUse.value = []
    item.archived = true
    snackbar('SUCCESS', 'Item Deleted')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting')

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
      const {status} = await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave, 'blueraven')
      snackbar('SUCCESS', 'Fields Updated')

      handleHidingGlobalLoader(vueInstance, status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Fields')

    store.commit(AppMutations.SET_LOADING, false)
  }

}
const filteredCustomFields = (customFields) => {
  return customFields.filter((cfgt) => cfgt.archived === false)
}

const filterCustomFieldGroups = computed(() => {
  return props.customFieldGroups.filter(cfgt => !cfgt.archived)
})
const getGroupsByCol = (colNumber) => {
  if (props.objectType && props.objectType.customColumns) {
    return filterCustomFieldGroups.value
      .filter(cfg => cfg.columnNumber === colNumber)
      .sort((cfg1, cfg2) => {
        if (cfg1.groupOrder < cfg2.groupOrder) {
          return -1
        }
        if (cfg1.groupOrder > cfg2.groupOrder) {
          return 1
        }
        return 0
      })
  }
  return filterCustomFieldGroups.value
}
const loadFieldsByParent = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    if (parent.value.isProcessStep) {
      const {data, status} = await getRequest(`/customField/getByParentProcessStep/${parent.value.id}`)
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
    const {status} = await putRequest(`/customFieldGroup/saveUseParentData`, field, 'blueraven')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const filterAvailableCustomFields = (current) => {
  return props.customFieldGroups.flatMap(g => g.customFields)
    .filter(cf => !cf.archived)
    .filter(cf => cf.id !== current.id)
}
const saveReadOnlyAndWhiteList = async (field) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList`, field, 'blueraven')
    field.positionsChanged = false
    if (!field.customFieldGroupAssignmentReadOnly) {
      vueInstance.$set(field, 'whiteListedPositions', [])
    }
    snackbar('SUCCESS', 'Field Updated')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveHiddenAndWhiteList = async (field) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/customFieldGroup/saveHiddenAndWhiteList`, field, 'blueraven')
    field.hiddenPositionsChanged = false
    if (!field.customFieldGroupAssignmentHidden) {
      vueInstance.$set(field, 'hiddenWhiteListedPositions', [])
    }
    handleHidingGlobalLoader(vueInstance, status)
    snackbar('SUCCESS', 'Field Updated')

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const selectAll = (f, attr) => {
  return f[attr]?.length === positions.value?.length
}
const selectSome = (f, attr) => {
  return f[attr]?.length > 0 && !selectAll.value(f, attr)
}
const icon = (f, attr = 'whiteListedPositions') => {
  if (selectAll.value(f, attr)) {
    return 'check_box'
  }
  if (selectSome.value(f, attr)) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
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
const toggleSelectAllPositions = (field, attr = 'whiteListedPositions') => {
  if (selectAll(field, attr)) {
    vueInstance.$set(field, attr, [])
  } else {
    vueInstance.$set(field, attr, cloneDeep(positions.value))
  }
  vueInstance.$set(field, 'positionsChanged', true) //todo change to use the 'attr'

}
const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue);
  snackbar('SUCCESS', 'Copied text to clipboard')
}

onMounted(() => {
  getPositions()
  groupsByColumn.value = [undefined, getGroupsByCol(1), getGroupsByCol(2)]
  for (let i = 1; i <= numberOfCols.value; i++) {
    let selectorString = `#column${i}Table tbody`

    defineSortableTable(selectorString, groupsByColumn, 'groupOrder', saveGroupChanges, i)
  }
})

</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.group-name-col {
  @media (max-width: 510px) {
    max-width: 80px;
  }
}
.item-icons {
  display: grid;
  grid-template-columns: repeat(6, 1fr);

  @media (max-width: 1040px) {
    grid-template-columns: repeat(3, 1fr);
  }

  @media (max-width: 510px) {
    grid-template-columns: repeat(2, 1fr);
    float: left;
  }
}

.item-icons-mobile {
  display: flex;
  flex-direction: column;
  float: right;
  @media(max-width: 465px) {
    flex-direction: row;
    div.row {

      flex-direction: column;
    }
  }
}

.handle {
  cursor: move !important;
}
</style>
<style lang="scss">
#columnTables > div > div > div.v-data-table__wrapper > table > tbody {
  display: table-row-group;
}
</style>
