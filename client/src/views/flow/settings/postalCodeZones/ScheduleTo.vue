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
                          autocomplete="off"
                          attach>
          </v-autocomplete>
          <v-autocomplete v-model="newUserCompanyTimezoneId"
                          :items="companyTimezones"
                          label="Time Zone"
                          v-if="zone.remote"
                          item-text="timezone"
                          item-value="id"
                          attach
          ></v-autocomplete>
          <v-btn color="primaryCustom" class="mr-3 mt-5 white--text" @click="addUserToZone(selectedUser)"
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
          :headers="filterHeaders"
          :items="filterUsers()"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          single-expand
          :expanded.sync="expanded"
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
              <td class="text-left">{{ item.fullName }}</td>
              <td class="text-left timezone-column" v-if="zone.remote">
                <span v-if="!item.edit">{{item.timezone || '--'}}</span>
                <v-autocomplete v-if="item.edit"
                                v-model="item.companyTimezoneId"
                                :items="companyTimezones"
                                label="Time Zone"
                                style="width: 200px;"
                                item-text="timezone"
                                item-value="id"
                                hide-details
                                attach
                ></v-autocomplete>
                <v-btn class="d-inline-block" x-small text @click="item.edit = !item.edit">
                  <v-icon size="18" v-if="!item.edit">edit</v-icon>
                  <v-icon size="18" v-else>close</v-icon>
                </v-btn>
                <v-btn class="d-inline-block" x-small text v-if="item.edit" @click="saveUserTimezone(item)">
                  <v-icon size="18">save</v-icon>
                </v-btn>
              </td>
              <td class="text-left">
                <v-tooltip top>
                  <template v-slot:activator="{ on }">
                    <span v-on="on">
                      {{ item.prescribedAllocation | percent(1) }}
                    </span>
                  </template>
                  <span>{{ getAllocationValue(item.prescribedAllocation) }}</span>
                </v-tooltip>

              </td>
              <td class="text-left">
                <input type="checkbox" v-if="item.manualAllocationWhole || item.manualAllocationWhole === 0" checked
                       disabled readonly>
                <input type="checkbox" v-else disabled readonly>
                <v-text-field text
                              type="number"
                              solo
                              single-line
                              dense
                              hide-details
                              :disabled="!userCanEdit"
                              :readonly="!userCanEdit"
                              @input="[item.dirty = true, valuesUpdated = true, getTotalManualAllocation()]"
                              class="ml-2 allocation-input d-inline-block"
                              v-model.number="item.manualAllocationWhole"></v-text-field>
                <span class="ml-2">%</span>
              </td>
              <td class="text-left">
                <v-tooltip top v-if="item.targetLeadAllocation || item.targetLeadAllocation === 0">
                  <template v-slot:activator="{ on }">
                    <span v-on="on">
                      {{ item.targetLeadAllocation | percent(1) }}
                    </span>
                  </template>
                  <span>{{ getAllocationValue(item.targetLeadAllocation) }}</span>
                </v-tooltip>
                <span v-else>--</span>
              </td>
              <td class="text-right">
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

          <template v-slot:body.append="{headers}">
            <tr>
              <td v-for="(header,i) in headers" :key="i" class="font-weight-bold">

                <div v-if="header.value === 'manuallySetAllocation'">
                  Total Manual: {{ totalManualAllocation }}%
                  <div v-if="totalManualAllocation > 100" class="error-text">
                    * ERROR: Total Cannot Exceed 100
                  </div>
                </div>

                <div v-if="is7oaksAdmin && header.value === 'prescribedAllocation'">
                  {{ totalPrescribedAllocation }}
                </div>

                <div v-if="is7oaksAdmin && header.value === 'targetLeadAllocation'">
                  {{ totalTargetLeadAllocation }}
                </div>

                <div v-if="header.value === 'icons'">
                  <v-btn @click="saveAllocationChanges"
                         color="primaryCustom"
                         :class="{'white--text': userCanEdit && totalManualAllocation <= 100 && valuesUpdated}"
                         :disabled="!userCanEdit || totalManualAllocation > 100 || !valuesUpdated">
                    Save Changes
                  </v-btn>
                </div>

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
import {handleHidingGlobalLoader, getRequest, putRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
import sumBy from "lodash.sumby"

export default {
  name: 'ScheduleTo',

  data() {
    return {
      snackbar: {},
      scheduleToUsers: [],
      is7oaksAdmin: this.$store.getters.isFullAdmin || this.$store.state.user.details.id === 2350555,
      userCanAdd: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'ADD'),
      userCanEdit: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'EDIT'),
      userCanDelete: this.$store.getters.userHasFeatureAccessLevel('ROUND_ROBIN', 'DELETE'),
      zoneId: this.$route.params.id,
      dataLoading: true,
      selectedUser: {},
      users: [],
      usersLoading: false,
      valuesUpdated: false,
      addUser: false,
      search: '',
      expanded: [],
      newUserCompanyTimezoneId: null,
      selectedIndex: null,
      totalManualAllocation: null,
      totalTargetLeadAllocation: null,
      totalPrescribedAllocation: null,
      zone: {},
      userHeaders: [],
      companyTimezones: [],
    }
  },
  async created() {
    //had to add this to determine if zone is remote or not
    this.getScheduleToUsers()
    await this.getZoneDetails()
    this.userHeaders = [
      {text: 'Name', value: 'fullName', show: true},
      {text: 'Timezone', value: 'timezone', show: this.zone.remote, width: 250},
      {text: 'Prescribed Allocation', value: 'prescribedAllocation', show: true},
      {text: 'Manually Set Allocation', value: 'manuallySetAllocation', width: '175px', show: true},
      {text: 'Adjusted Allocation', value: 'targetLeadAllocation', show: true},
      {text: '', value: 'icons', show: true},
    ]
    if (this.zone?.remote) {
      this.getCompanyTimezones()
    }
  },
  computed: {
    filterHeaders () {
      return this.userHeaders.filter(header => header.show === true)
    },
  },
  methods: {
    getAllocationValue(value) {
      //4 = leading '0.' + 2 more digits it being a % number (0.0132)
      let valueLength = value.toString().length - 4
      return valueLength <= 0 || value === 0 || value === null ? value : this.$filters.percent(value, valueLength)
    },
    async getCompanyTimezones() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequestWithParams(`/timezone`)
        this.companyTimezones = data
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Timezones')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    filterUsers() {
      return this.scheduleToUsers?.filter(pczu => {
        return !pczu.archived
      })
    },
    getTotalManualAllocation() {
      this.totalManualAllocation = sumBy(this.scheduleToUsers, function (o) {
        return o.manualAllocationWhole ? o.manualAllocationWhole : 0
      })
    },
    getOtherTotals() {
      this.totalPrescribedAllocation = sumBy(this.scheduleToUsers, function (o) {
        return o.prescribedAllocation
      })
      this.totalTargetLeadAllocation = sumBy(this.scheduleToUsers, function (o) {
        return o.targetLeadAllocation
      })
    },
    async getScheduleToUsers() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/postalCode/zone/${this.zoneId}/scheduleTo`)
        this.scheduleToUsers = data
        this.dataLoading = false
        this.getTotalManualAllocation()
        if (this.is7oaksAdmin) {
          this.getOtherTotals()
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveAllocationChanges() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let updatedRows = this.scheduleToUsers.filter(u => u.dirty)
        updatedRows.forEach(r => {
          r.manualAllocation = r.manualAllocationWhole ? r.manualAllocationWhole / 100 : null
        })
        if (updatedRows?.length > 0) {
          const {data, status} = await putRequest(`/postalCode/zone/${this.zoneId}/userAllocation`, updatedRows)
          this.scheduleToUsers = data
          this.getTotalManualAllocation()
          if (this.is7oaksAdmin) {
            this.getOtherTotals()
          }
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Saving Allocation Changes')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async deleteUserFromZone(user) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/postalCode/zone/${this.zoneId}/user/${user.postalCodeZoneUserId}/delete`)
        this.scheduleToUsers = data
        this.getTotalManualAllocation()
        if (this.is7oaksAdmin) {
          this.getOtherTotals()
        }
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Removing User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async addUserToZone(selected) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        let params = {
          postalCodeZoneId: this.zoneId,
          userId: selected.id,
          companyTimezoneId: this.newUserCompanyTimezoneId
        }
        const {data, status} = await postRequest(`/postalCode/zone/${this.zoneId}/saveScheduleToUser`, params)
        this.scheduleToUsers = data
        this.newUserCompanyTimezoneId = null
        this.getTotalManualAllocation()
        if (this.is7oaksAdmin) {
          this.getOtherTotals()
        }
        this.addUser = false
        this.selectedUser = {}
        handleHidingGlobalLoader(this, status)
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
    async getZoneDetails() {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await getRequest(`/postalCode/zone/${this.zoneId}`)
        this.zone = data
        this.dataLoading = false
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Retrieving Data')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
    async saveUserTimezone(user) {
      this.$store.commit(AppMutations.SET_LOADING, true)
      try {
        const {data, status} = await putRequest(`/postalCode/zone/user/${user.postalCodeZoneUserId}`, user)
        user.timezone = data.timezone
        user.edit = false
        this.snackbar = getSnackbar('SUCCESS', 'User Updated')
        handleHidingGlobalLoader(this, status)
      } catch (e) {
        console.error('*** ERROR ***', e)
        this.snackbar = getSnackbar('ERROR', 'Error Updating User')
        this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
        this.$store.commit(AppMutations.SET_LOADING, false)
      }
    },
  }
}
</script>

<style lang="scss">
#schedule-to-container .v-data-table__wrapper {
  height: calc(100vh - 510px);
  min-height: 400px;
}
</style>

<style lang="scss" scoped>
.allocation-input {
  width: 100px;
}
.timezone-column {
  display: flex;
  align-items: center;
}
</style>

