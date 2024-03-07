<template>
  <v-container id="data-view-container" v-if="viewLoaded">
    <v-row>
      <v-col class="shrink" cols="12">
        <AlbatrossButton variant="text"
                         class="pl-1 pr-2 anchor"
                         :to="'/settings/dataViews'"
                         prepend-icon="arrow-left"
                         text="Back"
        />
        <div class="flex-display pt-3 px-3 mb-4 one-hunned">
          <div class="one-hunned pl-3">
            <span class="page-title" v-if="!edit">{{ dataView.displayName }}</span>
            <v-text-field v-else color="primary"
                          v-model="dataView.displayName"
                          label="Display Name"></v-text-field>
            <div>
              <label class="mt-4">Table Name: {{ dataView.viewName }}</label>
              <div>
                <label class="mt-4">Company Processes:</label>
                <span v-if="!edit">
                  <span v-for="(cp, idx) in dataView.companyProcesses">
                    {{ cp.processName }}
                    <span v-if="idx !== dataView.companyProcesses.length - 1">,</span>
                  </span>
                </span>
                <div v-else>
                  <v-autocomplete
                    v-model="dataView.companyProcesses"
                    :items="companyProcesses"
                    label="Company Processes"
                    attach
                    multiple
                    item-text="processName"
                    return-object
                  ></v-autocomplete>
                </div>
              </div>
            </div>
          </div>
          <div class="text-right">
            <AlbatrossButton
              variant="text"
              color="primary"
              v-if="!edit"
              class=""
              @click="[oldName = dataView.displayName, edit = !edit, getCompanyProcesses()]"
              prepend-icon="edit"/>
            <AlbatrossButton
              variant="text"
              color="primary"
              class=""
              v-else
              :disabled="dataView.companyProcesses.length === 0"
              @click="[edit = false, saveDataView()]"
              prepend-icon="save"
            />

            <AlbatrossButton
              variant="text"
              color="primary"
              v-if="edit"
              @click="[dataView.displayName = oldName, edit = !edit, fixData()]"
              text="cancel"/>
          </div>
        </div>
        <v-divider class="mt-3 mb-1"></v-divider>
        <div class="search-header">
          <v-text-field
            v-if="!addNew"
            v-model="search"
            class="mb-2 px-4 py-2 d-inline-block"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
          <AlbatrossButton
            variant="text"
            color="primary"
            class="d-inline-block"
            v-if="!addNew"
            @click="[addNew = !addNew, newField = { processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null }, getAvailableDefaultFields(), getParentObjects(), fixData()]"
            :hide-text-on-mobile="constants.IS_MOBILE"
            :text="!addNew ? 'Add New Field' : 'Cancel'"
            :prepend-icon="addNew ? 'close' : 'add'"
          />
        </div>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add Field Config</h3>
          <div class="mb-3">
            <v-form ref="fieldConfigForm">
              <v-text-field text v-model="newField.displayName"
                            :rules="requiredRules"
                            label="Display Name"/>
              <v-text-field text v-model="newField.fieldToUpdate"
                            hint="5-60 lowercase characters, no spaces, no symbols"
                            persistent-hint
                            :rules="fieldToUpdateRule"
                            label="Field to Update"/>
              <v-radio-group v-model="fieldType" @change="resetAllFields()" hide-details>
                <v-radio label="Default Field" :value="1"></v-radio>
                <v-radio label="Custom Field" :value="2"></v-radio>
              </v-radio-group>

              <v-autocomplete
                v-if="fieldType === 1"
                v-model="selectedDefaultField"
                :items="defaultFields"
                label="Default Field"
                attach
                @change="[getProcessStepEventData(), getProcessStepData(), setObjectTypeId(selectedDefaultField)]"
                item-text="fieldName"
                return-object></v-autocomplete>
              <v-autocomplete
                v-if="selectedDefaultField && selectedDefaultField.objectTypeId === 6"
                v-model="newField.processStepEventId"
                :items="processStepEvents"
                label="Process Step Event"
                attach
                item-text="eventName"
                item-value="id">
                <template slot='item' slot-scope='{ item }'>
                  {{ item.processStepName }} - {{ item.eventName }}
                </template>
              </v-autocomplete>
              <v-autocomplete
                v-else-if="selectedDefaultField && selectedDefaultField.objectTypeId === 4"
                v-model="newField.processStepId"
                :items="processSteps"
                label="Process Step"
                attach
                item-text="processStepName"
                item-value="id">
              </v-autocomplete>
              <v-autocomplete v-if="fieldType === 2"
                              v-model="cfgaParentObject"
                              :items="parentObjects"
                              label="Parent Object"
                              item-text="name"
                              return-object
                              autocomplete="off"
                              @input="[setObjectTypeId(cfgaParentObject), loadFieldsByParent(false), loadProcessStepEvents()]"
              >
                <template slot='item' slot-scope='{ item }'>
                  {{ item.name }}
                </template>
              </v-autocomplete>
              <v-autocomplete v-if="cfgaParentObject && cfgaParentObject.objectTypeId === 4"
                              v-model="parentProcessStepEvent"
                              :items="parentProcessStepEvents"
                              label="Process Step Event"
                              item-text="eventName"
                              return-object
                              autocomplete="off"
                              @input="[loadFieldsByParent(true), setObjectTypeId({objectTypeId: 6})]"
              >
              </v-autocomplete>
              <v-autocomplete v-if="cfgaParentObject && cfgaParentObject.id"
                              v-model="newField.customFieldGroupAssignmentId"
                              :items="customFields"
                              label="Custom Field"
                              item-text="fieldName"
                              item-value="customFieldGroupAssignmentId"
                              autocomplete="off">
                <template slot='item' slot-scope='{ item }'>
                  {{ item.fieldName }}
                </template>
              </v-autocomplete>

              <div class="mb-3" v-if="[4,6].includes(selectedObjectTypeId)">
                <span class="mr-3">Update First Value Only?</span>
                <input
                  type="checkbox"
                  :disabled="newField.resetOnNew || newField.resetValuesOnMain"
                  v-model="newField.updateFirstValueOnly"
                />
                <br/>
                <span
                  class="mr-3">Match New {{ selectedObjectTypeId === 4 ? 'Process Step' : 'Event' }} on create?</span>
                <input
                  :disabled="newField.updateFirstValueOnly"
                  type="checkbox"
                  v-model="newField.resetOnNew"
                />
                <div v-if="selectedObjectTypeId === 4">
                <span
                  class="mr-3">Match Primary Process Step on change?</span>
                <input
                  :disabled="newField.updateFirstValueOnly"
                  type="checkbox"
                  v-model="newField.resetValuesOnMain"
                />
                </div>
                <div>
                  <span
                    class="mr-3">Ignore If Null?</span>
                  <input
                    type="checkbox"
                    v-model="newField.ignoreIfNull"
                  />
                </div>
              </div>
            </v-form>
            <AlbatrossButton
              :disabled="!newField.displayName || !newField.fieldToUpdate || (!selectedDefaultField.id && !newField.customFieldGroupAssignmentId)
                              || (selectedDefaultField.objectTypeId === 6 && !newField.processStepEventId) || (selectedDefaultField.objectTypeId === 4 && !newField.processStepId)"
              color="primary" class="white--text mr-2"
              @click="validateFields(newField, true)"
              text="save"
            />


            <AlbatrossButton
              @click="[addNew = !addNew, newField = { processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null}, selectedDefaultField = {}, fixData()]"
              variant="text"
              color="primary"
              text="Cancel"
            />
          </div>

        </v-card>
        <v-divider></v-divider>
        <v-data-table
          v-if="dataView.dataViewFieldConfigs && !addNew"
          :headers="headers"
          single-expand
          :expanded.sync="expanded"
          :items="dataView.dataViewFieldConfigs"
          :fixed-header="true"
          :items-per-page="100"
          :search="search"
          class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No fields assigned
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4"
                :class="{'shaded-row': dataView.dataViewFieldConfigs.indexOf(item) % 2}">
              <h3>Edit Field Configs</h3>
              <div class="flex-display">
                <v-text-field text v-model="item.displayName" class="d-inline-block display-name-field"
                              label="Display Name"/>
                <AlbatrossButton
                  variant="text"
                  :disabled="!item.displayName"
                  color="primary" class="white--text mr-2 d-inline-block"
                  @click="saveFieldConfig(item, false)"
                  prepend-icon="save"
                />
              </div>
              <v-text-field text v-model="item.fieldToUpdate" disabled readonly
                            label="Field to Update"/>
              <v-text-field v-if="item.defaultFieldId"
                            label="Default Field"
                            disabled readonly
                            v-model="item.fieldName"
              ></v-text-field>
              <v-text-field v-if="item.customFieldGroupAssignmentId"
                            label="Parent Object"
                            disabled readonly
                            v-model="item.parentObjectName"
              ></v-text-field>
              <v-text-field
                v-if="item.processStepId || (item.customFieldGroupAssignmentId && item.objectTypeId === 4)"
                label="Process Step"
                disabled readonly
                v-model="item.processStepName"
              ></v-text-field>
              <v-text-field
                v-if="item.processStepEventId || (item.customFieldGroupAssignmentId && item.objectTypeId === 6)"
                label="Process Step Event"
                disabled readonly
                v-model="item.processStepEventName"
              ></v-text-field>
              <v-text-field v-if="item.customFieldGroupAssignmentId"
                            label="Custom Field"
                            disabled readonly
                            v-model="item.fieldName"
              ></v-text-field>

              <div v-if="[4,6].includes(item.objectTypeId)">
                <span class="mr-3 disabled-label">Update First Value Only?</span>
                <input
                  type="checkbox"
                  disabled readonly
                  v-model="item.updateFirstValueOnly"
                />

                <br/>
                <span
                  class="mr-3 disabled-label">Match New {{
                    item.objectTypeId === 4 ? 'Process Step' : 'Event'
                  }} on create?</span>
                <input
                  disabled readonly
                  type="checkbox"
                  v-model="item.resetOnNew"
                />
                <div v-if="item.objectTypeId === 4">
                <span
                  class="mr-3 disabled-label">Match Primary Process Step on change?</span>
                <input
                  disabled readonly
                  type="checkbox"
                  v-model="item.resetValuesOnMain"
                />
                </div>
                <div>
                  <span
                    class="mr-3 disabled-label">Ignore If Null?</span>
                  <input
                    disabled readonly
                    type="checkbox"
                    v-model="item.ignoreIfNull"
                  />
                </div>
              </div>

              <v-card color="transparent" flat>
                <v-toolbar color="transparent" class="elevation-0">
                  <v-toolbar-title>Child Fields</v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-toolbar-items>
                    <AlbatrossButton
                      variant="text"
                      color="primary"
                      @click="[addChild = !addChild, childField = {}]"
                      prepend-icon="add"
                    />
                  </v-toolbar-items>
                </v-toolbar>

                <div v-if="addChild">
                  <v-form ref="childFieldForm">
                    <v-text-field text v-model="childField.displayName"
                                  :rules="requiredRules"
                                  label="Display Name"/>
                    <v-text-field text v-model="childField.fieldToUpdate"
                                  :rules="fieldToUpdateRule"
                                  label="Child Field to Update"/>
                    <v-autocomplete
                      v-model="childField.uniqueBehaviorTypeId"
                      :items="uniqueBehaviorTypes"
                      label="Unique Behavior Types"
                      attach
                      item-value="id"
                      item-text="uniqueBehaviorType">
                      <template slot="item" slot-scope="data">
                        {{ data.item.uniqueBehaviorType }} - {{ data.item.description }}
                      </template>
                    </v-autocomplete>
                    <div class="mb-3 error--text" v-if="childSaveError">
                      {{ childSaveErrorMsg }}
                    </div>
                    <AlbatrossButton
                      :disabled="!childField.displayName || !childField.fieldToUpdate || !childField.uniqueBehaviorTypeId"
                      color="primary" class="white--text mr-2"
                      @click="validateChildField(item, childField, true)"
                      text="Add Child Field"
                    />
                  </v-form>
                </div>
                <v-data-table
                  v-if="item.childFieldConfigs && item.childFieldConfigs.length > 0"
                  :headers="childFieldHeaders"
                  :items="item.childFieldConfigs"
                  :items-per-page="-1"
                  :mobile-breakpoint="0"
                  hide-default-footer
                  single-expand
                  :expanded.sync="childFieldExpanded"
                  :class="{'mt-4': addChild}"
                  class="elevation-1"
                >

                  <template #expanded-item="{ headers, item: childField }">
                    <tr :class="{'shaded-row': item.childFieldConfigs.indexOf(childField) % 2}">
                      <td :colspan="childFieldHeaders.length">
                        <v-card flat color="transparent">
                          <v-card-title class="pb-0">Edit Child Field Config</v-card-title>
                          <v-card-text class="pt-0">
                            <div class="flex-display">
                              <v-text-field text v-model="childField.displayName"
                                            :rules="requiredRules"
                                            label="Display Name"/>
                              <AlbatrossButton
                                variant="text"
                                :disabled="!childField.displayName"
                                color="primary" class="white--text mr-2 d-inline-block"
                                @click="saveChildFieldConfig(item, childField, false)"
                                prepend-icon="save"
                              />
                            </div>
                          </v-card-text>
                        </v-card>
                      </td>
                    </tr>
                  </template>

                  <template #item="{ item: childField }">
                    <tr class="text-left" :class="{'shaded-row': item.childFieldConfigs.indexOf(childField) % 2}">
                      <td class="text-left">{{ childField.displayName }}</td>
                      <td class="text-left">{{ childField.fieldToUpdate }}</td>
                      <td class="text-left">{{ childField.dataType }}</td>
                      <td class="text-left">
                        {{ childField.uniqueBehaviorType }} <br/>
                        {{ childField.uniqueBehaviorTypeDescription }}
                      </td>
                      <td style="width: 130px;">
                        <v-tooltip left>
                          <template v-slot:activator="{ on, attrs }">
                            <AlbatrossButton
                              size="small"
                              color="primary"
                              @click="copyToClipBoard(item.id)"
                              v-bind="attrs"
                              :activation-handler="on"
                              round
                              prepend-icon="mdi-information"/>

                          </template>
                          <span>ID: {{childField.id}}</span>
                          <div class="text-center">(click to copy)</div>
                        </v-tooltip>
                        <AlbatrossButton
                          size="small"
                          variant="text"
                          color="primary"
                          v-if="!childFieldExpanded.includes(childField)"
                          @click="[addChild = false, childFieldExpanded = [childField] ]"
                          prepend-icon="edit"
                        />
                        <AlbatrossButton
                          size="small"
                          variant="text"
                          color="primary"
                          v-if="childFieldExpanded.includes(childField)"
                          @click="childFieldExpanded = []"
                          text="cancel"
                        />
                      </td>
                    </tr>
                  </template>
                </v-data-table>
              </v-card>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': dataView.dataViewFieldConfigs.indexOf(item) % 2}">
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.fieldToUpdate }}</td>
              <td class="text-right">
                <v-tooltip left>
                  <template v-slot:activator="{ on, attrs }">
                      <AlbatrossButton
                        size="small"
                        color="primary"
                        :activation-handler="on"
                        @click="copyToClipBoard(item.id)" v-bind="attrs"
                        round
                        prepend-icon="mdi-information"
                        ></AlbatrossButton>
                  </template>
                  <span>ID: {{item.id}}</span>
                  <div class="text-center">(click to copy)</div>
                </v-tooltip>

                <AlbatrossButton
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="!expanded.includes(item)"
                  @click="[addNew = false, expanded = [item], getAvailableDefaultFields(), getParentObjects(), getUniqueBehaviorTypes(), addChild = false, childField = {}]"
                  prepend-icon="edit"
                />
                <AlbatrossButton
                  size="small"
                  variant="text"
                  color="primary"
                  v-if="expanded.includes(item)"
                  @click="expanded = []"
                  text="cancel"
                />
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, postRequest, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {getCurrentInstance, onMounted, ref} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const userStore = useUserStore()
const vuetify = vueInstance.$vuetify
const router = vueInstance.$router

