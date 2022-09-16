<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-container v-for="n in 2">
        <span v-if="objectType && objectType.customColumns" class="albatross-header-4 mb-2">Column {{n===1 ? 'One' : 'Two'}}</span>
        <v-data-table
            :id="n"
            :headers="headers"
            :items="groupsByColumn[n]"
            :items-per-page="-1"
            single-expand
            :sort-by="['groupOrder']"
            :sort-desc="[false]"
            :expanded.sync="expanded"
            hide-default-footer
            hide-default-header
            class="elevation-1 fix-column-width-bug mb-5 draggable-table"
            :hidden="n>1 && !objectType.customColumns"
          >
            <template #no-data>
              <span class="default-text-color">No available field groups</span>
            </template>

            <template #no-results>
              <span class="default-text-color">No available field groups</span>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td style="width: 50px">
                  <v-btn text color="primary" icon small class="handle" v-if="userCanEdit">
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
                    <v-btn v-if="userCanEdit" small text color="primary" @click="cfgToDelete=item"><v-icon>delete</v-icon></v-btn>
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
                          <v-icon color="primary">drag_handle</v-icon>
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
                            <v-btn text color="primary" @click="saveMinMax(cf)"
                                   :disabled="!cf.minMaxValueChanged">
                              <v-icon>save</v-icon>
                            </v-btn>
                          </div>
                        </v-list-item-content>
                        <v-btn v-if="$store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')" small text color="primary" @click="[cfgToDelete=item, cFieldToDelete = cf]">
                          <v-icon>delete</v-icon>
                        </v-btn>
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
      Are you sure you want to delete this Custom Field Group: <strong>{{cfgToDeleteName}}</strong>?
    </ConfirmationDialog>
    <ConfirmationDialog
        :open-dialog="!!cFieldToDelete"
        @confirm="deleteFieldFromGroup"
        @close-dialog="[cfgToDelete = null, cFieldToDelete = null]">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to "move" the field to another group please cancel and move the field. <br/><br/>
      Are you sure you want to delete this field from {{cfgToDeleteName}}: <strong>{{cFieldToDeleteName}}</strong>?
    </ConfirmationDialog>
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
import ConfirmationDialog from "@/ConfirmationDialog";

export default {
  name: 'CompanyCustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    draggable
  },
  data() {
    return {
      snackbar: {},
      constants,
      addNew: false,
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
      cfgToDelete: null,
      cFieldToDelete: null,
      groupsByColumn:[],
      columnChangeCount: 0,
      count: 0
    }
  },
  props :{
    objectType: Object,
    customFieldGroups: Array,
  },
  watch: {
    expanded(){
      this.count++
      console.log(this.count)
      console.log(this.expanded)
      debugger
    },
    objectType(){
      this.groupsByColumn = [undefined, this.getGroupsByCol(1), this.getGroupsByCol(2)]
    }
  },
  computed: {
    cfgToDeleteName(){
      return this.cfgToDelete ? this.cfgToDelete.groupName : ''
    },
    cFieldToDeleteName(){
      return this.cFieldToDelete ? this.cFieldToDelete.fieldName : ''
    },
    numberOfCols(){
      if(this.objectType && this.objectType.customColumns) {
        return 2
      }
      return 1
    }
  },
  mounted() {
    let tables = document.querySelectorAll('tbody')
    const _self = this
    console.log(this.objectType.customColumns)
    console.log(tables)
    for(const table of tables) {
      Sortable.create(table, {
        group: {name: 'fieldGroups', pull: true, put: true},
        handle: '.handle',
        connectWith: '.connectedSortable',
        onEnd({to, from, newIndex, oldIndex, oldDraggableIndex, newDraggableIndex}) {
          const fromColumnNumber = parseInt(from.parentElement.parentElement.parentElement.id)
          const toColumnNumber = parseInt(to.parentElement.parentElement.parentElement.id)
          //if the to and from tables don't match, move from old column to new column
          // if the tp and from tables DO match, it doesn't matter which one we use here
          const rowSelected = _self.groupsByColumn[fromColumnNumber].splice(oldIndex, 1)[0]
          rowSelected.groupColumnOrder = toColumnNumber //make sure the groupColumnOrder value is correct
          console.log(rowSelected)
          //put the selected group into the correct column at the new Index
          _self.groupsByColumn[rowSelected.groupColumnOrder].splice(newIndex, 0, rowSelected)
          //make sure each group in every column has the correct groupOrder
          // and concat all columns into a single array for updating
          let groupsClone = cloneDeep(_self.groupsByColumn)

          let updatedGroups = []
          for(let i =1; i<=_self.numberOfCols; i++) {
           groupsClone[i].forEach((g, idx) => {
             let save = g.newDisplayOrder === undefined ? g.groupOrder !== idx : g.newDisplayOrder !== idx
              //update display order
              g.groupOrder = idx
              //save only rows that changed
              if (save) {
                _self.groupsByColumn[i][idx].newDisplayOrder = idx
                updatedGroups.push(g)
              }
              g.groupOrder = idx
            })
          }
          _self.saveGroupChanges(updatedGroups)
          _self.columnChangeCount++
        }
      })
    }
  },
  created() {
    // for( let i=1; i<=this.numberOfCols; i++) {
    //   this.groupsByColumn.push(this.getGroupsByCol(i))
    // }
    this.groupsByColumn = [undefined, this.getGroupsByCol(1), this.getGroupsByCol(2)]

  },
  methods: {
    changedMinMax(cf) {
      this.$set(cf, 'minMaxValueChanged', true)
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
    async deleteGroup() {
      const item = this.cfgToDelete
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
      this.cfgToDelete=null
    },
    async deleteFieldFromGroup() {
      const item=this.cFieldToDelete
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
      this.cFieldToDelete=null
      this.cfgToDelete = null
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
    getGroupsByCol(colNumber) {
      if(this.objectType && this.objectType.customColumns) {
        return this.filterCustomFieldGroups().filter(cfg => cfg.groupColumnOrder === colNumber)
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
      return this.filterCustomFieldGroups()
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
