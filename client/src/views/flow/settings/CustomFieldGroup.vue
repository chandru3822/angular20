<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-btn text @click="addNew = !addNew; newGroup = {}; selectedGroupId = null; customFields = []">
            {{addNew ? 'Cancel' : 'Add New'}}
          </v-btn>
        </v-toolbar-items>
      </v-toolbar>
    <v-container>
      <v-text-field v-if="addNew"
          v-model="newGroup.groupName"
          placeholder="Enter new group name"
          label="Custom Field Group">
      </v-text-field>
      <!--<v-select v-else-->
          <!--v-models="selectedGroup"-->
          <!--:items="customFieldGroupTypes"-->
          <!--label="Custom Field Group"-->
          <!--item-text="groupName"-->
          <!--return-object-->
          <!--@input="fetchCustomFields"-->
      <!--&gt;</v-select>-->
      <draggable v-else-if="customFieldGroupTypes.length > 0" v-model="customFieldGroupTypes"
                 group="customFieldGroupTypes" @start="drag=true" @end="drag=false"  @change="changeGroupOrder">
        <v-list v-for="(cfgt, index) in filterBy(customFieldGroupTypes, false, 'archived')"
                :key="index">
          <v-list-item class="grab" :class="{ 'shaded-row': cfgt.id === selectedGroupId }">
            <v-list-item-content>
              <v-text-field class="one-hunned" v-if="selectedGroupId === cfgt.id" v-model="cfgt.groupName" @input="cfgt.nameChanged = true">
              </v-text-field>
              <div v-else>{{cfgt.groupName}}</div>
            </v-list-item-content>
            <v-list-item-action>
              <v-icon>drag_handle</v-icon>
            </v-list-item-action>
            <v-list-item-action class="clickable">
              <v-icon v-if="selectedGroupId === cfgt.id && cfgt.originalGroupName !== cfgt.groupName" @click="cfgt.originalGroupName = cfgt.groupName; saveGroupTypeName(index, cfgt)">save</v-icon>
              <v-icon v-else @click="selectedGroupId = cfgt.id; fetchCustomFields()">edit</v-icon>
            </v-list-item-action>
            <v-dialog
                v-model="cfgt.deleteConfirm"
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
                  Are you sure you want to delete this group: <strong>{{ cfgt.groupName }}</strong>?
                </v-card-text>

                <v-divider></v-divider>

                <v-card-actions>
                  <v-spacer></v-spacer>
                  <v-btn
                      @click="cfgt.deleteConfirm = false">
                    No
                  </v-btn>
                  <v-btn
                      color="primary"
                      text
                      @click="cfgt.archived = true; deleteGroup(cfgt.id)">
                    Yes
                  </v-btn>
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-list-item>

        </v-list>
      </draggable>
      <v-btn v-if="addNew" @click="addCustomFieldGroupType">Save</v-btn>
      <v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>
    </v-container>
    <v-container v-if="selectedGroupId !== null">
      <h3>Custom Fields</h3>
      <v-btn @click="addField = !addField; fetchAvailableCustomFields()">
        {{addField ? 'Cancel' : 'Add Field'}}
      </v-btn>
      <v-select v-if="addField"
                v-model="newField"
                :items="availableCustomFields"
                label="New Custom Field Group"
                item-text="fieldName"
                return-object
                @input="assignCustomField"
      ></v-select>
      <draggable v-model="customFields" v-if="customFields.length > 0"
                 group="customFields" @start="drag=true" @end="drag=false" @change="changeFieldOrder">
        <v-list v-for="(cf, index) in filterBy(customFields, false, 'archived')"
                :key="index">
          <v-list-item class="grab">
            <v-list-item-content>
              {{cf.fieldName}}
            </v-list-item-content>
            <v-list-item-action>
              <v-icon>drag_handle</v-icon>
            </v-list-item-action>
            <v-dialog
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
                    primary-title
                >
                  Confirm
                </v-card-title>

                <v-card-text>
                  Are you sure you want to delete <strong>{{ cf.fieldName }}</strong> from <strong>{{ cf.groupName }}</strong>?
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
      <v-btn v-if="fieldOrderChanged" @click="saveFieldChanges">Save Changes</v-btn>
    </v-container>
    </v-flex>
  </v-layout>
</template>

