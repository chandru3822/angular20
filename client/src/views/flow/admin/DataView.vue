<template>
  <v-container id="data-view-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{ dataView.displayName }} ({{ dataView.viewName }})
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newField = { processStepEventId: null, customFieldGroupAssignmentId: null }, getAvailableDefaultFields(), getParentObjects()]">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add Field Config</h3>
          <div class="mb-3">
            <v-form ref="fieldConfigForm">
              <v-text-field text v-model="newField.displayName"
                            label="Display Name"/>
              <v-text-field text v-model="newField.fieldToUpdate"
                            hint="5-60 lowercase characters, no spaces, no symbols"
                            persistent-hint
                            label="Field to Update"/>
              <v-radio-group v-model="fieldType" @change="resetAllFields()">
                <v-radio label="Default Field" :value="1"></v-radio>
                <v-radio label="Custom Field" :value="2"></v-radio>
              </v-radio-group>

              <v-autocomplete
                v-if="fieldType === 1"
                v-model="selectedDefaultField"
                :items="defaultFields"
                label="Default Field"
                attach
                @change="getProcessStepEventData"
                item-text="fieldName"
                return-object></v-autocomplete>
              <v-autocomplete
                v-if="selectedDefaultField && selectedDefaultField.objectTypeId === 6"
                v-model="newField.processStepEventId"
                :items="processStepEvents"
                label="Process Step Event"
                attach
                item-text="eventName"
                item-value="id"></v-autocomplete>
              <v-autocomplete v-if="fieldType === 2"
                              v-model="cfgaParentObject"
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
              <v-autocomplete v-if="cfgaParentObject && cfgaParentObject.id"
                              v-model="newField.customFieldGroupAssignmentId"
                              :items="customFields"
                              label="Custom Field"
                              item-text="fieldName"
                              item-value="id"
                              autocomplete="off">
                <template slot='item' slot-scope='{ item }'>
                  {{ item.fieldName }}
                </template>
              </v-autocomplete>

              <div>
                <span class="mr-3">Update First Value Only?</span>
                <input
                  type="checkbox"
                  v-model="newField.updateFirstValueOnly"
                />
              </div>
            </v-form>
            <div v-if="saveError" class="error--text">
              {{saveErrorMsg}}
            </div>
            <v-btn :disabled="!newField.displayName || !newField.fieldToUpdate || (!selectedDefaultField.id && !newField.customFieldGroupAssignmentId)
                              || (selectedDefaultField.objectTypeId === 6 && !newField.processStepEventId)"
                   color="primaryCustom" class="white--text mr-2"
                   @click="validateFields(newField, true)">
              Save
            </v-btn>
            <v-btn @click="[addNew = !addNew, newField = { processStepEventId: null, customFieldGroupAssignmentId: null}, selectedDefaultField = {}]">
              Cancel
            </v-btn>
          </div>

        </v-card>
        <v-text-field
          v-model="search"
          class="mb-2 px-4 py-2"
          prepend-inner-icon="search"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-divider></v-divider>
        <v-data-table
          v-if="dataView.dataViewFieldConfigs"
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
              <v-text-field text v-model="item.displayName"
                            label="Display Name"/>
              <v-text-field text v-model="item.fieldToUpdate" disabled readonly
                            label="Field to Update"/>
              <v-autocomplete
                v-model="item.defaultFieldId"
                disabled readonly
                :items="defaultFields"
                label="Default Field"
                attach
                item-text="fieldName"></v-autocomplete>
              <v-autocomplete
                v-if="item.objectTypeId === 6"
                disabled readonly
                v-model="item.processStepEventId"
                :items="processStepEvents"
                label="Process Step Event"
                attach
                item-text="eventName"></v-autocomplete>
              <v-autocomplete v-model="item.cfgaParentObjectId"
                              :items="parentObjects"
                              disabled readonly
                              label="Parent Object"
                              item-text="name"
                              autocomplete="off"
              >
                <template slot='item' slot-scope='{ item }'>
                  {{ item.name }}
                </template>
              </v-autocomplete>
              <v-autocomplete v-model="item.customFieldGroupAssignmentId"
                              :items="customFields"
                              label="Custom Field"
                              disabled readonly
                              item-text="fieldName"
                              autocomplete="off">
                <template slot='item' slot-scope='{ item }'>
                  {{ item.fieldName }}
                </template>
              </v-autocomplete>

              <div>
                <span class="mr-3">Update First Value Only?</span>
                <input
                  type="checkbox"
                  disabled readonly
                  v-model="item.updateFirstValueOnly"
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
                  <v-text-field text v-model="childField.fieldToUpdate"
                                label="Child Field to Update"/>
                  <v-autocomplete
                    v-model="childField.dataTypeId"
                    :items="dataTypes"
                    label="Data Type"
                    attach
                    item-value="id"
                    item-text="dataType"></v-autocomplete>
                  <v-autocomplete
                    v-model="childField.uniqueBehaviorTypeId"
                    :items="uniqueBehaviorTypes"
                    label="Unique Behavior Types"
                    attach
                    item-value="id"
                    item-text="uniqueBehaviorType"></v-autocomplete>
                  <v-btn :disabled="!childField.fieldToUpdate"
                         color="primaryCustom" class="white--text mr-2"
                         @click="saveChildFieldConfig(item, childField, true)">
                    Save New Child
                  </v-btn>
                </div>
                <div v-for="cf in item.childFieldConfigs">
                  {{ cf.fieldToUpdate }}
                </div>
              </v-card>

              <v-btn :disabled="!item.displayName"
                     color="primaryCustom" class="white--text mr-2"
                     @click="saveFieldConfig(item, false)">
                Save Primary
              </v-btn>
            </td>
          </template>

          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': dataView.dataViewFieldConfigs.indexOf(item) % 2}">
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.fieldToUpdate }}</td>
              <td>
                <v-btn small text v-if="!expanded.includes(item)"
                       @click="[addNew = false, expanded = [item], getAvailableDefaultFields(), getParentObjects(), getDataTypes(), getUniqueBehaviorTypes()]">
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

