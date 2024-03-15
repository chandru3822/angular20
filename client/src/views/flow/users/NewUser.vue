<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add User
        <v-spacer></v-spacer>
        <AlbatrossButton
            variant="text"
            color="primary"
            class="mr-3"
            to="/users"
            text="Cancel"
        ></AlbatrossButton>
        <AlbatrossButton
            color="primary "
            @click="validate"
            :disabled="loadingUserInsertFields || (newPosition.positionId != null && newPosition.endDate && !newPosition.startDate) || ((newPosition.startDate != null || newPosition.endDate != null) && !newPosition.positionId)"
            text="Save"
        ></AlbatrossButton>
      </v-card-title>

      <v-form ref="userForm">
        <v-container>
          <v-row>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="First Name"
                            :rules="requiredRules"
                            v-model="user.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            :rules="requiredRules"
                            v-model="user.lastName"></v-text-field>
            </v-col>
            <v-col cols="12" sm="6">
              <v-select attach v-model="user.userStatusTypeId"
                        :items="userStatusTypes"
                        label="User Status"
                        :rules="requiredRules"
                        item-text="userStatusType"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Phone"
                            :rules="userPhoneRule"
                            v-model="user.phoneNumber"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :rules="emailRules"
                            v-model="user.email"></v-text-field>
            </v-col>
          </v-row>
        </v-container>
        <SpinnerInline v-if="loadingUserInsertFields" :text="'Checking For Additional Fields...'" :size="20" color="primary"/>
        <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
          <h3>{{cfg.groupName}}</h3>
          <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                            :key="idx"
                            :callback="populateDirtyCfvs"
                            :required="cf.required"
                            :readonly="getReadOnly(cf)"
                            :field="cf"></CustomValueInput>
        </v-container>

        <v-expansion-panels class="mt-4 mb-6" v-model="userPositionPanel">
          <v-expansion-panel>
            <v-expansion-panel-header :style="{'color': 'var(--v-primaryText-base)', 'font-size': '1.25rem'}">
              Add User Position
            </v-expansion-panel-header>
            <v-expansion-panel-content>
              <DatetimePickerInput
                  v-model="newPosition.startDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="Start Date"
                  :max-date="newPosition.endDate"
                  :required="newPosition.positionId !== null && newPosition.positionId !== undefined"
              />
              <DatetimePickerInput
                  v-model="newPosition.endDate"
                  :timezone="timezone"
                  :type="'date'"
                  :format="'MM/DD/YYYY'"
                  label="End Date"
                  :min-date="newPosition.startDate"
              />
              <v-autocomplete v-model="newPosition.positionId"
                              :items="positions"
                              :rules="requiredRules"
                              label="Position"
                              item-text="position"
                              item-value="id"
                              attach
                              @input="populateHierarchy(newPosition, true)"/>
              <div v-if="newPositionHierarchyPopulated">
                <div v-for="(f, index) in filters" :key="index">
                  <v-autocomplete
                      v-if="newPosition.keyedHierarchy && newPosition.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, newPosition)"
                      v-model="newPosition.keyedHierarchy[f.orgLevelId]['orgId']"
                      :items="getOrgsMatchingPositionOrgType(f.orgs, newPosition)"
                      :label="f.levelName"
                      :rules="requiredRules"
                      item-value="id"
                      item-text="orgName"
                      autocomplete="off"
                      type="search"
                      attach
                  >
                    <template slot="selection" slot-scope="{ item }">
                      {{ item.orgName }}{{ item.showType ? ' (' + item.orgType + ')' : '' }}
                    </template>
                    <template slot='item' slot-scope='{ item }'>
                      {{ item.orgName }}{{ item.showType ? ' (' + item.orgType + ')' : '' }}
                    </template>
                  </v-autocomplete>
                </div>
              </div>
              <AlbatrossButton
                  color="primary"
                  class="mr-2"
                  @click="[userPositionPanel = undefined, newPosition = {}]"
                  text="Clear"
              ></AlbatrossButton>
            </v-expansion-panel-content>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-form>

    </v-card>
  </v-container>
</template>

<script setup>

import SpinnerInline from '@/components/SpinnerInline'
import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import {getUserStatusTypes} from '@/services/userService'
import DatetimePickerInput from '@/components/DatetimePickerInput'
import keyBy from 'lodash.keyby'
import {getOrgFilters} from '@/services/orgService'
import AlbatrossButton from "@/components/customVuetify/AlbatrossButton.vue"
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

