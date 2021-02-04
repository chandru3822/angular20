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
            <v-btn text v-if="userCanAdd" @click="[addScheduler = !addScheduler, selectedScheduler = {}, getSchedulers()]">
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
                          autocomplete="off">
          </v-autocomplete>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToZone(selectedScheduler)"
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
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fullName}}</td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500" v-if="userCanDelete">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title class="headline grey lighten-2" primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to remove this user: <strong>{{ item.fullName }}</strong>?
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
                        @click="deleteUserFromZone(item)">
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
  import {getRequest, deleteRequest, putRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'ScheduleBy',

    data() {
      return {
        snackbar: {},
        scheduleByUsers: [],
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
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
          const {data} = await getRequest(`/postalCode/zone/${this.zoneId}/scheduleBy`)
          this.scheduleByUsers = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUserFromZone (user) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/postalCode/zone/user/${user.id}`)
          user.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
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
          const {data} = await postRequest(`/postalCode/zone/saveScheduleByUser`, params)
          this.scheduleByUsers.push(data)
          this.addScheduler = false
          this.selectedScheduler = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
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

<style lang="scss" scoped>


</style>

