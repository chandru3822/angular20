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
      <v-data-table
          :headers="headers"
          :items="customFields"
          hide-actions
          hide-headers
          class="elevation-1"
          item-key="id"
          :expand="false"
      >
        <template slot="items" slot-scope="props">
          <tr v-if="!props.item.custom" :class="{ 'shaded-row': props.index % 2 }">
            <td class="text-xs-right">{{ props.item.fieldName }}</td>
            <td class="">
              <v-btn @click="props.expanded = !props.expanded; resetCustomField(props.item, props.expanded)">
                {{ props.expanded ? 'Cancel' : 'Edit' }}
              </v-btn>
              <v-btn flat @click="deleteField(props.item)" :loading="props.item.deleting">
                <v-icon>delete</v-icon>
              </v-btn>
            </td>
          </tr>
          <tr v-else :class="{ 'shaded-row': props.index % 2 }">
            <td colspan="2" class="text-xs-center">
              <v-btn  @click="props.expanded = !props.expanded; resetCustomField(props.item, props.expanded)">
                <v-icon class="mr-1" v-if="props.expanded">cancel</v-icon>
                <v-icon v-else>add</v-icon>
                {{props.expanded ? 'Cancel' : 'Add Field'}}
              </v-btn>
            </td>
          </tr>
        </template>
        <template v-slot:expand="props">
          <v-flex justify-center class="flex-display pl-3 pr-3" :class="{'shaded-row': props.index % 2}">

            <v-card flat class="text-xs-center field-card one-hunned"  :color="props.index % 2 ? 'rowShadeCustom' : 'white'">
              <v-card-text>{{props.item.custom ? 'Add Field' : 'Edit Field'}}</v-card-text>
              <v-text-field
                  label="Field Name"
                  tabindex=1
                  v-model="props.item.fieldName"
              ></v-text-field>
              <v-autocomplete
                  v-model="props.item.companyDataType"
                  :items="dataTypes"
                  :disabled="!props.item.custom"
                  :readonly="!props.item.custom"
                  tabindex=2
                  label="Data Type"
                  item-text="companyDataType"
                  item-value="id"
                  browser-autocomplete="new-password"
                  return-object
              ></v-autocomplete>

              <v-flex class="options-container" fluid v-if="props.item.companyDataType && props.item.companyDataType.hasListValues">
                <span>Selectable Options</span>
                <draggable v-model="props.item.dropdownOptions"
                           group="dropdownOptions" @start="drag=true" @end="drag=false">
                  <v-list v-for="(ddo, index) in filterBy(props.item.dropdownOptions, false, 'archived')"
                          :class="{'shaded-row': props.index % 2}"
                          :key="index">
                    <v-list-tile class="grab">
                      <v-list-tile-content>
                          <v-text-field
                              class="one-hunned"
                            :placeholder="ddo.placeholder"
                            v-model="ddo.name" >
                          </v-text-field>
                      </v-list-tile-content>
                      <v-list-tile-action>
                        <v-icon>drag_handle</v-icon>
                      </v-list-tile-action>
                      <v-list-tile-action class="clickable" @click="ddo.archived = true">
                        <v-icon>delete</v-icon>
                      </v-list-tile-action>
                    </v-list-tile>
                  </v-list>
                </draggable>
                <v-btn
                    @click="addOption(props.item.dropdownOptions)">
                  Add Option
                </v-btn>
              </v-flex>
              <v-flex class="options-container" fluid>
                <div>Included Object Types</div>
                <!--<v-container v-if="props.item.custom">-->
                  <!--<v-checkbox v-for="(ot, index) in customFieldObjectTypes"-->
                              <!--:key="index"-->
                              <!--v-model="ot.archived"-->
                              <!--:false-value="true" :true-value="false"-->
                              <!--:label="ot.objectType"></v-checkbox>-->
                <!--</v-container>-->
                <v-container>
                  <v-checkbox v-for="(ot, index) in props.item.customFieldObjectTypes"
                      :key="index"
                      v-model="ot.archived"
                      :false-value="true" :true-value="false"
                      :label="ot.objectType"></v-checkbox>
                </v-container>
              </v-flex>
              <v-btn
                  :disabled="invalid(props.item)"
                  @click="saveChanges(props.item.custom, props.item); props.expanded = !props.expanded">
                {{props.item.custom ? 'Add Field' : 'Save Changes'}}
              </v-btn>
            </v-card>
          </v-flex>

        </template>
      </v-data-table>
    </v-flex>
  </v-layout>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Vue2Filters from 'vue2-filters'
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import draggable from 'vuedraggable'
import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'

