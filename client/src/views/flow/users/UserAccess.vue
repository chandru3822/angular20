<template>
  <v-container>
    <!--    modal for leaving with unsaved fields -->
    <confirmation-dialog :open-dialog="unsavedFieldsModal" @close-dialog="unsavedFieldsModal = false"
                         @confirm="[navigationOverride = true, goToPath(toPath)]">
      You have unsaved fields. Are you sure you want to continue without saving?
      <template v-slot:no>Cancel</template>
      <template v-slot:yes>Don't Save</template>
    </confirmation-dialog>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Access Control
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="saveUserAccess"
                   color="primary" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">
              <v-icon>save</v-icon>
              Save
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <AccessControl v-if="userAccessLoaded"
                       :key="accessControlKey"
                       :show-secondary="true"
                       :user-can-edit="userCanEdit"
                       :companyFeatures="userCompanyFeatures || []" :callback="this.companyFeatureCallback"
                       :dirtyFieldsCallback="this.setFieldsDirty"></AccessControl>
      </v-col>
    </v-row>
    <v-row class="text-left">
      <v-col>
        <v-toolbar flat color="transparent" class="app-toolbar">
          Org Calendar Access
          <v-spacer></v-spacer>
          <v-toolbar-items>
<!--            <v-btn text @click="[addCalendar = !addCalendar, selectedCalendar = {}]"-->
<!--                   color="primary" v-if="$store.getters.userHasFeatureAccessLevel('USERS', 'EDIT')">-->
<!--              <v-icon class="mr-3">edit</v-icon>-->
<!--              Change Org Calendar(s)-->
<!--            </v-btn>-->
          </v-toolbar-items>
        </v-toolbar>
        <v-card class="square-card text-left pa-5 elevation-1">
          <SpinnerInline v-if="calendarAccessLoading" :size="50" :spinner-color="`primary`" :transparent="true" :centered="true"/>
          <div v-else>
            <v-autocomplete v-model="userOrgCalendars"
                            v-if="!userHasFullAccess"
                            :items="orgCalendars"
                            label="Selected Org Calendar(s)"
                            item-text="orgName"
                            item-value="orgId"
                            return-object
                            multiple
                            autocomplete="off"
                            attach
            />
            <v-checkbox
              class="pt-2 mb-4"
              v-model="userHasFullAccess"
              label="Grant User Access to All Calendars"
            />
            <v-btn text color="primary" @click="[addCalendar = !addCalendar]">Cancel</v-btn>
            <v-btn color="primary"
                   :disabled="!userHasFullAccess && userOrgCalendars.length === 0"
                   @click="[addCalendar = !addCalendar, saveUserOrgCalendars()]">Save</v-btn>
          </div>
        </v-card>
        <v-data-table
          v-if="false"
          :headers="headers"
          :items="filterUserOrgAccess()"
          :fixed-header="true"
          :items-per-page="-1"
          hide-default-footer
          disable-sort
          class="elevation-1 mt-1"
        >
          <template #no-data>
            <span class="default-text-color">No available calendars</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available calendars</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{ 'shaded-row': index % 2 }">
              <td class="text-left">{{ item.orgName }}</td>
<!--              <td class="text-right">-->
<!--                <v-btn small text color="primary" class="clickable" @click="[showDeleteDialog=true, itemToDelete=item]"><v-icon>delete</v-icon></v-btn>-->
<!--              </td>-->
            </tr>
          </template>

        </v-data-table>
      </v-col>
    </v-row>
<!--    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteOrgCalendarFromUser(itemToDelete)" @close-dialog="closeDeleteDialog">-->
<!--      Are you sure you want to delete <strong>{{itemToDeleteOrgName}}</strong> from this user?-->
<!--    </ConfirmationDialog>-->
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
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import SpinnerInline from '@/components/SpinnerInline'

  export default {
    name: 'UserAccess',
    components: {
      ConfirmationDialog,
      SpinnerInline,
      AccessControl
    },
    computed: {
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
        calendarAccessLoading: true,
        userHasFullAccess: false,
        userAccessLoaded: false,
        userCompanyFeatures: [],
        headers: [
          { text: 'Calendar', value: 'calendar', show: true },
          { text: '', value: 'icons', show: true },
        ],
        accessControlKey: 0,
        showDeleteDialog: false,
        itemToDelete: null,
        navigationOverride: false,
        toPath: null,
        dirtyFields: false,
        unsavedFieldsModal: false
      }
    },
    created () {
      this.getUserCompanyFeatures()
      this.getUserOrgAccessLevel()
      this.getAllOrgCalendars()
    },
    beforeRouteLeave(to, from, next) {
      // called when the route that renders this component is about to
      // be navigated away from.
      // has access to `this` component instance.
      if (this.navigationOverride || !this.dirtyFields) {
        //navigationOverride gets set to true if they click "Yes" to continue. if you don't override then it just hits the else again before navigating
        next()
      } else {
        this.toPath = to.path
        this.unsavedFieldsModal = true
      }
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
      async getUserOrgAccessLevel() {
        try {
          const {data, status} = await getRequest(`/org/user/${this.userId}/calendar/access`)
          this.userHasFullAccess = data
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Access Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async getAllOrgCalendars() {
        try {
          const {data, status} = await getRequestWithParams(`/org/getSchedulingOrgs`, {
            params: {
              isSchedulingTool: true
            }
          })
          this.orgCalendars = data
          this.orgCalendars.forEach(o => {
            o.orgId = o.id
          })
          await this.getUserOrgCalendars()
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Calendars')
        }
      },
      async getUserOrgCalendars() {
        try {
          const {data, status} = await getRequest(`/org/user/${this.userId}/calendars`)
          this.userOrgCalendars = data
          this.calendarAccessLoading = false
          //
          // this.userOrgCalendars.forEach((uoc, idx) => {
          //   this.userOrgCalendars[idx] = this.orgCalendars.find(oc => oc.id === uoc.orgId)
          // })

        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Org Calendars')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        }
      },
      async saveUserOrgCalendars() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: this.userId,
            userOrgAccess: this.userOrgCalendars || [],
            fullCalendarAccess: this.userHasFullAccess
          }
          const {data, status} = await postRequest(`/org/user/calendar`, params)
          // this.userOrgCalendars.push(data)
          //todo: update the save here
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
        this.closeDeleteDialog()
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
          this.dirtyFields = false
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
      closeDeleteDialog() {
        this.showDeleteDialog = false
        this.itemToDelete = null
      },
      setFieldsDirty() {
        this.dirtyFields = true;
      },
      goToPath(path, targetBlank) {
        if (targetBlank) {
          let routerData = this.$router.resolve({path})
          window.open(routerData.href, '_blank')
        } else {
          this.$router.push(path)
        }
      }
    }
  }
</script>
