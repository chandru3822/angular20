<template>
  <v-container class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar color="white" flat>
          <v-breadcrumbs :items="breadcrumbs"></v-breadcrumbs>
          <v-spacer></v-spacer>
          <div v-if="changesMade">
            <AlbatrossButton
              class="mr-2"
              :to="{ path: `/settings/processes`}"
              text="CANCEL"
            />
            <AlbatrossButton
              color="primary white--text"
              @click="saveProcess"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
              text="SAVE CHANGES"
            />
          </div>
        </v-toolbar>
        <v-toolbar flat>
            <v-text-field class=" d-inline-block mt-4" v-if="editName" v-model="process.processName" :class="{'one-hunned': isMobile}"></v-text-field>
            <span v-else :class="{'one-hunned': isMobile}">
              {{  processId ? process.processName : 'New Process Step'}}
            </span>
            <AlbatrossButton
              class="d-inline-block"
              size="small"
              variant="text"
              color="primary"
              v-if="processId && editName && userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
              @click="saveProcess()"
              prepend-icon="save"
            />
            <AlbatrossButton
              class="d-inline-block"
              size="small"
              variant="text"
              color="primary"
              v-else-if="processId && userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
              @click="editName = true"
              prepend-icon="edit"
            />
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="getAvailableProcessSteps()"
              v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
              :hide-text-on-mobile="isMobile"
              :prepend-icon="addNew && isMobile ? 'mdi-close' : isMobile ? 'mdi-plus' : ''"
              :text="addNew ? 'CANCEL' : 'ADD PROCESS STEP'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <div class="flex-display align-baseline">
          <v-autocomplete
            v-model="process.denyListPositions"
            :items="owningPositions"
            multiple
            clearable
            item-text="position"
            item-value="positionId"
            return-object
            label="Positions that Cannot Add Project to Process"
        >
            <template v-slot:selection="{item, index}">
              <v-chip small v-if="process.denyListPositions && process.denyListPositions.length < 10">
              <span>{{ item.position }}</span>
              </v-chip>
              <span
                  v-if="index == 1 && process.denyListPositions && process.denyListPositions.length >= 10"
                  class="primary--text text-caption"
              >{{ process.denyListPositions.length }} selected</span>
            </template>
            <template v-slot:prepend-item>
            <v-list-item
              @click="toggleSelectAllPositions(process)">
            <v-list-item-action>
              <v-icon>{{ icon }}</v-icon>
            </v-list-item-action>
            <v-list-item-title>Select All</v-list-item-title>
          </v-list-item>
            <v-divider
                class="mt-2"
            ></v-divider>
            </template>
        </v-autocomplete>
          <AlbatrossButton
            @click="saveDeniedPositions"
            variant="text"
            icon
            color="primary"
            class="mb-5"
            prepend-icon="save"
          />
        </div>
        <v-container v-if="addNew">
          <v-autocomplete v-model="newProcessStep.processStepId"
                          :items="availableProcessSteps"
                          no-data-text="No Steps Available"
                          label="Select a Process Step"
                          item-text="processStepName"
                          item-value="id"
                          attach
          ></v-autocomplete>
          <v-autocomplete v-model="newProcessStep.owningPositions"
                          :items="owningPositions"
                          no-data-text="No Positions Available"
                          label="Select Owning Positions"
                          item-text="position"
                          item-value="positionId"
                          multiple
                          return-object
                          attach
          ></v-autocomplete>
