<template>
  <v-container class="custom-field-group-container" v-if="processStep && processStep.id">
    <v-row>
      <v-col cols="12">
        <v-btn text color="primary" class="pl-1 pr-2" :to="'/settings/processSteps'">
          <v-icon>arrow_left</v-icon>
          <span>Back</span>
        </v-btn>
        <div class="flex-display pt-3 px-3 mb-4" style="width: 100%">
          <div style="width: 100%">
            <span class="headline-small" v-if="!editName">{{ processStep.processStepName }}</span>
            <v-text-field v-else color="primary"
                          :readonly="!userCanEdit"
                          :disabled="!userCanEdit"
                          v-model="processStep.processStepName"
                          label="Process Step Name"></v-text-field>

          </div>
          <div class="text-right" v-if="userCanEdit">
            <v-btn text color="primary" v-if="!editName" class=""
                   @click="[oldName = processStep.processStepName, editName = !editName]">
              <v-icon>edit</v-icon>
            </v-btn>
            <v-btn text color="primary" class="" v-else @click="saveProcessStep($event,true)">
              <v-icon>save</v-icon>
            </v-btn>
            <v-btn text color="primary" v-if="editName" class=""
                   @click="[processStep.processStepName = oldName, editName = !editName]">
              cancel
            </v-btn>
          </div>
        </div>
        <v-tabs class="tabs-bar">
          <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path"
                 class="text-capitalize ma-0"
                 :style="{'margin-left': index === 0 ? '12px !important' : '0'}">
            {{ tab.label }}
          </v-tab>
        </v-tabs>

        <router-view :non-admin-add="processStep.nonAdminAdd"/>
      </v-col>

    </v-row>
  </v-container>
  <v-container class="custom-field-group-container" v-else-if="!processStepLoading">
    Process Step Not Found
  </v-container>
</template>

<script setup>
import {AppMutations} from '@/stores/AppStore'
import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables";

const route = useRoute()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store

const processStepId = computed(() => {
  return route.params.id
})

const editName = ref(false)
const processStepLoading = ref(true)
const oldName = ref(null)
const processStep = ref({})
const positions = ref([])
const positionsLoading = ref(false)
const nonAdminAddWhiteListedPositionsChanged = ref(false)
const tabs = ref([
  {
    id: 1,
    label: 'UI Components',
    path: `/settings/processStep/${processStepId.value}/components`,
  },
  {
    id: 2,
    label: 'Custom Field Groups',
    path: `/settings/processStep/${processStepId.value}/customFieldGroups`,
  },
  {
    id: 3,
    label: 'Actions',
    path: `/settings/processStep/${processStepId.value}/actions`,
  },
  {
    id: 4,
    label: 'Events',
    path: `/settings/processStep/${processStepId.value}/events`,
  },
  {
    id: 5,
    label: 'Attachment Types',
    path: `/settings/processStep/${processStepId.value}/attachmentTypes`,
  }
])

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})

onMounted(() => {
  getProcessStepDetails()
  getPositions()
})

const getProcessStepDetails = async () => {
  processStepLoading.value = true
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {data, status} = await getRequest(`/processStep/${processStepId.value}`)
    processStep.value = data
    processStepLoading.value = false
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let msg = e?.data?.message || 'Error Retrieving Data'
    getSnackbar('ERROR', msg)
    store.commit(AppMutations.SET_LOADING, false)
    processStepLoading.value = false
  }
}
const saveProcessStep = async (closeEditor) => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/processStep?savePositions=${nonAdminAddWhiteListedPositionsChanged.value ?? false}`, processStep.value)
    editName.value = false
    getSnackbar('SUCCESS', 'Process Step Updated')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Updating Process Step')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getPositions = async () => {
  if (positions.value?.length === 0) {
    try {
      positionsLoading.value = true
      const {data, status} = await getRequest(`/position/withParent`)
      positions.value = data
      positionsLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      positionsLoading.value = false
      console.error('*** ERROR ***', e)
      getSnackbar('ERROR', 'Error Retrieving Positions')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
}

</script>

<style scoped lang="scss">
.non-admin-container {
  display: flex;
  flex-direction: row;
  max-width: 50%;
}

.name-container {
  background-color: var(--v-primary-lighten9) !important;
  border-radius: 5px;
}

.tabs-bar {
  top: -12px;
  border-top: 1px solid #E6E6E6;
  border-bottom: 1px solid #E6E6E6;

  .v-tab:hover {
    color: var(--v-primary-base);
  }
}
</style>
