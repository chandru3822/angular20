<template>
  <v-layout row wrap class="custom-field-container">
    <v-flex xs-12>
      <v-toolbar color="white" class="elevation-1">
        <v-toolbar-title class="app-title">Custom Fields</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-toolbar-items>
          <v-select
              class="mt-2"
              v-model="selectedObjectType"
              :items="objectFilters"
              label="Filter by Object Type"
              item-text="objectType"
              return-object
              @input="changeSelectedObjectType()"
          ></v-select>
        </v-toolbar-items>
      </v-toolbar>
      <v-list>
        <v-list-group
            v-for="(item, index) in customFields"
            :key="item.id"
            :class="{ 'shaded-row': index % 2 }"
        >
          <template v-slot:activator>
            <v-list-item-content>
              <v-list-item-title v-if="item.custom">Add New</v-list-item-title>
              <!--<v-text-field class="one-hunned" v-if="selectedFieldId === item.id" v-model="item.fieldName"-->
                            <!--@input="item.nameChanged = true">-->
              <!--</v-text-field>-->
              <v-list-item-title v-else>{{item.fieldName}}</v-list-item-title>
            </v-list-item-content>
            <v-list-item-action class="clickable">
              <v-icon v-if="item.custom">add</v-icon>
              <!--<v-icon v-else-if="item.custom && item.expanded">remove</v-icon>-->
              <v-icon v-else @click="selectedFieldId = item.id">edit</v-icon>
            </v-list-item-action>
          </template>

          <v-list-item>
            <v-list-item-content>
              <v-flex justify-center class="flex-display pl-3 pr-3" :class="{'shaded-row': index % 2}">
                <v-card text class="text-xs-center field-card one-hunned" flat
                        :color="index % 2 ? 'rowShadeCustom' : 'white'">
                  <v-card-text>{{item.custom ? 'Add Field' : 'Edit Field'}}</v-card-text>
                  <v-text-field
                      label="Field Name"
                      tabindex=1
                      v-model="item.fieldName"
                  ></v-text-field>
                  <v-autocomplete
                      v-model="item.companyDataType"
                      :items="dataTypes"
                      :disabled="!item.custom"
                      :readonly="!item.custom"
                      tabindex=2
                      label="Data Type"
                      item-text="companyDataType"
                      item-value="id"
                      autocomplete="new-password"
                      return-object
                  ></v-autocomplete>

                  <v-flex class="options-container" fluid
                          v-if="item.companyDataType && item.companyDataType.hasListValues">
                    <span>Selectable Options</span>
                    <draggable v-model="item.dropdownOptions"
                               group="dropdownOptions" @start="drag=true" @end="drag=false">
                      <v-list v-for="(ddo, index) in filterBy(item.dropdownOptions, false, 'archived')"
                              :class="{'shaded-row': item.index % 2}"
                              :key="index">
                        <v-list-item class="grab">
                          <v-list-item-content>
                            <v-text-field
                                class="one-hunned"
                                :placeholder="ddo.placeholder"
                                v-model="ddo.name">
                            </v-text-field>
                          </v-list-item-content>
                          <v-list-item-action>
                            <v-icon>drag_handle</v-icon>
                          </v-list-item-action>
                          <v-list-item-action class="clickable" @click="ddo.archived = true">
                            <v-icon>delete</v-icon>
                          </v-list-item-action>
                        </v-list-item>
                      </v-list>
                    </draggable>
                    <v-btn
                        @click="addOption(item.dropdownOptions)">
                      Add Option
                    </v-btn>
                  </v-flex>
                  <v-flex class="options-container" fluid>
                    <div>Included Object Types</div>
                    <v-container v-if="item.custom">
                      <v-checkbox v-for="(ot, index) in customFieldObjectTypes"
                        :key="index"
                        class="fix-opacity"
                        v-model="ot.archived"
                        :false-value="true" :true-value="false"
                        :label="ot.objectType"></v-checkbox>
                    </v-container>
                    <v-container>
                      <v-checkbox v-for="(ot, index) in item.customFieldObjectTypes"
                                  :key="index"
                                  flat
                                  v-model="ot.archived"
                                  :false-value="true" :true-value="false"
                                  :label="ot.objectType"></v-checkbox>
                    </v-container>
                  </v-flex>
                  <v-btn
                      :disabled="invalid(item)"
                      @click="saveChanges(item.custom, item); item.expanded = !item.expanded">
                    {{item.custom ? 'Add Field' : 'Save Changes'}}
                  </v-btn>
                </v-card>
              </v-flex>
            </v-list-item-content>
          </v-list-item>
        </v-list-group>
      </v-list>
      <!--<v-data-table-->
      <!--:headers="headers"-->
      <!--:items="customFields"-->
      <!--:single-expand="true"-->
      <!--:expanded.sync="expanded"-->
      <!--item-key="id"-->
      <!--hide-default-footer-->
      <!--:items-per-page="-1"-->
      <!--hide-default-header-->
      <!--class="elevation-1"-->
      <!--&gt;-->
      <!--<template v-slot:body="{ items }">-->
      <!--<tr v-for="(item, index) in items" :key="item.id" v-if="!item.custom" :class="{ 'shaded-row': index % 2 }">-->
      <!--<td class="text-xs-right">{{ item.fieldName }}</td>-->
      <!--<td class="">-->
      <!--<v-btn @click="expanded.push(item); resetCustomField(item, item.expand)">-->
      <!--{{ item.expand ? 'Cancel' : 'Edit' }}-->
      <!--</v-btn>-->
      <!--<v-btn text @click="deleteField(item)" :loading="item.deleting">-->
      <!--<v-icon>delete</v-icon>-->
      <!--</v-btn>-->
      <!--</td>-->
      <!--</tr>-->
      <!--<tr v-else :class="{ 'shaded-row': index % 2 }">-->
      <!--<td colspan="2" class="text-xs-center">-->
      <!--<v-btn  @click="item.expanded = !item.expanded; resetCustomField(item, item.expanded)">-->
      <!--<v-icon class="mr-1" v-if="item.expanded">cancel</v-icon>-->
      <!--<v-icon v-else>add</v-icon>-->
      <!--{{item.expanded ? 'Cancel' : 'Add Field'}}-->
      <!--</v-btn>-->
      <!--</td>-->
      <!--</tr>-->
      <!--</template>-->
      <!--<template v-slot:expanded-item="{headers}">-->
      <!--<td>Peek-a-boo!</td>-->
      <!--<v-flex justify-center class="flex-display pl-3 pr-3" :class="{'shaded-row': item.index % 2}">-->

      <!--<v-card text class="text-xs-center field-card one-hunned"  :color="item.index % 2 ? 'rowShadeCustom' : 'white'">-->
      <!--<v-card-text>{{item.custom ? 'Add Field' : 'Edit Field'}}</v-card-text>-->
      <!--<v-text-field-->
      <!--label="Field Name"-->
      <!--tabindex=1-->
      <!--v-model="item.fieldName"-->
      <!--&gt;</v-text-field>-->
      <!--<v-autocomplete-->
      <!--v-model="item.companyDataType"-->
      <!--:items="dataTypes"-->
      <!--:disabled="!item.custom"-->
      <!--:readonly="!item.custom"-->
      <!--tabindex=2-->
      <!--label="Data Type"-->
      <!--item-text="companyDataType"-->
      <!--item-value="id"-->
      <!--autocomplete="new-password"-->
      <!--return-object-->
      <!--&gt;</v-autocomplete>-->

      <!--<v-flex class="options-container" fluid v-if="item.companyDataType && item.companyDataType.hasListValues">-->
      <!--<span>Selectable Options</span>-->
      <!--<draggable v-model="item.dropdownOptions"-->
      <!--group="dropdownOptions" @start="drag=true" @end="drag=false">-->
      <!--<v-list v-for="(ddo, index) in filterBy(item.dropdownOptions, false, 'archived')"-->
      <!--:class="{'shaded-row': item.index % 2}"-->
      <!--:key="index">-->
      <!--<v-list-item class="grab">-->
      <!--<v-list-item-content>-->
      <!--<v-text-field-->
      <!--class="one-hunned"-->
      <!--:placeholder="ddo.placeholder"-->
      <!--v-model="ddo.name" >-->
      <!--</v-text-field>-->
      <!--</v-list-item-content>-->
      <!--<v-list-item-action>-->
      <!--<v-icon>drag_handle</v-icon>-->
      <!--</v-list-item-action>-->
      <!--<v-list-item-action class="clickable" @click="ddo.archived = true">-->
      <!--<v-icon>delete</v-icon>-->
      <!--</v-list-item-action>-->
      <!--</v-list-item>-->
      <!--</v-list>-->
      <!--</draggable>-->
      <!--<v-btn-->
      <!--@click="addOption(item.dropdownOptions)">-->
      <!--Add Option-->
      <!--</v-btn>-->
      <!--</v-flex>-->
      <!--<v-flex class="options-container" fluid>-->
      <!--<div>Included Object Types</div>-->
      <!--&lt;!&ndash;<v-container v-if="props.item.custom">&ndash;&gt;-->
      <!--&lt;!&ndash;<v-checkbox v-for="(ot, index) in customFieldObjectTypes"&ndash;&gt;-->
      <!--&lt;!&ndash;:key="index"&ndash;&gt;-->
      <!--&lt;!&ndash;v-model="ot.archived"&ndash;&gt;-->
      <!--&lt;!&ndash;:false-value="true" :true-value="false"&ndash;&gt;-->
      <!--&lt;!&ndash;:label="ot.objectType"></v-checkbox>&ndash;&gt;-->
      <!--&lt;!&ndash;</v-container>&ndash;&gt;-->
      <!--<v-container>-->
      <!--<v-checkbox v-for="(ot, index) in item.customFieldObjectTypes"-->
      <!--:key="index"-->
      <!--v-model="ot.archived"-->
      <!--:false-value="true" :true-value="false"-->
      <!--:label="ot.objectType"></v-checkbox>-->
      <!--</v-container>-->
      <!--</v-flex>-->
      <!--<v-btn-->
      <!--:disabled="invalid(item)"-->
      <!--@click="saveChanges(item.custom, item); item.expanded = !item.expanded">-->
      <!--{{props.item.custom ? 'Add Field' : 'Save Changes'}}-->
      <!--</v-btn>-->
      <!--</v-card>-->
      <!--</v-flex>-->

      <!--</template>-->
      <!--</v-data-table>-->
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import cloneDeep from 'lodash.clonedeep'
  import orderBy from 'lodash.orderby'
  import draggable from 'vuedraggable'
  import {getRequest, deleteRequest, putRequest, postRequest} from '@/helpers/helpers'

  export default {
    name: 'CustomFields',
    mixins: [Vue2Filters.mixin],
    components: {
      draggable
    },
    data() {
      return {
        model: '',
        expand: false,
        selectedFieldId: null,
        expanded: [],
        // this is used so the expanded row uses the full width...bug in vuetify
        headers: Array(2).fill({}),
        customFields: [],
        dataTypes: [],
        companyId: this.$store.state.user.details.companyId,
        selectedObjectType: {id: -1, objectType: 'All'},
        customFieldObjectTypes: [],
        objectFilters: [],
        blankNewObject: {
          id: -1,
          fieldName: '',
          custom: true,
          createdById: this.$store.state.user.details.id,
          companyId: this.$store.state.user.details.companyId,
          dropdownOptions: [],
          customFieldObjectTypes: []
        }
      }
    },
    methods: {
      async getCustomFields() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/customField/getAll`)
        data.forEach(d => {
          d.companyDataType = this.dataTypes.find(dt => dt.id === d.companyDataTypeId)
        })
        this.allCustomFields = orderBy(data, d => d.fieldName.toLowerCase())
        this.customFields = cloneDeep(this.allCustomFields)
        this.customFields.unshift(cloneDeep(this.blankNewObject))
      },
      async getCustomFieldObjectTypes() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/customField/getCustomFieldObjectTypes`)
        data.forEach(d => d.archived = true)
        this.customFieldObjectTypes = cloneDeep(data)
        this.objectFilters = data
        this.objectFilters.unshift({id: -2, objectType: 'Unassigned'})
        this.objectFilters.unshift({id: -1, objectType: 'All'},)
      },
      async getCompanyDataTypes() {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/dataType/getCompanyDataTypes`)
        this.dataTypes = data
      },
      async deleteField(item) {
        item.archived = true
        const {status} = await putRequest(`/api/v1/flow/customField/delete`, item)
        if (status === 200) {
          this.customFields = this.customFields.filter((cf) => {
            return cf.id !== item.id
          })
        }
      },
      changeSelectedObjectType() {
        if (this.selectedObjectType.id === -1) {
          this.customFields = cloneDeep(this.allCustomFields)
        } else if (this.selectedObjectType.id === -2) {
          this.customFields = this.allCustomFields.filter(cf => {
            return !cf.customFieldObjectTypes.some(cfot => (!cfot.archived && null != cfot.archived))
          })
        } else {
          this.customFields = this.allCustomFields.filter(cf => {
            const match = cf.customFieldObjectTypes.find(cfot => {
              return cfot.objectTypeId === this.selectedObjectType.id && (!cfot.archived && null != cfot.archived)
            })
            return !!match
          })
        }
        this.customFields.unshift(cloneDeep(this.blankNewObject))
      },
      async saveChanges(editMode, object) {
        // the 'Add Field' row had to have an id in order to use it in the data table repeat.  remove the id here
        object.id = object.id === -1 ? null : object.id

        // set the display order to save to DB
        object.dropdownOptions.forEach((ddo, idx) => {
          ddo.displayOrder = idx
        })

        object.companyDataTypeId = object.companyDataType.id
        object.modifiedById = this.$store.state.user.details.id

        // set the values of customFieldObjectTypes to be saved in db
        if(object.custom) {
          object.customFieldObjectTypes = this.customFieldObjectTypes.filter(cfot => {
            cfot.objectTypeId = cfot.id
            return !cfot.archived
          })
        }

        console.log('randaLogger', object)

        const {data} = await postRequest(`/api/v1/flow/companies/${this.companyId}/customField`, object)
        data.companyDataType = this.dataTypes.find(dt => dt.id === data.companyDataTypeId)

        // if it was a new field, reset the first index, then push it to both arrays
        if (null === object.id) {
          object = cloneDeep(this.blankNewObject)
          this.customFields[0] = object
          this.allCustomFields.push(data)
          this.customFields.push(data)
        }

        // re-sort in case the fieldName changed
        this.customFields = orderBy(this.customFields, cf => cf.fieldName.toLowerCase())
      },
      resetCustomField(item, expanded) {
        // is this really the only way to reset the values if they cancel changes?  i tried resetting just the one index but the dom doesn't refresh
        if (!expanded) {
          // const idx = this.customFields.indexOf(item)
          // console.log('randaLogger', idx)
          // this.customFields[idx] = cloneDeep(this.allCustomFields[idx])
          this.customFields = cloneDeep(this.allCustomFields)
          this.customFields.unshift(cloneDeep(this.blankNewObject))
        } else if (item.custom) {
          item.customFieldObjectTypes = cloneDeep(this.customFieldObjectTypes)
        }
      },
      addOption(options) {
        options.push({placeholder: 'Enter New Option Name', archived: false})
      },
      invalid(item) {
        // todo: use real form validation?
        let invalidOptions = false
        if (item.companyDataType && item.companyDataType.hasListValues) {
          if (item.dropdownOptions.length === 0) {
            invalidOptions = true
          } else {
            item.dropdownOptions.forEach(ddo => {
              if (!ddo.name && !ddo.archived) {
                invalidOptions = true
              }
            })
          }
        }
        return !item.fieldName || !item.companyDataType || invalidOptions

      }
    },
    async created() {
      await this.getCompanyDataTypes()
      this.getCustomFieldObjectTypes()
      this.getCustomFields()
    }
  }
</script>

<style scoped lang="scss">
  .custom-field-container {
    max-height: calc(100vh - 200px);
    overflow: auto;
  }

  .options-container {
    text-align: left;
    padding: 12px 0 !important;
  }

  .field-card {
  }
</style>