export default {
  name: 'DataView',

  data() {
    return {
      snackbar: {},
      childField: {},
      addChild: false,
      saveError: false,
      fieldType: 1,
      saveErrorMsg: '',
      selectedDefaultField: {},
      uniqueBehaviorTypes: [],
      dataTypes: [],
      expanded: [],
      defaultFields: [],
      processStepEvents: [],
      cfgaParentObject: {},
      parentObjects: [],
      customFields: [],
      constants,
      search: '',
      addNew: false,
      newField: {},
      viewId: parseInt(this.$route.params.id),
      dataView: {},
      userId: this.$store.state.user.details.id,
      companyId: this.$store.state.user.details.companyId,
      headers: [
        {text: 'Field Name', value: 'fieldName', show: true},
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
    resetAllFields() {
      //gets called when the field type changes so that all data is clean again
      this.selectedDefaultField = {}
      this.cfgaParentObject = {}
      this.newField.customFieldGroupAssignmentId = null
      this.newField.processStepEventId = null
    },
    validateFields(field, isNew) {
      this.saveError = false
      let valid = this.$refs.fieldConfigForm?.validate()
      let regex = /^[^a-z]*$/

      console.log('randaLogger',regex.test(field.fieldToUpdate))

      if(field.fieldToUpdate.indexOf(' ') >= 0) {
        this.saveError = true
        this.saveErrorMsg = 'Field to Update cannot contain whitespace'
      } else if(!regex.test(field.fieldToUpdate)) {
        this.saveError = true
        this.saveErrorMsg = 'Field to Update must be all lowercase characters'
      } else if(field.fieldToUpdate.length < 5 || field.fieldToUpdate.length > 60) {
        this.saveError = true
        this.saveErrorMsg = 'Field to Update must be 5-60 characters'
      } else if (valid) {
        this.saveFieldConfig(field, isNew)
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
    async getDataTypes() {
      if (this.dataTypes.length === 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dataType/getSystem`)
          this.dataTypes = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Data Types')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
    async loadFieldsByParent() {
      this.newField.customFieldGroupAssignmentId = null
      this.customFields = []
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.cfgaParentObject.isProcessStep) {
          const {data, status} = await getRequest(`/customField/getByParentProcessStep/${this.cfgaParentObject.id}`)
          this.customFields = data
          handleHidingGlobalLoader(this, status)
        } else {
          const {data, status} = await getRequest(`/customField/getByParentType/${this.cfgaParentObject.id}`)
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
      this.processStepEvents = []
      if (this.selectedDefaultField.objectTypeId === 6) {
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
    async getDataView() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/dataView/${this.viewId}`)
        this.dataView = data
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

        const {data, status} = await postRequest(`/dataView/${this.viewId}/field`, field)
        if (isNew) {
          this.dataView.dataViewFieldConfigs.push(data)
          this.addNew = false
          this.newField = {processStepEventId: null, customFieldGroupAssignmentId: null}
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
        this.snackbar = getSnackbar('ERROR', isNew ? 'Error Adding Field' : 'Error Updating Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveChildFieldConfig(primaryField, childField) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {
          data,
          status
        } = await postRequest(`/dataView/${this.viewId}/field/${primaryField.id}/childField`, childField)
        primaryField.childFieldConfigs.push(data)
        this.addChild = false
        this.childField = {}
        this.snackbar = getSnackbar('SUCCESS', 'New Child Field Config Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style lang="scss">
#data-view-container .v-data-table__wrapper {
  max-height: calc(100vh - 300px);
  min-height: 300px;
}
</style>
