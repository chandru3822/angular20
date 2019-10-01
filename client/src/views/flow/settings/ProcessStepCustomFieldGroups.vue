<template>
  <v-container class="">
    <v-row>
      <v-col cols="12" class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title class="app-title">Custom Field Groups</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="!createNew" @click="createNew = !createNew">
              <v-icon>add</v-icon>
              Create Group
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="createNew" text class="text-xs-center one-hunned pa-3" flat
                color="rowShadeCustom">
          <v-text-field
              label="Group Name"
              tabindex=1
              v-model="newGroup.groupName"
          ></v-text-field>
          <v-btn
              color="primary"
              class="white--text mr-2"
              :disabled="!newGroup.groupName"
              @click="saveFieldGroup()">
            Save
          </v-btn>
          <v-btn
              @click="newGroup = {}; createNew = false;">
            Cancel
          </v-btn>
        </v-card>
        <v-row v-if="customFieldGroups && customFieldGroups.length > 0">
          <v-col cols="12">
            <v-data-table
                :headers="headers"
                :items="filterCustomFieldGroups()"
                :items-per-page="-1"
                single-expand
                :expanded.sync="expanded"
                hide-default-footer
                hide-default-header
                class="elevation-1"
            >
              <template #no-data>
                No actions for this process step
              </template>

              <template #no-results>
                No actions for this process step
              </template>

              <template #item="{ item, index }">
                <tr :class="{'shaded-row': index % 2}">
                  <td class="text-left">
                    {{item.groupName}}
                  </td>
                  <td><div class="item-icons">
                    <v-btn small text @click="addField = !addField; selectedIndex = index, expanded = [item]; fetchAvailableCustomFields(item.objectTypeId, item.id)">
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
                              @click="item.archived = true; deleteGroupFromStep(item.id)">
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
                  <v-flex xs12 justify-center class="pl-3 pr-3" v-if="addField">
                    <h3 class="text-left">Add New Field</h3>
                    <v-radio-group v-model="newFieldType" @change="fetchAvailableCustomFields(item.objectTypeId, item.id)">
                      <v-radio label="Native Field"
                               value="native"></v-radio>
                      <v-radio label="Reference Field: viewed only from other process steps or objects"
                               value="ancillary"></v-radio>
                    </v-radio-group>
                    <v-select v-if="newFieldType === 'native'"
                              v-model="newField"
                              :items="availableCustomFields"
                              label="New Custom Field"
                              item-text="fieldName"
                              return-object
                              @input="assignCustomField(item)"
                    ></v-select>

                    <v-select v-if="newFieldType === 'ancillary'"
                              v-model="parent"
                              :items="parentObjects"
                              label="Parent Object"
                              item-text="name"
                              return-object
                              @input="loadFieldsByParent"
                    ></v-select>
                    <v-select v-if="newFieldType === 'ancillary'"
                              v-model="selectedAncillaryField"
                              :items="ancillaryCustomFields"
                              label="Custom Field"
                              item-text="fieldName"
                              return-object
                              @input="assignAncillaryCustomField(item)"
                    ></v-select>
                    <v-btn @click="addField = false">Cancel</v-btn>
                  </v-flex>
                  <v-flex xs12 justify-center class="px-3 py-0"
                          v-if="!addField && (!item.customFields || item.customFields.length === 0)">
                    No Custom Fields Added
                  </v-flex>
                  <v-flex xs12 justify-center class="px-3 py-0"
                          v-if="item.customFields && item.customFields.length > 0">
      <!--              <h3 class="text-left">Assigned Custom Fields</h3>-->
                    <draggable v-model="item.customFields" v-if="item.customFields && item.customFields.length > 0"
                               group="customFields" @start="drag=true" @end="drag=false" @change="saveFieldChanges(item.customFields)">
                      <v-list v-for="(cf, index) in filterBy(item.customFields, false, 'archived')"
                              :key="index" dense class="pa-0">
                        <v-list-item class="grab">
                          <v-list-item-action dense>
                            <v-icon>drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-content class="pa-0">
                            {{cf.fieldName}} {{ cf.ancillaryCustomFieldGroupAssignmentId == null ? '' : '(Ancillary)' }}
                          </v-list-item-content>
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
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

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
    data() {
      return {
        snackbar: {},
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
        companyId: this.$store.state.user.details.companyId,
        parentObjects: [],
        selectedAncillaryField: {},
        ancillaryCustomFields: [],
        headers: [
          { text: 'Name', value: 'groupName', show: true },
          { text: null, value: 'icons', show: true }
        ],
        expanded: [],
      }
    },
    computed: {},
    methods: {
      async saveFieldGroup() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          // todo: what is the best way to NOT hardcode this?  processStep objectTypeId = 4
          this.newGroup.objectTypeId = 4
          this.newGroup.groupOrder = 0
          this.newGroup.processStepId = this.$route.params.id

          const {data} = await postRequest(`/customFieldGroup/addCustomFieldGroup`, this.newGroup)
          this.customFieldGroups.push(data)
          this.newGroup = {}
          this.createNew = false
          this.snackbar = getSnackbar('SUCCESS', 'Group Saved')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Group')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      changeGroupOrder() {
        console.log('changed group order')
      },
      changeFieldOrder() {
        console.log('changed field order')
      },
      async deleteGroupFromStep(groupId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/customFieldGroup/deleteCustomFieldGroup/${groupId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Group Deleted From Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Group From Step')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteFieldFromGroup(fieldGroupId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/customFieldGroup/deleteFieldFromGroup/${fieldGroupId}`)
          this.snackbar = getSnackbar('SUCCESS', 'Field Deleted From Group')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Field From Group')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async fetchAvailableCustomFields(objectTypeId, groupId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          if (this.addField && this.newFieldType === 'native') {
            const {data} = await getRequest(`/customFieldGroup/getAvailableCustomFields`, {
              params: {
                objectTypeId,
                groupId,
                processStepId: this.processStepId
              }
            })
            this.availableCustomFields = data
            this.parentObjects = []
            this.ancillaryCustomFields = []
          } else if (this.addField && this.newFieldType === 'ancillary') {
            const {data} = await getRequest(`/processStep/getParentObjectsWithTypes`, { params: { id: this.processStepId}})
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
      async assignCustomField(cfg) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.addField = false
          this.newField.fieldOrder = 0
          this.newField.customFieldGroupId = cfg.id
          //this line makes pushing it to the list work
          this.newField.archived = false

          await postRequest(`/customFieldGroup/addFieldToGroup`, this.newField)
          cfg.customFields.push(this.newField)
          this.newField = {}
          this.snackbar = getSnackbar('SUCCESS', 'Custom Field Assigned')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Assigning Custom Field')
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
          console.log('randaLogger', fieldsToSave)
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
        return this.customFieldGroups.filter(cfg => { return !cfg.archived})
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
</style>