export default {
  name: 'CustomFields',
  mixins: [Vue2Filters.mixin],
  components: {
    draggable
  },
  data () {
    return {
      model: '',
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
        customFieldObjectTypes: []}
    }
  },
  methods: {
    async getCustomFields () {
      const {data} = await getRequest(`/api/v1/flow/customField/getAll`, { params: { companyId: this.companyId }})
      data.forEach(d => {
        d.companyDataType = this.dataTypes.find(dt => dt.id === d.companyDataTypeId)
      })
      this.allCustomFields = orderBy(data, d => d.fieldName.toLowerCase())
      this.customFields = cloneDeep(this.allCustomFields)
      this.customFields.unshift(cloneDeep(this.blankNewObject))
    },
    async getCustomFieldObjectTypes () {
      const {data} = await getRequest(`/api/v1/flow/customField/getCustomFieldObjectTypes`, { params: { companyId: this.companyId }})
      data.forEach(d => d.archived = true)
      this.customFieldObjectTypes = cloneDeep(data)
      this.objectFilters = data
      this.objectFilters.unshift({id: -2, objectType: 'Unused'})
      this.objectFilters.unshift({id: -1, objectType: 'All'},)
    },
    async getCompanyDataTypes () {
      const {data} = await getRequest(`/api/v1/flow/dataType/getCompanyDataTypes`, { params: { companyId: this.companyId }})
      this.dataTypes = data
    },
    async deleteField (item) {
      item.archived = true
      const { status } = await putRequest(`/api/v1/flow/customField/delete`, item)
      if (status === 200) {
        this.customFields = this.customFields.filter((cf) => { return cf.id !== item.id })
      }
    },
    changeSelectedObjectType () {
      if (this.selectedObjectType.id === -1) {
        this.customFields = cloneDeep(this.allCustomFields)
      } else if (this.selectedObjectType.id === -2){
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
    async saveChanges (editMode, object) {
      // the 'Add Field' row had to have an id in order to use it in the data table repeat.  remove the id here
      object.id = object.id === -1 ? null : object.id

      // set the display order to save to DB
      object.dropdownOptions.forEach((ddo, idx) => {
        ddo.displayOrder = idx
      })

      object.companyDataTypeId = object.companyDataType.id
      object.modifiedById = this.$store.state.user.details.id

      const {data} = await postRequest('/api/v1/flow/customField', object)
      data.companyDataType = this.dataTypes.find(dt => dt.id === data.companyDataTypeId)

      // if it was a new field, reset the first index, then push it to both arrays
      if(null === object.id) {
        object = cloneDeep(this.blankNewObject)
        this.customFields[0] = object
        this.allCustomFields.push(data)
        this.customFields.push(data)
      }

      // re-sort in case the fieldName changed
      this.customFields = orderBy(this.customFields, cf => cf.fieldName.toLowerCase())
    },
    resetCustomField (item, expanded) {
      // is this really the only way to reset the values if they cancel changes?  i tried resetting just the one index but the dom doesn't refresh
      if(!expanded) {
        // const idx = this.customFields.indexOf(item)
        // console.log('randaLogger', idx)
        // this.customFields[idx] = cloneDeep(this.allCustomFields[idx])
        this.customFields = cloneDeep(this.allCustomFields)
        this.customFields.unshift(cloneDeep(this.blankNewObject))
      } else if (item.custom) {
        item.customFieldObjectTypes = cloneDeep(this.customFieldObjectTypes)
      }
    },
    addOption (options) {
      options.push({ placeholder: 'Enter New Option Name', archived: false})
    },
    invalid (item) {
      // todo: use real form validation?
      let invalidOptions = false
      if(item.companyDataType && item.companyDataType.hasListValues) {
        if(item.dropdownOptions.length === 0 ) {
          invalidOptions = true
        } else {
          item.dropdownOptions.forEach(ddo => {
            if(!ddo.name && !ddo.archived) {
              invalidOptions = true
            }
          })
        }
      }
      return !item.fieldName || !item.companyDataType || invalidOptions

    }
  },
  async created () {
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
