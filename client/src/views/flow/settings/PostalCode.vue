<template>
  <v-container class="pa-2" id="postal-code-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <div v-if="editZone">
          <v-text-field text class="d-inline-block mt-4"
                        type="text"
                        label="Name"
                        v-model="zone.zoneName">
          </v-text-field>
          <v-text-field text class="d-inline-block mt-4 ml-3"
                        type="text"
                        label="Distribution Time Frame"
                        v-model="zone.distributionTimeFrameDays">
          </v-text-field>
          <v-btn text color="primaryCustom" @click="saveZoneInfo()">
            <v-icon>save</v-icon>
          </v-btn>
        </div>
        <div v-else>
          {{zone.zoneName}}

          <div class="dtf">
            Distribution Time Frame: {{zone.distributionTimeFrameDays}} days
          </div>


        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text v-if="userCanEdit" @click="editZone = !editZone">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule To
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanEdit" @click="[addUser = !addUser, selectedUser = {}, getUsers()]">
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
                          item-value="userPositionId"
                    return-object
                    autocomplete="off">
          </v-autocomplete>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToZone(selectedUser, true)"
                 :disabled="!selectedUser.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
          :headers="userHeaders"
          :items="filterUsers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fullName}} - {{item.position}}</td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500" v-if="userCanEdit">
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
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Schedule By
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanEdit" @click="[addScheduler = !addScheduler, selectedScheduler = {}, getSchedulers()]">
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
                    item-value="userPositionId"
                    return-object
                          autocomplete="off">
          </v-autocomplete>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToZone(selectedScheduler, false)"
                 :disabled="!selectedScheduler.id">
            Add
          </v-btn>

        </v-card>
        <v-divider v-if="addScheduler"></v-divider>
        <v-data-table
          :headers="schedulerHeaders"
          :items="filterSchedulers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="schedulersLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fullName}} - {{item.position}}</td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500" v-if="userCanEdit">
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
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Postal Codes
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="userCanEdit" @click="[addCode = !addCode, newCode = '']">
              <v-icon v-if="addCode">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addCode" class="square-card text-left pa-5">
          <v-text-field text
                        type="text"
                        label="Postal Code"
                        v-model="newCode">
          </v-text-field>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addCodeToZone()"
                 :disabled="!newCode">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addCode"></v-divider>
        <v-data-table
          :headers="codeHeaders"
          :items="filterPostalCodes()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available postal codes
          </template>

          <template #no-results>
            No available postal codes
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.postalCode}}</td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500" v-if="userCanEdit">
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
                      Are you sure you want to remove this postal code: <strong>{{ item.postalCode }}</strong>?
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
                        @click="deleteCodeFromZone(item)">
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
    name: 'PostalCode',

    data() {
      return {
        snackbar: {},
        editZone: false,
        zone: {},
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('SETTINGS', 'EDIT'),
        zoneId: this.$route.params.id,
        dataLoading: true,
        selectedScheduler: {},
        schedulers: [],
        schedulersLoading: false,
        addScheduler: false,
        schedulerHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: '', value: 'icons', show: true},
        ],
        selectedUser: {},
        users: [],
        usersLoading: false,
        addUser: false,
        userHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addCode: false,
        newCode: '',
        codeHeaders: [
          {text: 'Postal Code', value: 'postalCode', show: true},
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
      filterSchedulers () {
        return this.zone?.scheduleByUsers?.filter(pczu => { return !pczu.archived})
      },
      filterPostalCodes () {
        return this.zone.postalCodes?.length ? this.zone.postalCodes.filter(pc => { return !pc.archived}) : []
      },
      async saveZoneInfo () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/postalCode/zone`, this.zone)
          this.editZone = false
          this.snackbar = getSnackbar('SUCCESS', 'Zone Name Saved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Zone Name')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
      async addUserToZone (selected, scheduleTo) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            postalCodeZoneId: this.zoneId,
            userPositionId: selected.userPositionId,
          }
          let url = scheduleTo ? `/postalCode/zone/saveScheduleToUser` : `/postalCode/zone/saveScheduleByUser`
          const {data} = await postRequest(url, params)
          if(scheduleTo) {
            this.zone.scheduleToUsers.push(data)
          } else {
            this.zone.scheduleByUsers.push(data)
          }
          this.addUser = false
          this.addScheduler = false
          this.selectedUser = {}
          this.selectedScheduler = {}
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
      async deleteCodeFromZone (code) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/postalCode/zone/code/${code.id}`)
          code.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Removing Postal Code')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addCodeToZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            postalCodeZoneId: this.zoneId,
            postalCode: this.newCode
          }
          const {data} = await postRequest(`/postalCode/zone/addCode`, params)
          this.zone.postalCodes.push(data)
          this.addCode = false
          this.newCode = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          let msg = e.data?.message?.includes('Postal Code Already In User') ? e.data.message : 'Error Adding Postal Code'
          this.snackbar = getSnackbar('ERROR', msg)
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
  .dtf {
    font-size: 14px;
  }

</style>