<!--          <v-btn :disabled="!newProcessStep.processStepId || !newProcessStep.orgId" @click="assignProcessStep">Save</v-btn>-->
          <!--  per scott: temporarily removing requirement for orgId        -->
          <AlbatrossButton
            color="primary"
            :disabled="!newProcessStep.processStepId || !newProcessStep.owningPositions || newProcessStep.owningPositions.length === 0"
            @click="assignProcessStep"
            text="SAVE"
          />
        </v-container>
        <v-text-field
          v-model="search"
          class="mb-3 px-3 col-12"
          :style="{width: isMobile ? '100%' : '250px'}"
          append-icon="mdi-magnify"
          label="Search"
          single-line
          hide-details
        ></v-text-field>
        <v-data-table
            id="process-step-table"
            :headers="headers"
            :items="filterProcesses"
            :items-per-page="100"
            :footer-props="footerProps"
            single-expand
            :search="search"
            fixed-header
            :expanded.sync="expanded"
            class="elevation-1 table-striped"
        >
          <template v-slot:no-data>
            NO DATA HERE!
          </template>

          <template v-slot:no-results>
            NO RESULTS HERE!
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pb-4">
              <v-card flat color="transparent" class="text-left pa-4">
                <div class="mb-2">
                  <label>Initial Step:</label>
                  <input type="checkbox" class="ml-2" v-model="item.initialStep" @change="getActiveProcessAssignedToProcessStep(item)">
                  <v-autocomplete v-model="item.companyProcessStepStatusTypeId"
                                  v-if="item.initialStep"
                                  :loading="statusesLoading"
                                  class="mt-4 mb-2"
                                  :items="processStepStatusTypes"
                                  label="Initial Process Step Status Type"
                                  item-text="processStepStatusType"
                                  item-value="id"
                                  attach
                  ></v-autocomplete>
                </div>
                <v-autocomplete v-model="item.owningPositions"
                                class="pt-4"
                                :items="owningPositions"
                                no-data-text="No Positions Available"
                                label="Select Owning Positions"
                                item-text="position"
                                item-value="positionId"
                                multiple
                                return-object
                                attach
                ></v-autocomplete>
                <div class="mt-3 text-center">
                  <AlbatrossButton
                    color="primary"
                    :disabled="(item.initialStep && !item.companyProcessStepStatusTypeId) || (!item.owningPositions || item.owningPositions.length === 0)"
                    @click="saveProcessStepProcess(item)"
                    text="SAVE"
                  />
                  <AlbatrossButton
                    variant="text"
                    color="primary"
                    class="ml-3"
                    @click="expanded = []"
                    text="CANCEL"
                  />
                </div>
              </v-card>
            </td>
          </template>


              <template #item.processStepName="{item}" class="text-left">{{ item.processStepName }}</template>
              <template #item.positionName="{item}" class="text-left">
                <span v-for="(op,idx) in item.owningPositions" :key="idx">{{op.position}}<br/></span>
              </template>
              <template #item.dateModified="{item}" class="text-left">{{ item.dateModified ? item.dateModified : item.dateCreated | formatDate('date') }}</template>
              <template #item.initialStep="{item}" class="text-center">
                <input type="checkbox" v-model="item.initialStep"
                       disabled readonly>
              </template>
              <template #item.processStepStatusType="{item}" class="text-left">{{ item.processStepStatusType }}</template>
              <template #item.icons="{item}">
                <div style="display: flex; float: right;">
                  <AlbatrossButton
                    variant="text"
                    color="primary"
                    @click="[expanded.includes(item) ? expanded = [] : expanded = [item], getActiveProcessAssignedToProcessStep(item)]"
                    v-if="userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')"
                    :prepend-icon="expanded.includes(item) ? 'expand_less' : 'expand_more'"
                  />
                  <AlbatrossButton
                    :disabled="!userCanDelete"
                    variant="text"
                    color="primary"
                    @click="processStepToDelete=item"
                    prepend-icon="delete"
                  />
                </div>
              </template>

        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!processStepToDelete" @confirm="deleteStepFromProcess" @close-dialog="processStepToDelete = null">
      Are you sure you want to delete this process step from the {{process.processName}} process: <strong>{{processStepToDeleteName}}</strong>

    </ConfirmationDialog>
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'

import orderBy from 'lodash.orderby'
import cloneDeep from 'lodash.clonedeep'

import {getActiveAssignedToProcessStep} from '@/services/processStepStatusTypeService'
import { handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar } from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";

import {getCurrentInstance, onMounted, ref, computed} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = vueInstance.$route


