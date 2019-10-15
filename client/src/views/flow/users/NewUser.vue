<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add User
        <v-spacer></v-spacer>
        <v-btn text class="mr-3" to="/users">Cancel</v-btn>
        <v-btn color="primary" dark @click="validate">Save</v-btn>
      </v-card-title>

      <v-form ref="userForm">
        <v-container>
          <v-row>
            <v-col xs="12" sm="6">
              <v-text-field text
                            label="First Name"
                            :rules="requiredRules"
                            v-model="user.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            :rules="requiredRules"
                            v-model="user.lastName"></v-text-field>
              <v-text-field text
                            label="Address"
                            :rules="requiredRules"
                            v-model="user.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            :rules="requiredRules"
                            v-model="user.city"></v-text-field>
              <v-select v-model="user.stateId"
                        :items="states"
                        label="State"
                        :rules="requiredRules"
                        item-text="state"
                        item-value="id"
              ></v-select>
            </v-col>
            <v-col xs="12" sm="6">
              <v-text-field text
                            label="Phone"
                            :rules="requiredRules"
                            v-model="user.phone"></v-text-field>
              <v-text-field text
                            label="Mobile"
                            :rules="requiredRules"
                            v-model="user.mobile"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :rules="emailRules"
                            v-model="user.email"></v-text-field>
              <v-text-field text
                            label="Zip Code"
                            :rules="requiredRules"
                            v-model="user.postalCode"></v-text-field>
              <v-select v-model="user.countryId"
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
      <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
        <h3>{{cfg.groupName}}</h3>
        <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues" :key="idx" :readonly="false" :field="cf"></CustomValueInput>
      </v-container>
    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, BASIC_REQUIRED_RULE, EMAIL_RULES, getSnackbar} from '@/helpers/helpers'
import {getCountries} from '@/services/countryService'
import {getStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'

const { VUE_APP_ENV } = process.env

export default {
  name: 'NewUser',
  components: {
    Snackbar,
    CustomValueInput
  },
  data () {
    return {
      snackbar: {},
      user: {},
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
      this.setFakeUser()
    }
    this.getStates()
    this.getCountries()
    this.getCustomFieldGroups()
  },
  methods: {
    validate () {
      if (this.$refs.userForm.validate()) {
        this.saveUser()
      }
    },
    async getCustomFieldGroups () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getRequest(`/customFieldGroup/getUserInsertFields`)
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
    async saveUser () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      this.user.customFieldGroups = this.customFieldGroups
      try {
        const {data} = await putRequest(`/user`, this.user)
        this.$router.push({name: 'user', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Adding User')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    setFakeUser () {
      this.user = {
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

