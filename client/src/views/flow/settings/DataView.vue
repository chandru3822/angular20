<template>
  <v-container id="data-view-container" v-if="viewLoaded">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-btn text class="pl-1 pr-2" :to="'/settings/dataViews'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <div class="flex-display pt-3 px-3 mb-4 one-hunned">
          <div class="one-hunned pl-3">
            <span class="page-title" v-if="!edit">{{ dataView.displayName }}</span>
            <v-text-field v-else color="primaryCustom"
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
            <v-btn text v-if="!edit" class=""
                   @click="[oldName = dataView.displayName, edit = !edit, getCompanyProcesses()]">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text class="" v-else :disabled="dataView.companyProcesses.length === 0"
                   @click="[edit = false, saveDataView()]">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn text v-if="edit" class="" @click="[dataView.displayName = oldName, edit = !edit, fixData()]">
              cancel
            </v-btn>
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
          <v-btn text class="d-inline-block" v-if="!addNew"
                 @click="[addNew = !addNew, newField = { processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null }, getAvailableDefaultFields(), getParentObjects()]">
            <v-icon v-if="constants.IS_MOBILE">add</v-icon>
            <span v-else>{{ addNew ? 'Cancel' : 'Add New Field' }}</span>
          </v-btn>
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
                  :disabled="newField.resetOnNew"
                  v-model="newField.updateFirstValueOnly"
                />
                <br/>
                <span
                  class="mr-3">Reset on New {{ selectedObjectTypeId === 4 ? 'Main Process Step?' : 'Event?' }}</span>
                <input
                  :disabled="newField.updateFirstValueOnly"
                  type="checkbox"
                  v-model="newField.resetOnNew"
                />
              </div>
            </v-form>
            <v-btn :disabled="!newField.displayName || !newField.fieldToUpdate || (!selectedDefaultField.id && !newField.customFieldGroupAssignmentId)
                              || (selectedDefaultField.objectTypeId === 6 && !newField.processStepEventId) || (selectedDefaultField.objectTypeId === 4 && !newField.processStepId)"
                   color="primaryCustom" class="white--text mr-2"
                   @click="validateFields(newField, true)">
              Save
            </v-btn>
            <v-btn
              @click="[addNew = !addNew, newField = { processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null}, selectedDefaultField = {}]">
              Cancel
            </v-btn>
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
                <v-btn text :disabled="!item.displayName"
                       color="primaryCustom" class="white--text mr-2 d-inline-block"
                       @click="saveFieldConfig(item, false)">
                  <v-icon>save</v-icon>
                </v-btn>
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
                  class="mr-3 disabled-label">Reset on New {{
                    item.objectTypeId === 4 ? 'Main Process Step?' : 'Event?'
                  }}</span>
                <input
                  disabled readonly
                  type="checkbox"
                  v-model="item.resetOnNew"
                />
              </div>

              <v-card color="transparent" flat>
                <v-toolbar color="transparent" class="elevation-0">
                  <v-toolbar-title>Child Fields</v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-toolbar-items>
                    <v-btn text @click="[addChild = !addChild, childField = {}]">
                      <v-icon>add</v-icon>
                    </v-btn>
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
                    <v-btn
                      :disabled="!childField.fieldToUpdate || !childField.uniqueBehaviorTypeId"
                      color="primaryCustom" class="white--text mr-2"
                      @click="validateChildField(item, childField, true)">
                      Add Child Field
                    </v-btn>
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
                              <v-btn text :disabled="!childField.displayName"
                                     color="primaryCustom" class="white--text mr-2 d-inline-block"
                                     @click="saveChildFieldConfig(item, childField, false)">
                                <v-icon>save</v-icon>
                              </v-btn>
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
                      <td>
                        <v-btn small text v-if="!childFieldExpanded.includes(childField)"
                               @click="[addChild = false, childFieldExpanded = [childField] ]">
                          <v-icon>edit</v-icon>
                        </v-btn>
                        <v-btn small text v-if="childFieldExpanded.includes(childField)" @click="childFieldExpanded = []">cancel</v-btn>

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
              <td>
                <v-btn small text v-if="!expanded.includes(item)"
                       @click="[addNew = false, expanded = [item], getAvailableDefaultFields(), getParentObjects(), getUniqueBehaviorTypes(), addChild = false, childField = {}]">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>

              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import cloneDeep from 'lodash.clonedeep'

