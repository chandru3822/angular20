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
                <v-btn text @click="saveUser" v-if="userCanEdit">Save</v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <v-select v-model="user.userStatusTypeId"
                        :items="userStatusTypes"
                        label="User Status"
                        :readonly="!userCanEdit"
                        :disabled="!userCanEdit"
                        placeholder="Select a status..."
                        item-text="userStatusType"
                        item-value="id"
                        autocomplete="off">
              </v-select>
              <v-text-field text
                            label="Phone"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            placeholder=" "
                            v-model="user.phone"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            placeholder=" "
                            v-model="user.email"></v-text-field>
              <v-text-field text
                            label="Username"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            placeholder=" "
                            v-model="user.username"></v-text-field>
  <!--            <div class="mt-2" v-if="companies.length > 1">-->
              <div class="mt-2">
                <div v-if="userCanEdit">
                  <v-select
                      v-model="user.companies"
                      :items="companies"
                      label="Company Access"
                      multiple
                      item-text="companyName"
                      return-object
                  ></v-select>
                </div>
                <div v-else>
                  <label>Company Access:</label>
                  <div class="ml-4"  v-for="uc in user.companies">{{uc.companyName}}</div>
                </div>
              </div>
              <v-text-field text
                            v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'ADMIN')"
                            label="Password"
                            placeholder=" "
                            v-model="user.newPassword"></v-text-field>
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
        <v-col cols="12" md="6" class="text-left" style="padding-top: 0">
          <NotesAndActivity :showNotes="true" :showActivity="false"
                            :notes="notes" :primaryId="parseInt(userId)"
                            type="User"
          ></NotesAndActivity>
        </v-col>
      </v-row>
    </div>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import NotesAndActivity from '@/views/flow/components/NotesAndActivity.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getRequestWithParams, getSnackbar} from '@/helpers/helpers'
  import {getCustomFieldReadOnly} from '@/services/customFieldService'

  export default {
    name: 'User',
    components: {
      Snackbar,
      CustomValueInput,
      NotesAndActivity
    },
    data () {
      return {
        breadcrumbs: [
          {
            text: 'Back',
            disabled: false,
            exact: true,
            to: `/users`
          },
        ],
        snackbar: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT'),
        companies: [],
        dirtyCfvs: [],
        user: {},
        customFieldGroups: [],
        notes: [],
        owners: [],
        userId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        changeOwner: false,
        userStatusTypes: [],
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
      async saveUser() {
        if(this.user?.username?.length > 2) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          // this.user.customFieldGroups = this.customFieldGroups

          try {
            //save user
            await putRequest(`/user`, this.user)
            // save dirty custom field values
            const {data} = await postRequest(`/customFieldValues/user/${this.user.id}`, this.dirtyCfvs)
            this.dirtyCfvs = []
            this.user.newPassword = null
            this.customFieldGroups = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            let errorMsg = e?.data?.message ? 'Error Saving User: ' + e.data.message : 'Error Saving User'
            this.snackbar = getSnackbar('ERROR', errorMsg)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        } else {
          this.snackbar = getSnackbar('ERROR', 'Username must be at least 3 characters')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserStatusTypes () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/user/statuses`)
          this.userStatusTypes = data

          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Statuses')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getReadOnly: function (field) {
        return !this.userCanEdit || getCustomFieldReadOnly(this.$store, field)
      },
    }
  }
</script>

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
</style>

