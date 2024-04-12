<template>
  <v-container id="postal-codes" class="custom-field-group-container">
    <v-row>
      <v-col cols="12">
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title class="title-large">{{ postalCode.postalCode }}</v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <a-btn variant="text"
                             @click="savePostalCode"
                             :disabled="!postalCode.placeName || !postalCode.stateId"
                             color="primary" v-if="userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')"
                             prepend-icon="save"
                             text="SAVE"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-container>
          <v-card class="square-card" elevation="0">
            <a-text-field
                v-model="postalCode.placeName"
                label="Place Name"
                :rules="requiredRules"
                hide-details
            ></a-text-field>
            <a-autocomplete
                :items="zones"
                item-value="id"
                item-title="zoneName"
                clearable
                hide-details
                class="mt-5"
                label="Postal Code Zone"
                v-model="postalCode.postalCodeZoneId"
            ></a-autocomplete>
            <a-autocomplete
                :items="states"
                item-value="id"
                item-title="state"
                clearable
                :rules="requiredRules"
                hide-details
                class="mt-5"
                label="State"
                v-model="postalCode.stateId"
            ></a-autocomplete>
            <a-autocomplete
                :items="roundRobins"
                item-value="id"
                item-title="roundRobinName"
                clearable
                hide-details
                class="mt-5"
                label="Round Robin"
                v-model="postalCode.roundRobinId"
            ></a-autocomplete>
            <a-autocomplete
                :items="callGroups"
                item-value="id"
                item-title="callGroupName"
                clearable
                class="mt-5"
                label="Call Group"
                v-model="postalCode.callGroupId"
            ></a-autocomplete>
            <v-checkbox label="Disqualified"
                        class="default-text-color"
                        v-model="postalCode.disqualified"/>
            <v-checkbox label="Self-Gen Only"
                        class="default-text-color"
                        v-model="postalCode.selfGen"/>
            <v-checkbox label="Inside Sales"
                        class="default-text-color"
                        v-model="postalCode.insideSales"/>
            <v-checkbox label="Sales Partners"
                        class="default-text-color"
                        v-model="postalCode.salesPartners"/>
            <a-textarea class="body-medium" hide-details
                        auto-grow
                        rows="4"
                        label="Notes"
                        variant="outlined"
                        v-model="postalCode.notes"/>
          </v-card>
        </v-container>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>

import {getStates} from '@/services/stateService'
import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import ConfirmationDialog from "@/components/ConfirmationDialog";
import constants from "@/helpers/constants";
import {useUserStore} from '@/stores/UserStore.js'

import {ref, onMounted, getCurrentInstance, computed, defineProps, onUpdated} from "vue";
import {useRouter, useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStore.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar
const route = useRoute()
const router = useRouter()
const vuetify = vueInstance.$vuetify
const userStore = useUserStore()

const dataLoading = ref(true)
const postalCode = ref({})
const zones = ref([])
const states = ref([])
const roundRobins = ref([])
const callGroups = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)

const postalCodeId = computed(() => {
  return route.params.id
})


const userCanEdit = computed(() => {
  return userStore.userHasFeatureAccessLevel('POSTAL_CODE', 'EDIT')
})
const companyId = computed(() => {
  return userStore.details.companyId
})
const userId = computed(() => {
  return userStore.details.id
})

onMounted(() => {
  appStore.loading = true
  dataLoading.value = true
  Promise.all([
    getPostalCode(),
    getRoundRobins(),
    getZones(),
    getAllStates(),
    getCallGroups()
  ]).then(() => {
    appStore.loading = false;
    dataLoading.value = false;
  })
})
const getPostalCode = async () => {
  try {
    const {data, status} = await getRequest(`/postalCode/${postalCodeId.value}`)
    postalCode.value = data
    dataLoading.value = false
  } catch (e) {
    console.error('*** ERROR ***', e)
    dataLoading.value = false
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getAllStates = async () => {
  try {
    const {data, status} = await getStates()
    states.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getRoundRobins = async () => {
  try {
    const {data, status} = await getRequest(`/roundRobin`)
    roundRobins.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getZones = async () => {
  try {
    const {data, status} = await getRequest(`/postalCode/zones`)
    zones.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const getCallGroups = async () => {
  try {
    const {data, status} = await getRequest(`/callGroup`, 'blueraven')
    callGroups.value = data
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')

  }
}
const savePostalCode = async () => {
  appStore.loading = true
  try {
    const {data, status} = await postRequest(`/postalCode`, postalCode.value)
    snackbar('SUCCESS', 'Postal Code Saved')

    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Saving Postal Code')
    appStore.loading = false
  }
}
</script>

<style lang="scss">
#postal-codes .v-data-table__wrapper {
  height: calc(100vh - 300px);
  min-height: 300px;
  border-top: solid 1px #E0E0E0;
}
</style>