export default {
  name: 'DataView',

  data() {
    return {
      snackbar: {},
      childField: {},
      viewLoaded: false,
      selectedObjectTypeId: null,
      addChild: false,
      childFieldHeaders: [
        {text: 'Field Name', value: 'displayName', show: true},
        {text: 'Field To Update', value: 'fieldToUpdate', show: true},
        {text: 'Data Type', value: 'dataType', show: true},
        {text: 'Unique Behavior Type', value: 'uniqueBehaviorType', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ],
      fieldType: 1,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      fieldToUpdateRule: [
        // () => (this.newField.fieldToUpdate != null && this.newField.fieldToUpdate !== '') || "Field to Update is required",
        v => !!v || "Field is required",
        v => (!v || (v && (v.indexOf(' ') <= 0))) || 'Cannot contain whitespace',
        v => (!v || (v && (v.indexOf('__') <= 0))) || "All word dividers must be a single '_'",
        v => (!v || (/^[a-z]+(?:_+[a-z]+)*$/.test(v))) || "Field to Update must be all lowercase, no symbols except '_' and must start and end with a letter",
        v => (!v || (v && (v.length >= 5))) || 'Must be 5 characters or more',
        v => (!v || (v && (v.length <= 60))) || 'Must be 60 characters or less',
      ],
      selectedDefaultField: {},
      uniqueBehaviorTypes: [],
      dataTypes: [],
      expanded: [],
      childFieldExpanded: [],
      edit: false,
      oldName: null,
      defaultFields: [],
      processStepEvents: [],
      processSteps: [],
      cfgaParentObject: {},
      parentObjects: [],
      parentProcessStepEvent: {},
      parentProcessStepEvents: [],
      customFields: [],
      companyProcesses: [],
      oldCompanyProcessIds: [],
      oldCompanyProcesses: [],
      constants,
      search: '',
      addNew: false,
      childSaveError: false,
      childSaveErrorMsg: '',
      newField: {},
      viewId: parseInt(this.$route.params.id),
      dataView: {},
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      headers: [
        {text: 'Field Name', value: 'displayName', show: true},
        {text: 'Field to Update', value: 'fieldToUpdate', show: true},
        {text: null, value: 'icons', show: true, sortable: false}
      ]
    }
  },
  async created() {
    this.getDataView()
    this.getParentObjects()
  },
  methods: {
    async getCompanyProcesses() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/processes`)
        this.companyProcesses = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error loading processes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    setObjectTypeId(field) {
      this.selectedObjectTypeId = field.objectTypeId
    },
    async saveDataView() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.dataView.companyProcessIds = this.dataView.companyProcesses.map(cp => cp.id)
        const {data, status} = await postRequest(`/dataView`, this.dataView)
        this.oldCompanyProcessIds = cloneDeep(this.dataView.companyProcessIds)
        this.oldCompanyProcesses = cloneDeep(this.dataView.companyProcesses)
        this.snackbar = getSnackbar('SUCCESS', 'Data View Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Data View')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    resetAllFields() {
      //gets called when the field type changes so that all data is clean again
      this.selectedDefaultField = {}
      this.selectedObjectTypeId = null
      this.newField.customFieldGroupAssignmentId = null
      this.$set(this.newField, 'updateFirstValueOnly', false)
      this.$set(this.newField, 'resetOnNew', false)
      this.cfgaParentObject = {}
      this.newField.processStepEventId = null
      this.newField.processStepId = null
    },
    validateFields(field, isNew) {
      let valid = this.$refs.fieldConfigForm?.validate()

      //if they had set one of these as true but then changed the field type to a different type then reset the values here
      if (![4, 6].includes(this.selectedObjectTypeId)) {
        this.newField.updateFirstValueOnly = false
        this.newField.resetOnNew = false
      }

      if (valid) {
        this.saveFieldConfig(field, isNew)
      }
    },
    validateChildField(item, newChildField, isNew) {
      this.childSaveError = false
      let match = item?.childFieldConfigs.find(cfc => cfc.fieldToUpdate === newChildField.fieldToUpdate)


      if (match) {
        this.childSaveError = true
        this.childSaveErrorMsg = 'Field to Update already in use'
      } else if (newChildField.fieldToUpdate === item.fieldToUpdate) {
        this.childSaveError = true
        this.childSaveErrorMsg = 'Field to Update already in use by parent'
      } else if (this.$refs.childFieldForm?.validate()) {
        this.saveChildFieldConfig(item, newChildField, isNew)
      }
    },
    async validateForm() {
      if (this.$refs.projectEditForm.validate()) {
        //these could be combined - just dont have time atm
        this.saveProjectAddressFields()
        this.updateOwner()
        //have to wait for this one to complete or it doesn't have the right values to display fresh ones
        await this.updateStatus()
        //set project values if they hit save
        this.project = cloneDeep(this.tempProject)
        this.showEditProjectModal = false
      }
    },
    async getUniqueBehaviorTypes() {
      if (this.uniqueBehaviorTypes.length === 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dataView/getUniqueBehaviorTypes`)
          this.uniqueBehaviorTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Unique Behavior Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async loadProcessStepEvents() {
      //only load this data if the parent was a process step
      if (this.cfgaParentObject?.isProcessStep) {
        this.parentProcessStepEvent = {}
        this.parentProcessStepEvents = []
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/processStep/${this.cfgaParentObject?.id}/event`)
          this.parentProcessStepEvents = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async loadFieldsByParent(isEvent) {
      this.newField.customFieldGroupAssignmentId = null
      this.customFields = []
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (isEvent) {
          const {
            data,
            status
          } = await getRequest(`/customField/getByProcessStepEvent/${this.parentProcessStepEvent?.id}`)
          this.customFields = data
          handleHidingGlobalLoader(this, status)
        } else if (this.cfgaParentObject?.isProcessStep) {
          const {data, status} = await getRequest(`/customField/getByParentProcessStep/${this.cfgaParentObject?.id}`)
          this.customFields = data
          handleHidingGlobalLoader(this, status)
        } else {
          const {data, status} = await getRequest(`/customField/getByParentType/${this.cfgaParentObject?.id}`)
          this.customFields = data
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getParentObjects() {
      this.newField.customFieldGroupAssignmentId = null
      this.cfgaParentObject = {}
      this.customFields = []
      this.parentObjects = []
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`)
        this.parentObjects = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProcessStepEventData() {
      this.newField.processStepEventId = null
      this.newField.processStepId = null
      this.processStepEvents = []
      if (this.selectedDefaultField?.objectTypeId === 6) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {
            data,
            status
          } = await getRequest(`/dataView/${this.viewId}/defaultFieldPsEvents/${this.selectedDefaultField.id}`)
          this.processStepEvents = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getProcessStepData() {
      this.newField.processStepId = null
      this.processSteps = []
      if (this.selectedDefaultField?.objectTypeId === 4) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {
            data,
            status
          } = await getRequest(`/dataView/${this.viewId}/defaultFieldPs/${this.selectedDefaultField.id}`)
          this.processSteps = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    async getAvailableDefaultFields() {
      this.selectedDefaultField = {}
      this.defaultFields = []
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/dataView/${this.viewId}/getAvailableDefaultFields`)
        this.defaultFields = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    fixData() {
      this.dataView.companyProcesses = cloneDeep(this.oldCompanyProcesses)
      this.dataView.companyProcessIds = cloneDeep(this.oldCompanyProcessIds)
    },
    async getDataView() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/dataView/${this.viewId}`)
        this.dataView = data
        this.oldCompanyProcessIds = cloneDeep(data?.companyProcessIds)
        this.oldCompanyProcesses = cloneDeep(data?.companyProcesses)
        this.viewLoaded = true
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Loading Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldConfig(field, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //we have to use the whole object for selectedDefaultField because we need to use the data type in some other checks
        field.defaultFieldId = this.selectedDefaultField.id

        //if it was a cfga id for a pse we need to add this here
        if (this.parentProcessStepEvent && this.parentProcessStepEvent.id) {
          field.processStepEventId = this.parentProcessStepEvent.id
        }
        //if it was a cfga for a ps add it here
        if(this.cfgaParentObject?.id) {
          field.processStepId = this.cfgaParentObject?.id
        }

        const {data, status} = await postRequest(`/dataView/${this.viewId}/field`, field)
        if (isNew) {
          this.dataView.dataViewFieldConfigs.push(data)
          this.addNew = false
          this.selectedDefaultField = {}
          this.newField = {processStepEventId: null, processStepId: null, customFieldGroupAssignmentId: null}
          this.defaultFields = []
          this.snackbar = getSnackbar('SUCCESS', 'New Field Config Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.snackbar = getSnackbar('SUCCESS', 'Data View Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = null != e.data?.message ? e.data?.message : isNew ? 'Error Adding Field' : 'Error Updating Field'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveChildFieldConfig(primaryField, childField, isNew) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await postRequest(`/dataView/${this.viewId}/field/${primaryField.id}/childField`, childField)
        if(isNew) {
          primaryField.childFieldConfigs.push(data)
        }
        this.addChild = false
        this.childField = {}
        this.childFieldExpanded = []
        this.snackbar = getSnackbar('SUCCESS', 'Child Field Config Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let msg = null != e.data?.message ? e.data?.message : 'Error Saving Field'
        this.snackbar = getSnackbar('ERROR', msg)
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