const showMenu = ref(false)
const childField = ref({})
const viewLoaded = ref(false)
const selectedObjectTypeId = ref(null)
const addChild = ref(false)
const childFieldHeaders = ref([
  {text: 'Field Name', value: 'displayName', show: true},
  {text: 'Field To Update', value: 'fieldToUpdate', show: true},
  {text: 'Data Type', value: 'dataType', show: true},
  {text: 'Unique Behavior Type', value: 'uniqueBehaviorType', show: true},
  {text: null, value: 'icons', show: true, sortable: false}
])
const fieldType = ref(1)
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const fieldToUpdateRule = ref([
  // () => (this.newField.fieldToUpdate != null && this.newField.fieldToUpdate !== '') || "Field to Update is required",
  v => !!v || "Field is required",
  v => (!v || (v && (v.indexOf(' ') <= 0))) || 'Cannot contain whitespace',
  v => (!v || (v && (v.indexOf('__') <= 0))) || "All word dividers must be a single '_'",
  v => (!v || (/^[a-z]+(?:_+[a-z0-9]+)*$/.test(v))) || "Field to Update must be all lowercase, no symbols except '_' and must start with a letter",
  v => (!v || (v && (v.length >= 5))) || 'Must be 5 characters or more',
  v => (!v || (v && (v.length <= 60))) || 'Must be 60 characters or less',
])
const selectedDefaultField = ref({})
const uniqueBehaviorTypes = ref([])
const expanded = ref([])
const childFieldExpanded = ref([])
const edit = ref(false)
const oldName = ref(null)
const defaultFields = ref([])
const processStepEvents = ref([])
const processSteps = ref([])
const cfgaParentObject = ref({})
const parentObjects = ref([])
const parentProcessStepEvent = ref({})
const parentProcessStepEvents = ref([])
const customFields = ref([])
const companyProcesses = ref([])
const oldCompanyProcessIds = ref([])
const oldCompanyProcesses = ref([])
const search = ref('')
const addNew = ref(false)
const childSaveError = ref(false)
const childSaveErrorMsg = ref('')
const newField = ref({})
const viewId = ref(parseInt(vueInstance.$route.params.id))
const dataView = ref({})
const userId = ref(userStore.details.id)
const companyId = ref(userStore.details.companyId)
const headers = ref([
  {text: 'Field Name', value: 'displayName', show: true},
  {text: 'Field to Update', value: 'fieldToUpdate', show: true},
  {text: null, value: 'icons', show: true, sortable: false, width: 150}
])

