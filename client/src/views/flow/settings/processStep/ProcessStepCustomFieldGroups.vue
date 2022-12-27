<template>
  <v-container class="pt-0 px-0">
    <v-dialog
      v-model="deleteError"
    >
      <v-card>
        <v-card-title class="text-h5 error--text">
          {{deleteHeader}}
        </v-card-title>

        <v-card-text>
          {{deleteText}}
          <v-list v-for="(item, index) in fieldsInUse" :key="index">
            <v-list-item-content>
              <div v-if="item.objectType">{{item.objectType}}</div>
              <div v-if="item.processStepName">{{item.processStepName}}</div>
              <div v-if="item.groupName">{{ item.groupName }}<span v-if="item.fieldName"> - {{ item.fieldName }}</span>
              </div>
            </v-list-item-content>
          </v-list>

        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="primary"
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
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="!createNew && userCanAdd" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Create Group</span>
            </v-btn>
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
          <v-btn
            color="primary"
            class="white--text mr-2"
            :disabled="!newGroup.groupName"
            @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
              text color="primary"
            @click="[newGroup = {}, createNew = false]">
            Cancel
          </v-btn>
        </v-card>
        <v-row>
          <v-col cols="12">
            <v-data-table
              v-if="localCustomFieldGroups && localCustomFieldGroups.length > 0"
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
              class="elevation-1 fix-column-width-bug process-step-cfg-table square-card"
            >
              <template #no-data>
                <span class="default-text-color">No custom for this process step</span>
              </template>

              <template #no-results>
                <span class="default-text-color">No actions for this process step</span>
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <v-btn text color="primary" icon small class="handle" v-if="userCanEdit">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
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
                      <a style="text-decoration: underline;" v-else @click="item.edit = true" class="default-text-color">
                        {{item.groupName}}
                      </a>
                    </div>
                    <span v-else>{{item.groupName}}</span>
                  </td>
                  <td>
                    <div class="item-icons">
                      <v-btn v-if="userCanAdd" small text color="primary"
                             @click="[addField = !addField, selectedIndex = index, expanded = [item], fetchAvailableCustomFields(item.companyObjectTypeId, item.id)]">
                        <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                        <v-icon v-else>add</v-icon>
                      </v-btn>
                      <v-btn small text color="primary"
                             @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                        <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                        <v-icon v-else>expand_more</v-icon>
                      </v-btn>
                      <v-btn v-if="userCanEdit" small text color="primary" @click="customFieldGroupToDelete=item"><v-icon>delete</v-icon></v-btn>
                      <v-btn icon small color="primary" @click="item.showGroupId = !item.showGroupId"><v-icon>mdi-information</v-icon></v-btn>
                      <span v-if="item.showGroupId" class="flex-align-items-center">id: {{ item.id }}</span>
                    </div>
                  </td>
                  <ConfirmationDialog :open-dialog="customFieldGroupToDelete && !assignmentToDelete" @confirm="deleteWithChecks" @close-dialog="customFieldGroupToDelete=null">
                    <span class="error--text">WARNING:</span>
                    By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/><br/>
                    Are you sure you want to delete this Custom Field Group: <strong>{{ itemToDeleteGroupName }}</strong>?
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
                    <v-btn color="primary" @click="addField = false">Cancel</v-btn>
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 pt-2 justify"
                         v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-col>
                  <v-col cols="12" class="px-3 py-0 justify"
                         v-if="item.customFields && item.customFields.length > 0">
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               :disabled="!userCanEdit"
                               group="customFields" @start="drag=true" @end="drag=false"
                               @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                              :key="index" class="pa-0" color="transparent">
                        <v-list-item class="grab">
                          <v-list-item-action>
                            <v-icon color="primary" v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            <div v-if="cf.ancillaryCustomFieldGroupAssignmentId == null">
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{cf.fieldName}}</a>
                              <span v-if="cf.customFieldGroupAssignmentReadOnly || cf.systemReadonly">(Read Only)</span>
                              <span v-if="cf.customFieldGroupAssignmentHidden">(Hidden)</span>
                              <v-tooltip top>
                                <template v-slot:activator="{ on, attrs }">
                                  <v-btn icon color="primary" @click="[cf.showId = !cf.showId, copyToClipBoard(cf.customFieldId, cf.showId)]" v-bind="attrs"
                                         v-on="on"><v-icon>mdi-information</v-icon></v-btn>
                                </template>
                                <span v-if="!cf.showId">Show (and Copy) Custom Field Id</span>
                                <span v-if="cf.showId">Hide Custom Field Id</span>
                              </v-tooltip>
                              <span v-if="cf.showId">id: {{ cf.customFieldId }}</span>
                              <div class="text-left mt-3" v-if="cf.edit">
                                <v-row>
                                  <v-col cols="6">
                                    <v-card flat color="primary lighten-9" class="square-card">
                                      <v-card-title style="height: 40px" class="py-0">
                                        Read Only
                                        <v-checkbox type="checkbox" class="ml-3" v-if="cf.systemReadonly"
                                                    :disabled="true"
                                                    :readonly="true"
                                                    v-model="cf.systemReadonly"></v-checkbox>
                                        <v-checkbox type="checkbox" class="ml-3" v-else
                                                    v-model="cf.customFieldGroupAssignmentReadOnly"></v-checkbox>
                                      </v-card-title>
                                      <v-card-text v-if="cf.systemReadonly" class="mt-2">
                                        System Readonly Cannot Change
                                      </v-card-text>
                                      <v-card-text v-else>
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
                                        <br/>
                                        <v-btn color="primary" dark class="d-inline-block white--text"
                                               @click="saveReadOnlyAndWhiteList(cf)">
                                          <v-icon class="mr-2">save</v-icon>
                                          Save Read Only
                                        </v-btn>
                                      </v-card-text>
                                    </v-card>
                                  </v-col>
                                  <v-col cols="6">
                                    <v-card flat color="primary lighten-9" class="square-card">
                                      <v-card-title style="height: 40px" class="py-0">
                                        Hidden
                                        <v-checkbox type="checkbox" class="ml-2"
                                                    v-model="cf.customFieldGroupAssignmentHidden"></v-checkbox>
                                      </v-card-title>
                                      <v-card-text>
                                        <v-autocomplete
                                          v-if="cf.customFieldGroupAssignmentHidden"
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
                                            @click="toggleHiddenSelectAllPositions(cf)"
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
                                                    v-if="index === 0 && cf.hiddenWhiteListedPositions && cf.hiddenWhiteListedPositions.length < 2">
                                              <span>{{ item.position }}</span>
                                            </v-chip>
                                            <span
                                              v-if="index === 1 && cf.hiddenWhiteListedPositions && cf.hiddenWhiteListedPositions.length >= 2"
                                              class="primary--text text-caption"
                                            >{{ cf.hiddenWhiteListedPositions.length }} selected</span>
                                          </template>
                                        </v-autocomplete>
                                        <br/>
                                        <v-btn color="primary" dark class="white--text d-inline-block"
                                               @click="saveHiddenAndWhiteList(cf)">
                                          <v-icon class="mr-2">save</v-icon>
                                          Save Hidden
                                        </v-btn>
                                      </v-card-text>
                                    </v-card>
                                  </v-col>
                                </v-row>
                              </div>
                            </div>
                            <div v-else>
                              <a :href="`/settings/customField/${cf.customFieldId}`">{{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}}
                                (Ancillary)</a>
                              <div v-if="cf.edit" class="mt-3">
                                <label>Use Parent Data: </label>
                                <input type="checkbox" class="ml-3 mb-4" v-model="cf.useParentData"
                                       @change="saveUseParentData(cf)"
                                       :readonly="!userCanEdit" :disabled="!userCanEdit">
                              </div>
                            </div>
                          </v-list-item-content>
                          <v-menu offset-y
                                  v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <v-btn text small color="primary" v-on="{...tooltip, ...menu}"
                                         v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                                    <v-icon>mdi-cursor-move</v-icon>
                                  </v-btn>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in filterBy(localCustomFieldGroups, (g) => { return g.id !== cf.customFieldGroupId })"
                                :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <v-btn text color="primary" small @click="[$set(cf, 'edit', !cf.edit), getPositions()]" v-if="userCanEdit">
                            <v-icon>edit</v-icon>
                          </v-btn>
                          <v-btn v-if="userCanEdit" text color="primary" small @click="[assignmentToDelete=cf, customFieldGroupToDelete=item]"><v-icon>delete</v-icon></v-btn>
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
    <ConfirmationDialog :open-dialog="!!assignmentToDelete" @confirm="[addField=false, newField={}, deleteWithChecks()]" @close-dialog="[customFieldGroupToDelete = null, assignmentToDelete = null]">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to
      "move" the field to another group please cancel and move the field. <br/><br/>

      Are you sure you want to delete <strong>{{ assignmentToDeleteFieldName }}</strong> from <strong>{{itemToDeleteGroupName}}</strong>?

    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import Vue2Filters from 'vue2-filters'
  import draggable from 'vuedraggable'
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
  import ConfirmationDialog from "@/ConfirmationDialog";


  export default {
    name: 'ProcessStepCustomFieldGroups',
    mixins: [Vue2Filters.mixin],
    components: {
      ConfirmationDialog,
      draggable,
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
        newGroup: {},
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
          {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
          {text: 'Name', value: 'groupName', show: true},
          {text: null, value: 'icons', show: true}
        ],
        expanded: [],
        eventTypes: [],
        customFieldGroupToDelete: null,
        assignmentToDelete: null
      }
    },
    created () {},
    computed: {
      localCustomFieldGroups: {
        get: function () {
          return this.customFieldGroups
        },
        set: function (val) {
          val.forEach(v => {
            v.groupOrder = v.newGroupOrder ?? v.groupOrder
          })
          return orderBy(val, v => v.groupOrder)
        }
      },
      itemToDeleteGroupName(){
        return this.customFieldGroupToDelete ? this.customFieldGroupToDelete.groupName : ''
      },
      assignmentToDeleteFieldName() {
        return this.assignmentToDelete ? this.assignmentToDelete.fieldName : ''
      }
    },
    methods: {
      selectAll(f) {
        return f.whiteListedPositions?.length === this.positions?.length
      },
      selectSome(f) {
        return f.whiteListedPositions?.length > 0 && !this.selectAll(f)
      },
      icon(f) {
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

          const {data} = await postRequest(`/customFieldGroup/addProcessStepCustomFieldGroup`, this.newGroup)
          this.localCustomFieldGroups.push(data)
          this.newGroup = {
          }
          this.createNew = false
          this.snackbar = getSnackbar('SUCCESS', 'Group Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Group')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteWithChecks() {
        let item, customFieldGroupId, customFieldGroupAssignmentId;
        if(this.assignmentToDelete){
          item = this.assignmentToDelete
          customFieldGroupAssignmentId = this.assignmentToDelete.id
        } else {
          item = this.customFieldGroupToDelete
          customFieldGroupId = this.customFieldGroupToDelete.id
        }
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            customFieldGroupId, customFieldGroupAssignmentId
          }
          const {data, status} = await putRequest(`/customFieldGroup/deleteWithRequirementChecks`, params, null, [])
          if (data?.length > 0) {
            this.deleteError = true
            item.deleteConfirm = false
            this.fieldsInUse = data
            let errorMsg = 'Group Cannot Be Deleted'
            this.deleteHeader = 'Error Deleting Custom Field Group'
            this.deleteText = 'You cannot delete a group that has a field in use by other groups or requirements.'
            if (null !== customFieldGroupAssignmentId) {
              errorMsg = 'Field Cannot Be Deleted'
              this.deleteHeader = 'Error Deleting Custom Field from Group'
              this.deleteText = 'You cannot delete a field from a group that is in use by other groups or requirements.'
            }
            this.snackbar = getSnackbar('ERROR', errorMsg)
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          } else {
            this.fieldsInUse = []
            item.archived = true
            this.snackbar = getSnackbar('SUCCESS', 'Item Deleted')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            handleHidingGlobalLoader(this, status)
          }
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.assignmentToDelete = null
        this.customFieldGroupToDelete = null
      },
      async saveGroupName(group) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
          this.snackbar = getSnackbar('SUCCESS', 'Group Name Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async moveFieldToOtherGroup(field, newGroup) {
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
      async fetchAvailableCustomFields(objectTypeId, groupId) {
        if(this.addField) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            if (this.addField && this.newFieldType === 'native') {
              const {data, status} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
                params: {
                  companyObjectTypeId: objectTypeId,
                  groupId,
                  processStepId: this.processStepId
                }
              })
              this.availableCustomFields = data
              this.parentObjects = []
              this.ancillaryCustomFields = []
              handleHidingGlobalLoader(this, status)
            } else if (this.addField && this.newFieldType === 'ancillary') {
              this.availableCustomFields = []
              const {data, status} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: this.processStepId}})
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
        }
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
          const {status} = await putRequest(`/customFieldGroup/saveUseParentData`, field)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveReadOnlyAndWhiteList(field) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/customFieldGroup/saveReadOnlyAndWhiteList?savePositions=${field.positionsChanged ?? false}`, field)
          field.positionsChanged = false
          if (!field.customFieldGroupAssignmentReadOnly) {
            this.$set(field, 'whiteListedPositions', [])
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveHiddenAndWhiteList(field) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/customFieldGroup/saveHiddenAndWhiteList?savePositions=${field.hiddenPositionsChanged ?? false}`, field)
          field.hiddenPositionsChanged = false
          if (!field.customFieldGroupAssignmentHidden) {
            this.$set(field, 'hiddenWhiteListedPositions', [])
          }
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Field')
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
            const {status} = await putRequest(`/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
            handleHidingGlobalLoader(this, status)
          }
          this.snackbar = getSnackbar('SUCCESS', 'Fields Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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

          const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
          cfg.customFields.push(data)
          this.newField = {}
          this.snackbar = getSnackbar('SUCCESS', 'Custom Field Assigned')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Assigning Custom Field')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
          cfg.customFields.push(data)
          this.selectedAncillaryField = {}
          this.addField = false
          this.parent = {}
          this.snackbar = getSnackbar('SUCCESS', 'Reference Field Assigned')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Assigning Reference Field')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCustomFieldGroups() {
        return this.localCustomFieldGroups?.filter(cfg => {
          return !cfg.archived
        })
      },
      async saveRowChanges(rows) {
        if (rows?.length > 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {status} = await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
            this.localCustomFieldGroups = orderBy(this.localCustomFieldGroups, 'groupOrder')
            this.snackbar = getSnackbar('SUCCESS', 'Group Order Saved')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            // this componentKey forces the data-table component to re-render
            this.componentKey += 1
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving Group Order')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async getPositions() {
        if (this.positions?.length === 0) {
          try {
            this.positionsLoading = true
            const {data, status} = await getRequest(`/position/withParent`)
            this.positions = data
            this.positionsLoading = false
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            this.positionsLoading = false
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      toggleHiddenSelectAllPositions(field) {
        this.$nextTick(() => {
          if (this.selectAll(field)) {
            field.hiddenWhiteListedPositions = []
            field.hiddenPositionsChanged = true
          } else {
            field.hiddenWhiteListedPositions = cloneDeep(this.positions)
            field.hiddenPositionsChanged = true
          }
        })
      },
      toggleSelectAllPositions(field) {
        this.$nextTick(() => {
          if (this.selectAll(field)) {
            field.whiteListedPositions = []
            field.positionsChanged = true
          } else {
            field.whiteListedPositions = cloneDeep(this.positions)
            field.positionsChanged = true
          }
        })
      },
      copyToClipBoard(textValue, copy){
        if(copy) {
          navigator.clipboard.writeText(textValue);
          this.snackbar = getSnackbar('SUCCESS', 'Copied text to clipboard')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      }
    }

  }
</script>

<style scoped lang="scss">
  .custom-field-group {
    border: solid 1px var(--v-primary-lighten9) !important;
  }

  .custom-field-group-border {
    border-bottom: solid 1px var(--v-primary-lighten9) !important;
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
