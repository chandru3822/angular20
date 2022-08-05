<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add User
        <v-spacer></v-spacer>
        <v-btn text color="primary" class="mr-3" to="/users">Cancel</v-btn>
        <v-btn color="primary white--text" @click="validate"
               :disabled="loadingUserInsertFields || (newPosition.positionId != null && newPosition.endDate && !newPosition.startDate) || ((newPosition.startDate != null || newPosition.endDate != null) && !newPosition.positionId)">
          Save
        </v-btn>
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
              <v-btn color="primary" class="mr-2"
                     @click="[userPositionPanel = undefined, newPosition = {}]">Clear
              </v-btn>
            </v-expansion-panel-content>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-form>

    </v-card>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import SpinnerInline from '@/components/SpinnerInline'
  import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getCountries} from '@/services/countryService'
  import {getCompanyStates} from '@/services/stateService'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'
  import {getUserStatusTypes} from '@/services/userService'
  import DatetimePickerInput from "@/components/DatetimePickerInput";
  import keyBy from 'lodash.keyby'
  import {getOrgFilters} from '@/services/orgService'

  export default {
    name: 'NewUser',
    components: {
      SpinnerInline,
      CustomValueInput,
      DatetimePickerInput
    },
    data() {
      return {
        snackbar: {},
        user: {},
        states: [],
        countries: [],
        dirtyCfvs: [],
        loadingUserInsertFields: true,
        customFieldGroups: [],
        userStatusTypes: [],
        requiredRules: constants.BASIC_REQUIRED_RULE,
        emailRules: constants.EMAIL_RULES,
        companyId: this.$store.state.user.details.companyId,
        userPositionPanel: 0,
        positions: [],
        filters: [],
        timezone: this.$store.state.user.details.timezone.value,
        newPositionHierarchyPopulated: false,
        newPosition: {},
        userPhoneRule: [
          () => ((this.user.phoneNumber != null && this.user.phoneNumber !== '')) || "Field is required",
          v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
          v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number",
        ],
      }
    },
    created() {
      //todo: use only for testing
      // if (VUE_APP_ENV === 'local') {
      //   this.setFakeUser()
      // }
      this.getUserStatusTypes()
      this.getCompanyStates()
      this.getCountries()
      this.getCustomFieldGroups()
      this.getFilters()
      this.getPositions()
    },
    methods: {
      validate() {
        if (this.$refs.userForm.validate()) {
          this.saveUser()
        }
      },
      async getCustomFieldGroups() {
        this.loadingUserInsertFields = true
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/customFieldGroup/getUserInsertFields`)
          this.customFieldGroups = data
          this.loadingUserInsertFields = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.loadingUserInsertFields = false
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getUserStatusTypes()
          this.userStatusTypes = data

          //set the user status to the default if there is one
          this.user.userStatusTypeId = this.userStatusTypes?.find(ust => ust.newUserDefault)?.id

          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanyStates() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getCompanyStates()
          this.states = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving States')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCountries() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getCountries()
          this.countries = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Countries')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getPositions() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/position`)
          this.positions = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Positions')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getFilters() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getOrgFilters()
          this.filters = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving org levels')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      populateHierarchy(item, isNew) {
        this.newPositionHierarchyPopulated = false
        let selectedPosition = this.positions.find(p => p.id === item.positionId)
        item.hierarchy = []

        // push a hierarchy item in for the selected level
        this.filters.forEach(f => {
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
          this.newPositionHierarchyPopulated = true
        }
      },
      isSameLevelAsPosition(f, item) {
        // get hierarchy level to show on screen
        let selectedPosition = this.positions.find(p => p.id === item.positionId)
        return f.level === selectedPosition.level
      },
      getOrgsMatchingPositionOrgType(orgs, newPosition) {
        // get orgs that match the org type selected in the position (admin screen)
        let selectedPosition = this.positions.find(p => p.id === newPosition.positionId)
        return orgs.filter(o => o.orgTypeId === selectedPosition.orgTypeId)
      },
      async saveUser() {
        let phoneRegex = '^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$'
        if (!this.user?.phoneNumber?.match(phoneRegex) || this.user?.phoneNumber?.length > 20) {
          this.snackbar = getSnackbar('ERROR', 'Error saving user: Please enter a valid phone number')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          return;
        }

        this.$store.commit(AppMutations.SET_LOADING, true)
        this.user.customFieldGroups = this.customFieldGroups
        this.user.username = this.user.email
        try {
          // save user
          const {data} = await putRequest(`/user`, this.user)

          // save dirty custom field values
          if (data?.id) {
            await postRequest(`/customFieldValues/user/${data.id}`, this.dirtyCfvs)
          }

          // save new user position
          if (this.userPositionPanel === 0 && this.newPosition.positionId && data?.id) {
            await this.savePosition(data.id)
          }

          const {status} = await this.$router.push({name: 'userDetails', params: {id: data.id}})
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMsg = 'Error Adding User'
          if (e?.message?.includes('Email already in use')) {
            errorMsg += ': Email Already in Use'
          }
          this.snackbar = getSnackbar('ERROR', errorMsg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async savePosition(userId) {
        try {
          let params = {
            ...this.newPosition,
            userId: userId,
            orgId: this.newPosition?.hierarchy[0]?.orgId,
            primaryFlag: true
          }

          await postRequest(`/userPosition`, params)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error saving user new position')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      setFakeUser() {
        this.user = {
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
      },
      getReadOnly: function (field) {
        return getCustomFieldReadOnly(this.$store, field)
      },
      populateDirtyCfvs(field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)

        if (!match) {
          this.dirtyCfvs.push(field)
        }

      }
    }
  }
</script>

<style lang="scss" scoped>
  .v-select ::v-deep .v-select__selection {
    color: var(--v-primaryText-base);
  }
</style>

