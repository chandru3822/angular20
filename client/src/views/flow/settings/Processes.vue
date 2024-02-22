<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!constants.IS_MOBILE" class="app-title">Processes</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newProject = {}]"
              v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'ADD')"
              :hide-text-on-mobile="constants.IS_MOBILE"
              :prepend-icon="addNew ? 'add' : ''"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-text-field v-if="addNew"
                        v-model="newProcess.processName"
                        placeholder="Enter new process name"
                        label="Process">
          </v-text-field>
          <AlbatrossButton
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
                {{p.processName}}
              </v-list-item-content>
              <v-list-item-action class="clickable">
                <AlbatrossButton
                  @click="goToProcess(p.id)"
                  variant="text"
                  color="primary"
                  prepend-icon="edit"
                />
              </v-list-item-action>
              <AlbatrossButton
                  v-if="store.getters.userHasFeatureAccessLevel('SETTINGS', 'DELETE')"
                  @click="processToDelete=p"
                  color="primary"
                  variant="text"
                  prepend-icon="delete"
              />
              <ConfirmationDialog :open-dialog="!!processToDelete" @confirm="deleteProcess" @close-dialog="processToDelete = null">
                Are you sure you want to delete this process: <strong>{{ processToDeleteName }}</strong>?

              </ConfirmationDialog>
            </v-list-item>
          </v-list>
          <!--<v-btn v-else-if="groupOrderChanged" @click="saveGroupChanges">Save Changes</v-btn>-->
        </v-container>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'

import { handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {getCurrentInstance, onMounted, ref, computed} from "vue";

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const store = vueInstance.$store
const router = vueInstance.$router

const addNew = ref(false)
const selectedProcessId = ref(null)
const newProcess = ref({})
const companyId = ref(store.state.user.details.companyId)
const parentCompanyId = ref(store.state.user.details.highestParentCompanyId)
const userId = ref(store.state.user.details.id)
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
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/processes`)
    processes.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteProcess = async () => {
  const processId = processToDelete.value.id
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await deleteRequest(`/processes/${processId}`)
    snackbar('SUCCESS', 'Process Deleted')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Process')
    store.commit(AppMutations.SET_LOADING, false)
  }
  processToDelete.value.archived = true
  processToDelete.value = null
}
const addNewProcess = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    newProcess.value.companyId = companyId.value
    newProcess.value.parentCompanyId = parentCompanyId.value ? parentCompanyId.value : companyId.value
    newProcess.value.createdById = userId.value

    const {data, status} = await postRequest(`/processes`, newProcess.value)

    handleHidingGlobalLoader(vueInstance, status)
    router.push({name: 'process', params: {id: data.id}})
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Process')
    store.commit(AppMutations.SET_LOADING, false)
  }
}

onMounted(async () =>{
  getProcesses()
})

</script>