<script>
import { IS_MOBILE } from '@/helpers/helpers'
import Vue2Filters from 'vue2-filters'
import draggable from 'vuedraggable'
import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'
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
      selectedGroupId: null,
      customFieldGroupTypes: [],
      masterCustomFieldGroupTypes: [],
      customFields: [],
      masterCustomFields: [],
      availableCustomFields: [],
      companyId: this.$store.state.user.details.companyId,
      //if you set this to a value it doesn't update when the route param changes
      // objectTypeId: this.$route.params.id
    }
  },
  watch: {
    // whenever objectTypeId changes, this function will run
    '$route.params.id': function (oldObjectTypeId, newObjectTypeId) {
      // reset the selected group when the object type changes
      this.selectedGroupId = null
      this.customFields = []
      this.masterCustomFields = []
      this.availableCustomFields = []
      this.getCustomFieldGroupTypes()
    }
  },
  created () {
    this.getCustomFieldGroupTypes()
  },
  methods: {
    async getCustomFieldGroupTypes () {
      const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
        params: {
          objectTypeId: this.$route.params.id
        }
      })
      this.masterCustomFieldGroupTypes = data
      this.customFieldGroupTypes = cloneDeep(data)
    },
    async fetchCustomFields () {
      const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getCustomFieldsInGroup`, {
        params: {
          groupTypeId: this.selectedGroupId
        }
      })
      this.fieldOrderChanged = false
      this.masterCustomFields = data
      this.customFields = cloneDeep(data)
    },
    async fetchAvailableCustomFields () {
      const {data} = await getRequest(`/api/v1/flow/customFieldGroup/getAvailableCustomFieldsInGroup`, {
        params: {
          objectTypeId: this.$route.params.id,
          groupTypeId: this.selectedGroupId
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
      // re-order the list on the front-end
      this.masterCustomFieldGroupTypes = orderBy(this.customFieldGroupTypes, ['groupOrder', 'groupName'])
      this.customFieldGroupTypes = cloneDeep(this.masterCustomFieldGroupTypes)

      // load fields for the new type
      this.selectedGroupId = data.id
      this.fetchAvailableCustomFields()
    },
    async assignCustomField () {
      this.addField = false
      this.newField.fieldOrder = 0
      this.newField.customFieldGroupTypeId = this.selectedGroupId
      await postRequest(`/api/v1/flow/customFieldGroup/addFieldToGroup`, this.newField)

      this.masterCustomFields.push(this.newField)
      this.masterCustomFields = orderBy(this.masterCustomFields, ['fieldOrder', 'fieldName'])
      this.customFields = cloneDeep(this.masterCustomFields)
      this.newField = {}
    },
    changeGroupOrder () {
      this.groupOrderChanged = true
      // set the group order to save to DB
      this.customFieldGroupTypes.forEach((cfgt, idx) => {
        cfgt.groupOrder = idx
      })
    },
    async saveGroupChanges () {
      let groupsChanged = []
      this.masterCustomFieldGroupTypes.forEach((mcfg, idx) => {
        console.log('randaLogger',idx)
        if(this.customFieldGroupTypes[idx].id !== mcfg.id) {
          groupsChanged.push(this.customFieldGroupTypes[idx])
        }
      })
      console.log('we will save group changes here', groupsChanged)
      if(groupsChanged.length > 0) {
        await putRequest(`/api/v1/flow/customFieldGroup/updateCustomFieldGroupTypes`, groupsChanged)
        this.masterCustomFieldGroupTypes = cloneDeep(this.customFieldGroupTypes)
      }
      this.groupOrderChanged = false
    },
    async saveGroupTypeName (index, groupType) {
      // this updates the dom as needed
      this.$set(this.customFieldGroupTypes, index, groupType)
      await putRequest(`/api/v1/flow/customFieldGroup/updateCustomFieldGroupType`, groupType)
    },
    async deleteGroup (groupTypeId) {
      await deleteRequest(`/api/v1/flow/customFieldGroup/deleteCustomFieldGroupType/${groupTypeId}`)
    },
    async deleteFieldFromGroup (fieldGroupId) {
      await deleteRequest(`/api/v1/flow/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
    },
    changeFieldOrder () {
      console.log('field order changed')
      this.fieldOrderChanged = true
      // set the field order to save to DB
      this.customFields.forEach((cf, idx) => {
        cf.fieldOrder = idx
      })
    },
    async saveFieldChanges () {
      let fieldsChanged = []
      this.masterCustomFields.forEach((mcf, idx) => {
        if(this.customFields[idx].id !== mcf.id) {
          fieldsChanged.push(this.customFields[idx])
        }
      })
      console.log('we will save field changes here', fieldsChanged)
      if(fieldsChanged.length > 0) {
        await putRequest(`/api/v1/flow/customFieldGroup/updateFieldsInGroup`, fieldsChanged)
        this.masterCustomFields = cloneDeep(this.customFields)
      }
      this.fieldOrderChanged = false
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
  .test {
  }
</style>
