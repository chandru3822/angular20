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
            <a-btn
              variant="text"
              :disabled="!position.position || (!position.orgTypeId && !clonePositionId)"
              @click="savePosition"
              color="primary"
              v-if="userCanEdit || userCanEditAccessControl"
              prepend-icon="save"
              hide-text-on-mobile
              text="Save"
            />
            <a-btn
              variant="text"
              color="primary"
              @click="router.push('/settings/positions')"
              prepend-icon="close"
              hide-text-on-mobile
              text="Close"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mt-2 pa-5">
          <a-text-field v-model="position.position"
                        placeholder="Enter a value"
                        required
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        @input="setFieldsDirty"
                        label="Position Name">
          </a-text-field>
          <a-autocomplete
            v-if="!positionId"
            v-model="clonePositionId"
            :items="positions"
            label="Position to Clone (optional)"
            item-title="position"
            item-value="id"
          ></a-autocomplete>
          <div v-show="!clonePositionId">
            <a-autocomplete
                v-model="position.orgTypeId"
                :items="orgTypes"
                :readonly="!userCanEdit"
                :disabled="!userCanEdit"
                label="Organization Type"
                item-title="orgType"
                item-value="id"
                @change="setFieldsDirty"
            ></a-autocomplete>
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
            <v-expansion-panels   v-model="panel" multiple>
              <v-expansion-panel>
                <v-expansion-panel-header>
                  <h3>Access Control</h3>
                </v-expansion-panel-header>
                <v-expansion-panel-content>
                  <AccessControl v-if="positionLoaded" 
                  :key="accessControlKey"
                  :user-can-edit="userCanEditAccessControl"
                  :companyFeatures="getCompanyFeatures()" :callback="companyFeatureCallback"
                  :dirtyFieldsCallback="setFieldsDirty"></AccessControl>
                </v-expansion-panel-content>
              </v-expansion-panel>

               <v-expansion-panel  v-if="!userStore.userHasFeatureAccessLevel('USERS', 'ADMIN')" 
                 :style="{
                 display: 'inline-block',
                 cursor: 'pointer',
                  backgroundColor: !userStore.userHasFeatureAccessLevel('USERS', 'ADMIN') ? '#eeeeee' : ''
                }">
                <v-expansion-panel-header >
                 <v-tooltip bottom>
                  <template v-slot:activator="{ on, attrs }">
                  <span class="activeUser_font_size"
                  v-bind="attrs"
                    v-on="on"
                  >Active Users</span>
                </template>
                    <span>Insufficient permission to view user profile</span>
                </v-tooltip>
                </v-expansion-panel-header>
               </v-expansion-panel>
               
              <v-expansion-panel v-else >
                <v-expansion-panel-header>
                  
                  <h3>Active Users</h3>
                </v-expansion-panel-header>
                <v-expansion-panel-content>
                  <v-card class="square-card">
                    <v-card-title class="pt-0">
                      <a-text-field v-model="search" @input="debounceGetActiveUsers" prepend-inner-icon="search"
                        label="Search" single-line clearable hide-details></a-text-field>
                    </v-card-title>
                    <v-data-table  id="custom-fields-table" :headers="headersUsers" :items="filterActiveUsersFields"
                      :fixed-header="true" :server-items-length="totalActiveUsers" :loading="dataLoading"
                      :options.sync="options" :footer-props="footerProps"
                      class="elevation-1 mt-1 square-card table-striped">
                      <div style="height: 72vh;"></div>
                      <template #no-data>
                        <span class="default-text-color">No active users currently assigned this Position.</span>
                      </template>
                      <template #no-results>
                        <span class="default-text-color">No available fields</span>
                      </template>
                      <template #item="{ item, index }" >
                        <tr>
                          <td class="text-left clickable field-name-col">
                            <router-link class="router-link-td elevation-0 square-card"
                              :to="`/user/${item.id}/details`">

                              {{ item.firstName }}
                            </router-link>
                          </td>
                          <td class="text-left clickable field-name-col">
                            <router-link class="router-link-td elevation-0 square-card"
                              :to="`/user/${item.id}/details`">

                              {{ item.lastName }}
                            </router-link>
                          </td>
                          <td class="text-left clickable field-name-col">
                            <router-link class="router-link-td elevation-0 square-card"
                              :to="`/user/${item.id}/details`">

                              {{ item.email }}
                            </router-link>
                          </td>
                          <td>
                            {{ item.isPrimary }}
                          </td>
                        </tr>
                      </template>
                    </v-data-table>
                  </v-card>
                </v-expansion-panel-content>
              </v-expansion-panel>
            </v-expansion-panels>
          </div>
        </v-card>

      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>
  import {getOrgTypes} from '@/services/orgService'
  import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
  import {handleHidingGlobalLoader, getRequest, putRequest, postRequest,  getRequestWithParams} from '@/helpers/helpers'
  import {getCurrentInstance, onMounted, ref, computed, watch} from 'vue'
  import {onBeforeRouteLeave} from 'vue-router/composables'
  import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
  import { useUserStore } from '@/stores/UserStore.js'
  import {useRouter, useRoute} from "vue-router/composables"
  import { useAppStore } from '@/stores/AppStore.js'
  import debounce from 'lodash.debounce'
  import constants from '@/helpers/constants'


  const appStore = useAppStore()
  const vueInstance = getCurrentInstance().proxy

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

  const userCanEditAccessControl = computed(() => {
    return userStore.userHasFeatureAccessLevel('ACCESS_CONTROL', 'EDIT')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('SETTINGS', 'EDIT')
  })

  const positionId = computed(() => {
    return route.params.id
  })
  const search = ref("")
  const filterActiveUsersFields = ref([])
  const headersUsers = ref([
    { text: "First Name", value: "firstName", sortable: false },
    { text: "Last Name", value: "lastName", sortable: false },
    { text: "User ID", value: "email", sortable: false },
    { text: "Primary Position", value: "isPrimary", sortable: false },
  ])
  const footerProps = ref({
    'items-per-page-options': [10, 25, 50],
    'items-per-page-text': constants.IS_MOBILE ? '' : 'Rows per page:',
  })
  const options = ref({ itemsPerPage: 10 })
  const initialLoad = ref(true)
  const totalActiveUsers = ref(0)
  const dataLoading = ref(true)
