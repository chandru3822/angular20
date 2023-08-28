<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        </v-toolbar>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">
            {{dbFunction.functionName}}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" @click="[addNew = !addNew, newParam = {}, getDataTypes(), getParameterTypes(), getSystemValues()]">
              {{addNew ? 'Cancel' : 'Add New Param'}}
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-list>
          <v-list-item>
            <v-list-item-title>Display Name: <strong>{{dbFunction.displayName}}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Function Type: <strong>{{dbFunction.functionType}}</strong></v-list-item-title>
          </v-list-item>
<!--          only need to show return type for requirement functions -->
          <v-list-item v-if="dbFunction.dbFunctionTypeId === 1">
            <v-list-item-title>Function Return Data Type: <strong>{{dbFunction.returnDataType}}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Allow use by process steps: <strong>{{dbFunction.processStepActionable}}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Allow use by events: <strong>{{dbFunction.eventActionable}}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item v-if="dbFunction.dbFunctionTypeId === 2">
            <v-list-item-title>Run in Backend: <strong>{{dbFunction.runInBackend}}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Description: <strong>{{dbFunction.description || 'N/A'}}</strong></v-list-item-title>
          </v-list-item>
        </v-list>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add New Param</h3>
          <div class="mb-3">
            <v-text-field text label="Parameter Name"
                          v-model="newParam.parameterName"
                          hint="* This should be a UI friendly name"
                          persistent-hint></v-text-field>
            <v-select
              v-model="newParam.parameterTypeId"
              :items="parameterTypes"
              label="Parameter Type"
              item-text="parameterType"
              item-value="id"
            ></v-select>
            <v-select
              v-if="newParam.parameterTypeId === 1"
              v-model="newParam.systemValueId"
              :items="systemValues"
              label="System Value"
              item-text="systemValue"
              item-value="id"
            ></v-select>
            <v-select
              v-else-if="newParam.parameterTypeId != null"
              v-model="newParam.dataTypeId"
              :items="dataTypes"
              label="Data Type"
              item-text="dataType"
              item-value="id"
            ></v-select>
            <div v-if="newParam.parameterTypeId != null && newParam.parameterTypeId !== 1">
              <v-checkbox label="Nullable"
                          class="default-text-color"
                          v-model="newParam.nullable"
              />
              <v-textarea class="body-medium" hide-details
                          auto-grow
                          rows="4"
                          label="Description"
                          outlined v-model="newParam.description"/>
            </div>
          </div>
          <v-btn :disabled="!newParam || !newParam.parameterName || ( newParam.parameterTypeId !== 1 && !newParam.dataTypeId)
                    || !newParam.parameterTypeId || (newParam.parameterTypeId === 1 && !newParam.systemValueId)"
                 color="primary" class="mr-2"
                 @click="[addParam()]">