onMounted(async () => {
  getDataView()
  getParentObjects()
})
const copyToClipBoard = (textValue) => {
  navigator.clipboard.writeText(textValue)
  snackbar('SUCCESS', 'Copied text to clipboard')
}

const getCompanyProcesses = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/processes`)
    companyProcesses.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error loading processes')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const setObjectTypeId = (field) => {
  selectedObjectTypeId.value = field.objectTypeId
}

const saveDataView = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    dataView.value.companyProcessIds = dataView.value.companyProcesses.map(cp => cp.id)
    const {data, status} = await postRequest(`/dataView`, dataView.value)
    oldCompanyProcessIds.value = cloneDeep(dataView.value.companyProcessIds)
    oldCompanyProcesses.value = cloneDeep(dataView.value.companyProcesses)
    snackbar('SUCCESS', 'Data View Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Data View')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const resetAllFields = () => {
  //gets called when the field type changes so that all data is clean again
  selectedDefaultField.value = {}
  selectedObjectTypeId.value = null
  newField.value.customFieldGroupAssignmentId = null
  vueInstance.$set(newField.value, 'updateFirstValueOnly', false)
  vueInstance.$set(newField.value, 'resetOnNew', false)
  vueInstance.$set(newField.value, 'resetValuesOnMain', false)
  vueInstance.$set(newField,value, 'ignoreIfNull', false)
  cfgaParentObject.value = {}
  newField.value.processStepEventId = null
  newField.value.processStepId = null
}
const validateFields = (field, isNew) => {
  let valid = vueInstance.$refs.fieldConfigForm?.validate()

  //if they had set one of these as true but then changed the field type to a different type then reset the values here
  if (![4, 6].includes(selectedObjectTypeId.value)) {
    newField.value.updateFirstValueOnly = false
    newField.value.resetOnNew = false
    newField.value.resetValuesOnMain = false
  }

  if (valid) {
    saveFieldConfig(field, isNew)
  }
}
const validateChildField = (item, newChildField, isNew) => {
  childSaveError.value = false
  let match = item?.childFieldConfigs.find(cfc => cfc.fieldToUpdate === newChildField.fieldToUpdate)

  if (match) {
    childSaveError.value = true
    childSaveErrorMsg.value = 'Field to Update already in use'
  } else if (newChildField.fieldToUpdate === item.fieldToUpdate) {
    childSaveError.value = true
    childSaveErrorMsg.value = 'Field to Update already in use by parent'
  } else if (vueInstance.$refs.childFieldForm?.validate()) {
    saveChildFieldConfig(item, newChildField, isNew)
  }
}
const getUniqueBehaviorTypes = async () => {
  if (uniqueBehaviorTypes.value.length === 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/dataView/getUniqueBehaviorTypes`)
      uniqueBehaviorTypes.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Unique Behavior Types')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const loadProcessStepEvents = async () => {
  //only load this data if the parent was a process step
  if (cfgaParentObject.value?.isProcessStep) {
    parentProcessStepEvent.value = {}
    parentProcessStepEvents.value = []
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/processStep/${cfgaParentObject.value?.id}/event`)
      parentProcessStepEvents.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const loadFieldsByParent = async (isEvent) => {
  newField.value.customFieldGroupAssignmentId = null
  customFields.value = []
  store.commit(AppMutations.SET_LOADING, true)
  try {
    if (isEvent) {
      const {
        data,
        status
      } = await getRequest(`/customField/getByProcessStepEvent/${parentProcessStepEvent.value?.id}`)
      customFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } else if (cfgaParentObject.value?.isProcessStep) {
      const {data, status} = await getRequest(`/customField/getByParentProcessStep/${cfgaParentObject.value?.id}`)
      customFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } else {
      const {data, status} = await getRequest(`/customField/getByParentType/${cfgaParentObject.value?.id}`)
      customFields.value = data
      handleHidingGlobalLoader(vueInstance, status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getParentObjects = async () => {
  newField.value.customFieldGroupAssignmentId = null
  cfgaParentObject.value = {}
  customFields.value = []
  parentObjects.value = []
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`)
    parentObjects.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Details')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getProcessStepEventData = async () => {
  newField.value.processStepEventId = null
  newField.value.processStepId = null
  processStepEvents.value = []
  if (selectedDefaultField.value?.objectTypeId === 6) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {
        data,
        status
      } = await getRequest(`/dataView/${viewId.value}/defaultFieldPsEvents/${selectedDefaultField.value.id}`)
      processStepEvents.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Details')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}

