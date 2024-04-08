<template>
  <v-container id="functions-admin-container">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="app-title">Functions</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                :text="addNew ? 'Cancel' : 'Add New'"
                   @click="[addNew = !addNew, newFunction = {}, getDataTypes(), getFunctionTypes()]">
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat>
          <h3>Add New Function</h3>
          <div class="mb-3">
            <a-text-field  label="Function Name"
                          v-model="newFunction.functionName"
                          hint="* This MUST match the function name in the procedure files"
                          persistent-hint></a-text-field>
            <a-text-field  label="Display Name"
                          v-model="newFunction.displayName"></a-text-field>
            <a-select
                class="mt-2"
                v-model="newFunction.dbFunctionTypeId"
                :items="dbFunctionTypes"
                label="Function Type"
                item-title="functionType"
                item-value="id"
            ></a-select>
            <a-select
                v-if="newFunction.dbFunctionTypeId === 1"
                v-model="newFunction.returnDataTypeId"
                :items="dataTypes"
                label="Return Data Type"
                item-title="dataType"
                item-value="id"
            ></a-select>

            <v-checkbox
                type="checkbox"
                v-model="newFunction.processStepActionable"
                label="Allow use by process steps"
            />

            <v-checkbox
                type="checkbox"
                v-model="newFunction.eventActionable"
                label="Allow use by events"
            />

            <v-checkbox
                v-if="newFunction.dbFunctionTypeId === 2"
                type="checkbox"
                v-model="newFunction.runInBackend"
                label="Run in backend"
            />
          </div>
          <a-btn variant="text" text="Cancel" @click="[addNew = !addNew, newFunction = {}]" />
          <a-btn
              :disabled="!newFunction || !newFunction.functionName || !newFunction.displayName || !newFunction.dbFunctionTypeId || (newFunction.dbFunctionTypeId === 1 && !newFunction.returnDataTypeId)"
              text="Save" class="mr-2"
              @click="addFunction()">
          </a-btn>
        </v-card>
        <a-text-field
            v-model="search"
            class="mb-2 px-4 py-2"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
        ></a-text-field>
        <v-divider></v-divider>
        <v-data-table
            :headers="headers"
            :search="search"
            :items="filteredFunctions"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1 org-type-table"
        >
          <template #no-data>
            <span class="default-text-color">NO DATA HERE!</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No data</span>
          </template>


          <template #item="{ item }">
            <tr class="text-left" :class="{'shaded-row': functions.indexOf(item) % 2}">
              <td class="text-left">{{ item.functionName }}</td>
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.functionType }}</td>
              <td class="text-right">
                <a-btn variant="text" size="small" prepend-icon="edit" @click="goToFunction(item.id)">
                </a-btn>
                <a-btn variant="text" size="small" prepend-icon="delete" @click="functionToDelete=item">
                </a-btn>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!functionToDelete" @confirm="deleteFunction"
                        @close-dialog="functionToDelete = null">
      Are you sure you want to delete this function <strong>{{ functionToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest} from '@/helpers/helpers'
import ConfirmationDialog from '@/components/ConfirmationDialog'
import {getCurrentInstance, computed, onMounted, ref} from 'vue'
import { useUserStore } from '@/stores/UserStorePinia.js'
import { useAppStore } from '@/stores/AppStorePinia.js'
import {useRouter} from "vue-router/composables"

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const userStore = useUserStore()
const appStore = useAppStore()
const router = useRouter()
const snackbar = vueInstance.$snackbar

const search = ref('')
const addNew = ref(false)
const functions = ref([])
const dbFunctionTypes = ref([])
const dataTypes = ref([])
const newFunction = ref({})
const userId = ref(userStore.details.id)
const expanded = ref([])
const functionToDelete = ref(null)
const headers = ref([
  {text: 'Function', value: 'functionName', show: true},
  {text: 'Display Name', value: 'displayName', show: true},
  {text: 'Type', value: 'functionType', show: true},
  {text: null, value: 'icons', show: true, width: 150, sortable: false}
])
const functionToDeleteName = computed(() => {
  return functionToDelete.value ? functionToDelete.value.functionName : ''
})

const filteredFunctions = computed(() => {
  return functions.value.filter(f => !f.archived)
})
onMounted(() => {
  getFunctions()
})

const getFunctions = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/dbFunction`)
    functions.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Functions')
    appStore.loading = false
  }
}
const getDataTypes = async () => {
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
const getFunctionTypes = async () => {
  if (dbFunctionTypes.value.length === 0) {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/dbFunction/types`)
      dbFunctionTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Functions')
      appStore.loading = false
    }
  }
}
const addFunction = async () => {
  appStore.loading = true
  try {
    //unset the returnDataTypeId if they changed the function type back to Action
    newFunction.value.returnDataTypeId = newFunction.value.dbFunctionTypeId !== 1 ? null : newFunction.value.returnDataTypeId
    const {data, status} = await postRequest(`/dbFunction`, newFunction.value)
    goToFunction(data.id)
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Loading Functions')
    appStore.loading = false
  }
}
const deleteFunction = async () => {
  const item = functionToDelete.value
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/dbFunction/${item.id}`)
    item.archived = true
    handleHidingGlobalLoader(status)
    snackbar('SUCCESS', 'Function Deleted')
    appStore.loading = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Functions')
    appStore.loading = false
  }
}

const goToFunction = (functionId) => {
  router.push({path: `/admin/function/${functionId}`})
}
</script>

<style lang="scss">
#functions-admin-container .v-data-table__wrapper {
  max-height: calc(100vh - 275px);
  min-height: 300px;
}
</style>
