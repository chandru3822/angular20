<template>
  <v-container id="data-views-settings">
    <v-row>
      <v-col class="shrink" cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!isMobile" class="app-title">Data Views</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn v-if="is7oaksAdmin"
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newDataView = {}, getCompanyProcesses()]"
              :hide-text-on-mobile="isMobile"
              :text="!addNew ? 'Add New' : 'Cancel'"
              :prepend-icon="addNew ? 'close' : 'add'"
              >
            </a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addNew" class="text-left pa-5 mb-3 mt-2" flat >
          <h3>Add Data View</h3>
          <div class="mb-3">
            <v-form ref="dataViewForm">
            <a-text-field  v-model="newDataView.displayName"
                          :rules="requiredRules"
                          label="Display Name" />
            <a-text-field  v-model="newDataView.viewName"
                          :rules="tableNameRule"
                          label="Table Name (all lower case, underscores instead of spaces)" />
              <a-select label="Company Processes"
                        v-model="selectedCompanyProcesses"
                        :items="companyProcesses"
                        item-title="processName"
                        placeholder="Select"
                        multiple
                        return-object>
              </a-select>
            </v-form>
          </div>
          <div class="mb-3 error--text" v-if="saveError">
            {{saveErrorMsg}}
          </div>
          <a-btn
            :disabled="!newDataView.displayName || !newDataView.viewName || selectedCompanyProcesses.length === 0"
            color="primary"
            class="white--text mr-2"
            @click="validateForm(newDataView, true)"
            text="Save">
          </a-btn>
          <a-btn
            variant="text"
            color="primary"
            @click="[addNew = !addNew, newDataView = {}]"
            text="Cancel">
          </a-btn>
        </v-card>
        <v-data-table
            id="data-views-settings-table"
            :headers="headers"
            :items="dataViews"
            :fixed-header="true"
            :items-per-page="-1"
            :mobile-breakpoint="0"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            NO DATA HERE!
          </template>

          <template #no-results>
            No data
          </template>

          <template #item="{ item }">
            <tr  class="text-left" @click="goToView(item.id)" :class="{'shaded-row': dataViews.indexOf(item) % 2}">
              <td class="text-left">{{ item.displayName }}</td>
              <td class="text-left">{{ item.viewName }}</td>
              <td class="text-right">
                <a-btn
                  variant="text"
                  color="primary"
                  prepend-icon="edit">
                </a-btn>

              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
  import {handleHidingGlobalLoader, getRequest, postRequest} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getCurrentInstance, ref, onMounted, computed} from 'vue'

  import { useUserStore } from '@/stores/UserStorePinia.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  import {useRouter} from "vue-router/composables"

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()
  const appStore = useAppStore()
  const router = useRouter()
  const vuetify = vueInstance.$vuetify

  const addNew = ref(false)
  const saveError = ref(false)
  const saveErrorMsg = ref('')
  const dataViews = ref([])
  const companyProcesses = ref([])
  const selectedCompanyProcesses = ref([])
  const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
  const is7oaksAdmin = ref(userStore.isSystemAdmin)
  const newDataView = ref({})
  const tableNameRule = ref([
    () => (newDataView.value.viewName != null && newDataView.value.viewName !== '') || "Field to Update is required",
    v => (!v || (v && (v.length >= 5))) || 'Must be 5 characters or more',
    v => (!v || (v && (v.length <= 60))) || 'Must be 60 characters or less',
    v => (!v || (v && (v.indexOf(' ') <= 0))) || 'Cannot contain whitespace',
    v => (!v || (v && (v.indexOf('__') <= 0))) || "All word dividers must be a single '_'",
    v => (!v || (/^[a-z]+(?:_+[a-z]+)*$/.test(v))) || "Table Name must be all lowercase, no symbols except '_' and must start and end with a letter",
    v => (!v || (v && (!constants.RESERVED_SQL_WORDS.includes(v)))) || "Cannot use reserved words",
  ])

  const userId = ref(userStore.details.id)
  const companyId = ref(userStore.details.companyId)
  const headers = ref([
    { text: 'Display Name', value: 'displayName', show: true },
    { text: 'Table Name', value: 'viewName', width: 80, show: true },
    { text: null, value: 'icons', show: true, sortable: false }
  ])

  onMounted(async () => {
    await getDataViews()
  })

  const getCompanyProcesses = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/processes`)
      companyProcesses.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error loading processes')
      appStore.loading = false
    }
  }
  const validateForm = (view, isNew) => {
    saveError.value = false
    let match = dataViews.value?.find(dv => dv.viewName === view.viewName)
    if(match) {
      saveError.value = true
      saveErrorMsg.value = 'Table Name already in use'
    } else if (vueInstance.$refs.dataViewForm?.validate()) {
      saveDataView(view, isNew)
    }
  }
  const goToView = async (id) => {
    await router.push(`/settings/dataView/${id}`)
  }
  const saveDataView = async (dv, isNew) => {
    appStore.loading = true
    try {
      dv.companyProcessIds = selectedCompanyProcesses.value.map(cp => cp.id)
      const {data, status} = await postRequest(`/dataView`, dv)
      if(isNew){
        dataViews.value.push(data)
        addNew.value = false
        selectedCompanyProcesses.value = []
        newDataView.value = {}
        snackbar('SUCCESS', 'Data View Added')
      } else {
        snackbar('SUCCESS', 'Data View Updated')
      }
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', isNew ? 'Error Adding Data View' : 'Error Updating Data View')
      appStore.loading = false
    }
  }
  const getDataViews = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/dataView`)
      dataViews.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Data Views')
      appStore.loading = false
    }
  }

  const isMobile = computed(() => vuetify.breakpoint.smAndDown)
</script>

<style>
#data-views-settings-table > div.v-data-table__wrapper {
overflow-x: hidden;
}
</style>
