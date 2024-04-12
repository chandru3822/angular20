<template>
  <v-container>
    <!--    modal for leaving with unsaved fields -->
    <confirmation-dialog :open-dialog="unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Access Control
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn
                variant="text"
                @click="saveUserAccess"
                color="primary"
                v-if="userStore.userHasFeatureAccessLevel('USERS', 'EDIT')"
                prepend-icon="save"
                text="Save"
            ></a-btn>
          </v-toolbar-items>
        </v-toolbar>
        <AccessControl v-if="userAccessLoaded"
                       :key="accessControlKey"
                       :show-secondary="true"
                       :user-can-edit="userCanEdit"
                       :companyFeatures="userCompanyFeatures || []" :callback="companyFeatureCallback"
                       :dirtyFieldsCallback="setFieldsDirty"></AccessControl>
      </v-col>
    </v-row>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Org Calendar Access
          <v-spacer></v-spacer>
          <v-toolbar-items>
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card text-left pa-5 elevation-1">
          <SpinnerInline v-if="calendarAccessLoading" :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          <div v-else>
            <a-autocomplete v-model="userOrgCalendars"
                            v-if="!userHasFullAccess"
                            :items="orgCalendars"
                            label="Selected Org Calendar(s)"
                            item-title="orgName"
                            item-value="orgId"
                            return-object
                            multiple
                            clearable
                            autocomplete="off"
                            attach>
              <template
                  slot="selection"
                  slot-scope="{ item, index }"
              >
                <v-chip small v-if="index < 21 && userOrgCalendars.length < 21"
                        close @click:close="userOrgCalendars.splice(index, 1)">
                  <span>{{ item.orgName }}</span>
                </v-chip>
                <span v-else-if="index === 20"
                      class="primary--text text-caption">
                  {{ userOrgCalendars.length }} calendars selected
                </span>
              </template>
            </a-autocomplete>
            <v-checkbox
                class="pt-2 mb-4"
                v-model="userHasFullAccess"
                label="Grant User Access to All Calendars"
                @change="userOrgCalendars = []"
            />
            <a-btn
                variant="text"
                color="primary"
                @click="[addCalendar = !addCalendar]"
                text="Cancel"
            ></a-btn>
            <a-btn
                color="primary"
                @click="[addCalendar = !addCalendar, saveUserOrgCalendars()]"
                text="Save"
            ></a-btn>
          </div>
        </v-card>
        <v-data-table
            v-if="false"
            :headers="headers"
            :items="filterUserOrgAccess()"
            :fixed-header="true"
            :items-per-page="-1"
            hide-default-footer
            disable-sort
            class="elevation-1 mt-1"
        >
          <template #no-data>
            <span class="default-text-color">No available calendars</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available calendars</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': index % 2 }">
              <td class="text-left">{{ item.orgName }}</td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
    <!--    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteOrgCalendarFromUser(itemToDelete)" @close-dialog="closeDeleteDialog">-->
    <!--      Are you sure you want to delete <strong>{{itemToDeleteOrgName}}</strong> from this user?-->
    <!--    </ConfirmationDialog>-->
  </v-container>
</template>

<script setup>


import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  deleteRequest,
  putRequest,
  postRequest,

  getRequestWithParams
} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import SpinnerInline from '@/components/SpinnerInline'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter, onBeforeRouteLeave} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const addCalendar = ref(false)
const userId = ref(route.params.id)
const features = ref([])
const orgCalendars = ref([])
const userOrgCalendars = ref([])
const calendarAccessLoading = ref(true)
const userHasFullAccess = ref(false)
const userAccessLoaded = ref(false)
const userCompanyFeatures = ref([])
const headers = ref([
  { text: 'Calendar', value: 'calendar', show: true },
  { text: '', value: 'icons', show: true },
])
const accessControlKey = ref(0)
const showDeleteDialog = ref(false)
const itemToDelete = ref(null)
const navigationOverride = ref(false)
const toPath = ref(null)
const dirtyFields = ref(false)
const unsavedFieldsModal = ref(false)

const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ACCESS_CONTROL', 'EDIT')
})

onMounted(() => {
  getUserCompanyFeatures()
  getUserOrgAccessLevel()
  getAllOrgCalendars()
})

onBeforeRouteLeave(async (to, from, next) => {
  // called when the route that renders this component is about to
  // be navigated away from.
  // has access to `this` component instance.
  if (navigationOverride.value || !dirtyFields.value) {
    //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
    next()
  } else {
    toPath.value = to.path
    unsavedFieldsModal.value = true
  }
})

const getUserCompanyFeatures = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/feature/user/${userId.value}`)
    userCompanyFeatures.value = data.filter(d => !d.hidden)
    userAccessLoaded.value = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving User Access Details')

    appStore.loading = false
  }
}
const getUserOrgAccessLevel = async() => {
  try {
    const {data, status} = await getRequest(`/org/user/${userId.value}/calendar/access`)
    userHasFullAccess.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Access Level')

  }
}
const getAllOrgCalendars = async() => {
  try {
    const {data, status} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
      params: {
        isSchedulingTool: true
      }
    })
    orgCalendars.value = data
    orgCalendars.value.forEach(o => {
      o.orgId = o.id
    })
    await getUserOrgCalendars()
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Calendars')
  }
}
const getUserOrgCalendars = async() => {
  try {
    const {data, status} = await getRequest(`/org/user/${userId.value}/calendars`)
    userOrgCalendars.value = data
    calendarAccessLoading.value = false
    //
    // userOrgCalendars.value.forEach((uoc, idx) => {
    //   userOrgCalendars.value[idx] = orgCalendars.value.find(oc => oc.id === uoc.orgId)
    // })

  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Calendars')

  }
}
const saveUserOrgCalendars = async() => {
  appStore.loading = true
  try {
    let params = {
      userId: userId.value,
      userOrgAccess: userOrgCalendars.value || [],
      fullCalendarAccess: userHasFullAccess.value
    }
    const {data, status} = await postRequest(`/org/user/calendar`, params)
    // userOrgCalendars.value.push(data)
    //todo: update the save here
    addCalendar.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Org Calendar to User')

    appStore.loading = false
  }
}
const deleteOrgCalendarFromUser = async(item) => {
  appStore.loading = true
  try {
    const {status} = await deleteRequest(`/org/user/calendar/${item.id}`)
    item.archived = true
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Deleting Org Calendar from User')

    appStore.loading = false
  }
  closeDeleteDialog()
}
const saveUserAccess = async() => {
  appStore.loading = true
  try {
    //we do this temp so that we only send up the values that need to be saved
    let tempCompanyFeatures = userCompanyFeatures.value?.filter(cf => cf.dirty)
    const {data, status} = await putRequest(`/feature/user/${userId.value}`, tempCompanyFeatures)
    userCompanyFeatures.value = data.filter(d => !d.hidden)
    accessControlKey.value++
    handleHidingGlobalLoader( status)
    dirtyFields.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving User Access Details')

    appStore.loading = false
  }

}
const companyFeatureCallback =  (newValue) => {
  userCompanyFeatures.value = newValue
}
const filterUserOrgAccess =  () => {
  return userOrgCalendars.value.filter(uoc => { return !uoc.archived})
}
const closeDeleteDialog = () => {
  showDeleteDialog.value = false
  itemToDelete.value = null
}
const setFieldsDirty = () => {
  dirtyFields.value = true;
}
const goToPath = (path, targetBlank) => {
  if (targetBlank) {
    let routerData = router.resolve({path})
    window.open(routerData.href, '_blank')
  } else {
    router.push(path)
  }
}
</script>
