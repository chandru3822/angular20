<template>
  <v-layout row wrap class="custom-field-group-container">
    <v-flex xs-12>
      <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
      <v-toolbar class="testing elevation-1">
        <v-toolbar-title class="app-title">{{ details.companyFunctionName }}</v-toolbar-title>
      </v-toolbar>

      <v-data-table
          :headers="headers"
          :items="details.companyFunctionParams"
          :items-per-page="-1"
          single-expand
          item-key="dbFunctionParamId"
          :expanded.sync="expanded"
          hide-default-footer
          class="elevation-1"
      >
        <template #no-data>
          NO DATA HERE!
        </template>

        <template #no-results>
          No parameters exist for this function
        </template>

        <template #expanded-item="{ headers, item }">
          <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
            <v-text-field v-if="item.isDefaultValue"
                          v-model="item.defaultValue"
                          placeholder="Enter a value"
                          label="Value">
            </v-text-field>
            <v-select v-else-if="item.isSystemValue"
                        v-model="item.systemValueId"
                        :items="systemValues"
                        label="System Value"
                        item-text="systemValue"
                        item-value="id"></v-select>
            <div v-else>
              <v-select v-model="item.processStepId"
                        :items="parentObjects"
                        label="Parent Object"
                        item-text="processStepName"
                        item-value="id"
                        @input="loadFieldsByParent(item.processStepId)"
              ></v-select>
              <v-select v-if="item.processStepId"
                        v-model="item.customFieldGroupId"
                        :items="availableCustomFields"
                        label="Custom Field"
                        item-text="fieldName"
                        item-value="customFieldGroupId"
              ></v-select>
            </div>
            <v-btn @click="saveParam(item)">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </td>
        </template>


        <template #item="{ item }">
          <tr  class="text-xs-left" :class="{'shaded-row': details.companyFunctionParams.indexOf(item) % 2}">
            <td class="text-left">{{ item.parameterName }}</td>
            <!-- customTypeColumn -->
            <td class="text-left" v-if="!item.isDefaultValue && !item.isSystemValue">
              {{ item.processStepName || 'Custom Field'}}
            </td>
            <td class="text-left" v-else-if="item.isSystemValue">
              System
            </td>
            <td class="text-left" v-else-if="item.isDefaultValue">
              Default
            </td>
            <!-- customValueColumn -->
            <td class="text-left" v-if="item.customFieldGroupId !== null">
              {{item.fieldName}}
            </td>
            <td class="text-left" v-else-if="item.systemValueId !== null">
              {{item.systemValue}}
            </td>
            <td class="text-left" v-else-if="item.defaultValue !== null">
              {{item.defaultValue}}
            </td>
            <td class="text-left" v-else-if="item.customFieldGroupId === null && item.systemValueId === null && item.defaultValue === null">
              n/a
            </td>
            <!-- icon column -->
            <td>
              <v-btn text v-if="!expanded.includes(item)" @click="handleExpand(item, true)">
                <v-icon>edit</v-icon>
              </v-btn>
              <v-btn text v-if="expanded.includes(item)" @click="handleExpand(item, false)">cancel</v-btn>
            </td>
          </tr>
        </template>

        <template #item.customTypeColumn="{ item }">

        </template>
        <template #item.customValueColumn="{ item }">
          <span v-if="item.customFieldGroupId !== null">{{item.fieldName}}</span>
          <span v-else-if="item.systemValueId !== null">{{item.systemValue}}</span>
          <span v-else-if="item.defaultValue !== null">{{item.defaultValue}}</span>
          <span v-else-if="item.customFieldGroupId === null && item.systemValueId === null && item.defaultValue === null">n/a</span>
        </template>
        <template #item.icons="{ item }">
          <v-btn text v-if="!expanded.includes(item)" @click="handleExpand(item, true)">
            <v-icon>edit</v-icon>
          </v-btn>
          <v-btn text v-if="expanded.includes(item)" @click="handleExpand(item, false)">cancel</v-btn>
        </template>
      </v-data-table>

      <Snackbar :snackbar="snackbar"></Snackbar>
    </v-flex>
  </v-layout>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Vue2Filters from 'vue2-filters'
  import { getRequest, deleteRequest, putRequest, postRequest } from '@/helpers/helpers'
  import Snackbar from '@/components/Snackbar.vue'
  import { SNACKBAR_SUCCESS, SNACKBAR_ERROR } from '@/helpers/helpers'

  export default {
    name: 'ProcessSteps',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar
    },
    data () {
      return {
        headers: [
          { text: 'Parameter Name', value: 'parameterName', show: true },
          { text: 'Type', value: 'customTypeColumn', show: true },
          { text: 'Value', value: 'customValueColumn', show: true},
          { text: null, value: 'icons', show: true }
        ],
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/settings/functions`
          },
        ],
        companyId: this.$store.state.user.details.companyId,
        functionId: this.$route.params.id,
        userId: this.$store.state.user.details.id,
        systemValues: [],
        details: {},
        snackbar: {},
        parentObjects: [],
        availableCustomFields: [],
        selectedField: {},
        expanded: [],
      }
    },
    computed: {
    },
    methods: {
      async getFunctionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/function/${this.functionId}`)
        this.details = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      },
      async getSystemValues () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/function/systemValues`)
        this.systemValues = data
      },
      async loadParentObjects () {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/processStep/getParentObjects`)
        this.parentObjects = data
      },
      async loadFieldsByParent(id) {
        const {data} = await getRequest(`/api/v1/flow/companies/${this.companyId}/customField/getByParentProcessStep/${id}`)
        this.availableCustomFields = data
      },
      async handleExpand (item, expand) {
        if(expand) {
          this.expanded = [item]
          if(item.processStepId) {
            this.loadFieldsByParent(item.processStepId)
          }
        } else {
          this.expanded = []
        }
      },
      async saveParam (item) {

        try {
          this.$store.commit(AppMutations.SET_LOADING, true)
          await postRequest(`/api/v1/flow/companies/${this.companyId}/function/${this.functionId}/param`, item)
          this.expanded = []
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = SNACKBAR_SUCCESS
          this.snackbar.text = 'Successfully Updated Parameters'
          this.snackbar.enabled = true
        } catch (e) {
          this.$store.commit(AppMutations.SET_LOADING, false)
          this.snackbar = SNACKBAR_ERROR
          this.snackbar.text = 'Error Saving Updates'
          this.snackbar.enabled = true
        }

      }
    },
    async created () {
      this.getFunctionDetails()
      this.getSystemValues()
      this.loadParentObjects()
    }
  }
</script>

<style scoped lang="scss">


</style>
