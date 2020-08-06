<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addNew = !addNew, newGroup = {}]" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')">
              <v-icon v-if="constants.IS_MOBILE">add</v-icon>
              <span v-else>{{addNew ? 'Cancel' : 'Add New'}}</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
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
                  <v-btn text icon small class="handle">
                    <v-icon>drag_handle</v-icon>
                  </v-btn>
                </td>
                <td class="text-left">
                  <v-text-field text
                                v-if="item.edit"
                                v-model="item.groupName">
                    <template slot="append-outer">
                      <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                      <v-icon @click="item.edit = false">clear</v-icon>
                    </template>
                  </v-text-field>
                  <a style="text-decoration: underline;" v-else @click="item.edit = true">
                    {{item.groupName}}
                  </a>
                </td>
                <td>
                  <div class="item-icons">
                    <v-btn small text @click="[addField = !addField, fetchAvailableCustomFields(item.id), expanded = [item], selectedIndex = index]">
                      <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                      <v-icon v-else>add</v-icon>
                    </v-btn>
                    <v-btn small text @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                      <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                      <v-icon v-else>expand_more</v-icon>
                    </v-btn>
                    <v-dialog
                        v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
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
                          <div class="error-text">
                            WARNING: Any process step requirements currently using a field from this group will also be archived and any action logic currently using those requirements will be reset.
                          </div>

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
                              color="primary"
                              text
                              @click="[item.archived = true, deleteWithChecks(item.id, null)]">
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
                  <v-radio-group v-if="$route.params.id === '1'" v-model="newFieldType" @change="fetchAvailableCustomFields(item.id)">
                    <v-radio label="Project Custom Field"
                             value="native"></v-radio>
                    <v-radio label="Reference Field: from Process Step"
                             value="ancillary"></v-radio>
                  </v-radio-group>
                  <v-autocomplete v-if="newFieldType === 'native' || $route.params.id !== '1'"
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
                  <v-autocomplete v-if="newFieldType === 'ancillary' && $route.params.id === '1'"
                                  v-model="parent"
                                  :items="parentObjects"
                                  label="Parent Object"
                                  item-text="processStepName"
                                  return-object
                                  autocomplete="off"
                                  @input="loadFieldsByParent"
                  >
                    <template slot='item' slot-scope='{ item }'>
                      {{ item.processStepName }}
                    </template>
                  </v-autocomplete>
                  <v-autocomplete v-if="newFieldType === 'ancillary' && $route.params.id === '1'"
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
                </v-col>
                <v-col  cols="12" justify="center"  class="px-3 py-0" >
