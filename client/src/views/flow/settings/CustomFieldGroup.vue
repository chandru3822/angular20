<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newGroup = {}">
            {{addNew ? 'Cancel' : 'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
      <v-container>
        <v-text-field v-if="addNew"
            v-model="newGroup.groupName"
            placeholder="Enter new group name"
            append-outer-icon="save"
            @click:append-outer="addCustomFieldGroupType"
            label="Custom Field Group">
        </v-text-field>

        <v-data-table
            :headers="headers"
            :items="filterCustomFieldGroupTypes()"
            :items-per-page="-1"
            single-expand
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

          <template #item.groupName="{ item }">
            <v-text-field text
              v-if="item.edit"
              v-model="item.groupName">
              <template slot="append-outer">
                <v-icon @click="saveGroupTypeName(item); item.edit = false">save</v-icon>
                <v-icon @click="item.edit = false">clear</v-icon>
              </template>
            </v-text-field>
            <a style="text-decoration: underline;" v-else @click="item.edit = true">
              {{item.groupName}}
            </a>
          </template>

          <template #item.draggable="{ item }">
            <v-btn text icon small class="handle">
              <v-icon>drag_handle</v-icon>
            </v-btn>
          </template>


          <template #item.icons="{ item }">
            <div class="item-icons">
              <v-btn small text @click="addField = !addField; fetchAvailableCustomFields(item.id); expanded = [item]">
                <v-icon v-if="addField && expanded.includes(item)">remove</v-icon>
                <v-icon v-else>add</v-icon>
              </v-btn>
              <v-btn small text @click="expanded.includes(item) ? expanded = [] : expanded = [item]">
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
          </template>

          <template #expanded-item="{ headers, item, index }">
            <td :colspan="headers.length" class="pb-4">
              <v-flex xs12 justify-center class="pl-3 pr-3" >
                <v-select v-if="addField"
                          v-model="newField"
                          :items="availableCustomFields"
                          label="Select Custom Field to Add"
                          item-text="fieldName"
                          return-object
                          @input="assignCustomField(item)"
                ></v-select>
                <h3 class="text-left">Assigned Custom Fields</h3>
                <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                           group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                  <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                          :key="index"
                          :class="{ 'shaded-row': index % 2 }">
                    <v-list-item class="grab">
                      <v-list-item-action>
                        <v-icon>drag_handle</v-icon>
                      </v-list-item-action>
                      <v-list-item-content>
                        {{cf.fieldName}} {{ cf.ancillaryCustomFieldGroupId == null ? '' : '(Ancillary)' }}
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
              </v-flex>
            </td>
          </template>
        </v-data-table>

  <!--      <draggable v-if="customFieldGroupTypes.length > 0" v-model="customFieldGroupTypes"-->
  <!--                 group="customFieldGroupTypes" @start="drag=true" @end="drag=false"  @change="changeGroupOrder">-->
  <!--        <v-list v-for="(cfgt, index) in filterBy(customFieldGroupTypes, false, 'archived')"-->
  <!--                :key="index">-->
  <!--          <v-list-item class="grab" :class="{ 'shaded-row': cfgt.id === selectedGroupId }">-->
  <!--            <v-list-item-content>-->
  <!--              <v-text-field class="one-hunned" v-if="selectedGroupId === cfgt.id" v-model="cfgt.groupName" @input="cfgt.nameChanged = true">-->
  <!--              </v-text-field>-->
  <!--              <div v-else>{{cfgt.groupName}}</div>-->
  <!--            </v-list-item-content>-->
  <!--            <v-list-item-action>-->
  <!--              <v-icon>drag_handle</v-icon>-->
  <!--            </v-list-item-action>-->
  <!--            <v-list-item-action class="clickable">-->
  <!--              <v-icon v-if="selectedGroupId === cfgt.id && cfgt.originalGroupName !== cfgt.groupName" @click="cfgt.originalGroupName = cfgt.groupName; saveGroupTypeName(index, cfgt)">save</v-icon>-->
  <!--              <v-icon v-else @click="selectedGroupId = cfgt.id; fetchCustomFields()">edit</v-icon>-->
  <!--            </v-list-item-action>-->
  <!--            <v-dialog-->
  <!--                v-model="cfgt.deleteConfirm"-->
  <!--                width="500">-->
  <!--              <template v-slot:activator="{ on }">-->
  <!--                <v-list-item-action class="clickable" v-on="on">-->
  <!--                  <v-icon>delete</v-icon>-->
  <!--                </v-list-item-action>-->
  <!--              </template>-->
  <!--              <v-card>-->
  <!--                <v-card-title-->
  <!--                    class="headline grey lighten-2"-->
  <!--                    primary-title-->
  <!--                >-->
  <!--                  Confirm-->
  <!--                </v-card-title>-->

  <!--                <v-card-text>-->
  <!--                  Are you sure you want to delete this group: <strong>{{ cfgt.groupName }}</strong>?-->
  <!--                </v-card-text>-->

  <!--                <v-divider></v-divider>-->

  <!--                <v-card-actions>-->
  <!--                  <v-spacer></v-spacer>-->
  <!--                  <v-btn-->
  <!--                      @click="cfgt.deleteConfirm = false">-->
  <!--                    No-->
  <!--                  </v-btn>-->
  <!--                  <v-btn-->
  <!--                      color="primary"-->
  <!--                      text-->
  <!--                      @click="cfgt.archived = true; deleteGroup(cfgt.id)">-->
  <!--                    Yes-->
  <!--                  </v-btn>-->
  <!--                </v-card-actions>-->
  <!--              </v-card>-->
  <!--            </v-dialog>-->
  <!--          </v-list-item>-->

  <!--        </v-list>-->
  <!--      </draggable>-->
  <!--      <v-btn v-if="addNew" @click="addCustomFieldGroupType">Save</v-btn>-->
  <!--      <v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
  <!--    </v-container>-->
  <!--    <v-container v-if="selectedGroupId !== null">-->
  <!--      <h3>Custom Fields</h3>-->
  <!--      <v-btn @click="addField = !addField; fetchAvailableCustomFields()">-->
  <!--        {{addField ? 'Cancel' : 'Add Field'}}-->
  <!--      </v-btn>-->
  <!--      <v-select v-if="addField"-->
  <!--                v-model="newField"-->
  <!--                :items="availableCustomFields"-->
  <!--                label="New Custom Field Group"-->
  <!--                item-text="fieldName"-->
  <!--                return-object-->
  <!--                @input="assignCustomField"-->
  <!--      ></v-select>-->
  <!--      <draggable v-model="customFields" v-if="customFields.length > 0"-->
  <!--                 group="customFields" @start="drag=true" @end="drag=false" @change="changeFieldOrder">-->
  <!--        <v-list v-for="(cf, index) in filterBy(customFields, false, 'archived')"-->
  <!--                :key="index">-->
  <!--          <v-list-item class="grab">-->
  <!--            <v-list-item-content>-->
  <!--              {{cf.fieldName}}-->
  <!--            </v-list-item-content>-->
  <!--            <v-list-item-action>-->
  <!--              <v-icon>drag_handle</v-icon>-->
  <!--            </v-list-item-action>-->
  <!--            <v-dialog-->
  <!--                v-model="cf.deleteConfirm"-->
  <!--                width="500">-->
  <!--              <template v-slot:activator="{ on }">-->
  <!--                <v-list-item-action class="clickable" v-on="on">-->
  <!--                  <v-icon>delete</v-icon>-->
  <!--                </v-list-item-action>-->
  <!--              </template>-->
  <!--              <v-card>-->
  <!--                <v-card-title-->
  <!--                    class="headline grey lighten-2"-->
  <!--                    primary-title-->
  <!--                >-->
  <!--                  Confirm-->
  <!--                </v-card-title>-->

  <!--                <v-card-text>-->
  <!--                  Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{ cf.groupName }}</strong>?-->
  <!--                </v-card-text>-->

  <!--                <v-divider></v-divider>-->

  <!--                <v-card-actions>-->
  <!--                  <v-spacer></v-spacer>-->
  <!--                  <v-btn-->
  <!--                      @click="cf.deleteConfirm = false">-->
  <!--                    No-->
  <!--                  </v-btn>-->
  <!--                  <v-btn-->
  <!--                      color="primary"-->
  <!--                      text-->
  <!--                      @click="cf.archived = true; deleteFieldFromGroup(cf.id)">-->
  <!--                    Yes-->
  <!--                  </v-btn>-->
  <!--                </v-card-actions>-->
  <!--              </v-card>-->
  <!--            </v-dialog>-->
  <!--          </v-list-item>-->
  <!--        </v-list>-->
  <!--      </draggable>-->
  <!--      <v-btn v-if="fieldOrderChanged" @click="saveFieldChanges">Save Changes</v-btn>-->
      </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
import { IS_MOBILE } from '@/helpers/helpers'
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'
import Sortable from 'sortablejs'
import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

export default {
  name: 'CustomFieldGroup',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable
  },
  data () {
    return {
      addNew: false,
      fieldOrderChanged: false,
      groupOrderChanged: false,
      newGroup: {
        groupName: null
      },
      addField: false,
      newField: {},
      customFieldGroupTypes: [],
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
        const rowSelected = _self.customFieldGroupTypes.splice(oldIndex, 1)[0]
        _self.customFieldGroupTypes.splice(newIndex, 0, rowSelected)
        console.log('sort event happened', _self.customFieldGroupTypes)
        _self.saveGroupChanges(_self.customFieldGroupTypes)
      }
    })
  },
  watch: {
    // whenever objectTypeId changes, this function will run
    '$route.params.id': function (oldObjectTypeId, newObjectTypeId) {
      // reset the selected group when the object type changes
      this.availableCustomFields = []
      this.getCustomFieldGroupTypes()
    }
  },
  created () {
    this.getCustomFieldGroupTypes()
  },
  methods: {
    async getCustomFieldGroupTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
        params: {
          objectTypeId: this.$route.params.id
        }
      })
      this.customFieldGroupTypes = cloneDeep(data)
      this.$store.commit(AppMutations.SET_LOADING, false)
    },
    async fetchAvailableCustomFields (groupTypeId) {
      const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getAvailableCustomFieldsInGroup`, {
        params: {
          objectTypeId: this.$route.params.id,
          groupTypeId
        }
      })
      this.availableCustomFields = data
    },
    async addCustomFieldGroupType () {
      this.newGroup.objectTypeId = this.$route.params.id
      // setting groupOrder to 0, then they can sort later
      this.newGroup.groupOrder = 0
      const {data} = await postRequest(`/api/v1/flow/customFieldGroup/addCustomFieldGroupType`, this.newGroup)
      this.newGroup = {}
      this.addNew = false
      // add the new type to the list
      this.customFieldGroupTypes.push(data)
    },
    async assignCustomField (item) {
      this.addField = false
      this.newField.fieldOrder = 0
      this.newField.customFieldGroupTypeId = item.id
      const {data} = await postRequest(`/api/v1/flow/customFieldGroup/addFieldToGroup`, this.newField)
      console.log('randaLogger d', data)
      console.log('randaLogger i', item)
      item.customFields.unshift(data)
      this.newField = {}
    },
    async saveGroupChanges (groups) {
      groups.forEach((g, idx) => {
        g.groupOrder = idx
      })
      await putRequest(`/api/v1/flow/customFieldGroup/updateCustomFieldGroupTypes`, groups)
    },
    async saveGroupTypeName (groupType) {
      await putRequest(`/api/v1/flow/customFieldGroup/updateCustomFieldGroupType`, groupType)
    },
    async deleteGroup (groupTypeId) {
      await deleteRequest(`/api/v1/flow/customFieldGroup/deleteCustomFieldGroupType/${groupTypeId}`)
    },
    async deleteFieldFromGroup (fieldGroupId) {
      await deleteRequest(`/api/v1/flow/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
    },
    async saveFieldChanges (fields) {
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
      console.log('randaLogger', fieldsToSave)
      if(fieldsToSave.length > 0) {
        await putRequest(`/api/v1/flow/customFieldGroup/updateFieldsInGroup`, fieldsToSave)
      }

    },
    filterCustomFieldGroupTypes () {
      return this.customFieldGroupTypes.filter(cfgt => { return !cfgt.archived})
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
