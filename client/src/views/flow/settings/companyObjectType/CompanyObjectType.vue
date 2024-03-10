<template>
  <v-container class="custom-field-group-container pa-6">
    <v-row>
      <v-col cols="12" class="shrink">
        <router-link :to="`/settings/companyObjectTypes`">Back</router-link>
        <v-toolbar flat class="app-toolbar">
          <v-toolbar-title v-if="!isMobile" class="title-large">
            {{ objectType.objectType }} - Custom Field Groups
          </v-toolbar-title>
          <v-spacer />
          <v-text-field v-if="addNew"
                        v-model="newGroup.groupName"
                        placeholder="Enter new group name"
                        append-outer-icon="save"
                        @click:append-outer="addCustomFieldGroup"
                        label="Custom Field Group" />
          <v-toolbar-items>
            <AlbatrossButton
              variant="text"
              color="primary"
              @click="[addNew = !addNew, newGroup = {}]"
              v-if="userCanAdd"
              :prepend-icon="isMobile && addNew ? 'close' : 'add'"
              :text="addNew ? 'CANCEL' : 'ADD NEW'"
            />
          </v-toolbar-items>
        </v-toolbar>
        <v-card flat class="mb-4 pt-3 px-3">
          Note: Some company specific screens ignore the display order and group name of Custom Fields Groups
          represented here.
        </v-card>
        <CompanyCustomFieldGroup v-if="customFieldGroups.length && objectType.id != null" :object-type="objectType" :custom-field-groups="customFieldGroups" @group-deleted="getCustomFieldGroups"/>
      </v-col>

    </v-row>
  </v-container>
</template>

<script setup>
import constants from '@/helpers/constants'
import CompanyCustomFieldGroup from './CompanyCustomFieldGroup'
import {AppMutations} from "@/stores/AppStore";
import {getRequest, getRequestWithParams, getSnackbar, handleHidingGlobalLoader, postRequest} from "@/helpers/helpers";
import cloneDeep from "lodash.clonedeep";

import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue";
import {getCurrentInstance, onMounted, ref, computed, watch} from "vue";
import { useUserStore } from '@/stores/UserStorePinia.js'
import {useRoute} from "vue-router/composables"
import { useAppStore } from '@/stores/AppStorePinia.js'
const appStore = useAppStore()

const vueInstance = getCurrentInstance().proxy
const snackbar = vueInstance.$snackbar
const vuetify = vueInstance.$vuetify
const store = vueInstance.$store
const userStore = useUserStore()
const route = useRoute()

const objectType = ref({})
const customFieldGroups = ref([])
const addNew = ref(false)
const newGroup = ref({
  groupName: null
})

const companyObjectTypeId = computed(() => {
  return route.params.id
})
const userCanAdd = computed(() => {
  return userStore.userHasFeatureAccessLevel('SETTINGS', 'ADD')
})

const isMobile = computed(() => {
  return vuetify.breakpoint.smAndDown
})
const getObjectType = async () => {
  //we have to get the object type details to determine if it can use ancillary fields
  appStore.loading = true
  try {
    const { data, status } = await getRequest(`/objectType/getByType/${route.params.id}`, 'blueraven')
    objectType.value = data
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
const getCustomFieldGroups = async () => {
  appStore.loading = true
  try {
    const { data, status } = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupsByObjectTypeId`, {
      params: {
        companyObjectTypeId: route.params.id
      }
    }, 'blueraven')
    customFieldGroups.value = cloneDeep(data?.map(d => {
      d?.customFields?.forEach(cf => cf.hasConditionalOnId = !!cf.conditionalOnId)
      return d
    }))
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Data')
    appStore.loading = false
  }
}
onMounted(() => {
  getObjectType()
  getCustomFieldGroups()
})

const addCustomFieldGroup = async () => {
  appStore.loading = true
  try {
    newGroup.value.objectTypeId = parseInt(route.params.id)
    const { data, status } = await postRequest(`/customFieldGroup/addCustomFieldGroup`, newGroup.value, 'blueraven')
    newGroup.value = {}
    addNew.value = false
    // add the new type to the list
    customFieldGroups.value.push(data)
    snackbar('SUCCESS', 'Group Added')
    handleHidingGlobalLoader(status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Custom Field Group')
    appStore.loading = false
  }
}

</script>
