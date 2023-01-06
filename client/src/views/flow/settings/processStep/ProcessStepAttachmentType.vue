<template>
  <v-container class="pt-0">
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">{{ selectedAttachment.attachmentType }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>

          </v-toolbar-items>
        </v-toolbar>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pt-0 px-0">
        <v-toolbar flat class="cfg-header-bar">
          <v-toolbar-title class="app-title">Ancillary Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="!createNew && userCanAdd" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              <span v-if="!constants.IS_MOBILE">Create Group</span>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-left one-hunned pa-3 square-card add-new" flat
                color="rowShadeCustom">
          <div>
            <v-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
            ></v-text-field>
          </div>
          <v-btn
            color="primary"
            class="mr-2"
            :disabled="!newGroup.groupName"
            @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
            @click="[newGroup = {}, createNew = false]">
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
              class="elevation-1 fix-column-width-bug attachment-cfg-table square-card"
            >
              <template #no-data>
                No custom field groups for this process step attachment type
              </template>

              <template #no-results>
                No custom field groups for this process step attachment type
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': localCustomFieldGroups.indexOf(item) % 2}">
                  <td style="width: 50px">
                    <v-btn text icon small class="handle" v-if="userCanEdit">
                      <v-icon>drag_handle</v-icon>
                    </v-btn>
                  </td>
                  <td class="text-left">
                    <div v-if="userCanEdit">
                      <v-text-field text
                                    v-if="item.edit"
                                    v-model="item.groupName">
                        <template slot="append-outer">
                          <v-icon @click="[saveGroupName(item), item.edit = false]">save</v-icon>
                          <v-icon @click="item.edit = false">clear</v-icon>
                        </template>
                      </v-text-field>
                      <a style="text-decoration: underline;" v-else @click="item.edit = true">
                        {{ item.groupName }}
                      </a>
                    </div>
                    <span v-else>{{ item.groupName }}</span>
                  </td>
                  <td class="text-right">
                    <div class="item-icons">
                      <v-btn v-if="userCanAdd" small text
                             @click="[addField = !addField, selectedIndex = index, expanded = [item], loadFieldsByParent()]">
                        <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                        <v-icon v-else>add</v-icon>
                      </v-btn>
                      <v-btn small text
                             @click="[expanded.includes(item) ? expanded = [] : expanded = [item], selectedIndex = index]">
                        <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                        <v-icon v-else>expand_more</v-icon>
                      </v-btn>
                      <v-btn small color="primary" text @click="cfGroupToDelete = item"><v-icon>delete</v-icon></v-btn>
                    </div>
                  </td>
                </tr>
              </template>

              <template #expanded-item="{ headers, item }">
                <td :colspan="headers.length" class="pb-2 px-0" :class="{'shaded-row': selectedIndex % 2}">
                  <v-col cols="12" class="pl-3 pr-3 justify" v-if="addField">
                    <h3 class="text-left">Add Ancillary Field</h3>
                    <v-autocomplete v-model="selectedAncillaryField"
                                    :items="ancillaryCustomFields"
                                    label="Ancillary Custom Field"
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
                        <v-list-item :class="{grab: !item.attachmentTypeId}">
                          <v-list-item-action>
                            <v-icon v-if="userCanEdit">drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content>
                            {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                          </v-list-item-content>
                          <v-menu offset-y
                                  v-if="localCustomFieldGroups.length > 1 && $store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT')">
                            <template v-slot:activator="{ on: menu }">
                              <v-tooltip bottom>
                                <template v-slot:activator="{ on: tooltip }">
                                  <v-btn text small v-on="{...tooltip, ...menu}"
                                         v-if="!cf.ancillaryCustomFieldGroupAssignmentId">
                                    <v-icon>mdi-cursor-move</v-icon>
                                  </v-btn>
                                </template>
                                <span>Move to Other Group</span>
                              </v-tooltip>
                            </template>
                            <v-list>
                              <v-list-item
                                v-for="(cfg, index) in filterBy(localCustomFieldGroups, (g) => { return g.id !== cf.customFieldGroupId && !g.attachmentTypeId })"
                                :key="index" @click="moveFieldToOtherGroup(cf, cfg)">
                                <v-list-item-title>{{ cfg.groupName }}</v-list-item-title>
                              </v-list-item>
                            </v-list>
                          </v-menu>
                          <v-list-item-action v-if="userCanEdit" class="clickable" @click="customFieldToDelete = cf">
                            <v-icon color="primary">delete</v-icon>
                          </v-list-item-action>
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
    <ConfirmationDialog :open-dialog="!!cfGroupToDelete" @confirm="deleteWithChecks" @close-dialog="cfGroupToDelete = null">
      <span class="error--text">WARNING:</span>
      By deleting a Custom Field Group you will lose all data associated with fields in the group.<br/>
      Are you sure you want to delete this Custom Field Group: <strong>{{groupToDeleteName}}</strong>?<br/>
    </ConfirmationDialog>
    <ConfirmationDialog :open-dialog="!!customFieldToDelete" @confirm="[deleteWithChecks(), addField=false, newField={}]" @close-dialog="customFieldToDelete=null">
      <span class="error--text">WARNING:</span>
      By deleting a field you will lose all data associated with the field. If you meant to
      "move" the field to another group please cancel and move the field. <br/>
      Are you sure you want to delete <strong>{{ fieldToDeleteName }}</strong> from <strong>{{fieldToDeleteGroupName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
import Vue2Filters from 'vue2-filters'
import {AppMutations} from '@/stores/AppStore'
import {
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,
  getSnackbar, logError, handleHidingGlobalLoader, getRequestWithParams
} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import draggable from 'vuedraggable'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog";
import ConfirmationDialog from "../../../../ConfirmationDialog";

export default {
  name: 'ProcessStepAttachmentType',
  mixins: [Vue2Filters.mixin],
  components: {
    ConfirmationDialog,
    ConfirmDeleteDialog,
    draggable,
  },
  data() {
    return {
      snackbar: {},
      addField: false,
      createNew: false,
      constants,
      selectedAttachment: {},
      attachmentLoading: true,
      // selectedIndex is a dumb work around because `index` is not available in the `expanded-item` slot yet.
      selectedIndex: null,
      processStepId: this.$route.params.id,
      attachmentTypeId: parseInt(this.$route.params.attachmentTypeId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      componentKey: 0,
      newGroup: {},
      expanded: [],
      selectedAncillaryField: {},
      ancillaryCustomFields: [],
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Name', value: 'groupName', show: true},
        {text: null, value: 'icons', show: true}
      ],
      cfGroupToDelete: null,
      customFieldToDelete: null,
    }
  },
  computed: {
    localCustomFieldGroups: {
      get: function () {
        return this.selectedAttachment?.customFieldGroups
      },
      set: function (val) {
        val.forEach(v => {
          v.groupOrder = v.newGroupOrder ?? v.groupOrder
        })
        return orderBy(val, v => v.groupOrder)
      }
    },
    groupToDeleteName() {
      return this.cfGroupToDelete ? this.cfGroupToDelete.groupName : ''
    },
    fieldToDeleteName() {
      return this.customFieldToDelete ? this.customFieldToDelete.fieldName : ''
    },
    fieldToDeleteGroupName() {
      return this.customFieldToDelete ? this.customFieldToDelete.groupName : ''
    }
  },
  async created() {
    await this.getTypeDetails()
  },
  updated() {
    // this had to be in updated vs mounted so that after the re-render the dragging still works
    let table = document.querySelector('.attachment-cfg-table tbody')
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
  methods: {
    async getTypeDetails() {
      try {
        this.attachmentLoading = true
        const {data} = await getRequest(`/processStep/${this.processStepId}/attachmentType/${this.attachmentTypeId}`)
        this.selectedAttachment = data
        this.attachmentLoading = false
      } catch (e) {
        this.attachmentLoading = true
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Attachment Type Details')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.companyStatusesLoading = false
      }
    },
    async saveFieldGroup() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.newGroup.processStepAttachmentTypeId = this.$route.params.attachmentTypeId

        const {data} = await postRequest(`/customFieldGroup/addAttachmentCustomFieldGroup`, this.newGroup)
        this.localCustomFieldGroups.push(data)
        this.newGroup = {}
        this.createNew = false
        this.snackbar = getSnackbar('SUCCESS', 'Group Saved')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Group')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveFieldChanges(fields) {
      this.$store.commit(AppMutations.SET_LOADING, true)
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
    async saveGroupName(group) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await putRequest(`/customFieldGroup/updateCustomFieldGroup`, group)
        this.snackbar = getSnackbar('SUCCESS', 'Group Name Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Change')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async fetchAvailableCustomFields(objectTypeId, groupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        this.availableCustomFields = []
        const {data} = await getRequestWithParams(`/processStep/getParentObjectsWithTypes`, {params: {id: this.processStepId}})
        this.selectedAncillaryField = {}
        this.parentObjects = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteWithChecks() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      let item = this.cfGroupToDelete ? this.cfGroupToDelete : this.customFieldToDelete ? this.customFieldToDelete : null
      let customFieldGroupId = this.cfGroupToDelete ? this.cfGroupToDelete.id : null
      let customFieldGroupAssignmentId = this.customFieldToDelete ? this.customFieldToDelete.id : null
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
          if (null !== customFieldGroupAssignmentId) {
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
    async loadFieldsByParent() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/customField/getByParentProcessStep/${this.processStepId}`)
        this.ancillaryCustomFields = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
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
        const {data, status} = await postRequest(`/customFieldGroup/addFieldToGroup`, params)
        item.customFields.push(data)
        this.newField = {}
        this.selectedAncillaryField = {}
        this.parent = {}
        this.addField = false
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
    async saveRowChanges(rows) {
      if (rows?.length > 0) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/customFieldGroup/updateCustomFieldGroups`, rows)
          this.localCustomFieldGroups = orderBy(this.localCustomFieldGroups, 'groupOrder')
          this.snackbar = getSnackbar('SUCCESS', 'Group Order Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          // this componentKey forces the data-table component to re-render
          this.componentKey += 1
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Group Order')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    },
    filterCustomFieldGroups() {
      return this.localCustomFieldGroups?.filter(cfg => {
        return !cfg.archived
      })
    },
  }

}
</script>

<style lang="scss">


</style>

<style scoped lang="scss">

</style>
