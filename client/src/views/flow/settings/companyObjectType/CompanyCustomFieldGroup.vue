<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="shrink pt-0">
        <router-link :to="`/settings/companyObjectTypes`">Back</router-link>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">
            {{ objectType.objectType }} - Custom Field Groups
          </v-toolbar-title>
          <v-spacer />
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newGroup = {}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{ addNew ? 'Cancel' : 'Add New' }}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card flat class="mb-4">
            Note: Some company specific screens ignore the display order and group name of Custom Fields Groups
            represented here.
          </v-card>
          <v-text-field v-if="addNew"
                        v-model="newGroup.groupName"
                        placeholder="Enter new group name"
                        append-outer-icon="save"
                        @click:append-outer="addCustomFieldGroup"
                        label="Custom Field Group" />

          <v-data-table
            :headers="headers"
            :items="filterCustomFieldGroups()"
            :items-per-page="-1"
            single-expand
            :sort-by="['groupOrder']"
            :sort-desc="[false]"
            :expanded.sync="expanded"
            hide-default-footer
            hide-default-header
            class="elevation-1 fix-column-width-bug mb-5"
          >
            <template #no-data>
              No available field groups
            </template>

            <template #no-results>
              No available field groups
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': customFieldGroups.indexOf(item) % 2}">
                <td style="width: 50px">
                  <v-btn text icon small class="handle" v-if="userCanEdit">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">
                  <v-text-field text
                                v-if="item.edit"
                                v-model="item.groupName">
                  </v-text-field>
                  <span v-else>{{ item.groupName }}</span>
                </td>
                <td>
                  <div class="item-icons">
                    <div v-if="userCanEdit" class="flex-display">
                      <v-btn small text color="primary"
                             @click="item.edit = !item.edit">
                        <v-icon v-if="item.edit">remove</v-icon>
                        <v-icon v-else>edit</v-icon>
                      </v-btn>
                      <v-btn small text color="primary"
                             v-if="item.edit"
                             @click="[saveGroup(item), item.edit = false]">
                        <v-icon>save</v-icon>
                      </v-btn>
                    </div>
                    <v-btn small text color="primary"
                           v-if="userCanAdd"
                           @click="[addField = !addField, fetchAvailableCustomFields(item.id), expanded = [item], selectedIndex = index]">
                      <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                      <v-icon v-else>add</v-icon>
                    </v-btn>
                    <v-btn small text color="primary"
                           @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                      <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                      <v-icon v-else>expand_more</v-icon>
                    </v-btn>
                    <confirm-delete-dialog
                      v-if="userCanEdit"
                      label="this Custom Field Group: "
                      :item-to-delete="item.groupName"
                      @confirm-delete="deleteGroup(item)"
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
                             value="native" />
                    <v-radio label="Reference Field: viewed only from other process steps or objects"
                             value="ancillary" />
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
                    <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                            :key="index" class="pa-0" :class="{ 'shaded-row': selectedIndex % 2 }">
                      <v-list-item class="grab pr-1">
                        <v-list-item-action v-if="userCanEdit">
                          <v-icon>drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                            {{ cf.fieldName }}
                          </div>
                          <div v-else>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{ cf.fieldName }}
                            (Ancillary)<br />
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

                          <div>
                            <label>
                              <input type="checkbox" v-model="cf.hasConditionalOnId"
                                     :disabled="!userCanEdit" @change="saveConditionalField(cf)" />
                              Conditional On
                            </label>
                            <v-select v-model="cf.conditionalOnId"
                                      v-if="cf.hasConditionalOnId"
                                      :items="filterAvailableCustomFields(cf, item)"
                                      item-value="customFieldGroupAssignmentId"
                                      item-text="fieldName"
                                      placeholder="Choose a field"
                                      @change="saveConditionalField(cf)"
                            />
                          </div>

                          <div class="flex-display"
                               v-if="objectType.allowMinMax && [4,6].includes(cf.dataTypeId) && !cf.hasListValues">
                            <v-text-field text
                                          type="number"
                                          label="Minimum Value"
                                          @change="changedMinMax(cf)"
                                          :disabled="!userCanEdit"
                                          v-model.number="cf.minValue" />
                            <v-spacer />
                            <v-text-field text
                                          type="number"
                                          label="Maximum Value"
                                          @change="changedMinMax(cf)"
                                          :disabled="!userCanEdit"
                                          v-model.number="cf.maxValue" />
                            <v-btn text color="primaryCustom" @click="saveMinMax(cf)"
                                   :disabled="!cf.minMaxValueChanged">
                              <v-icon>save</v-icon>
                            </v-btn>
                          </div>
                        </v-list-item-content>
                        <confirm-delete-dialog
                          v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                          :label="`this field from ${item.groupName}: `"
                          :item-to-delete="cf.fieldName"
                          @confirm-delete="deleteFieldFromGroup(cf)"
                          :button-class="{'remove-padding':true}"
                        >
                          <span class="error--text">WARNING:</span>
                          By deleting a field you will lose all data associated with the field.<br /><br />
                        </confirm-delete-dialog>
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
  </v-container>
