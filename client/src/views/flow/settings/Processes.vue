<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Processes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newProcess = {}]"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="addNew ? 'add' : ''"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <a-text-field v-if="addNew"
                        v-model="newProcess.processName"
                        placeholder="Enter new process name"
                        label="Process">
          </a-text-field>
          <a-btn
            color="primary"
            :disabled="!newProcess.processName"
            v-if="addNew"
            @click="addNewProcess"
            text="SAVE"
          />
          <v-list v-for="(p, index) in filteredProcesses"
                  :key="index">
            <v-list-item :class="{'shaded-row': index % 2}">
              <v-list-item-content class="text-left clickable" @click="goToProcess(p.id)">
                <router-link :to="`/settings/processes/${p.id}`" class="router-link-td">
                  {{p.processName}}
                </router-link>
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <a-btn
                  @click="goToProcess(p.id)"
                  variant="text"
                  id="qa-edit-process-button"
                  color="primary"
                  prepend-icon="edit"
                />
              </v-list-item-action>
              <a-btn
                  v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  @click="processToDelete=p"
                  color="primary"
                  variant="text"
                  prepend-icon="delete"
              />
              <ConfirmationDialog :open-dialog="!!processToDelete" @confirm="[processToDelete.archived = true, deleteProcess()]" @close-dialog="processToDelete = null">
                Are you sure you want to delete this process: <strong>{{ processToDeleteName }}</strong>?

              </ConfirmationDialog>
            </v-list-item>
          </v-list>
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>


import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";


import {getCurrentInstance, onMounted, ref, computed} from "vue";
import { useUserStore } from '@/stores/UserStore.js'
import {useRouter} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()
const vueInstance = getCurrentInstance().proxy

const store = vueInstance.$store
const userStore = useUserStore()
const router = useRouter()

const addNew = ref(false)
const selectedProcessId = ref(null)
const newProcess = ref({})
const companyId = ref(userStore.details.companyId)
const parentCompanyId = ref(userStore.details.highestParentCompanyId)
const userId = ref(userStore.details.id)
const processes = ref([])
const processToDelete = ref(null)

const processToDeleteName = computed(() => {
  return processToDelete.value ? processToDelete.value.processName : ''
})

const filteredProcesses = computed(() => {
  return processes.value.filter((p) => p.archived === false)
})

const goToProcess = (processId) => {
  router.push({path: `/settings/processes/${processId}`})
}
const getProcesses = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/processes`)
    processes.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const deleteProcess = async () => {
  const processId = processToDelete.value.id
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/processes/${processId}`)
    appStore.showSnack('SUCCESS', 'Process Deleted')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Deleting Process')
    appStore.loading = false
  }
}
const addNewProcess = async () => {
  appStore.loading = true
  try {
    newProcess.value.companyId = companyId.value
    newProcess.value.parentCompanyId = parentCompanyId.value ? parentCompanyId.value : companyId.value
    newProcess.value.createdById = userId.value

    const {data, status} = await postRequest(`/processes`, newProcess.value)

    handleHidingGlobalLoader(status)
    await router.push({name: 'process', params: {id: data.id}})
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Process')
    appStore.loading = false
  }
}

onMounted(() =>{
  getProcesses()
})

</script>
