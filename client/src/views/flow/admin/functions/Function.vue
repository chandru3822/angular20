<template>
  <v-container>
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
        </v-toolbar>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">
            {{ dbFunction.functionName }}
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                :text="addNew ? 'Cancel' : 'Add New Param'"
                   @click="[addNew = !addNew, newParam = {}, getDataTypes(), getParameterTypes(), getSystemValues()]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-list>
          <v-list-item>
            <v-list-item-title>Display Name: <strong>{{ dbFunction.displayName }}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Function Type: <strong>{{ dbFunction.functionType }}</strong></v-list-item-title>
          </v-list-item>
          <!--          only need to show return type for requirement functions -->
          <v-list-item v-if="dbFunction.dbFunctionTypeId === 1">
            <v-list-item-title>Function Return Data Type: <strong>{{ dbFunction.returnDataType }}</strong>
            </v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Allow use by process steps: <strong>{{ dbFunction.processStepActionable }}</strong>
            </v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Allow use by events: <strong>{{ dbFunction.eventActionable }}</strong>
            </v-list-item-title>
          </v-list-item>
          <v-list-item v-if="dbFunction.dbFunctionTypeId === 2">
            <v-list-item-title>Run in Backend: <strong>{{ dbFunction.runInBackend }}</strong></v-list-item-title>
          </v-list-item>
          <v-list-item>
            <v-list-item-title>Description: <strong>{{ dbFunction.description || 'N/A' }}</strong></v-list-item-title>
          </v-list-item>
        </v-list>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add New Param</h3>
          <div class="mb-3">
            <a-text-field label="Parameter Name"
                          v-model="newParam.parameterName"
                          hint="* This should be a UI friendly name"
                          persistent-hint></a-text-field>
            <a-select
                v-model="newParam.parameterTypeId"
                :items="parameterTypes"
                label="Parameter Type"
                item-title="parameterType"
                item-value="id"
            ></a-select>
            <a-select
                v-if="newParam.parameterTypeId === 1"
                v-model="newParam.systemValueId"
                :items="systemValues"
                label="System Value"
                item-title="systemValue"
                item-value="id"
            ></a-select>
            <a-select
                v-else-if="newParam.parameterTypeId != null"
                v-model="newParam.dataTypeId"
                :items="dataTypes"
                label="Data Type"
                item-title="dataType"
                item-value="id"
            ></a-select>
            <div v-if="newParam.parameterTypeId != null && newParam.parameterTypeId !== 1">
              <v-checkbox label="Nullable"
                          class="default-text-color"
                          v-model="newParam.nullable"
              />
              <a-textarea class="body-medium" hide-details
                          auto-grow
                          rows="4"
                          label="Description"
                          variant="outlined"
                          v-model="newParam.description"/>
            </div>
          </div>
          <a-btn :disabled="!newParam || !newParam.parameterName || ( newParam.parameterTypeId !== 1 && !newParam.dataTypeId)
                    || !newParam.parameterTypeId || (newParam.parameterTypeId === 1 && !newParam.systemValueId)"
                 class="mr-2"
                 text="Save"
                 @click="addParam()">
          </a-btn>
          <a-btn text="Cancel" variant="text" @click="[addNew = !addNew, newParam = {}]" />
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
              <td :colspan="headers.length" class="pa-4"
                  :class="{'shaded-row': dbFunction.dbFunctionParams.indexOf(item) % 2}">
                <h3>Edit Param</h3>
                <div class="mb-3">
                  <a-text-field  label="Parameter Name"
                                v-model="item.parameterName"
                                hint="* This should be a UI friendly name"
                                persistent-hint></a-text-field>
                  <div v-if="item.parameterTypeId !== 1">
                    <v-checkbox label="Nullable"
                                class="default-text-color"
                                v-model="item.nullable"
                    />
                    <a-textarea class="body-medium" hide-details
                                auto-grow
                                rows="4"
                                label="Description"
                                variant="outlined"
                                v-model="item.description"/>
                  </div>
                </div>
                <a-btn class="mr-2" text="Save"
                       @click="saveParam(item)">
                </a-btn>
              </td>
            </template>

            <template #item="{ item, index }">
              <tr :class="{'shaded-row': index % 2}">
                <td class="text-left">
                  {{ item.id }}
                </td>
                <td class="text-left">
                  {{ item.parameterName }}
                </td>
                <td class="text-left">
                  {{ item.dataType }}
                </td>
                <td class="text-left">
                  {{ item.parameterType }}
                </td>
                <td class="text-left">
                  {{ item.systemValue }}
                </td>
                <td class="text-left">
                  <input type="checkbox" v-model="item.nullable" disabled readonly>
                </td>
                <td class="text-left">
                  <pre class="app-pre-wrapper">
                    {{ item.description }}
                  </pre>
                </td>
                <td>
                  <a-btn size="small" v-if="!expanded.includes(item)"
                                   prepend-icon="edit" variant="text"
                                   @click="expanded = [item]">
                  </a-btn>
                  <a-btn size="small" v-if="expanded.includes(item)"
                                   text="cancel"
                                   @click="expanded = []"></a-btn>
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
              {{ cf.companyName }},
            </span>
          </div>
          <div v-else>
            Not assigned to any companies yet
          </div>
        </v-card>
        <v-divider class="mt-5"></v-divider>
        <v-card flat class="px-3">
          <h3 class="pt-3">Save to Companies</h3>
          <a-select attach v-model="selectedCompanies"
                    :items="companies"
                    label="Select Companies"
                    item-title="companyName"
                    item-value="id"
                    return-object
                    clearable
                    multiple>
            <template v-slot:selection="{ item, index }">
              <div v-if="index === 0 && selectedCompanies.length < 2">
                <v-chip small v-for="sc in selectedCompanies">
                  <span>{{ sc.companyName }}</span>
                </v-chip>
              </div>
              <span
                  v-if="index === 1 && selectedCompanies.length >= 2"
                  class="primary--text text-caption"
              >{{ selectedCompanies.length }} selected</span>
            </template>
          </a-select>
          <a-btn :disabled="selectedCompanies.length === 0"
                 class="mr-2"
                 text="Push to Companies"
                 @click="pushToCompanies()">
          </a-btn>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
