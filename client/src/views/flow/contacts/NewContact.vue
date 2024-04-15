<template>
  <v-container class="mt-4">
    <v-card class="px-3">
      <v-card-title class="title-large-medium">
        Add Contact
        <v-spacer></v-spacer>
        <a-btn
            v-if="$vuetify.breakpoint.smAndUp"
            variant="text"
            color="primary"
            class="mr-3 body-medium"
            to="/contacts"
            text="Cancel"
        ></a-btn>
        <a-btn
            id="qa-add-contact-save"
            v-if="$vuetify.breakpoint.smAndUp"
            color="primary "
            :disabled="loadingInsertFields"
            @click="validate(true)"
            class="body-medium"
            text="Save"
        ></a-btn>
      </v-card-title>
      <v-card-text v-if="$vuetify.breakpoint.xsOnly">
        <a-btn
            variant="text"
            class="mr-3 body-medium"
            color="primary"
            to="/contacts"
            text="Cancel"
        ></a-btn>
        <a-btn
            color="primary "
            :disabled="loadingInsertFields"
            @click="validate(true)"
            id="qa-add-contact-save"
            class="body-medium"
            text="Save"
        ></a-btn>
      </v-card-text>
      <v-form ref="contactForm">
        <v-container>
          <v-row>
            <v-col cols="12" sm="6">
              <a-text-field
                            class="body-large"
                            label="First Name"
                            id="qa-first-name-field"
                            :rules="nameRequiredRules"
                            v-model="contact.firstName"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="Last Name"
                            id="qa-last-name-field"
                            :rules="nameRequiredRules"
                            v-model="contact.lastName"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="Address"
                            id="qa-address-field"
                            :maxlength="35"
                            counter
                            :rules="addressRules"
                            v-model="contact.street1"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="City"
                            id="qa-city-field"
                            :rules="cityRules"
                            v-model="contact.city"></a-text-field>
              <a-select attach v-model="contact.companyStateId"
                        class="body-large"
                        :items="states"
                        label="State"
                        id="qa-state-field"
                        item-title="state"
                        item-value="id"
              ></a-select>
            </v-col>
            <v-col cols="12" sm="6">
              <a-text-field
                            class="body-large"
                            label="Phone"
                            :rules="contactPhoneRule"
                            id="qa-phone-field"
                            v-model="contact.phone"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="Mobile"
                            :rules="contactPhoneRule"
                            id="qa-mobile-field"
                            v-model="contact.mobile"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="E-Mail"
                            id="qa-email-field"
                            :rules="emailRules"
                            v-model="contact.email"></a-text-field>
              <a-text-field
                            class="body-large"
                            label="Zip Code"
                            id="qa-zip-field"
                            counter
                            :maxlength="10"
                            @keydown="isNumberOrHyphen"
                            :rules="postalCodeRules"
                            v-model="contact.postalCode"></a-text-field>
              <a-select attach v-model="contact.companyCountryId"
                        class="body-large"
                        :items="countries"
                        label="Country"
                        id="qa-country-field"
                        item-title="country"
                        item-value="id"
              ></a-select>
            </v-col>
          </v-row>
        </v-container>
        <SpinnerInline v-if="loadingInsertFields" :text="'Checking For Additional Fields...'" :size="20" color="primary"/>
        <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
          <div class="label-large">{{cfg.groupName}}</div>
          <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                            class="body-large"
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

import SpinnerInline from '@/components/SpinnerInline'
import { handleHidingGlobalLoader, getRequestWithParams, isNumberOrHyphen, postRequest, } from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {saveContact} from '@/services/contactService'
import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from '@/services/customFieldService'

import { getCurrentInstance, toRefs, computed, ref, onMounted, watch } from 'vue'
import {useUserStore} from '@/stores/UserStore.js'
import {useRoute, useRouter} from "vue-router/composables";
import { useAppStore } from '@/stores/AppStore.js'

const appStore = useAppStore()
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const vueInstance = getCurrentInstance().proxy
const store = vueInstance.$store