const addNew = ref(false)
const search = ref('')
const editName = ref(false)
const newProcessStep = ref({})
const availableProcessSteps = ref([])
const processStepStatusTypes = ref([])
const owningPositions = ref([])
const processId = ref(route.params.id)
const changesMade = ref(false)
const statusesLoading = ref(false)
const process = ref({
  processStepProcesses: []
})
const breadcrumbs = ref([
  {
    text: 'Back',
    disabled: false,
    exact: true,
    to: `/settings/processes`
  },
])
const headers = ref([
  { text: 'Name', value: 'processStepName', show: true},
  { text: 'Owning Positions', value: 'positionName', sortable: false, show: true},
  { text: 'Last Modified', value: 'dateModified', show: true},
  { text: 'Initial', value: 'initialStep', show: true},
  { text: 'Status Type', value: 'processStepStatusType', show: true},
  { text: null, value: 'icons', show: true},
])
const footerProps = ref({
  'items-per-page-text': 'Rows per page:',
  'items-per-page-options': [25, 50, 100, 1000]
})
const expanded = ref([])
const selectedIndex = ref(null)
const processStepToDelete = ref(null)
const userCanAdd = ref(userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD'))
const userCanEdit = ref(userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
const userCanDelete = ref(userStore.userHasFeatureAccessLevel('SETTINGS', 'DELETE'))

onMounted(() => {
  getPositions()
  getProcessDetails()
})

const processStepToDeleteName = computed(() => {
  return processStepToDelete.value ? processStepToDelete.value.processStepName : ''
})
const selectAll = computed(() =>{
  return process.value.denyListPositions?.length === owningPositions.value?.length
})
const selectSome = computed(() => {
  return process.value.denyListPositions?.length > 0 && !selectAll.value
})
const icon = computed(() => {
  if (selectAll.value) {
    return 'check_box'
  }
  if (selectSome.value) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
})
const isMobile = computed(() =>{
  return vuetify.breakpoint.smAndDown
})

const filterProcesses = computed(() => {
  return process.value.processStepProcesses.filter(psp => { return !psp.archived})
})
const getProcessDetails = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/processes/${processId.value}`)
    process.value = cloneDeep(data)
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

    store.commit(AppMutations.SET_LOADING, false)
  }
}


const toggleSelectAllPositions = () => {
  vueInstance.$nextTick(() => {
    if (selectAll.value) {
      process.value.denyListPositions = []
      process.value.positionsChanged = true
    } else {
      process.value.denyListPositions = cloneDeep(owningPositions.value)
      process.value.positionsChanged = true
    }
  })
}
const saveDeniedPositions = async() => {
  store.commit(AppMutations.SET_LOADING, true);
  try {
    const {status} = await putRequest(`/processes/saveDenyListPositions`, process.value)
    snackbar('SUCCESS', 'Denied Positions Saved')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Field')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveRowChanges = async (rows) => {
  if(rows?.length > 0) {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {status} = await putRequest(`/processes/${processId.value}/processStepProcesses`, rows)
      snackbar('SUCCESS', 'Order Updated')

      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Order Changes')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}
const saveProcessStepProcess = async (item) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    item.companyProcessStepStatusTypeId = item.initialStep ? item.companyProcessStepStatusTypeId : null
    const {data, status} = await putRequest(`/processes/${processId.value}/processStepProcess`, item)
    item.initialStep = data.initialStep
    item.companyProcessStepStatusTypeId = data.companyProcessStepStatusTypeId
    item.processStepStatusType = data.processStepStatusType
    expanded.value = []
    snackbar('SUCCESS', 'Process Saved')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Process')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveProcess = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    editName.value = false
    const {status} = await putRequest(`/processes`, process.value)
    snackbar('SUCCESS', 'Process Updated')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Updating Process')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const deleteStepFromProcess = async () => {
  const id = processStepToDelete.value.id
  // reset the addNew field in case they delete one while it is open
  store.commit(AppMutations.SET_LOADING, true)
  try {
    addNew.value = false
    const {status} = await deleteRequest(`/processes/processStepProcess/${id}`)
    process.value.processStepProcesses = process.value.processStepProcesses.filter(psp => {
      return psp.id !== id
    })
    snackbar('SUCCESS', 'Step Deleted from Process')

    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Step From Process')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getPositions = async() => {
  try {
    const {data, status} = await getRequest(`/position/withParent`)
    owningPositions.value = data
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Positions')

    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getAvailableProcessSteps = async () => {
  try {
    //reset field in case they hit cancel
    newProcessStep.value = {}
    addNew.value = !addNew.value
    if(addNew.value) {
      store.commit(AppMutations.SET_LOADING, true)
      const {data, status} = await getRequest(`/processes/${processId.value}/availableProcessSteps`)
      availableProcessSteps.value = data
      handleHidingGlobalLoader(vueInstance, status)
    }
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const assignProcessStep = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await postRequest(`/processes/${processId.value}/processStep`, newProcessStep.value)
    process.value.processStepProcesses.push(data)
    process.value.processStepProcesses = orderBy(process.value.processStepProcesses, 'processStepName')

    addNew.value = false
    newProcessStep.value = {}
    snackbar('SUCCESS', 'Process Step Assigned')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Assigning Process Step')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getActiveProcessAssignedToProcessStep = async (item) => {
  if(item.initialStep) {
    processStepStatusTypes.value = []
    statusesLoading.value = true
    try {
      const {data} = await getActiveAssignedToProcessStep(item.processStepId)
      processStepStatusTypes.value = data
      statusesLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Data')
      statusesLoading.value = false
    }
  }
}

</script>

<style scoped lang="scss">
.handle {
  cursor: move !important;
}

.v-data-table ::v-deep .v-data-table__wrapper {
  max-height: calc(100vh - 350px);
}

.limit-positions-label.theme--light.v-label {
  color: purple !important;
}

</style>
<style lang="scss">
@media (max-width: 770px) {
  #process-step-table {
    padding-bottom: 12px;
    div.v-data-footer {
      display: inline-block;
      width: 100%;
      padding-bottom: 12px;

      div.v-data-footer__select {
        justify-content: center;
      }

      div.v-data-footer__pagination {

      }

      div.v-data-footer__icons-before {
        display: inline;
        margin-left: calc(50% - 36px);


      }

      div.v-data-footer__icons-after {
        display: inline;
      }

    }
  }
}
</style>

