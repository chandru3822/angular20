<template>
  <v-container>
    <v-card class="pa-3 text-left" >
      <v-card-title>
        Add Organization
        <v-spacer></v-spacer>
        <a-btn
            variant="text"
            color="primary"
            class="mr-3"
            to="/orgs"
            text="Cancel"
        ></a-btn>
        <a-btn
            color="primary "
            :disabled="loadingInsertFields || (org.schedulable && !org.companyTimezoneId)"
            @click="validate"
            text="Save"
        ></a-btn>
      </v-card-title>

      <v-form ref="orgForm">
        <v-container>
          <v-row>
            <v-col cols="12">
              <v-text-field text
                            label="Organization Name"
                            :rules="requiredRules"
                            v-model="org.orgName"></v-text-field>
              <v-autocomplete v-model="selectedOrgType"
                              :items="orgTypes"
                              label="Organization Type"
                              :rules="requiredRules"
                              item-text="orgType"
                              item-value="id"
                              return-object
                              @input="getAllOrgsByType()"
                              attach
              ></v-autocomplete>
              <v-autocomplete v-model="org.parentOrgId"
                              :items="parents"
                              label="Parent Organization"
                              item-text="orgName"
                              item-value="id"
                              attach
              ></v-autocomplete>
              <v-autocomplete attach v-model="org.companyStateId"
                              :items="states"
                              label="State"
                              item-text="state"
                              item-value="id"
              ></v-autocomplete>
              <v-checkbox label="Show in Scheduling Tool" class="mb-n4" v-model="org.schedulable" @change="getCompanyTimezones(org.schedulable)"></v-checkbox>
              <div v-if="org.schedulable">
                <v-autocomplete v-model="org.companyTimezoneId"
                                :items="companyTimezones"
                                label="Timezone"
                                hide-details
                                item-text="timezone"
                                item-value="id"
                                attach
                                class="pt-0"
                ></v-autocomplete>
                <h6 class="mt-3 error-text" v-if="org.schedulable && !org.companyTimezoneId">* Required when Schedulable Organization</h6>
              </div>
              <v-checkbox class="mb-n4" v-if="userStore.isParent" label="Make available in children" v-model="org.availableToChildren"></v-checkbox>
            </v-col>
          </v-row>
        </v-container>
        <SpinnerInline v-if="loadingInsertFields" :text="'Checking For Additional Fields...'" :size="20" color="primary"/>
        <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
          <h3>{{cfg.groupName}}</h3>
          <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                            :key="idx"
                            :callback="populateDirtyCfvs"
                            :required="cf.required"
                            :readonly="getReadOnly(cf)"
                            :field="cf"></CustomValueInput>
        </v-container>
      </v-form>

    </v-card>

  </v-container>
</template>

<script setup>


import {handleHidingGlobalLoader, getRequest, putRequest,  getRequestWithParams} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getOrgTypes, getOrgsByType} from '@/services/orgService'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import SpinnerInline from '@/components/SpinnerInline'
import {getCompanyStates} from "@/services/stateService";

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStorePinia.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStorePinia.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store
const snackbar = vueInstance.$snackbar

const selectedOrgType = ref(null)
const org = ref({})
const orgTypes = ref([])
const loadingInsertFields = ref(true)
const orgForm = ref(null)
const parents = ref([])
const companyTimezones = ref([])
const states = ref([])
const dirtyCfvs = ref([])
const customFieldGroups = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)

onMounted(() => {
  getAllCompanyStates()
  getCustomFieldGroups()
  getAllOrgTypes()
})
const companyId = computed(() => {
  return userStore.details.companyId
})

const validate = () => {
  if (orgForm.value.validate()) {
    saveOrg()
  }
}
const getCompanyTimezones = async(schedulable) => {
  if(schedulable) {
    appStore.loading = true
    try {
      const {data, status} = await getRequestWithParams(`/timezone`)
      companyTimezones.value = data
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Timezones')

      appStore.loading = false
    }
  }
}
const getCustomFieldGroups = async () => {
  loadingInsertFields.value = true
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/customFieldGroup/getOrgInsertFields`)
    customFieldGroups.value = data
    loadingInsertFields.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    loadingInsertFields.value = false
    snackbar('ERROR', 'Error Retrieving Custom Fields')

    appStore.loading = false
  }
}
const saveOrg = async () => {
  org.value.orgTypeId = selectedOrgType.value?.id
  appStore.loading = true
  org.value.customFieldGroups = customFieldGroups.value
  try {
    const {data, status} = await putRequest(`/org`, org.value)
    router.push({name: 'org', params: {id: data.id}})
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Adding Org')

    appStore.loading = false
  }
}
const getAllOrgTypes = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgTypes()
    orgTypes.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Org Types')

    appStore.loading = false
  }
}
const getAllOrgsByType = async () => {
  // this gets the available parents
  if(selectedOrgType.value?.orgParentTypeId) {
    appStore.loading = true
    try {
      const {data, status} = await getOrgsByType(selectedOrgType.value?.orgParentTypeId)
      parents.value = data
      handleHidingGlobalLoader( status)
    } catch (e) {
      console.error('*** ERROR ***', e)
      snackbar('ERROR', 'Error Retrieving Parent Orgs')

      appStore.loading = false
    }
  } else {
    parents.value = []
  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if (!match) {
    dirtyCfvs.value.push(field)
  }
}
const getReadOnly = (field) => {
  return getCustomFieldReadOnly(field)
}
const getAllCompanyStates = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyStates()
    states.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving States')

    appStore.loading = false
  }
}

</script>

<style lang="scss" scoped>
.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}
</style>

