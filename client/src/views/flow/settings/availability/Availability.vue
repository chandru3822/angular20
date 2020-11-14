<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title>
            Availability
          </v-toolbar-title>
        </v-toolbar>
        <v-autocomplete v-if="viewAll"
                  v-model="orgId"
                  :items="orgs"
                  label="Select an Organization..."
                  item-text="orgName"
                  item-value="id"
                  autocomplete="new-password"
                  @input="[userId = null, getApptLength()]">
        </v-autocomplete>
        <v-autocomplete v-model="userId"
                  :items="users"
                  :readonly="!viewAll"
                  :disabled="!viewAll"
                  label="Select a User..."
                  item-text="fullName"
                  item-value="id"
                  autocomplete="new-password"
                  @input="[orgId = null, getApptLength()]">
        </v-autocomplete>
        <v-toolbar flat class="app-toolbar mt-2" v-if="userId || orgId">
          <v-text-field
            class="d-inline-block"
            type="number"
            :readonly="!userCanEdit"
            :disabled="!userCanEdit"
            v-model="defaultAppointmentLength"
            label="Default Appointment Length (minutes)"
          ></v-text-field>
          <v-btn class="d-inline-block" v-if="userCanEdit" small text @click="saveApptLength()">
            <v-icon>save</v-icon>
          </v-btn>
        </v-toolbar>
        <v-app-bar dense tabs color="white" class="elevation-0">
          <v-tabs :optional="false" color="primaryCustom"
                  background-color="white" v-model="model" slider-color="primaryCustom">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view v-bind="resourceProps"></router-view>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import {getRequest, getRequestWithParams, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Availability',

    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      },
      resourceProps() {
        if (this.userId) { return { userId: this.userId }}
        if (this.orgId) { return { orgId: this.orgId }}
      }
    },
    data() {
      return {
        defaultAppointmentLength: null,
        snackbar: {},
        orgs: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'),
        orgId: null,
        orgsLoading: false,
        users: [],
        viewAll: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL'),
        // userId: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL') ? null : this.$store.state.user.details.id,
        userId: 2410262,
        usersLoading: false,
        model: '',
        tabs: [ {
          label: 'Schedule',
          path: '/settings/availability/schedule',
          display: this.$store.getters.userHasFeature('AVAILABILITY')
        }, {
          label: 'Appointments',
          path: '/settings/availability/appointments',
          display: this.$store.getters.userHasFeature('AVAILABILITY')
        }]
      }
    },
    created() {
      this.getOrgs()
      this.getUsers()
      if(null !== this.userId) {
        this.getApptLength()
      }
    },
    methods: {
      async getOrgs() {
        this.orgsLoading = true
        try {
          const {data} = await getRequestWithParams(`/org/getSchedulingOrgs`, { params: {
            isSchedulingTool: false
          }})
          this.orgs = data
          this.orgsLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Organizations')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getUsers() {
        this.usersLoading = true
        try {
          const {data} = await getRequestWithParams(`/user/getSchedulingUsers`, { params: {
            isSchedulingTool: false
          }})
          this.users = data
          this.usersLoading = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Users')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async saveApptLength() {
        try {
          let params = {
            userId: this.userId,
            orgId: this.orgId,
            defaultAppointmentLength: this.defaultAppointmentLength
          }
          await postRequest(`/availability/appointments/length`, params)
          this.snackbar = getSnackbar('SUCCESS', 'Appointment Length Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Appointment Length')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getApptLength() {
        if(this.orgId || this.userId) {
          this.$store.commit(AppMutations.SET_LOADING, true)
          try {
            const {data} = await getRequestWithParams(`/availability/appointments/length`, { params: {
                userId: this.userId,
                orgId: this.orgId,
              }})
            this.defaultAppointmentLength = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.$store.commit(AppMutations.SET_LOADING, false)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Default Appointment Length')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

