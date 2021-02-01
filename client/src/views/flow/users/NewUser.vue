<template>
  <v-container>
    <v-card class="pa-3">
      <v-card-title>
        Add User
        <v-spacer></v-spacer>
        <v-btn text class="mr-3" to="/users">Cancel</v-btn>
        <v-btn color="primaryCustom white--text" @click="validate"
               :disabled="(newPosition.positionId != null && newPosition.endDate && !newPosition.startDate) || ((newPosition.startDate != null || newPosition.endDate != null) && !newPosition.positionId)">
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
              <v-text-field text
                            label="Address"
                            v-model="user.street1"></v-text-field>
              <v-text-field text
                            label="City"
                            v-model="user.city"></v-text-field>
              <v-autocomplete v-model="user.companyStateId"
                              :items="states"
                              autocomplete="off"
                              label="State"
                              item-text="state"
                              item-value="id"/>
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
                            v-model="user.phoneNumber"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :rules="emailRules"
                            v-model="user.email"></v-text-field>
              <v-text-field text
                            label="Zip Code"
                            v-model="user.postalCode"></v-text-field>
              <v-select v-model="user.companyCountryId"
                        :items="countries"
                        label="Country"
                        item-text="country"
                        item-value="id"
              ></v-select>
            </v-col>
          </v-row>
        </v-container>
        <v-container class="text-left" v-for="(cfg, index) in customFieldGroups" :key="index"
                     v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
          <h3>{{cfg.groupName}}</h3>
          <div v-for="(cf, idx) in cfg.customFieldValues"
               :key="idx">
            <CustomValueInput v-if="cf.fieldName === 'Finding Source'"
                              :readonly="getReadOnly(cf)"
                              :callback="populateDirtyCfvs"
                              :field="cf"></CustomValueInput>
            <CustomValueInput v-if="cf.fieldName === 'Recruited By' && !hideRecruitedBy"
                              :readonly="getReadOnly(cf)"
                              :callback="populateDirtyCfvs"
                              :field="cf"></CustomValueInput>
            <CustomValueInput v-if="cf.fieldName === 'Referred By (Employee)' && !hideReferredBy"
                              :readonly="getReadOnly(cf)"
                              :callback="populateDirtyCfvs"
                              :field="cf"></CustomValueInput>
          </div>
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
                :required="newPosition.positionId !== null"
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
                              label="Position"
                              item-text="position"
                              item-value="id"
                              @input="populateHierarchy(newPosition, true)"/>
              <div v-if="newPositionHierarchyPopulated">
                <div v-for="(f, index) in filters" :key="index">
                  <v-autocomplete
                    v-if="newPosition.keyedHierarchy && newPosition.keyedHierarchy[f.orgLevelId] && isSameLevelAsPosition(f, newPosition)"
                    v-model="newPosition.keyedHierarchy[f.orgLevelId]['orgId']"
                    :items="f.orgs"
                    :label="f.levelName"
                    :rules="requiredRules"
                    item-value="id"
                    autocomplete="off"
                    type="search"
                  >
                    <template slot="selection" slot-scope="{ item, index }">
                      {{ item.orgName }}{{ item.showType ? ' (' + item.orgType + ')' : '' }}
                    </template>
                    <template slot='item' slot-scope='{ item }'>
                      {{ item.orgName }}{{ item.showType ? ' (' + item.orgType + ')' : '' }}
                    </template>
                  </v-autocomplete>
                </div>
              </div>
              <v-btn color="secondary" class="mr-2"
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

  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import constants from '@/helpers/constants'
  import {getCountries} from '@/services/countryService'
  import {getCompanyStates} from '@/services/stateService'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'
  import {getUserStatusTypes} from '@/services/userService'
  import DatetimePickerInput from "@/components/DatetimePickerInput";
  import keyBy from 'lodash.keyby'
  import {getOrgFilters} from '@/services/orgService'

  const {VUE_APP_ENV} = process.env

  export default {
    name: 'NewUser',
    components: {

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
        customFieldGroups: [],
        hideRecruitedBy: false,
        hideReferredBy: false,
        userStatusTypes: [],
        requiredRules: constants.BASIC_REQUIRED_RULE,
        emailRules: constants.EMAIL_RULES,
        companyId: this.$store.state.user.details.companyId,
        userPositionPanel: undefined,
        positions: [],
        filters: [],
        timezone: this.$store.state.user.details.timezone.value,
        newPositionHierarchyPopulated: false,
        newPosition: {}
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
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/customFieldGroup/getUserInsertFields`)
          this.customFieldGroups = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserStatusTypes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getUserStatusTypes()
          this.userStatusTypes = data

          //set the user status to the default if there is one
          this.user.userStatusTypeId = this.userStatusTypes?.find(ust => ust.newUserDefault)?.id

          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getCompanyStates()
          this.states = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getCountries()
          this.countries = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getRequest(`/position`)
          this.positions = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await getOrgFilters()
          this.filters = data
          this.$store.commit(AppMutations.SET_LOADING, false)
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

          await this.$router.push({name: 'userDetails', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMsg = 'Error Adding User'
          console.log('randaLogger', e.message)
          console.log('randaLogger', e?.message?.includes('Email already exists'))
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

        if (field.fieldName !== 'Finding Source' && field?.intValue === undefined) {
          if (this.dirtyCfvs.length === 1) {
            this.dirtyCfvs = []
          } else if (this.dirtyCfvs.length === 2) {
            this.dirtyCfvs = this.dirtyCfvs.filter(cfv => cfv.fieldName === 'Finding Source')
          }

          this.hideRecruitedBy = false
          this.hideReferredBy = false
        } else {
          let customField = this.dirtyCfvs.filter(cfv => cfv.fieldName !== 'Finding Source')

          if (customField !== undefined && customField[0]?.intValue !== undefined) {
            if (customField[0].fieldName === 'Recruited By') {
              this.hideRecruitedBy = false
              this.hideReferredBy = true
            } else if (customField[0].fieldName === 'Referred By (Employee)') {
              this.hideRecruitedBy = true
              this.hideReferredBy = false
            }
          }
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