import {handleHidingGlobalLoader, getRequest, postRequest, putRequest} from '@/helpers/helpers'
import {getCurrentInstance, computed, onMounted, ref} from 'vue'

import { useAppStore } from '@/stores/AppStore.js'
import {useRouter, useRoute} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const appStore = useAppStore()
const router = useRouter()
const route = useRoute()
const snackbar = vueInstance.$snackbar

const addNew = ref(false)
const dbFunction = ref({})
const newParam = ref({})
const dataTypes = ref([])
const parameterTypes = ref([])
const systemValues = ref([])
const companies = ref([])
const expanded = ref([])
const selectedCompanies = ref([])
const headers = ref([
  {text: 'ID', value: 'id', show: true},
  {text: 'Parameter Name', value: 'parameterName', show: true},
  {text: 'Data Type', value: 'dataType', show: true},
  {text: 'Parameter Type', value: 'parameterType', show: true},
  {text: 'System Value', value: 'systemValue', show: true},
  {text: 'Nullable', value: 'nullable', show: true},
  {text: 'Description', value: 'description', show: true},
  {text: '', value: 'icons', show: true},
])
const breadcrumbs = ref([
  {
    text: 'Back',
    disabled: false,
    exact: true,
    to: `/admin/functions`
  }
])

const functionId = computed(() => {
  return parseInt(route.params.id)
})

onMounted(() => {
  getFunction()
  getCompanies()
})

const getFunction = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/dbFunction/${functionId.value}`)
    dbFunction.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Function')
    appStore.loading = false
  }
}
const getCompanies = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/dbFunction/${functionId.value}/availableCompanies`)
    companies.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Function')
    appStore.loading = false
  }
}
const getDataTypes = async() => {
  if (dataTypes.value.length === 0) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/dataType/getSystem`)
      dataTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Data Types')
      appStore.loading = false
    }
  }
}
const getParameterTypes = async() => {
  if (dataTypes.value.length === 0) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/dbFunction/parameterTypes`)
      parameterTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Parameter Types')
      appStore.loading = false
    }
  }
}
const saveParam = async(item) => {
  appStore.loading = true
  try {
    const {data, status} = await putRequest(`/dbFunction/param`, item)
    expanded.value = []
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Function Param')
    appStore.loading = false
  }
}
const addParam = async() => {
  appStore.loading = true
  try {
    newParam.value.dbFunctionId = functionId.value
    newParam.value.dataTypeId = newParam.value.dataTypeId != null ? newParam.value.dataTypeId :
        systemValues.value.find(sv => sv.id === newParam.value.systemValueId)?.dataTypeId
    const {data, status} = await postRequest(`/dbFunction/param`, newParam.value)
    dbFunction.value = data
    newParam.value = {}
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Function Param')
    appStore.loading = false
  }
}
const pushToCompanies = async() => {
  appStore.loading = true
  try {
    let params = {
      ...dbFunction.value,
      selectedCompanyIds: selectedCompanies.value.map(sc => sc.id),
    }
    const {data, status} = await postRequest(`/dbFunction/${functionId.value}/addToCompany`, params)
    dbFunction.value = data
    companies.value = companies.value.filter(c => {
      let match = selectedCompanies.value.find(sc => sc.id === c.id)
      return !match
    })
    selectedCompanies.value = []
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Function Param')
    appStore.loading = false
  }
}
const getSystemValues = async() => {
  if (systemValues.value.length === 0) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/dbFunction/systemValues`)
      systemValues.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      appStore.loading = false
    }
  }
}
</script>
