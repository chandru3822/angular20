<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-toolbar flat dense>
          <v-toolbar-title>
            Availability
          </v-toolbar-title>
        </v-toolbar>
        <div class="px-4">
          <a-autocomplete v-if="viewAll"
                    v-model="orgId"
                    :items="orgs"
                    label="Select an Organization..."
                    item-title="orgName"
                    item-value="id"
                    autocomplete="off"
                    @input="[userId = null, getApptLength()]"
                          attach>
          </a-autocomplete>
          <a-autocomplete v-model="userId"
                    :items="users"
                    v-if="viewAll"
                    :readonly="!viewAll"
                    :disabled="!viewAll"
                    label="Select a User..."
                    item-title="fullName"
                    item-value="id"
                    autocomplete="off"
                    @input="[orgId = null, getApptLength()]"
                          attach>
          </a-autocomplete>
          <a-text-field
                        v-else
                        :disabled="true"
                        label="User"
                        v-model="currentUser">
          </a-text-field>
          <div class="mb-4" v-if="userId || orgId">
            <label>Default Appointment Length (minutes)</label>
            <a-text-field
              class="d-inline-block ml-3 shrink"
              style="width:100px;"
              type="number"
              filled
              dense
              hide-details
              :readonly="!userIsAdmin"
              :disabled="!userIsAdmin"
              placeholder="--"
              @input="valueChanged = true"
              v-model="defaultAppointmentLength"
            ></a-text-field>
            <a-btn class="d-inline-block"
                             v-if="userIsAdmin && valueChanged"
                             size="small"
                             variant="text"
                             @click="saveApptLength()"
                             prepend-icon="save"
            />
          </div>
        </div>
        <v-divider class="mb-2"></v-divider>
        <v-card class="mt-3 elevation-4" v-if="(userId || orgId) && !usersLoading">
          <v-app-bar dense tabs class="elevation-1">
            <v-tabs :optional="false" color="primary"
                    background-color="white" v-model="model" slider-color="primary">
              <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
                {{tab.label}}
              </v-tab>
            </v-tabs>
          </v-app-bar>
          <router-view v-bind="resourceProps"></router-view>
        </v-card>
      </v-col>
    </v-row>

  </v-container>
</template>

<script setup>

  import { handleHidingGlobalLoader, getRequestWithParams, postRequest} from '@/helpers/helpers'

  import {getCurrentInstance, onMounted, ref, computed} from 'vue'
  import { useUserStore } from '@/stores/UserStore.js'
  import { useAppStore } from '@/stores/AppStorePinia.js'
  const appStore = useAppStore()

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store
  const userStore = useUserStore()

  const defaultAppointmentLength = ref(null)
  //userId has to be a ref so that it can change
  const userId = ref(userStore.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL') ? null : userStore.details.id)
  const valueChanged = ref(false)
  const orgs = ref([])
  const orgId = ref(null)
  const orgsLoading = ref(false)
  const users = ref([])
  // serId: 2410262
  const usersLoading = ref(false)
  const model = ref('')
  const tabs = ref([
    {
      label: 'Schedule',
      path: '/settings/availability/main/schedule',
      display: userStore.userHasFeature('AVAILABILITY')
    },
    {
      label: 'Appointments',
      path: '/settings/availability/main/appointments',
      display: userStore.userHasFeature('AVAILABILITY')
    }])
  const displayedTabs = computed(() => {
    return tabs.value.filter(tab => tab.display)
  })
  const viewAll = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL')
  })
  const userIsAdmin = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN')
  })
  const userCanEdit = computed(() => {
    return userStore.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT')
  })
  const currentUser = computed(() => {
    return userStore.details.fullName
  })
  const resourceProps = computed(() =>{
    if (userId.value) {
      return { userId: userId.value, useSlotSchedule: useSlotSchedule() }}
    if (orgId.value) { return { orgId: orgId.value, useSlotSchedule: false }}
  })

  onMounted(() => {
      if (null !== userId.value) {
        getApptLength()
      } else {
        getOrgs()
        getUsers()
      }
    }
  )

  const useSlotSchedule = () => {
    if(userId.value) {
      let user = viewAll.value ? users.value.find(u => u.id === userId.value) : userStore.details
      let useSlots = false
      user?.userPositions?.forEach(up => {
        if(up.useSlotSchedule) {
          useSlots = true
        }
      })
      return useSlots
    }
    return false
  }
  const getOrgs = async () => {
    orgsLoading.value = true
    try {
      const {data} = await getRequestWithParams(`/org/getSchedulingOrgs`, { params: {
        isSchedulingTool: false
      }})
      orgs.value = data
      orgsLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Organizations')

    }
  }
  const getUsers = async () => {
    appStore.loading = true
    usersLoading.value = true
    try {
      const {data, status} = await getRequestWithParams(`/user/getSchedulingUsers`, { params: {
        isSchedulingTool: false
      }})
      users.value = data
      handleHidingGlobalLoader(status)
      usersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Users')
      appStore.loading = false
    }
  }
  const saveApptLength = async () => {
    try {
      let params = {
        userId: userId.value,
        orgId: orgId.value,
        defaultAppointmentLength: defaultAppointmentLength.value
      }
      await postRequest(`/availability/appointments/length`, params)
      snackbar('SUCCESS', 'Appointment Length Saved')

    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Saving Appointment Length')

    }
  }
  const getApptLength = async () => {
    if(orgId.value || userId.value) {
      // appStore.loading = true
      valueChanged.value = false
      try {
        const {data} = await getRequestWithParams(`/availability/appointments/length`, { params: {
            userId: userId.value,
            orgId: orgId.value,
          }})
        defaultAppointmentLength.value = data
        // appStore.loading = false
      } catch (e) {
        console.error('*** ERROR ***', e)
        valueChanged.value = false
        defaultAppointmentLength.value = null
        // appStore.loading = false
        snackbar('ERROR', 'Error Loading Default Appointment Length')

      }
    }
  }
</script>


