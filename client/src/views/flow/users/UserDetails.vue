<template>
  <v-container py-0>
    <div v-if="user.id">
      <v-row>
        <v-col cols="12" md="6" class="text-left" style="padding-top: 0">
          <div>
            <v-toolbar color="transparent" class="elevation-0">
              <v-toolbar-title>Summary</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text :disabled="fieldsSaving"
                       @click="[fieldsSaving = true, saveUser()]" v-if="userCanEdit">Save</v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <v-select attach v-model="user.userStatusTypeId"
                        :items="userStatusTypes"
                        label="User Status"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        placeholder="Select a status..."
                        @change="dirtySystemFields = true"
                        item-text="userStatusType"
                        item-value="id"
                        autocomplete="off">
              </v-select>
              <v-text-field text
                            label="First Name"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.firstName"></v-text-field>
              <v-text-field text
                            label="Last Name"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.lastName"></v-text-field>
              <v-text-field text
                            label="Phone"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.phoneNumber"></v-text-field>
              <v-text-field text
                            label="Phone Extension"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.phoneExtension"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.email"></v-text-field>
              <v-text-field text
                            label="Username"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.username"></v-text-field>
  <!--            <div class="mt-2" v-if="companies.length > 1">-->
              <v-text-field text class="mt-4"
                            v-if="userIsAdmin"
                            label="Password"
                            @change="dirtySystemFields = true"
                            placeholder=" "
                            v-model="user.newPassword"></v-text-field>
              <v-card color="#ffcac7" class="pa-4" v-if="user.loginAttempts >= 9">
                <label>Too Many Attempts, User Account Locked</label><br/>
                <v-btn v-if="userIsAdmin" @click="unlockUserAccount" color="primaryCustom" class="white--text mt-2">
                  Unlock
                </v-btn>
              </v-card>
              <div class="mt-2">
                <v-toolbar color="transparent" class="elevation-0" id="company-access-toolbar">
                  <v-toolbar-title>Company Access:</v-toolbar-title>
                  <v-spacer></v-spacer>
                  <v-toolbar-items>
                    <v-btn
                      v-if="userIsAdmin"
                      text
                      @click="addUserCompany = !addUserCompany">Add</v-btn>
                  </v-toolbar-items>
                </v-toolbar>
                <v-divider :class="{'mb-2': !addUserCompany}"></v-divider>
                <v-card flat color="transparent" class="px-3" v-if="addUserCompany">
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
                    @click="saveUserCompany">Add User to Company</v-btn>
                </v-card>
                <v-divider v-if="addUserCompany" class="mb-2"></v-divider>

                <div v-for="uc in user.companies">
                    {{uc.companyName}}
                  <v-dialog
                    v-if="userIsAdmin"
                    v-model="uc.deleteConfirm"
                    width="500">
                    <template #activator="{ on }">
                      <v-btn x-small text v-on="on">
                        <v-icon>delete</v-icon>
                      </v-btn>
                    </template>
                    <v-card>
                      <v-card-title
                        class="headline grey lighten-2"
                        primary-title>
                        Confirm
                      </v-card-title>

                      <v-card-text class="pt-4">
                        Are you sure you want to delete {{uc.companyName}} from this user?
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
                </div>

              </div>
            </v-card>
          </div>
          <div class="mt-4" v-for="(cfg, index) in customFieldGroups" :key="index">
            <v-toolbar color="transparent" class="elevation-0">
              <v-toolbar-title>{{cfg.groupName}}</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <!--              <v-btn text @click="saveUser">Save</v-btn>-->
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <CustomValueInput v-for="(cf, index) in cfg.customFieldValues"
                                :key="index"
                                :readonly="getReadOnly(cf)"
                                :callback="populateDirtyCfvs" :field="cf"></CustomValueInput>
            </v-card>
          </div>
        </v-col>
        <v-col cols="12" md="6" class="text-left pa-0">
          <NotesAndActivity ref="notes" :showNotes="true" :showActivity="false"
                            :notes="notes" :primaryId="parseInt(userId)"
                            type="User"
          ></NotesAndActivity>

          <Attachments :object-type-id="3" :user-id="userId" />
        </v-col>

      </v-row>

    </div>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
  import {getRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'
  import cloneDeep from 'lodash.clonedeep'
  import Attachments from '@/views/flow/components/Attachments'

  export default {
    name: 'User',
    components: {
      CustomValueInput,
      NotesAndActivity,
      Attachments
    },
    data () {
      return {
        breadcrumbs: [
          {
            text: 'Back to Users',
            disabled: false,
            exact: true,
            to: `/users`
          },
        ],
        snackbar: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT'),
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('USERS', 'ADMIN'),
        companies: [],
        dirtyCfvs: [],
        user: {},
        dirtySystemFields: false,
        fieldsSaving: false,
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
    created () {
      this.getUser()
      this.getCompanies()
      this.getCustomFieldGroups()
      this.getNotes()
      this.getUserStatusTypes()
    },
    methods: {
      hasDirtyFields() {
        return this.dirtyCfvs.length > 0 || this.dirtySystemFields
      },
      hasDirtyNotes() {
        return this.$refs.notes.hasUnsavedNotes()
      },
      async saveUser() {
        let phoneRegex = '^\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*$'
        if (this.user?.username?.length > 2) {
          if ((!this.user?.phoneNumber?.match(phoneRegex) || this.user?.phoneNumber?.length > 20)) {
            this.snackbar = getSnackbar('ERROR', 'Error Saving User: Please enter a valid phone number')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.fieldsSaving = false
            return;
          }

          this.$store.commit(AppMutations.SET_LOADING, true)
          // this.user.customFieldGroups = this.customFieldGroups

          try {
            //save user
            await putRequest(`/user`, this.user)
            // save dirty custom field values
            const {data} = await postRequest(`/customFieldValues/user/${this.user.id}`, this.dirtyCfvs)
            this.dirtyCfvs = []
            this.dirtySystemFields = false
            this.user.newPassword = null
            this.customFieldGroups = data
            this.fieldsSaving = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            let errorMsg = e?.message ? 'Error Saving User: ' + e.message : 'Error Saving User'
            this.snackbar = getSnackbar('ERROR', errorMsg)
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.fieldsSaving = false
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.snackbar = getSnackbar('ERROR', 'Username must be at least 3 characters')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }

      },
      populateDirtyCfvs(field) {
        let match = this.dirtyCfvs.find(f => (null !== f.id && f.id === field.id) || f.customFieldGroupAssignmentId === field.customFieldGroupAssignmentId)
        if(!match) {
          this.dirtyCfvs.push(field)
        }
      },
      async getCustomFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/customFieldValues/user/${this.userId}`)
          this.customFieldGroups = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Custom Fields')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUser () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/${this.userId}`)
          this.user = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCompanies () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/companies/availableForUser`)
          this.companies = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Companies')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getNotes() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/note/getUserNotes`, { params: {
              primaryId: this.userId
            }})
          this.notes = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Notes')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserStatusTypes (companyId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            companyId: companyId
          }
          const {data} = await getRequestWithParams(`/user/statuses`, {params})
          if(companyId) {
            //the user status types for adding a user to a user_company
            this.companyUserStatusTypes = cloneDeep(data)
          } else {
            // the user statuses for saving the current user
            this.userStatusTypes = cloneDeep(data)
          }

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async removeUserCompany (uc) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            companyId: uc.id,
            userId: this.userId
          }
          const {data} = await postRequest(`/user/removeFromCompany`, params)
          this.user.companies = data
          if(this.companyId === uc.id) {
            this.$router.push({name: 'users'})
          }
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing User Company')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUserCompany () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            companyId: this.newCompany.id,
            companyUserStatusTypeId: this.newCompany.companyUserStatusTypeId,
            userId: this.userId
          }
          const {data} = await postRequest(`/user/addToCompany`, params)
          this.user.companies = data
          this.newCompany = {}
          this.addUserCompany = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving User Company')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUserStatus () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/user/${this.userId}/status/${this.user.userStatusTypeId}`)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving User Status')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async unlockUserAccount () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await putRequest(`/user/${this.userId}/unlock`)
          this.user.loginAttempts = 0
          this.snackbar = getSnackbar('SUCCESS', 'User Unlocked')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
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
</style>
<style lang="scss" scoped>
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
</style>

