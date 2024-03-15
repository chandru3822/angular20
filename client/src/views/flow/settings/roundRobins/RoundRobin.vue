<template>
  <v-container class="px-0 py-2" id="postal-code-container">
    <v-breadcrumbs :items="breadcrumbs" class="pl-3 pt-1 pb-3"></v-breadcrumbs>
    <v-toolbar class="elevation-0">
      <v-toolbar-title class="pt-2">
        {{ roundRobin.roundRobinName }}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <a-btn
            icon
            color="primary"
            v-if="userCanEdit"
            :prepend-icon="editRoundRobin ? '' : 'edit'"
            :text="editRoundRobin ? 'Cancel' : ''"
            @click="editRoundRobin = !editRoundRobin"
            :size="$vuetify.breakpoint.smAndDown ? 'large' : 'default'"
        >
        </a-btn>

      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <div v-if="!editRoundRobin" class="px-4 py-2">
      <div class="dtf">
        Distribution Time Frame: {{ roundRobin.distributionTimeFrameDays }} days
      </div>
      <div class="dtf">
        Schedulable Future Days:
        <span v-if="roundRobin.schedulableFutureDays">{{ roundRobin.schedulableFutureDays }} days</span>
        <span v-else>N/A</span>
      </div>
      <div  class="dtf">
        Timezone: {{ roundRobin.timezone }}
      </div>
      <div class="dtf">
        Uses Total Lead Allocation: {{ roundRobin.usesTotalLeadAllocation ? 'Yes' : 'No'}}
      </div>
    </div>
    <div v-else>
      <v-row>
        <v-col cols="12" md="6" class="px-8">

          <a-text-field
                        type="text"
                        label="Name"
                        v-model="roundRobin.roundRobinName">
          </a-text-field>

          <div class="d-flex align-baseline">
            <a-text-field
                          style="max-width: 200px"
                          type="text"
                          label="Distribution Time Frame"
                          v-model="roundRobin.distributionTimeFrameDays">
            </a-text-field>
            <span class="body-medium">days</span>
          </div>
          <div class="d-flex align-baseline">
            <a-text-field
                          style="max-width: 200px"
                          type="text"
                          label="Schedulable Future Days"
                          v-model="roundRobin.schedulableFutureDays">
            </a-text-field>
            <span class="body-medium">days</span>
          </div>
          <v-autocomplete v-model="roundRobin.companyTimezoneId"
                          :items="companyTimezones"
                          label="Time Zone"
                          style="width: 200px;"
                          item-text="timezone"
                          item-value="id"
                          attach
          ></v-autocomplete>

          <div class="d-flex align-center mb-4">Uses Total Lead Allocation?
          <!--                <v-checkbox label="Uses Total Lead Allocation?" v-model="roundRobin.usesTotalLeadAllocation"></v-checkbox>-->
          <v-simple-checkbox class="pl-2" label="Uses Total Lead Allocation?" v-model="roundRobin.usesTotalLeadAllocation"></v-simple-checkbox>
          </div>

          <a-btn
              color="primary"
              :disabled="!roundRobin.roundRobinName || !roundRobin.companyTimezoneId"
              class=""
              @click="saveRoundRobinInfo()"
              text="Save"
          ></a-btn>

        </v-col>
      </v-row>
    </div>
    <v-divider></v-divider>
    <!--    <v-toolbar dense color="white" tabs flat class="elevation-1">-->
    <v-tabs :optional="false" color="primary" id="round-robin-tabs"
            slot="extension"
            class="hello"
            dense
            background-color="white" v-model="model" slider-color="primary">
      <v-tab v-for="(tab, index) in tabs" :key="index" :to="tab.path">
        {{ tab.label }}
      </v-tab>
    </v-tabs>
    <v-divider></v-divider>
    <!--    </v-toolbar>-->
    <router-view class="mt-1 pt-0 postal-code-view"/>

  </v-container>
</template>

<script setup>

import {handleHidingGlobalLoader, getRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import { getCurrentInstance, computed, ref, onMounted } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
const userStore = useUserStore()
import {useRoute} from "vue-router/composables";

import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const route = useRoute()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const roundRobinId = computed(() => {
  return route.params.id
})

      const model = ref( '')
      const editRoundRobin = ref( false)
      const companyTimezones = ref( [])
      const roundRobin = ref( {})
      const dataLoading = ref( true)
      const breadcrumbs = ref([
        {
          text: 'Back to Round Robins',
          disabled: false,
          exact: true,
          to: `/settings/roundRobins`
        },
      ])
      const tabs = ref([{
        label: 'Schedule To',
        path: `/settings/roundRobin/${roundRobinId.value}/scheduleTo`,
        display: true
      }, {
        label: 'Schedule By',
        path: `/settings/roundRobin/${roundRobinId.value}/scheduleBy`,
        display: true
      }, {
        label: 'Postal Codes',
        path: `/settings/roundRobin/${roundRobinId.value}/codes`,
        display: true
      }])



const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT')
})

onMounted(async () => {
  getCompanyTimezones()
  await getRoundRobinDetails()
})

    const saveRoundRobinInfo = async() => {
      appStore.loading = true
      try {
        const {status} = await postRequest(`/roundRobin`, roundRobin.value)
        editRoundRobin.value = false
        snackbar('SUCCESS', 'Round Robin Name Saved')
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Saving Round Robin Name')
        appStore.loading = false
      }
    }
    const getCompanyTimezones = async() => {
      appStore.loading = true
      try {
        const {data, status} = await getRequestWithParams(`/timezone`)
        companyTimezones.value = data
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Timezones')
        appStore.loading = false
      }
    }
    const getRoundRobinDetails = async() => {
      appStore.loading = true
      try {
        const {data, status} = await getRequest(`/roundRobin/${roundRobinId.value}`)
        roundRobin.value = data
        dataLoading.value = false
        handleHidingGlobalLoader(status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        snackbar('ERROR', 'Error Retrieving Data')
        appStore.loading = false
      }
    }
</script>

<style lang="scss" scoped>
.dtf {
  font-size: 14px;
}
.allocation-label {
  color: rgba(0, 0, 0, 0.6);
  font-size: 12px;
  width: 200px;
  display: flex;
}


</style>
<style lang="scss">
@media (max-width: 959px) {
  #round-robin-tabs > div > div.v-slide-group__wrapper > div {
    justify-content: center;
  }
  #round-robin-tabs > div > div.v-slide-group__prev.v-slide-group__prev--disabled {
    display: none;
  }
}
</style>

