<template>
  <v-container>
    <v-row>
      <v-col cols="12">
        <v-toolbar flat>
          <v-toolbar-title>
            Availability
          </v-toolbar-title>
        </v-toolbar>
        <v-select v-model="orgId"
                  :items="orgs"
                  label="Select an Organization..."
                  item-text="orgName"
                  item-value="id"
                  autocomplete="off"
                  @input="[userId = null, resourceType = 'ORG']">
        </v-select>
        <v-select v-model="userId"
                  :items="users"
                  label="Select a User..."
                  item-text="fullName"
                  item-value="id"
                  autocomplete="off"
                  @input="[orgId = null, resourceType = 'USER']">
        </v-select>
        <v-app-bar dense tabs color="white" class="elevation-0">
          <v-tabs :optional="false" color="primaryCustom"
                  background-color="white" v-model="model" slider-color="primaryCustom">
            <v-tab v-for="(tab, index) in displayedTabs" :key="index" :to="tab.path">
              {{tab.label}}
            </v-tab>
          </v-tabs>
        </v-app-bar>
        <router-view></router-view>
      </v-col>
    </v-row>
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, getRequestWithParams, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'Availability',
    components: {
      Snackbar
    },
    computed: {
      displayedTabs () {
        return this.tabs.filter(tab => tab.display)
      }
    },
    data() {
      return {
        snackbar: {},
        orgs: [],
        orgId: null,
        orgsLoading: false,
        users: [],
        userId: null,
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
    //testing something
    created() {
      this.getOrgs()
      this.getUsers()
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
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>

</style>

