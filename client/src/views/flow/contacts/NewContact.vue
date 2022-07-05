<template>
  <v-container class="mt-4">
    <v-card class="px-3">
      <v-card-title>
        Add Contact
        <v-spacer></v-spacer>
        <v-btn v-if="!constants.IS_MOBILE" text class="mr-3" to="/contacts">Cancel</v-btn>
        <v-btn v-if="!constants.IS_MOBILE" color="primaryCustom white--text" :disabled="loadingInsertFields" @click="validate(true)">Save</v-btn>
      </v-card-title>
      <v-card-text  v-if="constants.IS_MOBILE">
        <v-btn text class="mr-3" to="/contacts">Cancel</v-btn>
        <v-btn color="primaryCustom white--text" :disabled="loadingInsertFields"
               @click="validate(true)" id="qa-add-contact-save"  >Save</v-btn>
      </v-card-text>
      <v-form ref="contactForm">
        <v-container>
          <v-row>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="First Name"
                            id="qa-first-name-field"
                            :rules="nameRequiredRules"
                            v-model="contact.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            id="qa-last-name-field"
                            :rules="nameRequiredRules"
                            v-model="contact.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            id="qa-address-field"
                            :rules="addressRules"
                            v-model="contact.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            id="qa-city-field"
                            :rules="cityRules"
                            v-model="contact.city"></v-text-field>
              <v-select attach v-model="contact.companyStateId"
                        :items="states"
                        label="State"
                        id="qa-state-field"
                        item-text="state"
                        item-value="id"
              ></v-select>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="Phone"
                            :rules="contactPhoneRule"
                            id="qa-phone-field"
                            v-model="contact.phone"></v-text-field>
              <v-text-field text
                            label="Mobile"
                            :rules="contactPhoneRule"
                            id="qa-mobile-field"
                            v-model="contact.mobile"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            id="qa-email-field"
                            :rules="emailRules"
                            v-model="contact.email"></v-text-field>
              <v-text-field text
                            label="Zip Code"
                            id="qa-zip-field"
                            counter
                            maxlength="10"
                            @keypress="isNumberOrHyphen"
                            :rules="postalCodeRules"
                            v-model="contact.postalCode"></v-text-field>
              <v-select attach v-model="contact.companyCountryId"
                        :items="countries"
                        label="Country"
                        id="qa-country-field"
                        item-text="country"
                        item-value="id"
              ></v-select>
            </v-col>
          </v-row>
        </v-container>
        <SpinnerInline v-if="loadingInsertFields" :text="'Checking For Additional Fields...'" :size="20" color="primaryCustom"/>
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

<script>
import {AppMutations} from '@/stores/AppStore'
import SpinnerInline from '@/components/SpinnerInline'
import { handleHidingGlobalLoader, getRequestWithParams, isNumberOrHyphen, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from '@/services/customFieldService'

const { VUE_APP_ENV } =  import.meta.env

export default {
  name: 'NewContact',
  components: {
    SpinnerInline,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      constants,
      contact: {},
      isNumberOrHyphen,
      states: [],
      postalCodeRules: constants.POSTAL_CODE_REQUIRED_RULES,
      cityRules: constants.CITY_RULES,
      addressRules: constants.ADDRESS_RULES,
      // phoneRules: constants.PHONE_REQUIRED_RULES,
      nameRules: constants.NAME_RULES,
      nameRequiredRules: constants.NAME_REQUIRED_RULES,
      contactPhoneRule: [
        () => ((this.contact.phone != null && this.contact.phone !== '') || (this.contact.mobile != null && this.contact.mobile !== '')) || "Phone or Mobile is required",
        v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
        v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",
        v => ((!v || (this.contact.phone !== this.contact.mobile))) || 'Phone and Mobile Cannot be the same',
      ],
      loadingInsertFields: true,
      countries: [],
      dirtyCfvs: [],
      customFieldGroups: [],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      emailRules: constants.EMAIL_RULES,
      companyId: this.$route.query.cid || this.$store.state.user.details.companyId,
    }
  },
  watch: {
    contact: {
      // This will let Vue know to look inside the array
      deep: true,

      // We have to move our method to a handler field
      handler() {
        this.validate(false)
      }
    }
  },
  created () {
    //todo: use only for testing
    if(VUE_APP_ENV === 'local') {
      // this.setFakeContact()
    }
    this.getCompanyStates()
    this.getCountries()
    this.getCustomFieldGroups()
  },
  methods: {
    validate (saveContact) {

      let valid = this.$refs.contactForm.validate()
      console.log('VALID', valid)
      if (valid && saveContact) {
        this.saveContact()
      }
    },
    async getCustomFieldGroups () {
      this.loadingInsertFields = true
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/customFieldGroup/getContactInsertFields`, {
          params: {
            companyId: this.companyId
          }
        })
        this.customFieldGroups = data
        this.loadingInsertFields = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.loadingInsertFields = false
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyStates () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCompanyStates(parseInt(this.companyId))
        this.states = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCountries () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getCountries(parseInt(this.companyId))
        this.countries = data
        if(this.countries?.length === 1) {
          this.contact.companyCountryId = this.countries[0].id
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveContact () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.contact.customFieldGroups = this.customFieldGroups
      try {
        this.contact.companyId = this.companyId
        const {data, status} = await postRequest(`/contact`, this.contact)
        if(data && data.id && this.dirtyCfvs?.length > 0) {
          await postRequest(`/customFieldValues/contact/${data.id}`, this.dirtyCfvs)
          // Save BlueRaven Solar Contacts to Genesys
          if (this.companyId === 3) {
            await postRequest(`/genesys/contact/${data.id}`, this.dirtyCfvs, 'blueraven')
          }

          this.$router.push({name: 'contact', params: {id: data.id}})
          handleHidingGlobalLoader(this, status)
        } else {
          this.$router.push({name: 'contact', params: {id: data.id}})
          handleHidingGlobalLoader(this, status)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Contact')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if(!match) {
        this.dirtyCfvs.push(field)
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field)
    },
    setFakeContact () {
      this.contact = {
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
  }

}
</script>
