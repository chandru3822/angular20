<template>
  <v-container class="">
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
      <v-col cols="12" class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="!createNew && userCanAdd" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Create Group</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3" flat
                color="rowShadeCustom">
          <div>
            <v-text-field
                label="Group Name"
                tabindex=1
                v-model="newGroup.groupName"
            ></v-text-field>
            <div v-if="showScheduleGroupCheckbox()">
              <label>Schedule Group:</label>
              <input type="checkbox" class="ml-2" v-model="newGroup.schedulable" @change="[getSchedulingFields(), getEventTypes()]">
            </div>
            <div v-if="newGroup.schedulable">
              <v-select
                  v-model="newGroup.eventTypeId"
                  :items="eventTypes"
                  label="Scheduling Tool Event Type"
                  placeholder="Select One..."
                  item-text="eventType"
                  item-value="id"
              ></v-select>
              <div  v-for="(sf, index) in schedulingFields" :key="index">
                <v-select v-model="newGroup.schedulingFields[index]"
                          text
                          :items="sf.availableCustomFields"
                          :label="`Please select a field to be used as the ${sf.fieldType}`"
                          placeholder="Select One..."
                          item-value="id"
                          item-text="fieldName"
                          return-object
                ></v-select>
              </div>
            </div>
          </div>
          <v-btn
              color="primary"
              class="white--text mr-2"
              :disabled="!newGroup.groupName || (newGroup.schedulable && ((newGroup.schedulingFields.length !== schedulingFields.length) || (!newGroup.eventTypeId)))"
              @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
              @click="[newGroup = { schedulingFields: [], schedulable: false }, createNew = false]">
            Cancel
          </v-btn>
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
                class="elevation-1 fix-column-width-bug process-step-cfg-table"
            >
              <template #no-data>
                No custom for this process step
              </template>

              <template #no-results>
                No actions for this process step
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <v-btn text icon small class="handle" v-if="userCanEdit">
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
                  <td><div class="item-icons">
                    <v-btn v-if="!item.eventTypeId && userCanAdd" small text @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]">
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

                        <v-card-text class="pt-4">
                          <span class="error--text">WARNING:</span>
                          By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/><br/>

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
                              @click="deleteWithChecks(item, item.id, null)">
                            Yes
                          </v-btn>
                        </v-card-actions>
                      </v-card>
                    </v-dialog>
                  </div></td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0"  :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" justify="center" class="pl-3 pr-3" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <v-radio-group v-model="newFieldType" @change="fetchAvailableCustomFields(item.companyObjectTypeId, item.id)">
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
                    <v-btn @click="addField = false">Cancel</v-btn>
                  </v-col>
                  <v-col cols="12" justify="center" class="px-3 py-0"
                          v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-col>
                  <v-col  cols="12" justify="center" class="px-3 py-0"
                          v-if="item.customFields && item.customFields.length > 0">
                    <div v-if="item.eventTypeId">Scheduling Tool Event Type: {{item.eventType}}</div>
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                              :key="index" class="pa-0"  color="transparent">
                        <v-list-item :class="{grab: !item.eventTypeId}">
                          <v-list-item-action>
                            <v-icon v-if="!item.eventTypeId && userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <div v-if="cf.ancillaryCustomFieldGroupAssignmentId == null">
                              {{cf.fieldName}} <span v-if="cf.customFieldGroupAssignmentReadOnly">(Read Only)</span>
                              <div class="text-left mt-3" v-if="cf.edit">
                                <div>
                                  <input type="checkbox" v-model="cf.customFieldGroupAssignmentReadOnly">
                                  Read Only
                                </div>
                                <v-autocomplete
                                  v-if="cf.customFieldGroupAssignmentReadOnly"
                                  v-model="cf.whiteListedPositions"
                                  :items="positions"
                                  :loading="positionsLoading"
                                  multiple
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
                                  <v-list-item
                                    slot="prepend-item"
                                    ripple
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
                                <v-btn color="primaryCustom" dark class="mt-2 white--text" @click="saveReadOnlyAndWhiteList(cf)">
                                  Save
                                </v-btn>
                              </div>
                            </div>
                            <div v-else>
                              {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                            </div>
                          </v-list-item-content>
                          <v-btn text small @click="[$set(cf, 'edit', !cf.edit), getPositions()]" v-if="userCanEdit">
                            <v-icon>edit</v-icon>
                          </v-btn>
                          <v-menu offset-y v-if="!item.eventTypeId && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <v-btn text small v-on="{...tooltip, ...menu}">
                                    <v-icon>mdi-cursor-move</v-icon>
                                  </v-btn>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                              <v-list>
                                <v-list-item
                                  v-for="(cfg, index) in filterBy(localCustomFieldGroups, (g) => { return g.id !== cf.customFieldGroupId && !g.eventTypeId })"
                                  :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                  <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                                </v-list-item>
                              </v-list>
                            </v-menu>


                          <v-dialog
                              v-if="!item.eventTypeId && userCanEdit"
                              v-model="cf.deleteConfirm"
                              width="500">
                            <template v-slot:activator="{ on }">
                              <v-list-item-action class="clickable" v-on="on">
                                <v-icon>delete</v-icon>
                              </v-list-item-action>
                            </template>
                            <v-card>
                              <v-card-title
                                  class="headline grey lighten-2"
                                  primary-title>
                                Confirm
                              </v-card-title>

                              <v-card-text class="mt-2">
                                <span class="error--text">WARNING:</span>
                                By deleting a field you will lose all data associated with the field. If you meant to "move" the field to another group please cancel and move the field. <br/><br/>

                                Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{ item.groupName }}</strong>?
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
                                    @click="deleteWithChecks(cf, null, cf.id)">
                                  Yes
                                </v-btn>
                              </v-card-actions>
                            </v-card>
                          </v-dialog>
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
        <Snackbar :snackbar="snackbar"></Snackbar>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getEventTypes} from '@/services/scheduleService'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import Sortable from "sortablejs";
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from "lodash.orderby"


  export default {
    name: 'ProcessStepCustomFieldGroups',
    mixins: [Vue2Filters.mixin],
    components: {
      draggable,
      Snackbar
    },
    props: {
      customFieldGroups: Array,
    },
    updated() {
      // this had to be in updated vs mounted so that after the re-render the dragging still works
      let table = document.querySelector('.process-step-cfg-table tbody')
      const _self = this
      Sortable.create(table, {
        handle: '.handle',
        onEnd({ newIndex, oldIndex }) {
          if(_self.localCustomFieldGroups?.length > 0) {
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
              if(save) {
                _self.localCustomFieldGroups[idx].newGroupOrder = idx
                rowsToSave.push(r)
              }
            })
            _self.saveRowChanges(rowsToSave)
          }
        }
      })
    },
    data() {
      return {
        snackbar: {},
        componentKey: 0,
        deleteError: false,
        deleteHeader: null,
        deleteText: null,
        fieldsInUse: [],
        positions: [],
        positionsLoading: false,
        constants,
        newGroup: {
          schedulingFields: [],
          schedulable: false
        },
        newField: {},
        // selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet.
        selectedIndex: null,
        createNew: false,
        newFieldType: 'native',
        addField: false,
        selectedGroupId: null,
        availableCustomFields: [],
        parent: {},
        processStepId: this.$route.params.id,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
        companyId: this.$store.state.user.details.companyId,
        parentObjects: [],
        selectedAncillaryField: {},
        ancillaryCustomFields: [],
        headers: [
          { text: null, value: 'draggable', width: '50px', show: true, sortable: false },
          { text: 'Name', value: 'groupName', show: true },
          { text: null, value: 'icons', show: true }
        ],
        expanded: [],
        schedulingFields: [],
        eventTypes: []
      }
    },
    computed: {
      localCustomFieldGroups: {
        get: function() {
          return this.customFieldGroups
        },
        set: function(val) {
          val.forEach(v => {
            v.groupOrder = v.newGroupOrder ?? v.groupOrder
          })
          return orderBy(val, v => v.groupOrder)
        }
      },

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
      async saveFieldGroup() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newGroup.processStepId = this.$route.params.id

          this.newGroup.schedulingFields = this.newGroup.schedulable ? this.newGroup.schedulingFields : []
          this.newGroup.eventTypeId = this.newGroup.schedulable ? this.newGroup.eventTypeId : null

          const {data} = await postRequest(`/customFieldGroup/addProcessStepCustomFieldGroup`, this.newGroup)
          this.localCustomFieldGroups.push(data)
          this.newGroup = {
            schedulingFields: [],
            schedulable: false,
          }
          this.createNew = false
          this.snackbar = getSnackbar('SUCCESS', 'Group Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Group')
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
          } else {
            this.fieldsInUse = []
            item.archived = true
            this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting')
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
      async fetchAvailableCustomFields(objectTypeId, groupId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if (this.addField && this.newFieldType === 'native') {
            const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
              params: {
                companyObjectTypeId: objectTypeId,
                groupId,
                processStepId: this.processStepId
              }
            })
            this.availableCustomFields = data
            this.parentObjects = []
            this.ancillaryCustomFields = []
          } else if (this.addField && this.newFieldType === 'ancillary') {
            this.availableCustomFields = []
            const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, { params: { id: this.processStepId}})
            this.selectedAncillaryField = {}
            this.parentObjects = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async loadFieldsByParent() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if(this.parent.isProcessStep) {
            const {data} = await getRequest(`/customField/getByParentProcessStep/${this.parent.id}`)
            this.ancillaryCustomFields = data
          } else {
            const {data} = await getRequest(`/customField/getByParentType/${this.parent.id}`)
            this.ancillaryCustomFields = data
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
      async assignCustomField(cfg) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addField = false
          this.newField.customFieldGroupId = cfg.id
          //this line makes pushing it to the list work
          this.newField.archived = false

          const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
          cfg.customFields.push(data)
          this.newField = {}
          this.snackbar = getSnackbar('SUCCESS', 'Custom Field Assigned')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Assigning Custom Field')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async assignAncillaryCustomField(cfg) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {
            customFieldGroupId: cfg.id,
            id: null,
            ancillaryCustomFieldGroupAssignmentId: this.selectedAncillaryField.customFieldGroupAssignmentId,
            fieldOrder: 0
          }
          const {data} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
          cfg.customFields.push(data)
          this.selectedAncillaryField = {}
          this.addField = false
          this.parent = {}
          this.snackbar = getSnackbar('SUCCESS', 'Reference Field Assigned')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Assigning Reference Field')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCustomFieldGroups () {
        return this.localCustomFieldGroups?.filter(cfg => { return !cfg.archived})
      },
      async getSchedulingFields () {
        if(this.newGroup.schedulable) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequest(`/customFieldGroup/getEventTypesAndFields`)
            this.schedulingFields = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async getEventTypes () {
        if(this.newGroup.schedulable) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getEventTypes()
            this.eventTypes = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      showScheduleGroupCheckbox () {
        let tempGroups = this.localCustomFieldGroups.filter(cfg => !cfg.archived)
        return tempGroups?.length === 0 ||
          tempGroups.find(cfg => cfg.eventTypeId) === undefined
      },
      async saveRowChanges(rows) {
        if(rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
            this.localCustomFieldGroups = orderBy(this.localCustomFieldGroups, 'groupOrder')
            this.snackbar = getSnackbar('SUCCESS', 'Group Order Saved')
            // this componentKey forces the data-table component to re-render
            this.componentKey += 1
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Group Order')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
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
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      toggleSelectAllPositions (field) {
        this.$nextTick(() => {
          if (this.selectAll(field)) {
            field.whiteListedPositions = []
          } else {
            this.$set(field, 'whiteListedPositions', this.positions.map(p => p.id))
          }
        })
      },
    }

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
</style>
