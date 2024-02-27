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
          <v-autocomplete v-if="viewAll"
                    v-model="orgId"
                    :items="orgs"
                    label="Select an Organization..."
                    item-text="orgName"
                    item-value="id"
                    autocomplete="off"
                    @input="[userId = null, getApptLength()]"
                          attach>
          </v-autocomplete>
          <v-autocomplete v-model="userId"
                    :items="users"
                    v-if="showAllUsers"
                    :readonly="!viewAll"
                    :disabled="!viewAll"
                    label="Select a User..."
                    item-text="fullName"
                    item-value="id"
                    autocomplete="off"
                    @input="[orgId = null, getApptLength()]"
                          attach>
          </v-autocomplete>
          <v-text-field text
                        v-else
                        :disabled="true"
                        label="User"
                        v-model="currentUser">
          </v-text-field>
          <div class="mb-4" v-if="userId || orgId">
            <label>Default Appointment Length (minutes)</label>
            <v-text-field
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
            ></v-text-field>
            <AlbatrossButton class="d-inline-block"
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
  import {AppMutations} from '@/stores/AppStore'

  import { handleHidingGlobalLoader, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'

  import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
  import {getCurrentInstance, onMounted, ref, computed} from "vue";

  const vueInstance = getCurrentInstance().proxy
  const snackbar = vueInstance.$snackbar
  const store = vueInstance.$store

  const defaultAppointmentLength = ref(null)
  const valueChanged = ref(false)
  const orgs = ref([])
  const userCanEdit = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'))
  const orgId = ref(null)
  const orgsLoading = ref(false)
  const users = ref([])
  const userIsAdmin = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN'))
  const viewAll = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL'))
  const userId = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL') ? null : store.state.user.details.id)
  const showAllUsers = ref(store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL'))
  const currentUser = ref(store.state.user.details.fullName)
  // serId: 2410262
  const usersLoading = ref(false)
  const model = ref('')
  const tabs = ref([
    {
      label: 'Schedule',
      path: '/settings/availability/main/schedule',
      display: store.getters.userHasFeature('AVAILABILITY')
    },
    {
      label: 'Appointments',
      path: '/settings/availability/main/appointments',
      display: store.getters.userHasFeature('AVAILABILITY')
    }])
  const displayedTabs = computed(() => {
    return tabs.value.filter(tab => tab.display)
  })
  const resourceProps = computed(() =>{
    if (userId.value) {
      return { userId: userId.value, useSlotSchedule: useSlotSchedule.value() }}
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
      let user = showAllUsers.value ? users.value.find(u => u.id === userId.value) : store.state.user.details
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
    store.commit(AppMutations.SET_LOADING, true)
    usersLoading.value = true
    try {
      const {data, status} = await getRequestWithParams(`/user/getSchedulingUsers`, { params: {
        isSchedulingTool: false
      }})
      users.value = data
      handleHidingGlobalLoader(vueInstance, status)
      usersLoading.value = false
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Loading Users')
      store.commit(AppMutations.SET_LOADING, false)
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
      // store.commit(AppMutations.SET_LOADING, true)
      valueChanged.value = false
      try {
        const {data} = await getRequestWithParams(`/availability/appointments/length`, { params: {
            userId: userId.value,
            orgId: orgId.value,
          }})
        defaultAppointmentLength.value = data
        // store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        valueChanged.value = false
        defaultAppointmentLength.value = null
        // store.commit(AppMutations.SET_LOADING, false)
        snackbar('ERROR', 'Error Loading Default Appointment Length')

      }
    }
  }
</script>