</template>

<script>
import { AppMutations } from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'

import {
  deleteRequest,
  getRequest,
  getRequestWithParams,
  getSnackbar,
  handleHidingGlobalLoader,
  postRequest,
  putRequest
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmDeleteDialog from '@/ConfirmDeleteDialog'

export default {
  name: 'CompanyCustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmDeleteDialog,
    draggable
  },
  data() {
    return {
      snackbar: {},
      constants,
      addNew: false,
      objectType: {},
      newFieldType: 'native',
      deleteError: false,
      deleteHeader: null,
      deleteText: null,
      fieldsInUse: [],
      minMaxValueChanged: false,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      selectedIndex: null,
      fieldOrderChanged: false,
      groupOrderChanged: false,
      newGroup: {
        groupName: null
      },
      addField: false,
      newField: {},
      customFieldGroups: [],
      availableCustomFields: [],
      companyId: this.$store.state.user.details.companyId,
      //if you set this to a value it doesn't update when the route param changes
      // objectTypeId: this.$route.params.id
      headers: [
        { text: null, value: 'draggable', width: '50px', show: true },
        { text: 'Name', value: 'groupName', show: true },
        { text: null, value: 'icons', show: true }
      ],
      expanded: [],
      parent: {},
      parentObjects: [],
      selectedAncillaryField: {},
      ancillaryCustomFields: []
    }
  },
  mounted() {
    let table = document.querySelector('tbody')
    const _self = this
    Sortable.create(table, {
      handle: '.handle',
      onEnd({ newIndex, oldIndex }) {
        const rowSelected = _self.customFieldGroups.splice(oldIndex, 1)[0]
        _self.customFieldGroups.splice(newIndex, 0, rowSelected)
        let fieldGroupsClone = cloneDeep(_self.customFieldGroups)
        fieldGroupsClone.forEach((g, idx) => {
          g.groupOrder = idx
        })
        _self.saveGroupChanges(fieldGroupsClone)
      }
    })
  },
  created() {
    this.getObjectType()
    this.getCustomFieldGroups()
  },
  methods: {
    changedMinMax(cf) {
      this.$set(cf, 'minMaxValueChanged', true)
    },
    async getObjectType() {
      //we have to get the object type details to determine if it can use ancillary fields
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequest(`/objectType/getByType/${this.$route.params.id}`, 'blueraven')
        this.objectType = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
          params: {
            companyObjectTypeId: this.$route.params.id
          }
        }, 'blueraven')
        this.customFieldGroups = cloneDeep(data.map(d => {
          d.customFields.forEach(cf => cf.hasConditionalOnId = !!cf.conditionalOnId)
          return d
        }))
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields(groupId) {
      try {
        if (this.addField && this.newFieldType === 'native') {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const { data, status } = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
            params: {
              objectTypeId: parseInt(this.$route.params.id),
              groupId
            }
          }, 'blueraven')
          this.availableCustomFields = data
          handleHidingGlobalLoader(this, status)
        } else if (this.addField && this.newFieldType === 'ancillary') {
          this.$store.commit(AppMutations.SET_LOADING, true)
          this.availableCustomFields = []
          const {
            data,
            status
          } = await getRequest(`/objectType/${this.$route.params.id}/getParentObjectsWithTypes`, 'blueraven')
          this.selectedAncillaryField = {}
          this.parentObjects = data
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async updateRequired(cf) {
      try {
        const field = {
          customFieldGroupAssignmentId: cf.customFieldGroupAssignmentId,
          required: cf.required || false
        }
        const { status } = await putRequest(`/customFieldGroup/updateRequired`, field, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Updated Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveMinMax(cf) {
      try {
        const { status } = await putRequest(`/customFieldGroup/saveMinMax`, cf, 'blueraven')
        cf.minMaxValueChanged = false
        this.snackbar = getSnackbar('SUCCESS', 'Updated Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveConditionalField(cf) {
      try {
        if (cf.hasConditionalOnId && !cf.conditionalOnId){
          return
        }

        if (!cf.hasConditionalOnId){
          // if this has been cleared out make sure to unset it
          cf.conditionalOnId = undefined
        }

        const { status } =  await putRequest(`/customFieldGroup/updateConditionalId`, cf, 'blueraven')
        const snackbar = getSnackbar('SUCCESS', 'Updated Field')
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        const snackbar = getSnackbar('ERROR', 'Error Saving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addCustomFieldGroup() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.objectTypeId = parseInt(this.$route.params.id)
        const { data, status } = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup, 'blueraven')
        this.newGroup = {}
        this.addNew = false
        // add the new type to the list
        this.customFieldGroups.push(data)
        this.snackbar = getSnackbar('SUCCESS', 'Group Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Custom Field Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignCustomField(cfg, isAncillary) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addField = false
        this.newField.customFieldGroupId = cfg.id
        let params = !isAncillary ? this.newField : {
          customFieldGroupId: cfg.id,
          id: null,
          ancillaryCustomFieldGroupAssignmentId: this.selectedAncillaryField.customFieldGroupAssignmentId,
          fieldOrder: 0
        }
        const { data, status } = await postRequest(`/customFieldGroup/addFieldToGroup`, params, 'blueraven')
        cfg.customFields.push(data)
        this.newField = {}
        this.selectedAncillaryField = {}
        this.ancillaryCustomFields = []
        this.addField = false
        this.parent = {}
        this.snackbar = getSnackbar('SUCCESS', 'Field Added to Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Field to Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveGroupChanges(groups) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { status } = await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups, 'blueraven')
        this.snackbar = getSnackbar('SUCCESS', 'Groups Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Group Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveGroup(group) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data, status } = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group, 'blueraven')
        group.tabName = data.tabName
        group.companyObjectTypeTabDisplayOrder = data.companyObjectTypeTabDisplayOrder
        this.snackbar = getSnackbar('SUCCESS', 'Custom Field Group Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteGroup(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { status } = await deleteRequest(`/customFieldGroup/${item.id}`, 'blueraven')
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Group Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteFieldFromGroup(item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { status } = await deleteRequest(`/customFieldGroup/assignment/${item.id}`, 'blueraven')
        this.fieldsInUse = []
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteField(item, customFieldGroupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { status } = await deleteRequest(`/customFieldGroup/${customFieldGroupId}`, 'blueraven')
        this.fieldsInUse = []
        item.archived = true
        this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldChanges(fields) {
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
          this.$store.commit(AppMutations.SET_LOADING, true)
          const { status } = await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },
    filterCustomFieldGroups() {
      return this.customFieldGroups.filter(cfgt => {
        return !cfgt.archived
      })
    },
    async loadFieldsByParent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.parent.isProcessStep) {
          const { data, status } = await getRequest(`/customField/getByParentProcessStep/${this.parent.id}`)
          this.ancillaryCustomFields = data
          handleHidingGlobalLoader(this, status)
        } else {
          const { data, status } = await getRequest(`/customField/getByParentType/${this.parent.id}`)
          this.ancillaryCustomFields = data
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUseParentData(field) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { status } = await putRequest(`/customFieldGroup/saveUseParentData`, field, 'blueraven')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterAvailableCustomFields(current, item) {
      return item.customFields?.filter(cf => {
        return !cf.archived && cf.id !== current.id
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.item-icons {
  display: flex;
  float: right;
}

.handle {
  cursor: move !important;
}
</style>
