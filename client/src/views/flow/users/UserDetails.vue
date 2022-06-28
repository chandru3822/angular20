<template>
  <div id="user-detail-container">
    <!--    modal for editing user fields -->
    <v-dialog width="500"
              v-if="user && user.id"
              v-model="showEditModal" content-class="square-card">
      <v-card class="px-6 py-4 square-card">
        <v-form ref="userEditForm">
          <v-card-title
            color="blackText"
            class="albatross-header-3 text-capitalize pa-0"
            primary-title>
            User Overview
          </v-card-title>
          <v-card-text class="pt-4 px-0">
            <div>
              <v-select attach v-model="tempUser.userStatusTypeId"
                        :items="userStatusTypes"
                        label="User Status"
                        :rules="requiredRules"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        placeholder="Select a status..."
                        item-text="userStatusType"
                        item-value="id"
                        autocomplete="off">
              </v-select>
              <v-text-field text
                            label="User First Name"
                            placeholder=" "
                            :rules="requiredRules"
                            :readonly="!userCanEdit"
                            v-model="tempUser.firstName"
              ></v-text-field>
              <v-text-field text
                            label="User Last Name"
                            :rules="requiredRules"
                            :readonly="!userCanEdit"
                            v-model="tempUser.lastName"
              ></v-text-field>
              <v-text-field text
                            label="Phone"
                            placeholder=" "
                            :rules="userPhoneRule"
                            :readonly="!userCanEdit"
                            v-model="tempUser.phoneNumber"></v-text-field>
              <v-text-field text
                            label="Phone Extension"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            v-model="tempUser.phoneExtension"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            placeholder=" "
                            :rules="emailRule"
                            :readonly="!userCanEdit"
                            v-model="tempUser.email"></v-text-field>
              <v-text-field text
                            label="Username"
                            placeholder=" "
                            :rules="usernameRule"
                            :readonly="!userCanEdit"
                            v-model="tempUser.username"></v-text-field>
              <v-text-field text class="mt-4"
                            v-if="userIsAdmin"
                            label="Password"
                            placeholder=" "
                            v-model="tempUser.newPassword"></v-text-field>
            </div>
          </v-card-text>
        </v-form>

        <v-card-actions class="pa-0">
          <v-btn @click="showEditModal = false" class="text-capitalize">
            cancel
          </v-btn>
          <v-spacer></v-spacer>
          <v-btn
            color="primaryCustom"
            class="white--text text-capitalize font-weight-bold"
            @click="validateForm()">
            Save
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <!--    end dialog -->
    <ThreeColumnLayout :header-hidden="true"
                       :auto-overflow-left="false">
      <template v-slot:left-column>
        <div v-if="!$store.state.project.leftSideSplit && user && user.id"
             class="px-2 height-one-hunned overflow-y-auto">
          <v-toolbar flat color="transparent">
            <v-toolbar-title class="albatross-header-3">User Overview</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <v-btn
                text x-small
                @click="[getUserStatusTypes(), tempUser = cloneDeep(user), showEditModal = true]"
                v-if="user && user.id && userCanEdit">
                <v-icon>edit</v-icon>
              </v-btn>
            </v-toolbar-items>
          </v-toolbar>
          <div class="mx-4 address-details">
            <span class="detail-label">User Status:</span>
            <span class="detail-item" :class="{'status-cancelled': !user.hasAccess,
                                               'status-active': user.hasAccess}">{{ user.userStatusType }}</span> <br/>
            <span class="detail-label">Phone:</span>
            <span class="detail-item">{{ formatPhoneNumber(user.phoneNumber) }}</span> <br/>
            <span class="detail-label">Phone Extension:</span>
            <span class="detail-item">{{ user.phoneExtension }}</span> <br/>
            <span class="detail-label">Email:</span>
            <span class="detail-item">{{ user.email }}</span> <br/>
            <span class="detail-label">Username:</span>
            <span class="detail-item">{{ user.username }}</span> <br/>
          </div>
          <v-divider class="mt-4" v-if="user.loginAttempts >= 9"></v-divider>
          <v-card color="#ffcac7" class="pa-4 mx-2 mt-2" v-if="user.loginAttempts >= 9">
            <label>Too Many Attempts, User Account Locked</label><br/>
            <v-btn v-if="userIsAdmin" @click="unlockUserAccount" color="primaryCustom" class="white--text mt-2">
              Unlock
            </v-btn>
          </v-card>
          <v-divider class="mt-4"></v-divider>
          <div class="mt-2">
            <v-toolbar color="transparent" flat>
              <v-toolbar-title class="albatross-header-3">Company Access</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-menu
                  v-if="$store.getters.userHasFeatureAccessLevel('PROJECTS', 'ADD')"
                  bottom
                  offset-y
                  :close-on-content-click="false"
                >
                  <template v-slot:activator="{ on: menu }">
                    <v-btn text
                           v-on="{ ...menu }"
                           v-if="userIsAdmin"
                           @click="addUserCompany = !addUserCompany">
                      <v-icon>add</v-icon>
                    </v-btn>
                  </template>
                  <v-card class="pa-5">
                    <v-select
                      v-model="newCompany.id"
                      :items="filterUserCompanies()"
                      label="Company"
                      item-text="companyName"
                      item-value="id"
                      @input="getUserStatusTypes(newCompany.id)"
                    ></v-select>
                    <v-select
                      v-model="newCompany.companyUserStatusTypeId"
                      :items="companyUserStatusTypes"
                      label="User Status"
                      item-text="userStatusType"
                      item-value="id"
                    ></v-select>
                    <v-btn
                      v-if="userIsAdmin"
                      color="primaryCustom"
                      class="white--text mb-2"
                      :disabled="!newCompany.id || !newCompany.companyUserStatusTypeId"
                      text
                      @click="saveUserCompany">Add User to Company
                    </v-btn>
                  </v-card>
                </v-menu>
              </v-toolbar-items>
            </v-toolbar>
            <div class="mx-2">
              <v-card flat v-for="uc in user.companies"
                      class="user-company-button albatross-body-1">
                {{ uc.companyName }}
                <v-dialog
                  v-if="userIsAdmin"
                  v-model="uc.deleteConfirm"
                  width="500">
                  <template #activator="{ on }">
                    <v-btn fab small text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="text-h5 grey lighten-2"
                      primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text class="pt-4">
                      Are you sure you want to delete {{ uc.companyName }} from this user?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="uc.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="removeUserCompany(uc)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </v-card>
            </div>
          </div>
        </div>
      </template>
      <template v-slot:main-column>
        <div v-if="user && user.id && !fieldsLoading" style="overflow-x: hidden">
          <v-toolbar flat color="secondary" class="cfg-name-header fixed-toolbar toolbar-z-index-override">
            <v-toolbar-title class="albatross-header-3">
              User Summary
            </v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items>
              <div>
                <v-btn color="primaryCustom"
                       class="white--text mt-3"
                       v-if="userCanEdit"
                       :loading="fieldsLoading"
                       :disabled="fieldsSaving"
                       @click="saveUser()">
                  Save Fields
                </v-btn>
              </div>
            </v-toolbar-items>
          </v-toolbar>
          <v-row class="px-5">
            <v-col cols="12" class="text-left py-0 px-0">
              <!--    process field groups-->
              <v-form ref="userForm">
                <v-col
                  class="pt-0"
                  v-for="(cfg, index) in customFieldGroups"
                  :key="index"
                >
                  <v-toolbar color="transparent" class="elevation-0 cfg-name-toolbar" dense>
                    <v-toolbar-title>
                      {{ cfg.groupName }}
                    </v-toolbar-title>
                    <v-spacer></v-spacer>
                    <v-toolbar-items>
                    </v-toolbar-items>
                  </v-toolbar>

                  <v-card class="px-4 square-card" v-if="cfg.customFieldValues && cfg.customFieldValues.length > 0">
                    <v-row>
                      <v-col :cols="12" class="pb-0 pt-2">
                        <CustomValueInput v-for="(cf, idx) in cfg.customFieldValues"
                                          :key="idx"
                                          :required="cf.required"
                                          :readonly="getReadOnly(cf)"
                                          :callback="populateDirtyCfvs"
                                          :field="cf"></CustomValueInput>
                      </v-col>
                    </v-row>

                  </v-card>
                </v-col>

              </v-form>
            </v-col>
          </v-row>
        </div>
        <div v-else>
          <SpinnerInline centered :size="50" color="primaryCustom"/>
        </div>
      </template>
      <template v-slot:right-column>
        <ProjectActivity v-if="user && user.id"
                         :user-id="userId"
                         :show-sms-tab="false"></ProjectActivity>
      </template>
    </ThreeColumnLayout>

  </div>