const panel = ref([0]) // open first panel only


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
    if(userStore.userHasFeatureAccessLevel('USERS', 'ADMIN'))
    {
    getActiveUser()
    }

  })
  onBeforeRouteLeave(async (to, from, next) => {
    // called when the route that renders this component is about to
    // be navigated away from.
    if (to.path === '/login' || navigationOverride.value || !dirtyFields.value) {
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
    appStore.loading = true
    try {
      const {data, status} = await getOrgTypes()
      orgTypes.value = data
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Org Types')

      appStore.loading = false
    }
  }
  const savePosition = async () => {
    appStore.loading = true
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
        handleHidingGlobalLoader(status)
        dirtyFields.value = false
      } else {
        if (clonePositionId.value) {
          const {data, status} = await postRequest('/position/clone/' + clonePositionId.value, position.value)
          clonePositionId.value = ''
          position.value = data
          accessControlKey.value++
          dirtyFields.value = false
          await router.push(`/settings/position/${data.id}`)
          handleHidingGlobalLoader(status)
          // window.location.reload()
        }
        else {
          const {data, status} = await postRequest(`/position`, position.value)
          position.value = data
          accessControlKey.value++
          dirtyFields.value = false
          await router.push(`/settings/position/${data.id}`)
          handleHidingGlobalLoader(status)
        }
      }
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Saving Position')
      appStore.loading = false
    }
  }
  const getPosition = async () => {
    appStore.loading = true
    try {
      const {data, status} = await getRequest(`/position/${positionId.value}`)
      position.value = data
      positionLoaded.value = true
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Position')

      appStore.loading = false
    }
  }
  const getPositions = async () => {
    try {
      const {data, status} = await getRequest(`/position`)
      positions.value = data
      // dataLoading.value = false
      handleHidingGlobalLoader(status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      appStore.showSnack('ERROR', 'Error Retrieving Positions')

      appStore.loading = false
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

  const debounceGetActiveUsers = debounce(async () => {
  //don't allow search to be null - causes issues
  dataLoading.value = true
  search.value = search.value || ''
  localStorage.setItem('contactSearch', search.value)
  getActiveUser()
}, 500)


watch(
  () => options,
  (newValue, oldValue) => {
    if (!initialLoad.value) {
      getActiveUser();
    }
  },
  { deep: true }
)
const getActiveUser = async () => {
  try {
    const { page, itemsPerPage } = options.value
    const { data } = await getRequestWithParams(
      `/userPosition/search`,
      {
        params: {
          positionId: positionId.value,
          searchQuery: search.value,
          page: page - 1,
          size: itemsPerPage
        }
      },
      null,
      []
    );
 
    totalActiveUsers.value =  data.totalElements
    filterActiveUsersFields.value = data.content || []
    dataLoading.value = false
    initialLoad.value = false
  } catch (error) {
    console.error("Error fetching active users:", error);
  }
};
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
.activeUser_font_size{
  font-size: 1.17em;
  font-weight: bold;
}
</style>

