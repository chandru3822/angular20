<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!IS_MOBILE" class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addNew = !addNew; newGroup = {}">
              <v-icon v-if="IS_MOBILE">add</v-icon>
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
              class="elevation-1 fix-column-width-bug"
          >
            <template #no-data>
              No available field groups
            </template>

            <template #no-results>
              No available field groups
            </template>

            <template #item="{ item, index }">
              <tr  :class="{'shaded-row': index % 2}">
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
                      <v-icon @click="saveGroupName(item); item.edit = false">save</v-icon>
                      <v-icon @click="item.edit = false">clear</v-icon>
                    </template>
                  </v-text-field>
                  <a style="text-decoration: underline;" v-else @click="item.edit = true">
                    {{item.groupName}}
                  </a>
                </td>
                <td>
                  <div class="item-icons">
                    <v-btn small text @click="addField = !addField; fetchAvailableCustomFields(item.id); expanded = [item]; selectedIndex = index">
                      <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                      <v-icon v-else>add</v-icon>
                    </v-btn>
                    <v-btn small text @click="expanded.includes(item) ? expanded = [] : expanded = [item]; selectedIndex = index">
                      <v-icon v-if="expanded.includes(item)">expand_less</v-icon>
                      <v-icon v-else>expand_more</v-icon>
                    </v-btn>
                    <v-dialog
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
                              color="primary"
                              text
                              @click="item.archived = true; deleteGroup(item.id)">
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
                <v-col  cols="12" justify="center"  class="px-3 py-0" >
                  <v-select v-if="addField"
                            v-model="newField"
                            :items="availableCustomFields"
                            label="Select Custom Field to Add"
                            item-text="fieldName"
                            return-object
                            @input="assignCustomField(item)"
                  ></v-select>
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
                          {{cf.fieldName}} {{ cf.ancillaryCustomFieldGroupAssignmentId == null ? '' : '(Ancillary)' }}
                          <div class="text-left">
                            <input type="checkbox" v-model="cf.showOnInsert" @change="updateShowOnInsert(cf)">
                            Show On Insert
                          </div>
                        </v-list-item-content>
                        <v-dialog
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

                            <v-card-text>
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
                                  @click="cf.archived = true; deleteFieldFromGroup(cf.id)">
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
import { getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar, IS_MOBILE } from '@/helpers/helpers'

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
      IS_MOBILE,
      addNew: false,
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
        console.log('sort event happened', fieldGroupsClone)
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
        const {data} = await getRequestWithParams(`/customFieldGroup/getAvailableCustomFields`, {
          params: {
            companyObjectTypeId: this.$route.params.id,
            groupId
          }
        })
        this.availableCustomFields = data
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
    async deleteGroup (groupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/customFieldGroup/deleteCustomFieldGroup/${groupId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Group Deleted')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Deleting Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteFieldFromGroup (fieldGroupId) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        await deleteRequest(`/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
        this.snackbar = getSnackbar('SUCCESS', 'Field Removed From Group')
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing Field from Group')
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