<!--                  <h3 class="text-left">Assigned Custom Fields</h3>-->
                  <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                             group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                    <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                            :key="index" class="pa-0" :class="{ 'shaded-row': selectedIndex % 2 }">
                      <v-list-item class="grab">
                        <v-list-item-action>
                          <v-icon>drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div v-if="cf.ancillaryCustomFieldGroupAssignmentId == null">
                            {{cf.fieldName}}
                          </div>
                          <div v-else>
                            {{ cf.processStepName }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                          </div>
                          <div class="text-left" v-if="cf.ancillaryCustomFieldGroupAssignmentId == null && $route.params.id !== '1'">
                            <input type="checkbox" v-model="cf.showOnInsert" @change="updateShowOnInsert(cf)">
                            Show On Insert
                          </div>
                        </v-list-item-content>
                        <v-menu offset-y v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                          <template v-slot:activator="{ on }">
                            <v-btn text small v-on="on">
                              <v-icon>mdi-cursor-move</v-icon>
                            </v-btn>
                          </template>
                          <v-list>
                            <v-list-item
                              v-for="(cfg, index) in filterBy(customFieldGroups, (g) => { return g.id !== cf.customFieldGroupId })"
                              :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                              <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                            </v-list-item>
                          </v-list>
                        </v-menu>
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
                              <div class="error-text mb-3">
                                WARNING: Any process step requirements currently using this field will also be archived and any action logic currently using those requirements will be reset.
                              </div>

                              <span class="error--text">WARNING:</span>
                              By deleting a field you will lose all data associated with the field. If you meant to "move" the field to another group please cancel and move the field. <br/><br/>
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
                                  color="primary"
                                  text
                                  @click="[cf.archived = true, deleteWithChecks(null, cf.id)]">
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
        <v-divider v-if="$route.params.id === '1'"></v-divider>
        <v-row v-if="$route.params.id === '1'">
          <v-col cols="12" class="pt-0">
            <v-toolbar flat>
              <v-toolbar-title class="app-title">Attachment Types</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="getAttachmentTypesForProjects" v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                  <v-icon v-if="!addNewType">add</v-icon>
                  {{ addNewType ? 'Cancel' : 'Add Type'}}
                </v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-select v-if="addNewType"
                      v-model="newType.attachmentTypeId"
                      :items="availableAttachmentTypes"
                      label="Select Attachment Type"
                      item-text="attachmentType"
                      item-value="id"
                      @input="assignNewType"
            ></v-select>
            <v-card flat >
              <v-list v-for="(a, index) in filterBy(projectAttachmentTypes, false, 'archived')"
                      :key="index">
                <v-list-item :class="{'shaded-row': index % 2}">
                  <v-list-item-content>
                    {{a.attachmentType}}
                  </v-list-item-content>
                  <v-dialog
                      v-model="a.deleteConfirm"
                      width="500">
                    <template v-slot:activator="{ on }">
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

                      <v-card-text>
                        Are you sure you want to delete this attachment type: <strong>{{ a.attachmentType }}</strong>?
                      </v-card-text>

                      <v-divider></v-divider>

                      <v-card-actions>
                        <v-spacer></v-spacer>
                        <v-btn
                            @click="a.deleteConfirm = false">
                          No
                        </v-btn>
                        <v-btn
                            color="primary"
                            text
                            @click="[a.archived = true, deleteAttachmentType(a.id)]">
                          Yes
                        </v-btn>
                      </v-card-actions>
                    </v-card>
                  </v-dialog>
                </v-list-item>
              </v-list>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-col>
    <Snackbar :snackbar="snackbar"></Snackbar>
    </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'
import Snackbar from '@/components/Snackbar.vue'
import { getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'CustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
    Snackbar
  },
  data () {
    return {
      snackbar: {},
      constants,
      addNew: false,
      newFieldType: 'native',
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

      addNewType: false,
      newType: {},
      availableAttachmentTypes: [],
      projectAttachmentTypes: []
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
  watch: {
    // whenever objectTypeId changes, this function will run
    '$route.params.id': function (oldObjectTypeId, newObjectTypeId) {
      // reset the selected group when the object type changes
      this.availableCustomFields = []
      this.getCustomFieldGroups()
    }
  },
  created () {
    this.getCustomFieldGroups()
    this.getProjectAttachmentTypes()
  },
  methods: {
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
          params: {
            companyObjectTypeId: this.$route.params.id
          }
        })
        this.customFieldGroups = cloneDeep(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields (groupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if(this.addField && this.newFieldType === 'native') {
          const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
            params: {
              companyObjectTypeId: this.$route.params.id,
              groupId
            }
          })
          this.availableCustomFields = data
        } else if (this.addField && this.newFieldType === 'ancillary') {
          const {data} = await getRequest(`/processStep/getParentObjects`)
          this.selectedAncillaryField = {}
          this.parentObjects = data
          this.availableCustomFields = []
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addCustomFieldGroup () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.companyObjectTypeId = this.$route.params.id
        // setting groupOrder to 0, then they can sort later
        this.newGroup.groupOrder = 0
        const {data} = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup)
        this.newGroup = {}
        this.addNew = false
        // add the new type to the list
        this.customFieldGroups.push(data)
        this.snackbar = getSnackbar('SUCCESS', 'Group Added')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Custom Field Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignCustomField (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addField = false
        this.newField.fieldOrder = 0
        this.newField.customFieldGroupId = item.id
        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
        item.customFields.unshift(data)
        this.newField = {}
        this.selectedAncillaryField = {}
        this.parent = {}
        this.addField = false
        this.snackbar = getSnackbar
        this.snackbar = getSnackbar('SUCCESS', 'Field Added to Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Field to Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async moveFieldToOtherGroup (field, newGroup) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
        this.snackbar = getSnackbar('SUCCESS', 'Field Moved')
        //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Moving Field')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignAncillaryCustomField (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          customFieldGroupId: item.id,
          id: null,
          ancillaryCustomFieldGroupAssignmentId: this.selectedAncillaryField.customFieldGroupAssignmentId,
          fieldOrder: 0
        }
        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
        item.customFields.unshift(data)
        this.newField = {}
        this.snackbar = getSnackbar('SUCCESS', 'Field Added to Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Field to Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveGroupChanges (groups) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        // debugger
        // groups.forEach((g, idx) => {
        //   g.groupOrder = idx
        // })
        await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups)
        this.snackbar = getSnackbar('SUCCESS', 'Groups Updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Group Changes')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveGroupName (group) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
        this.snackbar = getSnackbar('SUCCESS', 'Group Name Updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWithChecks(customFieldGroupId, customFieldGroupAssignmentId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          customFieldGroupId, customFieldGroupAssignmentId
        }
        await putRequest(`/customFieldGroup/deleteWithRequirementChecks`, params)
        this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    // async deleteFieldFromGroup (fieldGroupId) {
    //   this.$store.commit(AppMutations.SET_LOADING, true)
    //   try {
    //     await deleteRequest(`/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
    //     this.snackbar = getSnackbar('SUCCESS', 'Field Removed From Group')
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   } catch (e) {
    //     console.error('*** ERROR ***', e)
    //     this.snackbar = getSnackbar('ERROR', 'Error Removing Field from Group')
    //     this.$store.commit(AppMutations.SET_LOADING, false)
    //   }
    // },
    async saveFieldChanges (fields) {
      this.$store.commit(AppMutations.SET_LOADING, true)
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
          await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
        }
        this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }

    },
    filterCustomFieldGroups () {
      return this.customFieldGroups.filter(cfgt => { return !cfgt.archived})
    },
    async updateShowOnInsert(cf) {
      try {
        const objectType = {
          id: cf.customFieldObjectTypeId,
          showOnInsert: cf.showOnInsert
        }
        await putRequest(`/customFieldGroup/updateFieldShowOnInsert`, objectType)
        this.snackbar = getSnackbar('SUCCESS', 'Updated Field')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async loadFieldsByParent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customField/getByParentProcessStep/${this.parent.id}`)
        this.ancillaryCustomFields = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getProjectAttachmentTypes () {
      //this one loads attachment types already assigned to a project
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const { data } = await getRequest(`/attachmentType/projectTypes`)
        this.projectAttachmentTypes = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getAttachmentTypesForProjects () {
      //this one loads attachment types AVAILABLE TO BE assigned to a project ...idk maybe this should be one function
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = !this.addNewType
        if(this.addNewType){
          const { data } = await getRequest(`/attachmentType/typesForProjects`)
          this.availableAttachmentTypes = data
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignNewType () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newType.processStepId = this.$route.params.id
        const { data } = await postRequest(`/attachmentType/projectType`, this.newType)
        this.projectAttachmentTypes.push(data)
        // reset fields
        this.addNewType = false
        this.newType = {}
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Added')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Attachment Type')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteAttachmentType (id) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addNewType = false
        await deleteRequest(`/attachmentType/projectType/${id}`)
        // this.availableAttachmentTypes = data
        this.snackbar = getSnackbar('SUCCESS', 'Attachment Type Deleted')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Attachment Type')
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
