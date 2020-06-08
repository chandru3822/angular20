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
                        label="DTF"
                        v-model="zone.distributionTimeFrameDays">
          </v-text-field>
          <v-btn text color="primaryCustom" @click="saveZoneInfo()">
            <v-icon>save</v-icon>
          </v-btn>
        </div>
        <div v-else>
          {{zone.zoneName}}
          <v-tooltip top>
            <template v-slot:activator="{ on }">
              <div class="dtf" v-on="on">
                DTF: {{zone.distributionTimeFrameDays}} days
              </div>
            </template>
            <span>Distribution Time Frame</span>
          </v-tooltip>

        </div>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <v-btn text @click="editZone = !editZone">
          <v-icon>edit</v-icon>
        </v-btn>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Users
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addUser = !addUser, selectedUser = {}, getUsers()]">
              <v-icon v-if="addUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left pa-5">
          <v-select v-model="selectedUser.id"
                    :items="users"
                    label="Select a User..."
                    :loading="usersLoading"
                    item-text="fullName"
                    item-value="id"
                    autocomplete="off">
          </v-select>
          <v-text-field type="number" v-model="selectedUser.allocation"></v-text-field>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToZone()"
                 :disabled="!selectedUser.id || !selectedUser.allocation">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
          :headers="userHeaders"
          :items="filterPostalCodeZoneUsers()"
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

          <template #header.icons="{ props: {} }">
            <th v-if="allocationChangesMade">
              <v-btn small dark color="primaryCustom" class="white--text" @click="saveAllocationChanges()">Save</v-btn>
            </th>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.fullName}}</td>
              <td class="text-left">
                <v-text-field type="number" v-model="item.allocation" @input="[allocationChangesMade = true, item.dirty = true]"></v-text-field>
              </td>
              <td>
                <v-dialog v-model="item.deleteConfirm" width="500">
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
                        color="primary"
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
            <v-btn text @click="[addCode = !addCode, newCode = '']">
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
                <v-dialog v-model="item.deleteConfirm" width="500">
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
                        color="primary"
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
    <Snackbar :snackbar="snackbar"></Snackbar>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import Snackbar from '@/components/Snackbar.vue'
  import {getRequest, deleteRequest, putRequest, getRequestWithParams, postRequest, getSnackbar} from '@/helpers/helpers'

  export default {
    name: 'PostalCode',
    components: {
      Snackbar
    },
    data() {
      return {
        snackbar: {},
        selectedUser: {},
        editZone: false,
        allocationChangesMade: false,
        zone: {},
        users: [],
        zoneId: this.$route.params.id,
        dataLoading: true,
        usersLoading: false,
        addUser: false,
        userHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Allocation', value: 'allocation', show: true},
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
      filterPostalCodeZoneUsers () {
        return this.zone.postalCodeZoneUsers?.length ? this.zone.postalCodeZoneUsers.filter(pczu => { return !pczu.archived}) : []
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Zone Name')
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
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addUserToZone () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            postalCodeZoneId: this.zoneId,
            userId: this.selectedUser.id,
            allocation: this.selectedUser.allocation,
          }
          const {data} = await postRequest(`/postalCode/zone/saveUser`, params)
          this.zone.postalCodeZoneUsers.push(data)
          this.addUser = false
          this.selectedUser = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveAllocationChanges () {
        let dirtyUsers = []
        this.zone.postalCodeZoneUsers?.forEach(u => {
          if(u.dirty && !u.archived) {
            dirtyUsers.push(u)
            //reset dirty for future saves
            u.dirty = false
          }
        })

        if(dirtyUsers.length > 0) {
          try {
            await postRequest(`/postalCode/zone/saveAllocations`, dirtyUsers)
            this.allocationChangesMade = false
            this.snackbar = getSnackbar('SUCCESS', 'Allocations Saved')
            this.$store.commit(AppMutations.SET_LOADING, false)
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Saving User Allocations')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
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

