<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add Lead
        <v-spacer></v-spacer>
        <v-btn v-if="!IS_MOBILE" text class="mr-3" to="/leads">Cancel</v-btn>
        <v-btn v-if="!IS_MOBILE" color="primary" dark @click="validate">Save</v-btn>
      </v-card-title>
      <v-card-text  v-if="IS_MOBILE">
        <v-btn text class="mr-3" to="/leads">Cancel</v-btn>
        <v-btn color="primary" dark @click="validate">Save</v-btn>
      </v-card-text>

      <v-form ref="leadForm">
        <v-container>
          <v-row>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="First Name"
                            :rules="requiredRules"
                            v-model="lead.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            :rules="requiredRules"
                            v-model="lead.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            :rules="requiredRules"
                            v-model="lead.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            :rules="requiredRules"
                            v-model="lead.city"></v-text-field>
              <v-select v-model="lead.stateId"
                        :items="states"
                        label="State"
                        :rules="requiredRules"
                        item-text="state"
                        item-value="id"
              ></v-select>
            </v-col>
            <v-col cols="12" sm="6">
              <v-text-field text
                            label="Phone"
                            :rules="requiredRules"
                            v-model="lead.phone"></v-text-field>
              <v-text-field text
                            label="Mobile"
                            :rules="requiredRules"
                            v-model="lead.mobile"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :rules="emailRules"
                            v-model="lead.email"></v-text-field>
              <v-text-field text
                            label="Zip Code"
                            :rules="requiredRules"
                            v-model="lead.postalCode"></v-text-field>
              <v-select v-model="lead.countryId"
                        :items="countries"
                        :rules="requiredRules"
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
        <CustomValueInput v-for="cf in cfg.customFieldValues" :readonly="false" :field="cf"></CustomValueInput>
      </v-container>
    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, BASIC_REQUIRED_RULE, EMAIL_RULES, getSnackbar, IS_MOBILE} from '@/helpers/helpers'
import {getCountries} from '@/services/countryService'
import {getStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

const { VUE_APP_ENV } = process.env

export default {
  name: 'NewLead',
  components: {
    Snackbar,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      IS_MOBILE,
      lead: {},
      states: [],
      countries: [],
      customFieldGroups: [],
      requiredRules: BASIC_REQUIRED_RULE,
      emailRules: EMAIL_RULES,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created () {
    //todo: use only for testing
    if(VUE_APP_ENV === 'local') {
      this.setFakeLead()
    }
    this.getStates()
    this.getCountries()
    this.getCustomFieldGroups()
  },
  methods: {
    validate () {
      if (this.$refs.leadForm.validate()) {
        this.saveLead()
      }
    },
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customFieldGroup/getCustomerInsertFields`)
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
    async saveLead () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.lead.customFieldGroups = this.customFieldGroups
      try {
        const {data} = await postRequest(`/customer`, this.lead)
        this.$router.push({name: 'lead', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding Lead')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    setFakeLead () {
      this.lead = {
        firstName: 'Randa',
        lastName: 'Test',
        phone: '1111111111',
        mobile: '1111111111',
        street1: '1234 Oak St.',
        city: 'Salt Lake City',
        stateId: 44,
        countryId: 1,
        postalCode: '87654',
        email: 'randa@randa.com'
      }
    }
  }

}
</script>

<style lang="scss" scoped>
</style>