</template>

<script>
import {AppMutations} from '@/stores/AppStore'
import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
import {
  handleHidingGlobalLoader,
  getRequest,
  putRequest,
  postRequest,
  getRequestWithParams,
  getSnackbar, formatPhoneNumber, logError
} from '@/helpers/helpers'
import {getCustomFieldReadOnly} from '@/services/customFieldService'
import cloneDeep from 'lodash.clonedeep'
import ThreeColumnLayout from '@/views/ThreeColumnLayout'
import ProjectActivity from '@/views/flow/project/ProjectActivity'
import constants from "@/helpers/constants";
import SpinnerInline from '@/components/SpinnerInline'

export default {
  name: 'User',
  components: {
    CustomValueInput,
    ThreeColumnLayout,
    SpinnerInline,
    ProjectActivity
  },
  data() {
    return {
      breadcrumbs: [
        {
          text: 'Back to Users',
          disabled: false,
          exact: true,
          to: `/users`
        },
      ],
      userPhoneRule: [
        v => !!v || 'Field is required',
        v => (!v || (v && v.length !== 0)) || 'Field is required',
        v => (!v || (v && (v.length <= 20))) || 'Must be 20 characters or less',
        v => (!v || (/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/.test(v))) || "Please reformat the Phone field with a valid phone number"
      ],
      usernameRule: constants.USERNAME_RULES,
      emailRule: constants.EMAIL_RULES,
      snackbar: {},
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT'),
      userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('USERS', 'ADMIN'),
      companies: [],
      dirtyCfvs: [],
      tempUser: {},
      user: {},
      formatPhoneNumber,
      showEditModal: false,
      cloneDeep,
      requiredRules: constants.BASIC_REQUIRED_RULE,
      fieldsSaving: false,
      fieldsLoading: true,
      customFieldGroups: [],
      notes: [],
      owners: [],
      userId: parseInt(this.$route.params.id),
      companyId: this.$store.state.user.details.companyId,
      changeOwner: false,
      userStatusTypes: [],
      addUserCompany: false,
      newCompany: {},
      companyUserStatusTypes: [],
    }
  },
  async created() {
    this.fieldsLoading = true
    let requests = [this.getUser(), this.getCompanies(), this.getCustomFieldGroups()]
    await Promise.all(requests).then(async () => {
      this.$store.commit(AppMutations.SET_LOADING, false)
      this.fieldsLoading = false
    })
  },
  methods: {
    async validateForm() {
      if (this.$refs.userEditForm.validate()) {
        this.saveUserSystemFields()
      }
    },
    saveUserSystemFields: async function () {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        //temp user holds all the changes in case they cancel. use those values
        const {data, status} = await putRequest(`/user`, this.tempUser)
        this.user = cloneDeep(this.tempUser)
        this.user.userStatusType = data.userStatusType
        this.user.hasAccess = data.hasAccess
        this.showEditModal = false
        this.snackbar = getSnackbar('SUCCESS', 'User Updated')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        logError(e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUser() {
      if (this.$refs.userForm.validate()) {
        //validation moved to vue form validation with rules
        this.$store.commit(AppMutations.SET_LOADING, true)
        // this.user.customFieldGroups = this.customFieldGroups
        this.fieldsSaving = true
        try {
          // save dirty custom field values
          const {data, status} = await postRequest(`/customFieldValues/user/${this.user.id}`, this.dirtyCfvs)
          this.dirtyCfvs = []
          this.customFieldGroups = data
          this.fieldsSaving = false
          this.snackbar = getSnackbar('SUCCESS', 'User Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let errorMsg = e?.message ? 'Error Saving User: ' + e.message : 'Error Saving User'
          this.snackbar = getSnackbar('ERROR', errorMsg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.fieldsSaving = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      } else {
        this.snackbar = getSnackbar('ERROR', 'Missing Required Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
      }
    },
    populateDirtyCfvs(field) {
      let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
      if (!match) {
        this.dirtyCfvs.push(field)
      }
    },
    async getCustomFieldGroups() {
      try {
        const {data, status} = await getRequestWithParams(`/customFieldValues/user/${this.userId}`)
        this.customFieldGroups = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUser() {
      try {
        const {data, status} = await getRequest(`/user/${this.userId}`)
        this.user = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getCompanies() {
      try {
        const {data, status} = await getRequestWithParams(`/companies/availableForUser`)
        this.companies = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Companies')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getNotes() {
      try {
        const {data, status} = await getRequestWithParams(`/note/getUserNotes`, {
          params: {
            primaryId: this.userId
          }
        }, null, [])
        this.notes = data
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Notes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async getUserStatusTypes(companyId) {
      try {
        let params = {
          companyId: companyId
        }
        const {data, status} = await getRequestWithParams(`/user/statuses`, {params})
        if (companyId) {
          //the user status types for adding a user to a user_company
          this.companyUserStatusTypes = cloneDeep(data)
        } else {
          // the user statuses for saving the current user
          this.userStatusTypes = cloneDeep(data)
        }
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async removeUserCompany(uc) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          companyId: uc.id,
          userId: this.userId
        }
        const {data, status} = await postRequest(`/user/removeFromCompany`, params)
        this.user.companies = data
        if (this.companyId === uc.id) {
          this.$router.push({name: 'users'})
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing User Company')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUserCompany() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          companyId: this.newCompany.id,
          companyUserStatusTypeId: this.newCompany.companyUserStatusTypeId,
          userId: this.userId
        }
        const {data, status} = await postRequest(`/user/addToCompany`, params)
        this.user.companies = data
        this.newCompany = {}
        this.addUserCompany = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving User Company')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUserStatus() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await postRequest(`/user/${this.userId}/status/${this.user.userStatusTypeId}`)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving User Status')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async unlockUserAccount() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {status} = await putRequest(`/user/${this.userId}/unlock`)
        this.user.loginAttempts = 0
        this.snackbar = getSnackbar('SUCCESS', 'User Unlocked')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Unlocking User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    getReadOnly: function (field) {
      return !this.userCanEdit || getCustomFieldReadOnly(this.$store, field)
    },
    filterUserCompanies: function () {
      let companiesInUse = this.user.companies.map(c => c.id)
      return this.companies.filter(c => !companiesInUse.includes(c.id))
    },
  }
}
</script>

<style lang="scss">
#company-access-toolbar .v-toolbar__content {
  padding-left: 0;
  padding-top: 0;
}

.cfg-name-toolbar .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-name-toolbar .v-toolbar__title {
  font-size: 14px;
}

.cfg-detail-header .v-toolbar__content {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

.cfg-detail-header .v-toolbar__title {
  font-size: 16px;
}

</style>

<style lang="scss" scoped>
#user-detail-container {
  width: calc(100vw);
  height: calc(100% - 81px);
  max-height: calc(100% - 81px);
  padding: 0 !important;
  overflow: hidden;
  margin-left: -15px;
}

.cfg-detail-header {
  background-color: var(--v-secondary-base) !important;
  margin-left: -10px;
  margin-right: -10px;
  padding-left: 10px;
  padding-right: 10px;
}

.user-header {
  background-color: white;
}

.user-title {
  font-size: 30px;
}

.user-subtitle {
  font-size: 20px;
}

.user-status {
  font-size: 20px;
  display: flex;
  align-items: flex-end;
  text-align: left;
}

.user-owner {
  font-size: 18px;
  /*display: flex;*/
  /*align-items: flex-end;*/
  text-align: right;
}

.change-owner-button {
  text-decoration: underline;
  text-transform: lowercase;
}

.v-select ::v-deep .v-select__selection {
  color: var(--v-primaryText-base);
}

.detail-label {
  font-size: 12px;
  color: #9E9C9C;
}

.detail-item {
  font-size: 0.875rem;
  margin-left: 5px;
  overflow-wrap: break-word;
}

.user-company-button {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border: solid 1px #C4C4C4;
  padding: 10px;
  margin-bottom: 10px;
}

</style>

