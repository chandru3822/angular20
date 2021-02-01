<template>
  <v-container class="pa-0" id="schedule-to-container">
    <v-row>
      <v-col class="pt-0">
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule To
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanAdd" @click="[addUser = !addUser, selectedUser = {}, getUsers()]">
              <v-icon v-if="addUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left pa-5">
          <v-autocomplete v-model="selectedUser"
                    :items="users"
                    label="Select a User..."
                    :loading="usersLoading"
                    item-text="fullName"
                    item-value="userId"
                    return-object
                    autocomplete="off">
          </v-autocomplete>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToZone(selectedUser)"
                 :disabled="!selectedUser.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-card-title class="pt-0">
          <v-text-field
            v-model="search"
            prepend-inner-icon="search"
            label="Search"
            single-line
            hide-details
          ></v-text-field>
        </v-card-title>
        <v-divider></v-divider>
        <v-data-table
          :headers="userHeaders"
          :items="filterUsers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :search="search"
          :loading="dataLoading"
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
    name: 'ScheduleTo',

    data() {
      return {
        snackbar: {},
        zone: {},
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
        userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
        zoneId: this.$route.params.id,
        dataLoading: true,
        selectedUser: {},
        users: [],
        usersLoading: false,
        addUser: false,
        search: '',
        userHeaders: [
          {text: 'Name', value: 'fullName', show: true},
          {text: '', value: 'icons', show: true},
        ],
      }
    },
    created () {
      this.getZoneDetails()
    },
    methods: {
      filterUsers () {
        return this.zone?.scheduleToUsers?.filter(pczu => { return !pczu.archived})
      },
      async getZoneDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/postalCode/zone/${this.zoneId}`)
          this.zone = data
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
          const {data} = await postRequest(`/postalCode/zone/saveScheduleToUser`, params)
          this.zone.scheduleToUsers.push(data)
          this.addUser = false
          this.selectedUser = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUsers() {
        if (this.addUser) {
          this.usersLoading = true
          try {
            const {data} = await getRequest(`/postalCode/zone/${this.zoneId}/users`)
            this.users = data
            this.usersLoading = false
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
  #schedule-to-container .v-data-table__wrapper {
    max-height: calc(100vh - 410px);
    min-height: 300px;
  }
</style>

<style lang="scss" scoped>

</style>

