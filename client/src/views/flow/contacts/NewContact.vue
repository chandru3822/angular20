<template>
  <v-container class="mt-4">
    <v-card class="px-3">
      <v-card-title>
        Add Contact
        <v-spacer></v-spacer>
        <v-btn v-if="!constants.IS_MOBILE" text class="mr-3" to="/contacts">Cancel</v-btn>
        <v-btn v-if="!constants.IS_MOBILE" color="primaryCustom" dark @click="validate">Save</v-btn>
      </v-card-title>
      <v-card-text  v-if="constants.IS_MOBILE">
        <v-btn text class="mr-3" to="/contacts">Cancel</v-btn>
        <v-btn color="primaryCustom" dark @click="validate">Save</v-btn>
      </v-card-text>

      <v-form ref="contactForm">
        <v-container>
          <v-row>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="First Name"
                            :rules="requiredRules"
                            v-model="contact.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            :rules="requiredRules"
                            v-model="contact.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            v-model="contact.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            v-model="contact.city"></v-text-field>
              <v-select v-model="contact.stateId"
                        :items="states"
                        label="State"
                        item-text="state"
                        item-value="id"
              ></v-select>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="Phone"
                            :rules="requiredRules"
                            v-model="contact.phone"></v-text-field>
              <v-text-field text
                            label="Mobile"
                            v-model="contact.mobile"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :rules="emailRules"
                            v-model="contact.email"></v-text-field>
              <v-text-field text
                            label="Zip Code"
                            v-model="contact.postalCode"></v-text-field>
              <v-select v-model="contact.countryId"
                        :items="countries"
                        label="Country"
                        item-text="country"
                        item-value="id"
              ></v-select>
            </v-col>
          </v-row>
        </v-container>
      </v-form>
      <v-container class="text-left" v-for="cfg in customFieldGroups" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
        <h3>{{cfg.groupName}}</h3>
        <CustomValueInput v-for="cf in cfg.customFieldValues"
                          :readonly="getReadOnly(cf)"
                          :callback="populateDirtyCfvs"
                          :field="cf"></CustomValueInput>
      </v-container>
    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, getRequestWithParams, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {getStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from '@/services/customFieldService'

const { VUE_APP_ENV } = process.env

export default {
  name: 'NewContact',
  components: {
    Snackbar,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      constants,
      contact: {},
      states: [],
      countries: [],
      dirtyCfvs: [],
      customFieldGroups: [],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      emailRules: constants.EMAIL_RULES,
      companyId: this.$route.query.cid || this.$store.state.user.details.companyId,
    }
  },
  created () {
    console.log('paramamsmsmam', this.$route.query.cid)
    //todo: use only for testing
    if(VUE_APP_ENV === 'local') {
      this.setFakeContact()
    }
    this.getStates()
    this.getCountries()
    this.getCustomFieldGroups()
  },
  methods: {
    validate () {
      if (this.$refs.contactForm.validate()) {
        this.saveContact()
      }
    },
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequestWithParams(`/customFieldGroup/getContactInsertFields`, {
          params: {
            companyId: this.companyId
          }
        })
        this.customFieldGroups = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getStates () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getStates()
        this.states = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCountries () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCountries()
        this.countries = data
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveContact () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.contact.customFieldGroups = this.customFieldGroups
      try {
        this.contact.companyId = this.companyId
        const {data} = await postRequest(`/contact`, this.contact)
        if(data && data.id) {
          await postRequest(`/customFieldValues/contact/${data.id}`, this.dirtyCfvs)
          this.$router.push({name: 'contact', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Contact')
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
        stateId: 44,
        countryId: 1,
        postalCode: '84115',
        email: 'randa@randa.com'
      }
    }
  }

}
</script>

<style lang="scss" scoped>
</style>

