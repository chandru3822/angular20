<template>
  <v-container class="custom-field-group-container">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="headline error--text">
          {{deleteHeader}}
        </v-card-title>

        <v-card-text>
          {{deleteText}}
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              {{ item.objectType }}
              <div v-if="item.processStepName">{{item.processStepName}}</div>
              <div v-if="item.groupName">{{ item.groupName }}<span v-if="item.fieldName"> - {{ item.fieldName }}</span></div>
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primaryCustom"
            text
            dark
            class="white--text"
            @click="deleteError = false"
          >
            OK
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-row>
      <v-col cols="12" class="shrink pt-0">
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
              :sort-by="['companyObjectTypeTabDisplayOrder', 'groupOrder']"
              :sort-desc="[false]"
              :expanded.sync="expanded"
              hide-default-footer
              :hide-default-header="!isProject"
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
                <td class="text-left">
                  <v-select v-if="item.edit && isProject"
                            v-model="item.companyObjectTypeTabId"
                            :items="objectTypeTabs"
                            label="Tab"
                            item-text="tabName"
                            item-value="id"
                            autocomplete="off">
                  </v-select>
                  <span v-if="!item.edit && isProject">
                    {{item.tabName || 'n/a'}}
                  </span>
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
                              @click="deleteWithChecks(item, item.id, null)">
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
                  <v-radio-group v-if="isProject" v-model="newFieldType" @change="fetchAvailableCustomFields(item.id)">
                    <v-radio label="Project Custom Field"
                             value="native"></v-radio>
                    <v-radio label="Reference Field: from Process Step"
                             value="ancillary"></v-radio>
                  </v-radio-group>
                  <v-autocomplete v-if="newFieldType === 'native' || !isProject"
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
                  <v-autocomplete v-if="newFieldType === 'ancillary' && isProject"
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
                  <v-autocomplete v-if="newFieldType === 'ancillary' && isProject"
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
                             :disabled="!userCanEdit"
                             group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                    <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                            :key="index" class="pa-0" :class="{ 'shaded-row': selectedIndex % 2 }">
                      <v-list-item class="grab">
                        <v-list-item-action v-if="userCanEdit">
                          <v-icon>drag_handle</v-icon>
                        </v-list-item-action>
                        <v-list-item-content>
                          <div v-if="cf.ancillaryCustomFieldGroupAssignmentId == null">
                            {{cf.fieldName}} <span v-if="cf.customFieldGroupAssignmentReadOnly">(Read Only)</span>
                            <div class="text-left mt-3" v-if="cf.edit">
                              <div>
                                <input type="checkbox" :readonly="!userCanEdit"
                                       :disabled="!userCanEdit" v-model="cf.customFieldGroupAssignmentReadOnly">
                                Read Only
                              </div>
                              <v-autocomplete
                                v-if="cf.customFieldGroupAssignmentReadOnly"
                                v-model="cf.whiteListedPositions"
                                :items="positions"
                                :loading="positionsLoading"
                                multiple
                                :readonly="!userCanEdit"
                                :disabled="!userCanEdit"
                                label="White Listed Positions"
                                item-text="position"
                                item-value="positionId"
                                return-object
                                height="35px"
                                class="mt-2"
                                @change="cf.positionsChanged = true"
                              >
                                <v-list-item
                                  slot="prepend-item"
                                  ripple
                                  @click="toggleSelectAllPositions(cf)"
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
                                  <v-chip small v-if="index === 0 && cf.whiteListedPositions && cf.whiteListedPositions.length < 2">
                                    <span>{{ item.position }}</span>
                                  </v-chip>
                                  <span
                                    v-if="index === 1 && cf.whiteListedPositions && cf.whiteListedPositions.length >= 2"
                                    class="primary--text caption"
                                  >{{ cf.whiteListedPositions.length }} selected</span>
                                </template>
                              </v-autocomplete>
                              <v-btn color="primaryCustom" dark class="mt-2 white--text"
                                     v-if="userCanEdit"
                                     @click="saveReadOnlyAndWhiteList(cf)">
                                Save
                              </v-btn>
                            </div>
                          </div>
                          <div v-else>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                          </div>
                          <div class="text-left" v-if="!cf.edit && cf.ancillaryCustomFieldGroupAssignmentId == null && !isProject">
                            <input type="checkbox" v-model="cf.showOnInsert" :readonly="!userCanEdit"
                                   :disabled="!userCanEdit" @change="updateShowOnInsert(cf)">
                            Show On Insert
                          </div>
                        </v-list-item-content>
                        <v-btn text small v-if="userCanEdit" @click="[$set(cf, 'edit', !cf.edit), getPositions()]">
                          <v-icon>edit</v-icon>
                        </v-btn>
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
                                  color="primaryCustom"
                                  text
                                  @click="deleteWithChecks(cf, null, cf.id)">
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

import { getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'

export default {
  name: 'CustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
  },
  props: {
    isProject: Boolean
  },
  data () {
    return {
      snackbar: {},
      constants,
      addNew: false,
      deleteError: false,
      deleteHeader: null,
      deleteText: null,
      fieldsInUse: [],
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      positions: [],
      positionsLoading: false,
      newFieldType: 'native',
      selectedIndex: null,
      fieldOrderChanged: false,
      groupOrderChanged: false,
      newGroup: {
        groupName: null
      },
      //ugh! is this a good idea? projects is a custom view that calls this but orgs/users/contacts do too and i dont want to add a view for each of those
      typeId: this.$route.params.id ?? this.$route.query.companyObjectTypeId,
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
        { text: 'Tab', value: 'tabName', show: true },
        { text: null, value: 'icons', show: true }
      ],
      expanded: [],
      parent: {},
      parentObjects: [],
      selectedAncillaryField: {},
      ancillaryCustomFields: [],
      objectTypeTabs: []
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
      this.typeId = this.$route.params.id ?? this.$route.query.companyObjectTypeid
      this.availableCustomFields = []
      this.getCustomFieldGroups()
    }
  },
  created () {
    this.getCustomFieldGroups()
    this.getObjectTypeTabs()
  },
  methods: {
    selectAll (f) {
      return f.whiteListedPositions?.length === this.positions?.length
    },
    selectSome (f) {
      return f.whiteListedPositions?.length > 0 && !this.selectAll(f)
    },
    icon (f) {
      if (this.selectAll(f)) {
        return 'check_box'
      }
      if (this.selectSome(f)) {
        return 'indeterminate_check_box'
      }
      return 'check_box_outline_blank'
    },
    async getObjectTypeTabs() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //currently we only do this for projects.. will have to change if we allow custom tabs for other object types
        const {data} = await getRequest(`/objectTypeTab/project`)
        this.objectTypeTabs = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Tabs')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
          params: {
            companyObjectTypeId: this.typeId
          }
        })
        this.customFieldGroups = cloneDeep(data)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields (groupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        if(this.addField && this.newFieldType === 'native') {
          const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
            params: {
              companyObjectTypeId: this.typeId,
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
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addCustomFieldGroup () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.companyObjectTypeId = this.$route.params.id ?? this.$route.query.companyObjectTypeId
        const {data} = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup)
        this.newGroup = {}
        this.addNew = false
        // add the new type to the list
        this.customFieldGroups.push(data)
        this.snackbar = getSnackbar('SUCCESS', 'Group Added')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Custom Field Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignCustomField (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.addField = false
        this.newField.customFieldGroupId = item.id
        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
        item.customFields.push(data)
        this.newField = {}
        this.selectedAncillaryField = {}
        this.parent = {}
        this.addField = false
        this.snackbar = getSnackbar
        this.snackbar = getSnackbar('SUCCESS', 'Field Added to Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Field to Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async moveFieldToOtherGroup (field, newGroup) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await postRequest(`/customFieldGroup/moveFieldToOtherGroup/${newGroup.id}`, field)
        this.snackbar = getSnackbar('SUCCESS', 'Field Moved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        //currently reloading the page because moving the field in the UI seems too hard (even though it isn't i just cant make myself do it right now)
        window.location.reload()
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Moving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async assignAncillaryCustomField (item) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const params = {
          customFieldGroupId: item.id,
          id: null,
          ancillaryCustomFieldGroupAssignmentId: this.selectedAncillaryField.customFieldGroupAssignmentId
        }
        const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
        item.customFields.push(data)
        this.newField = {}
        this.selectedAncillaryField = {}
        this.parent = {}
        this.addField = false
        this.snackbar = getSnackbar('SUCCESS', 'Field Added to Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        await putRequest(`/customFieldGroup/updateCustomFieldGroups`, groups)
        this.snackbar = getSnackbar('SUCCESS', 'Groups Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
        const {data} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
        group.tabName = data.tabName
        group.companyObjectTypeTabDisplayOrder = data.companyObjectTypeTabDisplayOrder
        this.snackbar = getSnackbar('SUCCESS', 'Custom Field Group Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWithChecks(item, customFieldGroupId, customFieldGroupAssignmentId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          customFieldGroupId, customFieldGroupAssignmentId
        }
        const {data} = await putRequest(`/customFieldGroup/deleteWithRequirementChecks`, params)
        if (data?.length > 0) {
          this.deleteError = true
          item.deleteConfirm = false
          this.fieldsInUse = data
          let errorMsg = 'Group Cannot Be Deleted'
          this.deleteHeader = 'Error Deleting Custom Field Group'
          this.deleteText = 'You cannot delete a group that has a field in use by other groups or requirements.'
          if(null !== customFieldGroupAssignmentId) {
            errorMsg = 'Field Cannot Be Deleted'
            this.deleteHeader = 'Error Deleting Custom Field from Group'
            this.deleteText = 'You cannot delete a field from a group that is in use by other groups or requirements.'
          }
          this.snackbar = getSnackbar('ERROR', errorMsg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } else {
          this.fieldsInUse = []
          item.archived = true
          this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveReadOnlyAndWhiteList (field) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
        field.positionsChanged = false
        if(!field.customFieldGroupAssignmentReadOnly) {
          this.$set(field, 'whiteListedPositions', [])
        }
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
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
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
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
    async updateShowOnInsert(cf) {
      try {
        const objectType = {
          id: cf.customFieldObjectTypeId,
          showOnInsert: cf.showOnInsert
        }
        await putRequest(`/customFieldGroup/updateFieldShowOnInsert`, objectType)
        this.snackbar = getSnackbar('SUCCESS', 'Updated Field')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },

    async getPositions() {
      if(this.positions?.length === 0) {
        try {
          this.positionsLoading = true
          const {data} = await getRequest(`/position/withParent`)
          this.positions = data
          this.positionsLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.positionsLoading = false
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    toggleSelectAllPositions (field) {
      this.$nextTick(() => {
        if (this.selectAll(field)) {
          field.whiteListedPositions = []
        } else {
          field.whiteListedPositions = cloneDeep(this.positions)
          field.positionsChanged = true
        }
      })
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
