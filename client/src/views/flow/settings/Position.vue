<template>
  <v-container id="positions-container">
    <!--    modal for leaving with unsaved fields -->
    <confirmation-dialog :open-dialog="unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>

    <v-row class="fill-height" align="center" justify="start">
      <v-col class="shrink" cols="12">
        <v-toolbar color="white" class="elevation-1">
          <v-toolbar-title class="app-title">
            <span v-if="positionId">Update Position</span>
            <span v-else>New Position</span>
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              :disabled="!position.position || (!position.orgTypeId && !clonePositionId)"
              @click="savePosition"
              color="primary"
              v-if="userCanEdit || userCanEditAccessControl"
              prepend-icon="save"
              text="SAVE"
            />
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="router.push('/settings/positions')"
              prepend-icon="close"
              text="CLOSE"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <v-text-field v-model="position.position"
                        placeholder="Enter a value"
                        required
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @input="setFieldsDirty"
                        label="Position Name">
          </v-text-field>
          <v-autocomplete
            v-if="!positionId"
            v-model="clonePositionId"
            :items="positions"
            label="Position to Clone (optional)"
            item-text="position"
            item-value="id"
          ></v-autocomplete>
          <div v-show="!clonePositionId">
            <v-autocomplete
                v-model="position.orgTypeId"
                :items="orgTypes"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Organization Type"
                item-text="orgType"
                item-value="id"
                @change="setFieldsDirty"
            ></v-autocomplete>
            <div class="mb-3">
              <label>Enable 2-way SMS:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.smsEnabled" @change="setFieldsDirty">
            </div>
            <div class="mb-3">
              <label>Show in Scheduling Tool:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.schedulable" @change="setFieldsDirty">
  <!--            removing from UI for now since we dont know how to handle the schedule data if they change this manually -->
  <!--            <div class="ml-5" v-if="position.schedulable">-->
  <!--              <label>Use Slot Schedules:</label>-->
  <!--              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.useSlotSchedule">-->
  <!--            </div>-->
            </div>
            <div class="mb-3">
              <label>Can Schedule Round Robins:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.scheduler" @change="setFieldsDirty">
            </div>
            <div class="mb-3">
              <label>Can Own Contacts:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.contactOwner" @change="setFieldsDirty">
            </div>
            <div class="mb-3">
              <label>Can Own Projects:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.projectOwner" @change="setFieldsDirty">
            </div>
            <div class="mb-3">
              <label>Can Own SMS Tickets:</label>
              <input type="checkbox" :disabled="!userCanEdit" class="ml-3" v-model="position.smsOwner" @change="setFieldsDirty">
            </div>
            <div v-if="userStore.isParent">
              <label>Make Available in Children</label>
              <input type="checkbox" class="ml-3" v-model="position.availableToChildren" @change="setFieldsDirty">
            </div>
          </div>
          <div v-show="!positionId && clonePositionId">
            <div class="mb-3">
              <label>Clone access control permissions:</label>
              <input type="checkbox" class="ml-3" v-model="position.cloneAccess">
            </div>
            <div class="mb-3">
              <label>Clone process step ownership:</label>
              <input type="checkbox" class="ml-3" v-model="position.cloneOwnership">
            </div>
            <div class="mb-3">
              <label>Clone system-list dropdown fields:</label>
              <input type="checkbox" class="ml-3" v-model="position.cloneSystemList">
            </div>
            <div class="mb-3">
              <label>Clone position white list:</label>
              <input type="checkbox" class="ml-3" v-model="position.cloneWhitelist">
            </div>
          </div>
          <div v-show="positionId && (!clonePositionId || (clonePositionId && !position.cloneAccess))">
            <v-divider class="my-2"></v-divider>
            <h3>Access Control</h3>
            <AccessControl v-if="positionLoaded"
                           :key="accessControlKey"
                           :user-can-edit="userCanEditAccessControl"
                           :companyFeatures="getCompanyFeatures()" :callback="companyFeatureCallback"
                           :dirtyFieldsCallback="setFieldsDirty"></AccessControl>
          </div>
        </v-card>

      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
  import {AppMutations} from '@/stores/AppStore'
  import {getOrgTypes} from '@/services/orgService'
  import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
  import {handleHidingGlobalLoader, getRequest, putRequest, postRequest} from '@/helpers/helpers'
  import AlbatrossButton from '@/components/customVuetify/AlbatrossButton.vue'
  import {getCurrentInstance, onMounted, ref, computed, watch} from 'vue'
  import {onBeforeRouteLeave} from 'vue-router/composables'
  import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
  import { useUserStore } from '@/stores/UserStorePinia.js'
  import {useRouter, useRoute} from "vue-router/composables"

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()
  const route = useRoute()
  const router = useRouter()
  const position = ref({
    companyFeatures: []
  })
  const positions = ref([])
  const selectedRows = ref([])
  const positionLoaded = ref(false)
  const userCanEdit = ref(userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT'))
  const userCanEditAccessControl = ref(userStore.userHasFeatureAccessLevel('ACCESS_CONTROL', 'EDIT'))
  const orgTypes = ref([])
  const clonePositionId = ref('')
  const features = ref([])
  const accessControlList = ref([])
  const accessControlKey = ref(0)
  const unsavedFieldsModal = ref(false)
  const navigationOverride = ref(false)
  const toPath = ref(null)
  const dirtyFields = ref(false)
  const headers = ref([
    { text: 'Feature', value: 'featureName', show: true },
  ])

  const positionId = computed(() => {
    return route.params.id
  })

  watch(selectedRows, () => {
    alterEnabledFlagForRows()
  })

  onMounted (() => {
    if(positionId.value) {
      getPosition()
    } else {
      positionLoaded.value = true
      getPositions()
    }
    getAllOrgTypes()
  })
  onBeforeRouteLeave(async (to, from, next) => {
    // called when the route that renders this component is about to
    // be navigated away from.
    if (navigationOverride.value || !dirtyFields.value) {
      //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
      next()
    } else {
      toPath.value = to.path
      unsavedFieldsModal.value = true
    }
  })

  const getCompanyFeatures = () => {
      return position.value?.companyFeatures?.filter(cf => !cf.hidden) || []
  }
  const getAllOrgTypes = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getOrgTypes()
      orgTypes.value = data
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Org Types')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const savePosition = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      if(positionId.value) {
        //we do this temp so that we only send up the values that need to be saved
        let tempCompanyFeatures = position.value?.companyFeatures?.filter(cf => cf.dirty)
        position.value.companyFeatures = tempCompanyFeatures
        //removing for now since we dont know how to handle the data if we allow them to change this in the UI
        //if the position isn't schedulable, dont allow them to save a true value for useSlotSchedule
        // this.position.useSlotSchedule = this.position.schedulable ? this.position.useSlotSchedule : false
        const {data, status} = await putRequest(`/position`, position.value)
        position.value = data
        accessControlKey.value++
        handleHidingGlobalLoader(vueInstance, status)
        dirtyFields.value = false
      } else {
        if (clonePositionId.value) {
          const {data, status} = await postRequest('/position/clone/' + clonePositionId.value, position.value)
          clonePositionId.value = ''
          position.value = data
          accessControlKey.value++
          dirtyFields.value = false
          await router.push(`/settings/position/${data.id}`)
          handleHidingGlobalLoader(vueInstance, status)
          // window.location.reload()
        }
        else {
          const {data, status} = await postRequest(`/position`, position.value)
          position.value = data
          accessControlKey.value++
          dirtyFields.value = false
          await router.push(`/settings/position/${data.id}`)
          handleHidingGlobalLoader(vueInstance, status)
        }
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Position')
      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getPosition = async () => {
    store.commit(AppMutations.SET_LOADING, true)
    try {
      const {data, status} = await getRequest(`/position/${positionId.value}`)
      position.value = data
      positionLoaded.value = true
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Position')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const getPositions = async () => {
    try {
      const {data, status} = await getRequest(`/position`)
      positions.value = data
      // dataLoading.value = false
      handleHidingGlobalLoader(vueInstance, status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Positions')

      store.commit(AppMutations.SET_LOADING, false)
    }
  }
  const companyFeatureCallback = (newValue) => {
    position.value.companyFeatures = newValue
  }
  const setFieldsDirty = () => {
    dirtyFields.value = true;
  }

  const goToPath = (path, targetBlank) =>{
    if (targetBlank) {
      let routerData = route.resolve({path})
      window.open(routerData.href, '_blank')
    } else {
      router.push(path)
    }
  }
</script>

<style lang="scss">
  #positions-container .v-data-table__wrapper {
    height: calc(100vh - 400px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>
  #positions-container {
    margin-top: -15px;
    padding-left: 0;
    padding-right: 0;
    padding-top: 0;
  }

  .positions-table {
    margin-top: 2px;
  }

</style>

