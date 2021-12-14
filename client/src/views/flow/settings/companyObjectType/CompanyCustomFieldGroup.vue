<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12" class="shrink pt-0">
        <router-link :to="`/settings/companyObjectTypes`">Back</router-link>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newGroup = {}]" v-if="userCanAdd">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card flat class="mb-4">
            Note: Some company specific screens ignore the display order and group name of Custom Fields Groups represented here.
          </v-card>
          <v-text-field v-if="addNew"
              v-model="newGroup.groupName"
              placeholder="Enter new group name"
              append-outer-icon="save"
              @click:append-outer="addCustomFieldGroup"
              label="Custom Field Group">
          </v-text-field>

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
              <tr  :class="{'shaded-row': customFieldGroups.indexOf(item) % 2}">
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
                  <span v-else>{{item.groupName}}</span>
                </td>
                <td>
                  <div class="item-icons">
                    <div v-if="userCanEdit" class="flex-display">
                      <v-btn small text
                             @click="item.edit = !item.edit">
                        <v-icon v-if="item.edit">remove</v-icon>
                        <v-icon v-else>edit</v-icon>
                      </v-btn>
                      <v-btn small text
                             v-if="item.edit"
                             @click="[saveGroup(item), item.edit = false]">
                        <v-icon>save</v-icon>
                      </v-btn>
                    </div>
                    <v-btn small text
                           v-if="userCanAdd"
                           @click="[addField = !addField, fetchAvailableCustomFields(item.id), expanded = [item], selectedIndex = index]">
                      <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                      <v-icon v-else>add</v-icon>
                    </v-btn>
                    <v-btn small text @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                      <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                      <v-icon v-else>expand_more</v-icon>
                    </v-btn>
                    <v-dialog
                      v-if="userCanEdit"
                      v-model="item.deleteConfirm"
                      width="500">
                      <template #activator="{ on }">
                        <v-btn small text v-on="on">
                          <v-icon>delete</v-icon>
                        </v-btn>
                      </template>
                      <v-card>
                        <v-card-title
                          class="headline grey lighten-2"
                          primary-title>
                          Confirm
                        </v-card-title>

                        <v-card-text>
                          Are you sure you want to delete this Custom Field Group: <strong>{{ item.groupName }}</strong>?
                        </v-card-text>

                        <v-divider></v-divider>

                        <v-card-actions>
                          <v-spacer></v-spacer>
                          <v-btn
                            @click="item.deleteConfirm = false">
                            No
                          </v-btn>
                          <v-btn
                            color="primaryCustom"
                            text
                            @click="deleteGroup(item)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </div>
                </td>
              </tr>
            </template>

            <template #expanded-item="{ headers, item, index }">
              <td :colspan="headers.length" class="pb-2"  :class="{'shaded-row': selectedIndex % 2}">
                <v-col cols="12" justify="center" class="pl-3 pr-3" v-if="addField">
                  <h3 class="text-left">Add New Field</h3>
                  <v-radio-group v-if="objectType.allowAncillary"
                                 v-model="newFieldType" @change="fetchAvailableCustomFields(item.id)">
                    <v-radio label="Native Custom Field"
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
                                  @input="assignCustomField(item, true)"
                  >
                    <template slot='item' slot-scope='{ item }'>
                      {{ item.fieldName }}
                    </template>
                  </v-autocomplete>
                </v-col>
                <v-col cols="12" justify="center" class="pl-3 pr-3" v-if="!item.customFields || item.customFields.length === 0">
                  No fields assigned to this group
                </v-col>
                <v-col  cols="12" justify="center"  class="px-3 py-0" v-else>
                  <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                             :disabled="!userCanEdit"
                             group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                    <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                            :key="index" class="pa-0" :class="{ 'shaded-row': selectedIndex % 2 }">
                      <v-list-item class="grab">
                        <v-list-item-action v-if="userCanEdit">
                          <v-icon>drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                            {{cf.fieldName}}
                          </div>
                          <div v-else>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}}
                            (Ancillary)<br/>
                            <div v-if="cf.processStepName">
                              <label>Use Parent Data: </label>
                              <input type="checkbox" class="ml-3 mb-4" v-model="cf.useParentData"
                                     @change="saveUseParentData(cf)"
                                     :readonly="!userCanEdit" :disabled="!userCanEdit">
                            </div>
                          </div>
                        </v-list-item-content>
                        <v-dialog
                            v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                            v-model="cf.deleteConfirm"
                            width="500">
                          <template #activator="{ on }">
                            <v-list-item-action class="clickable" v-on="on">
                              <v-icon>delete</v-icon>
                            </v-list-item-action>
                          </template>
                          <v-card>
                            <v-card-title
                                class="headline grey lighten-2"
                                primary-title
                            >
                              Confirm
                            </v-card-title>

                            <v-card-text class="mt-2">
                              <span class="error--text">WARNING:</span>
                              By deleting a field you will lose all data associated with the field.<br/><br/>
                              Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{
                              item.groupName }}</strong>?
                            </v-card-text>

                            <v-divider></v-divider>

                            <v-card-actions>
                              <v-spacer></v-spacer>
                              <v-btn
                                  @click="cf.deleteConfirm = false">
                                No
                              </v-btn>
                              <v-btn
                                  color="primaryCustom"
                                  text
                                  @click="deleteFieldFromGroup(cf)">
                                Yes
                              </v-btn>
                            </v-card-actions>
                          </v-card>
                        </v-dialog>
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
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'

