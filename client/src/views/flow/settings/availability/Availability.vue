<template>
  <v-container>
    <v-row  class="pt-0">
      <v-col cols="12"  class="pt-0">
        <v-toolbar flat dense>
          <v-toolbar-title>
            Availability
          </v-toolbar-title>
        </v-toolbar>
        <div class="px-4">
          <v-autocomplete v-if="viewAll"
                    v-model="orgId"
                    :items="orgs"
                    label="Select an Organization..."
                    item-text="orgName"
                    item-value="id"
                    autocomplete="off"
                    @input="[userId = null, getApptLength()]">
          </v-autocomplete>
          <v-autocomplete v-model="userId"
                    :items="users"
                    :readonly="!viewAll"
                    :disabled="!viewAll"
                    label="Select a User..."
                    item-text="fullName"
                    item-value="id"
                    autocomplete="off"
                    @input="[orgId = null, getApptLength()]">
          </v-autocomplete>
          <div class="mb-4" v-if="userId || orgId">
            <label>Default Appointment Length (minutes)</label>
            <v-text-field
              class="d-inline-block ml-3 shrink"
              style="width:100px;"
              type="number"
              filled
              dense
              hide-details
              :readonly="!userIsAdmin"
              :disabled="!userIsAdmin"
              placeholder="--"
              @input="valueChanged = true"
              v-model="defaultAppointmentLength"
            ></v-text-field>
            <v-btn class="d-inline-block" v-if="userIsAdmin && valueChanged" small text @click="saveApptLength()">
              <v-icon>save</v-icon>
            </v-btn>
          </div>
        </div>
        <v-divider class="mb-2"></v-divider>
        <v-card class="mt-3 elevation-4" v-if="userId || orgId">
          <v-app-bar dense tabs class="elevation-1">
            <v-tabs :optional="false" color="primaryCustom"
                    background-color="white" v-model="model" slider-color="primaryCustom">
              <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
                {{tab.label}}
              </v-tab>
            </v-tabs>
          </v-app-bar>
          <router-view v-bind="resourceProps"></router-view>
        </v-card>
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
        if (this.userId) { return { userId: this.userId, useSlotSchedule: this.useSlotSchedule() }}
        if (this.orgId) { return { orgId: this.orgId, useSlotSchedule: false }}
      }
    },
    data() {
      return {
        defaultAppointmentLength: null,
        snackbar: {},
        valueChanged: false,
        orgs: [],
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'EDIT'),
        orgId: null,
        orgsLoading: false,
        users: [],
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'ADMIN'),
        viewAll: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL'),
        userId: this.$store.getters.userHasFeatureAccessLevel('AVAILABILITY', 'VIEW_ALL') ? null : this.$store.state.user.details.id,
        // userId: 2410262,
        usersLoading: false,
        model: '',
        tabs: [ {
          label: 'Schedule',
          path: '/settings/availability/main/schedule',
          display: this.$store.getters.userHasFeature('AVAILABILITY')
        }, {
          label: 'Appointments',
          path: '/settings/availability/main/appointments',
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
      useSlotSchedule() {
        if(this.userId) {
          let user = this.users.find(u => u.id === this.userId)
          console.log('randaLogger',user)
          let useSlots = false
          user?.userPositions?.forEach(up => {
            if(up.useSlotSchedule) {
              useSlots = true
            }
          })
          return useSlots
        }
        return false
      },
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
          this.valueChanged = false
          try {
            const {data} = await getRequestWithParams(`/availability/appointments/length`, { params: {
                userId: this.userId,
                orgId: this.orgId,
              }})
            this.defaultAppointmentLength = data
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.valueChanged = false
            this.defaultAppointmentLength = null
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
.schedule-wrap {

}
</style>

