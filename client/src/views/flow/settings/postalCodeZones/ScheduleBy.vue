<template>
  <v-container class="pa-0" id="schedule-by-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule By
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="userCanAdd" @click="[addScheduler = !addScheduler, selectedScheduler = {}, getSchedulers()]">
              <v-icon v-if="addScheduler">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addScheduler" class="square-card text-left pa-5">
          <v-autocomplete v-model="selectedScheduler"
                    :items="schedulers"
                    label="Select a User..."
                    :loading="schedulersLoading"
                    item-text="fullName"
                    item-value="userId"
                    return-object
                          autocomplete="off"
                          attach>
          </v-autocomplete>
          <v-btn color="primary" class="mr-3 white--text" @click="addUserToZone(selectedScheduler)"
                 :disabled="!selectedScheduler.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addScheduler"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="schedulerSearch"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table
          :headers="schedulerHeaders"
          :items="filterSchedulers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="schedulerSearch"
          :loading="schedulersLoading"
          class="elevation-0"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fullName}}</td>
              <td>
                <v-btn v-if="userCanEdit" text color="primary" @click="userToDelete = item"><v-icon>delete</v-icon></v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="!!userToDelete" @confirm="deleteUserFromZone" @close-dialog="userToDelete = null">
      Are you sure you want to remove this user: <strong>{{ userToDeleteName }}</strong>?
    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";

  export default {
    name: 'ScheduleBy',
    components: {ConfirmationDialog},
    data() {
      return {
        snackbar: {},
        scheduleByUsers: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
        //per carlin 10-31-22 - users with edit should be able to delete users from a RR
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
        zoneId: this.$route.params.id,
        dataLoading: true,
        selectedScheduler: {},
        schedulers: [],
        schedulersLoading: false,
        addScheduler: false,
        schedulerSearch: '',
        schedulerHeaders: [
          {text: 'Name', value: 'fullName', show: true},
          {text: '', value: 'icons', show: true},
        ],
        userToDelete: null
      }
    },
    computed: {
      userToDeleteName(){
        return this.userToDelete ? this.userToDelete.fullName : ''
      }
    },
    created () {
      this.getScheduleByUsers()
    },
    methods: {
      filterSchedulers () {
        return this.scheduleByUsers?.filter(pczu => { return !pczu.archived})
      },
      async getScheduleByUsers () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/postalCode/zone/${this.zoneId}/scheduleBy`)
          this.scheduleByUsers = data
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUserFromZone () {
        const user = this.userToDelete
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/postalCode/zone/user/${user.id}`)
          user.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addUserToZone (selected) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            postalCodeZoneId: this.zoneId,
            userId: selected.id,
          }
          const {data, status} = await postRequest(`/postalCode/zone/saveScheduleByUser`, params)
          this.scheduleByUsers.push(data)
          this.addScheduler = false
          this.selectedScheduler = {}
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getSchedulers() {
        if (this.addScheduler) {
          this.schedulersLoading = true
          try {
            const {data} = await getRequest(`/postalCode/zone/${this.zoneId}/schedulers`)
            this.schedulers = data
            this.schedulersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Loading Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          }
        }
      },
    }
  }
</script>

<style lang="scss">
  #schedule-by-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
</style>