const user = ref({})
const states = ref([])
const countries = ref([])
const dirtyCfvs = ref([])
const loadingUserInsertFields = ref(true)
const customFieldGroups = ref([])
const userStatusTypes = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const emailRules = ref(constants.EMAIL_RULES)
const userPositionPanel = ref(0)
const positions = ref([])
const filters = ref([])
const newPositionHierarchyPopulated = ref(false)
const newPosition = ref({})
const userPhoneRule = ref([() => ((user.value.phoneNumber != null && user.value.phoneNumber !== '')) || "Field is required",v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",])
const userForm = ref(null)

onMounted(() => {
  //todo: use only for testing
  // if (VUE_APP_ENV === 'local') {
  //   setFakeUser()
  // }
  getAllUserStatusTypes()
  getAllCompanyStates()
  getAllCountries()
  getCustomFieldGroups()
  getFilters()
  getPositions()
})

const companyId = computed(() => {
  return userStore.details.companyId
})
const timezone = computed(() => {
  return userStore.timezone.value
})

const validate = () => {
  if (userForm.value.validate()) {
    saveUser()
  }
}
const getCustomFieldGroups = async() => {
  loadingUserInsertFields.value = true
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/customFieldGroup/getUserInsertFields`)
    customFieldGroups.value = data
    loadingUserInsertFields.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Custom Fields')
    loadingUserInsertFields.value = false

    appStore.loading = false
  }
}
const getAllUserStatusTypes = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getUserStatusTypes()
    userStatusTypes.value = data

    //set the user status to the default if there is one
    user.value.userStatusTypeId = userStatusTypes.value?.find(ust => ust.newUserDefault)?.id

    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving User Statuses')

    appStore.loading = false
  }
}
const getAllCompanyStates = async() => {
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
const getAllCountries = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getCountries()
    countries.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Countries')

    appStore.loading = false
  }
}
const getPositions = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getRequest(`/position`)
    positions.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error Retrieving Positions')

    appStore.loading = false
  }
}
const getFilters = async() => {
  appStore.loading = true
  try {
    const {data, status} = await getOrgFilters()
    filters.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error retrieving org levels')

    appStore.loading = false
  }
}
const populateHierarchy = (item, isNew) => {
  newPositionHierarchyPopulated.value = false
  let selectedPosition = positions.value.find(p => p.id === item.positionId)
  item.hierarchy = []

  // push a hierarchy item in for the selected level
  filters.value.forEach(f => {
    if (f.level === selectedPosition.level) {
      let obj = {
        level: f.level,
        orgLevelId: f.orgLevelId,
        positionLevel: null,
        orgName: null,
        orgId: null,
        parentOrgId: null
      }
      item.hierarchy.push(obj)
    }
  })

  item.keyedHierarchy = keyBy(item.hierarchy, 'orgLevelId')

  if (isNew) {
    newPositionHierarchyPopulated.value = true
  }
}
const isSameLevelAsPosition = (f, item) => {
  // get hierarchy level to show on screen
  let selectedPosition = positions.value.find(p => p.id === item.positionId)
  return f.level === selectedPosition.level
}
const getOrgsMatchingPositionOrgType = (orgs, newPosition) => {
  // get orgs that match the org type selected in the position (admin screen)
  let selectedPosition = positions.value.find(p => p.id === newPosition.positionId)
  return orgs.filter(o => o.orgTypeId === selectedPosition.orgTypeId)
}
const saveUser = async() => {
  let phoneRegex = '^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$'
  if (!user.value?.phoneNumber?.match(phoneRegex) || user.value?.phoneNumber?.length > 20) {
    snackbar('ERROR', 'Error saving user: Please enter a valid phone number')

    return;
  }

  appStore.loading = true
  user.value.customFieldGroups = customFieldGroups.value
  user.value.username = user.value.email
  try {
    // save user
    const {data} = await putRequest(`/user`, user.value)

    // save dirty custom field values
    if (data?.id) {
      await postRequest(`/customFieldValues/user/${data.id}`, dirtyCfvs.value)
    }

    // save new user position
    if (userPositionPanel.value === 0 && newPosition.value.positionId && data?.id) {
      await savePosition(data.id)
    }

    const {status} = await router.push({name: 'userDetails', params: {id: data.id}})
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    let errorMsg = 'Error Adding User'
    if (e?.message?.includes('Email already in use')) {
      errorMsg += ': Email Already in Use'
    }
    snackbar('ERROR', errorMsg)

    appStore.loading = false
  }
}
const savePosition = async(userId) => {
  try {
    let params = {
      ...newPosition.value,
      userId: userId,
      orgId: newPosition.value?.hierarchy[0]?.orgId,
      primaryFlag: true
    }

    await postRequest(`/userPosition`, params)
  } catch (e) {
    console.error('*** ERROR ***', e)
    snackbar('ERROR', 'Error saving user new position')

    appStore.loading = false
  }
}
const setFakeUser = () => {
  user.value = {
    firstName: 'Randa',
    lastName: 'Test',
    street1: '1234 Oak St.',
    city: 'Salt Lake City',
    companyStateId: 2,
    userStatusTypeId: 9,
    phoneNumber: '1111111111',
    email: 'randa@randa.com',
    postalCode: '87654',
    companyCountryId: 1
  }
}
const getReadOnly = (field) => {
  return getCustomFieldReadOnly(field)
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)

  if (!match) {
    dirtyCfvs.value.push(field)
  }

}

</script>

<style lang="scss" scoped>
.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}
</style>

