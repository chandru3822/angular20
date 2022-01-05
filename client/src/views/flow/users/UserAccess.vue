<template>
  <v-container>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Access Control
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="saveUserAccess"
                   color="primaryCustom" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <AccessControl v-if="userAccessLoaded"
                       :key="accessControlKey"
                       :show-secondary="true"
                       :user-can-edit="userCanEdit"
                       :companyFeatures="userCompanyFeatures || []" :callback="this.companyFeatureCallback"></AccessControl>
      </v-col>
    </v-row>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Org Calendar Access
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addCalendar = !addCalendar, selectedCalendar = {}]"
                   color="primaryCustom" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">
              <v-icon>add</v-icon>
              Add Org Calendar
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-card v-if="addCalendar" class="square-card text-left pa-5 elevation-1">
          <v-autocomplete v-model="selectedCalendar"
                          :items="availableCalendarOrgs"
                          label="New Org Calendar"
                          item-text="orgName"
                          item-value="id"
                          return-object
                          autocomplete="off"
                          @input="saveUserOrgCalendars"
                          attach
          />
          <v-btn text @click="[addCalendar = !addCalendar, selectedCalendar = {}]">Cancel</v-btn>
        </v-card>
        <v-data-table
          :headers="headers"
          :items="filterUserOrgAccess()"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          disable-sort
          class="elevation-1 mt-1"
        >
          <template #no-data>
            No available calendars
          </template>

          <template #no-results>
            No available calendars
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': index % 2 }">
              <td class="text-left">{{ item.orgName }}</td>
              <td class="text-right">
                <v-dialog
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn small text class="clickable" v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="text-h5 grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete <strong>{{item.orgName}}</strong> from this user?
                    </v-card-text>

                    <v-divider></v-divider>

                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn
                        @click="item.deleteConfirm = false">
                        No
                      </v-btn>
                      <v-btn
                        color="primaryCustom"
                        text
                        @click="deleteOrgCalendarFromUser(item)">
                        Yes
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                </v-dialog>
              </td>
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>

  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'

  import AccessControl from '@/views/flow/settings/components/AccessControl.vue'
  import {
    handleHidingGlobalLoader,
    getRequest,
    deleteRequest,
    putRequest,
    postRequest,
    getSnackbar,
    getRequestWithParams
  } from '@/helpers/helpers'

  export default {
    name: 'UserAccess',
    components: {

      AccessControl
    },
    computed: {
      availableCalendarOrgs () {
        return this.orgCalendars.filter(oc => {
          return this.userOrgCalendars.find(uoc => uoc.orgId === oc.id && !uoc.archived) == null
        })
      },
    },
    data() {
      return {
        snackbar: {},
        addCalendar: false,
        userId: this.$route.params.id,
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ACCESS_CONTROL', 'EDIT'),
        features: [],
        orgCalendars: [],
        userOrgCalendars: [],
        selectedCalendar: {},
        userAccessLoaded: false,
        userCompanyFeatures: [],
        headers: [
          { text: 'Calendar', value: 'calendar', show: true },
          { text: '', value: 'icons', show: true },
        ],
        accessControlKey: 0
      }
    },
    created () {
      this.getUserCompanyFeatures()
      this.getAllOrgCalendars()
      this.getUserOrgCalendars()
    },
    methods: {
      async getUserCompanyFeatures() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/feature/user/${this.userId}`)
          this.userCompanyFeatures = data.filter(d => !d.hidden)
          this.userAccessLoaded = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User Access Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserOrgCalendars() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/org/user/${this.userId}/calendars`)
          this.userOrgCalendars = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Calendars')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUserOrgCalendars() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: this.userId,
            orgId: this.selectedCalendar.id
          }
          const {data, status} = await postRequest(`/org/user/calendar`, params)
          this.userOrgCalendars.push(data)
          this.selectedCalendar = {}
          this.addCalendar = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Org Calendar to User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteOrgCalendarFromUser(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/org/user/calendar/${item.id}`)
          item.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Org Calendar from User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getAllOrgCalendars() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              isSchedulingTool: true
            }
          })
          this.orgCalendars = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Calendars')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveUserAccess() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          //we do this temp so that we only send up the values that need to be saved
          let tempCompanyFeatures = this.userCompanyFeatures?.filter(cf => cf.dirty)
          const {data, status} = await putRequest(`/feature/user/${this.userId}`, tempCompanyFeatures)
          this.userCompanyFeatures = data
          this.accessControlKey++
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving User Access Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }

      },
      companyFeatureCallback (newValue) {
        this.userCompanyFeatures = newValue
      },
      filterUserOrgAccess () {
        return this.userOrgCalendars.filter(uoc => { return !uoc.archived})
      },
    }
  }
</script>
