<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add User
        <v-spacer></v-spacer>
        <v-btn text class="mr-3" to="/users">Cancel</v-btn>
        <v-btn color="primaryCustom" dark @click="validate">Save</v-btn>
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
              <v-text-field text
                            label="Address"
                            :rules="requiredRules"
                            v-model="user.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            :rules="requiredRules"
                            v-model="user.city"></v-text-field>
              <v-autocomplete v-model="user.companyStateId"
                              :items="states"
                              autocomplete="new-password"
                              label="State"
                              :rules="requiredRules"
                              item-text="state"
                              item-value="id"/>
              <v-select v-model="user.companyCountryId"
                        :items="countries"
                        :rules="requiredRules"
                        label="Country"
                        item-text="country"
                        item-value="id"
              ></v-select>
            </v-col>
            <v-col cols="12" sm="6">
              <v-select v-model="user.userStatusTypeId"
                        :items="userStatusTypes"
                        label="User Status"
                        :rules="requiredRules"
                        item-text="userStatusType"
                        item-value="id"
              ></v-select>
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

            </v-col>
          </v-row>
        </v-container>
      </v-form>
      <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
        <h3>{{cfg.groupName}}</h3>
        <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                          :key="idx"
                          :readonly="getReadOnly(cf)"
                          :field="cf"></CustomValueInput>
      </v-container>
    </v-card>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import Snackbar from '@/components/Snackbar.vue'
import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
import constants from '@/helpers/constants'
import {getCountries} from '@/services/countryService'
import {getCompanyStates} from '@/services/stateService'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import {getUserStatusTypes} from '@/services/userService'

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
      userStatusTypes: [],
      requiredRules: constants.BASIC_REQUIRED_RULE,
      emailRules: constants.EMAIL_RULES,
      companyId: this.$store.state.user.details.companyId,
    }
  },
  created () {
    //todo: use only for testing
    if(VUE_APP_ENV === 'local') {
      this.setFakeUser()
    }
    this.getUserStatusTypes()
    this.getCompanyStates()
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
    async getUserStatusTypes () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getUserStatusTypes()
        this.userStatusTypes = data

        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanyStates () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data} = await getCompanyStates()
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
        this.$router.push({name: 'userDetails', params: {id: data.id}})
        this.$store.commit(AppMutations.SET_LOADING, false)
      } catch (e) {
        console.error('*** ERROR ***', e)
        let errorMsg = 'Error Adding User'
        if(e?.data?.message?.includes('Email already exists')) {
          errorMsg += ': Email Already in Use'
        }
        this.snackbar = getSnackbar('ERROR', errorMsg)
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
        companyStateId: 2,
        companyCountryId: 1,
        postalCode: '87654',
        email: 'randa@randa.com'
      }
    },
    getReadOnly: function (field) {
      return getCustomFieldReadOnly(this.$store, field)
    },
  }

}
</script>

<style lang="scss" scoped>
</style>