import { handleHidingGlobalLoader, getRequest, putRequest, postRequest, deleteRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'CompanyCustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
  },
  data () {
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
      ancillaryCustomFields: [],
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
  created () {
    this.getObjectType()
    this.getCustomFieldGroups()
  },
  methods: {
    async getObjectType() {
      //we have to get the object type details to determine if it can use ancillary fields
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/objectType/getByType/${this.$route.params.id}`,  'blueraven')
        this.objectType = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
          params: {
            companyObjectTypeId: this.$route.params.id
          }
        }, 'blueraven')
        this.customFieldGroups = cloneDeep(data)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields (groupId) {
      try {
        if(this.addField && this.newFieldType === 'native') {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {data, status} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
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
          const {data, status} = await getRequest(`/objectType/${this.$route.params.id}/getParentObjectsWithTypes`, 'blueraven')
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
    async addCustomFieldGroup () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.objectTypeId = parseInt(this.$route.params.id)
        const {data, status} = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup, 'blueraven')
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
    async assignCustomField (cfg, isAncillary) {
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
        const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params, 'blueraven')
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
    async saveGroupChanges (groups) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups, 'blueraven')
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
    async saveGroup (group) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group, 'blueraven')
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
        const {data, status} = await deleteRequest(`/customFieldGroup/${item.id}`, 'blueraven')
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
        const {data, status} = await deleteRequest(`/customFieldGroup/assignment/${item.id}`, 'blueraven')
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
    async deleteField(item, customFieldGroupId, customFieldGroupAssignmentId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await deleteRequest(`/customFieldGroup/${customFieldGroupId}`, 'blueraven')
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
    async saveFieldChanges (fields) {
      try {
        // if the fieldOrder of any item does not match idx + 1, it means it was changed and needs to be saved
        // pull those needing to be saved out of list
        let fieldsToSave = []
        fields.forEach((f, idx) => {
          let order = idx + 1
          if(f.fieldOrder !== order){
            f.fieldOrder = order
            fieldsToSave.push(f)
          }
        })
        // save them here
        if(fieldsToSave.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          const {status} = await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave, 'blueraven')
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
    filterCustomFieldGroups () {
      return this.customFieldGroups.filter(cfgt => { return !cfgt.archived})
    },
    async loadFieldsByParent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if (this.parent.isProcessStep) {
          const {data, status} = await getRequest(`/customField/getByParentProcessStep/${this.parent.id}`)
          this.ancillaryCustomFields = data
          handleHidingGlobalLoader(this, status)
        } else {
          const {data, status} = await getRequest(`/customField/getByParentType/${this.parent.id}`)
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
        const {status} = await putRequest(`/customFieldGroup/saveUseParentData`, field, 'blueraven')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
