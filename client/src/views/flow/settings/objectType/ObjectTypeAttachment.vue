<template>
    <v-container class="pt-0" v-if="!attachmentLoading">
      <v-row>
        <v-col cols="12" class="pt-0 px-0">
          <v-toolbar flat>
            <v-toolbar-title class="app-title">{{ selectedAttachment.attachmentType }}</v-toolbar-title>
          </v-toolbar>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="12" class="pt-0 px-0">
          <v-toolbar flat class="cfg-header-bar">
            <v-toolbar-title class="app-title">Ancillary Custom Field Groups</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn text v-if="!createNew && userCanAdd" @click="createNew = !createNew">
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
                  No custom field groups assigned
                </template>

                <template #no-results>
                  No custom field groups assigned
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
                        <confirm-delete-dialog
                          v-if="userCanEdit"
                          label="this Custom Field Group: "
                          :item-to-delete="item.groupName"
                          @confirm="deleteWithChecks(item, item.id, null)"
                        ><span class="error--text">WARNING:</span>
                          By deleting a Custom Field Group you will lose all data associated with native fields in the group.<br/><br/>
                        </confirm-delete-dialog>
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
                              <div v-if="null != cf.defaultFieldId">
                                {{ cf.objectType }}: {{ cf.fieldName }}
                              </div>
                              <div v-else>
                                {{ cf.processStepName || cf.objectType }}: {{ cf.groupName }} - {{cf.fieldName}} (Ancillary)
                              </div>
                            </v-list-item-content>

                            <v-dialog
                              v-if="userCanEdit"
                              v-model="cf.deleteConfirm"
                              width="500">
                              <template v-slot:activator="{ on }">
                                <v-list-item-action class="clickable" v-on="on">
                                  <v-icon>delete</v-icon>
                                </v-list-item-action>
                              </template>
                              <v-card>
                                <v-card-title
                                  class="text-h5 grey lighten-2"
                                  primary-title>
                                  Confirm
                                </v-card-title>

                                <v-card-text class="mt-2">
                                  Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{
                                    item.groupName
                                  }}</strong>?
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
                                    @click="[addField=false, newField={}, deleteWithChecks(cf, null, cf.customFieldGroupAssignmentId)]">
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

        </v-col>
      </v-row>
  </v-container>
</template>

<script>
import {AppMutations} from "@/stores/AppStore";
import draggable from 'vuedraggable'
import {
  handleHidingGlobalLoader,
  deleteRequest,
  getRequest,
  getSnackbar,
  postRequest,
  putRequest,
  getRequestWithParams
} from "@/helpers/helpers";
import Vue2Filters from "vue2-filters";
import constants from "@/helpers/constants";
import orderBy from 'lodash.orderby'
import Sortable from "sortablejs"
import cloneDeep from 'lodash.clonedeep'
import ConfirmDeleteDialog from "@/ConfirmDeleteDialog"

export default {
  name: 'ObjectTypeAttachment',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable,
    ConfirmDeleteDialog
  },
  props: {
    objectTypeValue: String,
    showReadOnly: Boolean,
    primaryKey: Number //used for getting attachments for events
  },
  data () {
    return {
      snackbar: {},
      addField: false,
      createNew: false,
      constants,
      newField: {},
      ancillaryCustomFields: [],
      selectedAncillaryField: {},
      selectedAttachment: {},
      attachmentLoading: true,
      selectedIndex: null,
      companyObjectTypeId: parseInt(this.$route.query.companyObjectTypeId) || parseInt(this.$route.params.id),
      attachmentTypeId: parseInt(this.$route.params.attachmentTypeId),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD'),
      componentKey: 0,
      newGroup: {},
      expanded: [],
      headers: [
        {text: null, value: 'draggable', width: '50px', show: true, sortable: false},
        {text: 'Name', value: 'groupName', show: true},
        {text: null, value: 'icons', show: true}
      ],
    }
  },
  watch: {},
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
    objectType () {
      if(null != this.objectTypeValue) {
        return this.objectTypeValue
      } else {
        switch(this.companyObjectTypeId) {
          case 3: return 'user'
          case 2: return 'contact'
          case 5: return 'organization'
        }
      }
    },
  },
  async created () {
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
        const {data} = await getRequest(`/attachmentType/${this.attachmentTypeId}/${this.objectType}`)
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
        switch(this.objectType) {
          case 'project':
            this.newGroup.projectAttachmentTypeId = this.attachmentTypeId
            break
          case 'contact':
            this.newGroup.contactAttachmentTypeId = this.attachmentTypeId
            break
          case 'user':
            this.newGroup.userAttachmentTypeId = this.attachmentTypeId
            break
          case 'organization':
            this.newGroup.orgAttachmentTypeId = this.attachmentTypeId
            break
          case 'event':
            this.newGroup.eventAttachmentTypeId = this.attachmentTypeId
            break
        }

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
    async fetchAvailableCustomFields() {
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
    async deleteWithChecks(item, customFieldGroupId, customFieldGroupAssignmentId) {
      console.log('item',item)
      console.log('cfga',customFieldGroupAssignmentId)
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
        let url = `/customField/getByParentType/${this.companyObjectTypeId}`
        if(this.objectTypeValue === 'event') {
          url = `/customField/getByEvent/${this.primaryKey}`
        }
        const {data, status} = await getRequest(url)
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
          defaultFieldId: this.selectedAncillaryField.defaultFieldId,
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

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">

</style>
