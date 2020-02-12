<template>
  <v-container>
    <div v-if="user.id">
      <v-row>
        <v-col cols="12" md="6" class="text-left">
          <div>
            <v-toolbar color="transparent" class="elevation-0">
              <v-toolbar-title>Summary</v-toolbar-title>
              <v-spacer></v-spacer>
              <v-toolbar-items>
                <v-btn text @click="saveUser" v-if="userCanEdit">Save</v-btn>
              </v-toolbar-items>
            </v-toolbar>
            <v-card class="pa-4">
              <v-text-field text
                            label="Phone"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            v-model="user.phone"></v-text-field>
              <v-text-field text
                            label="E-Mail"
                            placeholder=" "
                            :readonly="!userCanEdit"
                            v-model="user.email"></v-text-field>
  <!--            <div class="mt-2" v-if="companies.length > 1">-->
              <div class="mt-2">
                <div v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">
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
              <CustomValueInput v-for="(cf, index) in cfg.customFieldValues" :key="index" :readonly="!userCanEdit" :field="cf"></CustomValueInput>
            </v-card>
          </div>
        </v-col>
        <v-col cols="12" md="6" class="text-left">
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
        user: {},
        customFieldGroups: [],
        notes: [],
        owners: [],
        userId: this.$route.params.id,
        companyId: this.$store.state.user.details.companyId,
        changeOwner: false
      }
    },
    created () {
      this.getUser()
      this.getCompanies()
      this.getCustomFieldGroups()
      this.getNotes()
    },
    methods: {
      async saveUser() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        this.user.customFieldGroups = this.customFieldGroups
        try {
          await putRequest(`/user`, this.user)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getCustomFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequestWithParams(`/customFieldValues/user`, { params: {
              primaryId: this.userId
            }})
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
      }
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

