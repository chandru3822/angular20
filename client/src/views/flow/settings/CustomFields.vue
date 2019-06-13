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
          expand
      >
        <template slot="items" slot-scope="props">
          <tr v-if="!props.item.custom" :class="{ 'shaded-row': props.index % 2 }">
            <td class="text-xs-right">{{ props.item.fieldName }}</td>
            <td class="">
              <v-btn @click="props.expanded = !props.expanded; resetCustomField(props.item.id, props.expanded)">
                {{ props.expanded ? 'Cancel' : 'Edit' }}
              </v-btn>
              <v-btn flat @click="deleteField(props.item)" :loading="props.item.deleting">
                <v-icon>delete</v-icon>
              </v-btn>
            </td>
          </tr>
          <tr v-else :class="{ 'shaded-row': props.index % 2 }">
            <td colspan="2" class="text-xs-center">
              <v-btn  @click="props.expanded = !props.expanded; resetCustomField(props.item.id, props.expanded)">
                <v-icon class="mr-1" v-if="props.expanded">cancel</v-icon>
                <v-icon v-else>add</v-icon>
                {{props.expanded ? 'Cancel' : 'Add Field'}}
              </v-btn>
            </td>
          </tr>
        </template>
        <template v-slot:expand="props">
          <v-flex justify-center class="flex-display" :class="{'shaded-row': props.index % 2}">

            <v-card flat class="text-xs-center field-card"  :color="props.index % 2 ? 'rowShadeCustom' : 'white'">
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
                <v-text-field v-for="(ddo, index) in props.item.dropdownOptions"
                              :key="index"
                              :placeholder="ddo.placeholder"
                    v-model="ddo.name"
                ></v-text-field>
                <v-btn
                    @click="addOption(props.item.dropdownOptions)">
                  Add Option
                </v-btn>
              </v-flex>
              <v-container fluid>
                {{props.item.customFieldGroups}}
                <v-checkbox v-for="(ot, index) in customFieldObjectTypes"
                            :key="index"
                            v-model="props.item.selectedCustomFieldObjectTypes"
                            :label="ot.objectType"
                            :value="ot.id"></v-checkbox>
              </v-container>
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
import cloneDeep from 'lodash.clonedeep'
import orderBy from 'lodash.orderby'
import { getRequest, deleteRequest, postRequest } from '@/helpers/helpers'

export default {
  name: 'CustomFields',
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
        fieldName: null,
        custom: true,
        createdById: this.$store.state.user.details.id,
        companyId: this.$store.state.user.details.companyId,
        dropdownOptions: [],
        selectedCustomFieldObjectTypes: []}
    }
  },
  methods: {
    async getCustomFields () {
      const {data} = await getRequest(`/api/v1/flow/customField/getAll`, { params: { companyId: this.companyId }})
      data.forEach(d => {
        d.companyDataType = this.dataTypes.find(dt => dt.id === d.companyDataTypeId)
      })
      this.allCustomFields = cloneDeep(data)
      this.customFields = data
      this.customFields.unshift(cloneDeep(this.blankNewObject))
    },
    async getCustomFieldObjectTypes () {
      const {data} = await getRequest(`/api/v1/flow/customField/getCustomFieldObjectTypes`, { params: { companyId: this.companyId }})
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
      const { status } = await deleteRequest(`/api/v1/flow/customField/${item.id}`)
      if (status === 200) {
        this.customFields = this.customFields.filter((cf) => { return cf.id !== item.id })
      }
    },
    changeSelectedObjectType () {
      if (this.selectedObjectType.id === -1) {
        this.customFields = cloneDeep(this.allCustomFields)
      } else if (this.selectedObjectType.id === -2){
        this.customFields = this.allCustomFields.filter(cf => {
          return cf.selectedCustomFieldObjectTypes.length === 0
        })
      } else {
        this.customFields = this.allCustomFields.filter(cf => { return cf.selectedCustomFieldObjectTypes.includes(this.selectedObjectType.id) })
      }
      this.customFields.unshift(cloneDeep(this.blankNewObject))
    },
    async saveChanges (editMode, object) {
      // todo:
      // todo: make work for post and put
      // the 'Add Field' row had to have an id in order to use it in the data table repeat.  remove the id here
      object.id = object.id === -1 ? null : object.id

      object.dropdownOptions.forEach((ddo, idx) => {
        console.log('idx', idx)
        ddo.diplayOrder = idx
      })

      object.companyDataTypeId = object.companyDataType.id

      const {data} = await postRequest('/api/v1/flow/customField', object)
      data.companyDataType = this.dataTypes.find(dt => dt.id === data.companyDataTypeId)
      // i saw how to sort and insert in one command with sortedIndexBy but i couldn't get it to work :(
      this.allCustomFields.push(data)
      this.allCustomFields = orderBy(this.allCustomFields, cf => cf.fieldName.toLowerCase())
      this.customFields[this.customFields.indexOf(object)] = data
      this.customFields = orderBy(this.customFields, cf => cf.fieldName.toLowerCase())

      // i thought i understood cloning until this
      object = cloneDeep(this.blankNewObject)
      this.customFields.unshift(object)
    },
    resetCustomField (id, expanded) {
      if(id && !expanded) {
        const original = cloneDeep(this.allCustomFields.find(cf => cf.id === id))
        const idx = this.customFields.findIndex(cf => cf.id === id)
        console.log('randaLogger', original)
        console.log('randaLogger', idx)
        console.log('randaLoggerOld', this.customFields[idx])
        this.customFields[idx] = cloneDeep(this.allCustomFields.find(cf => cf.id === id))
        console.log('randaLoggerNew', this.customFields[idx])
      }
    },
    addOption (options) {
      options.push({ placeholder: 'Enter New Option Name'})
    },
    invalid (item) {
      let invalidOptions = false
      if(item.companyDataType && item.companyDataType.hasListValues) {
        if(item.dropdownOptions.length === 0 ) {
          invalidOptions = true
        } else {
          item.dropdownOptions.forEach(ddo => {
            if(!ddo.name) {
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
  width: 50%;
}
</style>