const getProcessStepData = async () => {
  newField.value.processStepId = null
  processSteps.value = []
  if (selectedDefaultField.value?.objectTypeId === 4) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {
        data,
        status
      } = await getRequest(`/dataView/${viewId.value}/defaultFieldPs/${selectedDefaultField.value.id}`)
      processSteps.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Details')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const getAvailableDefaultFields = async () =>{
  selectedDefaultField.value = {}
  defaultFields.value = []
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/dataView/${viewId.value}/getAvailableDefaultFields`)
    defaultFields.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Details')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const fixData = () => {
  dataView.value.companyProcesses = cloneDeep(oldCompanyProcesses.value)
  dataView.value.companyProcessIds = cloneDeep(oldCompanyProcessIds.value)
  resetAllFields()
}

const getDataView = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/dataView/${viewId.value}`)
    dataView.value = data
    oldCompanyProcessIds.value = cloneDeep(data?.companyProcessIds)
    oldCompanyProcesses.value = cloneDeep(data?.companyProcesses)
    viewLoaded.value = true
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Details')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveFieldConfig = async (field, isNew) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    //we have to use the whole object for selectedDefaultField because we need to use the data type in some other checks
    field.defaultFieldId = selectedDefaultField.value.id

    //if it was a cfga id for a pse we need to add this here
    if (parentProcessStepEvent.value && parentProcessStepEvent.value.id) {
      field.processStepEventId = parentProcessStepEvent.value.id
    }
    //if it was a cfga for a ps add it here
    if(cfgaParentObject.value?.id) {
      field.processStepId = cfgaParentObject.value?.id
    }

    const {data, status} = await postRequest(`/dataView/${viewId.value}/field`, field)
    if (isNew) {
      dataView.value.dataViewFieldConfigs.push(data)
      addNew.value = false
      selectedDefaultField.value = {}
      newField.value = {processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null}
      defaultFields.value = []
      snackbar('SUCCESS', 'New Field Config Added')
    } else {
      snackbar('SUCCESS', 'Data View Updated')
    }
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = null != e.data?.message ? e.data?.message : isNew ? 'Error Adding Field' : 'Error Updating Field'
    snackbar('ERROR', msg)
    store.commit(AppMutations.SET_LOADING, false)
  }
}

const saveChildFieldConfig = async (primaryField, childField, isNew) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {
      data,
      status
    } = await postRequest(`/dataView/${viewId.value}/field/${primaryField.id}/childField`, childField)
    if(isNew) {
      primaryField.childFieldConfigs.push(data)
    }
    addChild.value = false
    childField.value = {}
    childFieldExpanded.value = []
    snackbar('SUCCESS', 'Child Field Config Saved')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = null != e.data?.message ? e.data?.message : 'Error Saving Field'
    snackbar('ERROR', msg)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
</script>

<style lang="scss">
#data-view-container .v-data-table__wrapper {
  max-height: calc(100vh - 350px);
  min-height: 90px;
}
</style>

<style lang="scss" scoped>
.display-name-field {
  width: 90%;
}

.search-header {
  width: 100%;
  display: flex;
  align-items: center;
}

.page-title {
  font-size: 18px;
  font-weight: 200;
}
</style>