const contact = ref({})
const states = ref([])
const postalCodeRules = ref(constants.POSTAL_CODE_REQUIRED_RULES)
const cityRules = ref(constants.CITY_RULES)
const addressRules = ref(constants.ADDRESS_RULES)
const nameRules = ref(constants.NAME_RULES)
const nameRequiredRules = ref(constants.NAME_REQUIRED_RULES)
const contactPhoneRule = ref([() => ((contact.value.phone != null && contact.value.phone !== '') || (contact.value.mobile != null && contact.value.mobile !== '')) || "Phone or Mobile is required",v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",v => ((!v || (contact.value.phone !== contact.value.mobile))) || 'Phone and Mobile Cannot be the same',])
const loadingInsertFields = ref(true)
const countries = ref([])
const dirtyCfvs = ref([])
const customFieldGroups = ref([])
const requiredRules = ref(constants.BASIC_REQUIRED_RULE)
const emailRules = ref(constants.EMAIL_RULES)
const contactForm = ref(null)

const { VITE_ENV } = import.meta.env

watch(
    () => contact,
    (newValue, oldValue) => {
      validate(false);
    },
    { deep: true }
)
onMounted(() => {
  //todo: use only for testing
  if(VITE_ENV === 'local') {
    // setFakeContact()
  }
  getAllCompanyStates()
  getAllCountries()
  getCustomFieldGroups()
})

const companyId  = computed(() => {
  return route.query.cid || userStore.details.companyId
})

const validate =  (saveContact) => {

  let valid = contactForm.value.validate()
  if (valid && saveContact) {
    saveNewContact()
  }
}
const getCustomFieldGroups = async () => {
  loadingInsertFields.value = true
  appStore.loading = true
  try {
    const {data, status} = await getRequestWithParams(`/customFieldGroup/getContactInsertFields`, {
      params: {
        companyId: companyId.value
      }
    })
    customFieldGroups.value = data
    loadingInsertFields.value = false
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    loadingInsertFields.value = false
    appStore.showSnack('ERROR', 'Error Retrieving Custom Fields')

    appStore.loading = false
  }
}
const getAllCompanyStates = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCompanyStates(parseInt(companyId.value))
    states.value = data
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving States')

    appStore.loading = false
  }
}
const getAllCountries = async () => {
  appStore.loading = true
  try {
    const {data, status} = await getCountries(parseInt(companyId.value))
    countries.value = data
    if(countries.value?.length === 1) {
      contact.value.companyCountryId = countries.value[0].id
    }
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Retrieving Countries')

    appStore.loading = false
  }
}
const saveNewContact = async () => {
  appStore.loading = true
  contact.value.customFieldGroups = customFieldGroups.value
  try {
    contact.value.companyId = companyId.value
    let body = {
      contact: contact.value,
      cfvs: dirtyCfvs.value?.length > 0 ? dirtyCfvs.value : []
    }
    const {data, status} = await saveContact(contact.value.id, body)
    // postRequest(`/contact/custom`, body)

    router.push({path: `/contact/${data?.contact?.id}`})
    handleHidingGlobalLoader( status)
  } catch (e) {
    console.error('*** ERROR ***', e)
    appStore.showSnack('ERROR', 'Error Adding Contact')

    appStore.loading = false
  }
}
const populateDirtyCfvs = (field) => {
  let match = dirtyCfvs.value.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
  if(!match) {
    dirtyCfvs.value.push(field)
  }
}
const getReadOnly = (field) => {
  return getCustomFieldReadOnly(field)
}
const setFakeContact =  () => {
  contact.value = {
    firstName: 'Randa',
    lastName: 'Test',
    phone: '1111111111',
    mobile: '1111111111',
    street1: '1234 Oak St.',
    city: 'Salt Lake City',
    companyStateId: 2,
    companyCountryId: 1,
    postalCode: '84115',
    email: 'randa@randa.com'
  }
}

</script>