<!--                 @click="[addNew = false, addParam()]">-->
            Save
          </v-btn>
          <v-btn text color="primary" @click="[addNew = !addNew, newParam = {}]">Cancel</v-btn>
        </v-card>
        <v-divider></v-divider>
        <v-card flat class="px-3">
          <h3 class="pt-3">Params</h3>
          <v-data-table
            :headers="headers"
            :items="dbFunction.dbFunctionParams"
            :fixed-header="true"
            hide-default-footer
            single-expand
            :expanded.sync="expanded"
            class="elevation-1 mt-3"
          >
            <template #no-data>
              <span class="default-text-color">No available params</span>
            </template>
            <template #no-results>
              <span class="default-text-color">No available params</span>
            </template>

            <template #expanded-item="{ headers, item }">
              <td :colspan="headers.length" class="pa-4" :class="{'shaded-row': dbFunction.dbFunctionParams.indexOf(item) % 2}">
                <h3>Edit Param</h3>
                <div class="mb-3">
                  <v-text-field text label="Parameter Name"
                                v-model="item.parameterName"
                                hint="* This should be a UI friendly name"
                                persistent-hint></v-text-field>
                  <div v-if="item.parameterTypeId !== 1">
                    <v-checkbox label="Nullable"
                                class="default-text-color"
                                v-model="item.nullable"
                    />
                    <v-textarea class="body-medium" hide-details
                                auto-grow
                                rows="4"
                                label="Description"
                                outlined v-model="item.description"/>
                  </div>
                </div>
                <v-btn color="primary" class="white--text mr-2"
                       @click="saveParam(item)">
                  Save
                </v-btn>
              </td>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  {{item.id}}
                </td>
                <td class="text-left">
                  {{item.parameterName}}
                </td>
                <td class="text-left">
                  {{item.dataType}}
                </td>
                <td class="text-left">
                  {{item.parameterType}}
                </td>
                <td class="text-left">
                  {{item.systemValue}}
                </td>
                <td class="text-left">
                  <input type="checkbox" v-model="item.nullable" disabled readonly>
                </td>
                <td class="text-left">
                  <pre class="app-pre-wrapper">
                    {{item.description}}
                  </pre>
                </td>
                <td>
                  <v-btn small text color="primary" v-if="!expanded.includes(item)" @click="expanded = [item]">
                    <v-icon>edit</v-icon>
                  </v-btn>
                  <v-btn small text color="primary" v-if="expanded.includes(item)" @click="expanded = []">cancel</v-btn>
                </td>
              </tr>
            </template>
          </v-data-table>
        </v-card>
        <v-divider class="mt-5"></v-divider>
        <v-card flat class="px-3">
          <h3 class="pt-3">Already Assigned To:</h3>
          <div v-if="null != dbFunction.companyFunctions && dbFunction.companyFunctions.length > 0">
            <span v-for="(cf, index) in dbFunction.companyFunctions" :key="index">
              {{cf.companyName}},
            </span>
          </div>
          <div v-else>
            Not assigned to any companies yet
          </div>
        </v-card>
        <v-divider class="mt-5"></v-divider>
        <v-card flat class="px-3">
          <h3 class="pt-3">Save to Companies</h3>
          <v-select attach v-model="selectedCompanies"
                    :items="companies"
                    label="Select Companies"
                    item-text="companyName"
                    item-value="id"
                    return-object
                    clearable
                    multiple
          >
            <template
              slot="selection"
              slot-scope="{ item, index }"
            >
              <div v-if="index === 0 && selectedCompanies.length < 3">
                <v-chip small v-for="sc in selectedCompanies">
                  <span>{{ sc.companyName }}</span>
                </v-chip>
              </div>
              <span
                v-if="index === 1 && selectedCompanies.length >= 3"
                class="primary--text text-caption"
              >{{ selectedCompanies.length }} selected</span>
            </template>
          </v-select>
          <v-btn :disabled="selectedCompanies.length === 0"
                 color="primary" class="white--text mr-2"
                 @click="pushToCompanies()">
            Push to Companies
          </v-btn>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, postRequest, putRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'

  export default {
    name: 'DbFunction',
    data() {
      return {
        constants,
        snackbar: {},
        addNew: false,
        dbFunction: {},
        newParam: {},
        dataTypes: [],
        parameterTypes: [],
        systemValues: [],
        companies: [],
        expanded: [],
        selectedCompanies: [],
        functionId: parseInt(this.$route.params.id),
        headers: [
          {text: 'ID', value: 'id', show: true},
          {text: 'Parameter Name', value: 'parameterName', show: true},
          {text: 'Data Type', value: 'dataType', show: true},
          {text: 'Parameter Type', value: 'parameterType', show: true},
          {text: 'System Value', value: 'systemValue', show: true},
          {text: 'Nullable', value: 'nullable', show: true},
          {text: 'Description', value: 'description', show: true},
          {text: '', value: 'icons', show: true},
        ],
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/admin/functions`
          },
        ]
      }
    },
    async created () {
      this.getFunction()
      this.getCompanies()
    },
    methods: {
      blah(item) {
        this.$set(item, 'edit', true)
      },
      async getFunction() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dbFunction/${this.functionId}`)
          this.dbFunction = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Function')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanies() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/dbFunction/${this.functionId}/availableCompanies`)
          this.companies = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Function')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getDataTypes() {
        if(this.dataTypes.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data, status} = await getRequest(`/dataType/getSystem`)
            this.dataTypes = data
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Data Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async getParameterTypes() {
        if(this.dataTypes.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data, status} = await getRequest(`/dbFunction/parameterTypes`)
            this.parameterTypes = data
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Parameter Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async saveParam(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await putRequest(`/dbFunction/param`, item)
          this.expanded = []
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Function Param')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addParam() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newParam.dbFunctionId = this.functionId
          this.newParam.dataTypeId = this.newParam.dataTypeId != null ? this.newParam.dataTypeId :
              this.systemValues.find(sv => sv.id === this.newParam.systemValueId)?.dataTypeId
          const {data, status} = await postRequest(`/dbFunction/param`, this.newParam)
          this.dbFunction = data
          this.newParam = {}
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Function Param')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async pushToCompanies() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            ...this.dbFunction,
            selectedCompanyIds: this.selectedCompanies.map(sc => sc.id),
          }
          const {data, status} = await postRequest(`/dbFunction/${this.functionId}/addToCompany`, params)
          this.dbFunction = data
          this.companies = this.companies.filter(c => {
            let match = this.selectedCompanies.find(sc => sc.id === c.id)
            return !match
          })
          this.selectedCompanies = []
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Function Param')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSystemValues () {
        if(this.systemValues.length === 0) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data, status} = await getRequest(`/dbFunction/systemValues`)
            this.systemValues = data
            handleHidingGlobalLoader(this, status)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
    }
  }
</script>
