<template>
  <v-container class="custom-field-group-container">
    <v-card flat color="primary lighten-9" class="square-card">
      <v-card-text>
        <multi-select-group
            v-if="!objectTypeDetailsLoading"
            background-color="primary lighten-9"
            :userCanEdit="userCanEdit"
            :returnObject="projectObjectType"
            :content="positions"
            :dropdownEnabled="projectObjectType.statusReadOnly"
            :selectedContent="projectObjectType.statusReadOnlyWhiteListedPositions"
            :title="'Status Read Only'"
            :label="'Allowed Positions'"
            :alternateLabel="'Denied Positions'"
            user
            :allow="projectObjectType.statusReadOnlyAllow"
            :contentLoading="objectTypeDetailsLoading"
            @selected-changed="statusReadOnlySelectedEventListener"
            @allow-changed="statusReadOnlyAllowEventListener"
            @checkbox-changed="statusReadOnlyCheckboxEventListener"></multi-select-group>
        <br/>
        <v-btn v-if="userCanEdit" color="primary" dark class="d-inline-block white--text"
               @click="saveReadOnlyAndWhiteList()">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-card-text>
    </v-card>
    <v-card flat color="primary lighten-9" class="square-card mt-5">
      <v-card-text>
        <multi-select-group
            v-if="!objectTypeDetailsLoading"
            background-color="primary lighten-9"
            :userCanEdit="userCanEdit"
            :returnObject="projectObjectType"
            :content="positions"
            :dropdownEnabled="projectObjectType.ownerReadOnly"
            :selectedContent="projectObjectType.ownerReadOnlyWhiteListedPositions"
            :title="'Owner Read Only'"
            :label="'Allowed Positions'"
            :alternateLabel="'Denied Positions'"
            :allow="projectObjectType.ownerReadOnlyAllow"
            :contentLoading="objectTypeDetailsLoading"
            @selected-changed="ownerReadOnlySelectedEventListener"
            @allow-changed="ownerReadOnlyAllowEventListener"
            @checkbox-changed="ownerReadOnlyCheckboxEventListener"></multi-select-group>
        <br/>
        <v-btn v-if="userCanEdit" color="primary" dark class="d-inline-block white--text"
               @click="saveOwnerReadOnlyAndWhiteList()">
          <v-icon class="mr-2">save</v-icon>
          Save
        </v-btn>
      </v-card-text>
    </v-card>
  </v-container>
</template>


<script setup>
import {AppMutations} from '@/stores/AppStore'
import cloneDeep from 'lodash.clonedeep'
import {handleHidingGlobalLoader, getRequest, putRequest, getSnackbar} from '@/helpers/helpers'
import {getCurrentInstance, computed, ref, onMounted} from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'

const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const positions = ref([])
const projectObjectType = ref({})
const statusReadOnlyWhiteListedPositions = ref([])
const statusReadOnlyPositionsChanged = ref(false)
const ownerReadOnlyPositionsChanged = ref(false)
const ownerReadOnlyWhiteListedPositions = ref([])
const positionsLoading = ref(false)
const objectTypeDetailsLoading = ref(false)

const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})
const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})

onMounted(() => {
  getPositions()
  getObjectTypeDetails()
})

const selectAll = () => {
  return statusReadOnlyWhiteListedPositions.value?.length === value?.length
}
const selectSome = (f) => {
  return statusReadOnlyWhiteListedPositions.value?.length > 0 && !selectAll(f)
}
const icon = (f) => {
  if (selectAll(f)) {
    return 'check_box'
  }
  if (selectSome(f)) {
    return 'indeterminate_check_box'
  }
  return 'check_box_outline_blank'
}
const toggleSelectAllPositions = () => {
  vueInstance.$nextTick(() => {
    if (selectAll()) {
      statusReadOnlyWhiteListedPositions.value = []
    } else {
      statusReadOnlyWhiteListedPositions.value = cloneDeep(positions.value)
      statusReadOnlyPositionsChanged.value = true
    }
  })
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

const saveReadOnlyAndWhiteList = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/objectType/saveStatusReadOnlyAndWhiteList?savePositions=${statusReadOnlyPositionsChanged.value ?? false}`, projectObjectType.value)
    statusReadOnlyPositionsChanged.value = false
    if (!projectObjectType.value.statusReadOnly) {
      statusReadOnlyWhiteListedPositions.value = []
    }
    getSnackbar('SUCCESS', 'Saved Successfully')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const saveOwnerReadOnlyAndWhiteList = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    const {status} = await putRequest(`/objectType/saveOwnerReadOnlyAndWhiteList?savePositions=${ownerReadOnlyPositionsChanged.value ?? false}`, projectObjectType.value)
    ownerReadOnlyPositionsChanged.value = false
    if (!projectObjectType.value.ownerReadOnly) {
      ownerReadOnlyWhiteListedPositions.value = []
    }
    getSnackbar('SUCCESS', 'Saved Successfully')
    handleHidingGlobalLoader(vueInstance, status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const getObjectTypeDetails = async () => {
  store.commit(AppMutations.SET_LOADING, true)
  try {
    objectTypeDetailsLoading.value = true;
    const {data, status} = await getRequest(`/objectType/getByType/1`)
    projectObjectType.value = data
    handleHidingGlobalLoader(vueInstance, status)
    objectTypeDetailsLoading.value = false;
  } catch (e) {
    console.error('*** ERROR ***', e)
    getSnackbar('ERROR', 'Error Retrieving Details')
    store.commit(AppMutations.SET_LOADING, false)
  }
}
const statusReadOnlySelectedEventListener = (e) => {
  projectObjectType.value.statusReadOnlyWhiteListedPositions = e;
  statusReadOnlyPositionsChanged.value = true;
}
const statusReadOnlyAllowEventListener = (e) => {
  projectObjectType.value.statusReadOnlyAllow = (e === 0);
}
const statusReadOnlyCheckboxEventListener = (e) => {
  projectObjectType.value.statusReadOnly = e;
}
const ownerReadOnlySelectedEventListener = (e) => {
  projectObjectType.value.ownerReadOnlyWhiteListedPositions = e;
  ownerReadOnlyPositionsChanged.value = true;
}
const ownerReadOnlyAllowEventListener = (e) => {
  projectObjectType.value.ownerReadOnlyAllow = (e === 0);
}
const ownerReadOnlyCheckboxEventListener = (e) => {
  projectObjectType.value.ownerReadOnly = e;
}
</script>
