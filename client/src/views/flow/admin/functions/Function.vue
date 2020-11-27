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
            <v-btn text @click="[addNew = !addNew, newParam = {}, getDataTypes(), getParameterTypes(), getSystemValues()]">
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
          <v-list-item v-if="dbFunction.functionTypeId === 1">
            <v-list-item-title>Function Return Data Type: <strong>{{dbFunction.returnDataType}}</strong></v-list-item-title>
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
              v-model="newParam.dataTypeId"
              :items="dataTypes"
              label="Data Type"
              item-text="dataType"
              item-value="id"
            ></v-select>
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
          </div>
          <v-btn :disabled="!newParam || !newParam.parameterName || !newParam.dataTypeId
                    || !newParam.parameterTypeId || (newParam.parameterTypeId === 1 && !newParam.systemValueId)"
                 color="primaryCustom" class="white--text mr-2"
                 @click="[addNew = false, addParam()]">
            Save
          </v-btn>
          <v-btn @click="[addNew = !addNew, newParam = {}]">Cancel</v-btn>
        </v-card>
        <v-divider></v-divider>
        <v-card flat class="px-3">
          <h3 class="pt-3">Params</h3>
          <v-data-table
            :headers="headers"
            :items="dbFunction.dbFunctionParams"
            :fixed-header="true"
            hide-default-footer
            class="elevation-1 mt-3"
          >
            <template #no-data>
              No available params
            </template>
            <template #no-results>
              No available params
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
          <v-select v-model="selectedCompanies"
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
                class="primary--text caption"
              >{{ selectedCompanies.length }} selected</span>
            </template>
          </v-select>
          <v-btn :disabled="selectedCompanies.length === 0"
                 color="primaryCustom" class="white--text mr-2"
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

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
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
        selectedCompanies: [],
        functionId: parseInt(this.$route.params.id),
        headers: [
          {text: 'ID', value: 'id', show: true},
          {text: 'Parameter Name', value: 'parameterName', show: true},
          {text: 'Data Type', value: 'dataType', show: true},
          {text: 'Parameter Type', value: 'parameterType', show: true},
          {text: 'System Value', value: 'systemValue', show: true}
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
      async getFunction() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/dbFunction/${this.functionId}`)
          this.dbFunction = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/dbFunction/${this.functionId}/availableCompanies`)
          this.companies = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
            const {data} = await getRequest(`/dataType/getSystem`)
            this.dataTypes = data
            this.$store.commit(AppMutations.SET_LOADING, false)
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
            const {data} = await getRequest(`/dbFunction/parameterTypes`)
            this.parameterTypes = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Parameter Types')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addParam() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          this.newParam.dbFunctionId = this.functionId
          const {data} = await postRequest(`/dbFunction/param`, this.newParam)
          this.dbFunction = data
          this.newParam = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await postRequest(`/dbFunction/${this.functionId}/addToCompany`, params)
          this.dbFunction = data
          this.companies = this.companies.filter(c => {
            let match = this.selectedCompanies.find(sc => sc.id === c.id)
            return !match
          })
          this.selectedCompanies = []
          this.$store.commit(AppMutations.SET_LOADING, false)
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
            const {data} = await getRequest(`/dbFunction/systemValues`)
            this.systemValues = data
            this.$store.commit(AppMutations.SET_LOADING, false)
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

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

