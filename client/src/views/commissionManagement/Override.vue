<template>
  <v-container class="pa-0" id="override-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="overrideId">{{override.name}}</span>
        <span v-else>New Override Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container" v-if="overrideId">
          <v-dialog v-if="override.status !== 'ACTIVE'"
                    v-model="deleteConfirm"
                    width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Delete
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title>
                Confirm
              </v-card-title>

              <v-card-text class="pt-4">
                Are you sure you want to delete this plan?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  @click="deleteConfirm = false">
                  No
                </v-btn>
                <v-btn
                  color="primary"
                  text
                  @click="deleteConfirm = true; deleteOverride()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-dialog v-else
              v-model="inactivateConfirm"
              width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Inactivate
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                  class="headline grey lighten-2"
                  primary-title>
                Confirm
              </v-card-title>

              <v-card-text class="pt-4">
                Are you sure you want to inactivate this plan?
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                    @click="inactivateConfirm = false">
                  No
                </v-btn>
                <v-btn
                    color="primary"
                    text
                    @click="inactivateConfirm = true; inactivateOverride()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-dialog v-if="override"
                    v-model="cloneDialog"
                    width="600"
          >
            <template v-slot:activator="{ on }">
              <v-btn color="primaryCustom" dark v-on="on">
                Clone
              </v-btn>
            </template>

            <v-card>
              <v-card-title
                class="headline grey lighten-2"
                primary-title
              >
                Clone {{override.name}}
              </v-card-title>

              <v-card-text class="pt-4">
                <div class="mb-2">
                  This option allows you to copy an entire plan over. <br/>
                  By default, no users are copied over.
                </div>
                Users to Copy:
                <div v-for="u in override.receivingUsers">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}
                </div>
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  text
                  @click="cloneDialog = false; cloneStartDate = null"
                >
                  Cancel
                </v-btn>
                <v-btn
                  color="primaryCustom"
                  class="white--text"
                  @click="cloneDialog = false; cloneOverride(override.receivingUsers)"
                >
                  Clone
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-btn color="primaryCustom" dark v-else @click="cloneOverride()">
            Clone
          </v-btn>
        </div>
        <div class="commission-button-container" v-else>
          <v-btn color="primaryCustom" class="white--text"
                 :disabled="!override.name"
                 @click="saveOverride()">
            Save
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>


    <v-divider></v-divider>
    <v-form ref="overrideForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="override.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="override.description"></v-text-field>
              <v-select v-model="override.positionId"
                        :items="positions"
                        :disabled="override.assignedUsers.length > 0"
                        no-data-text="No Users Available"
                        label="Position Type"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Rate per kW ($)"
                            v-model="override.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="overrideId">
              <v-text-field text
                            label="Status"
                            readonly
                            v-model="override.status"></v-text-field>
              <v-text-field text
                            v-if="override.createdBy"
                            readonly
                            label="Created By"
                            v-model="override.createdBy.name"></v-text-field>
              <v-text-field text
                            readonly
                            v-if="override.approved"
                            label="Approved"
                            v-model="override.approved"></v-text-field>
              <v-text-field text
                            readonly
                            label="Approved By"
                            v-if="override.approvedBy"
                            v-model="override.approvedBy.name"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="overrideId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Milestones
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="override.status === 'PENDING'" @click="addMilestone = !addMilestone; getMilestones()">
              <v-icon v-if="addMilestone">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addMilestone" class="square-card text-left pa-5">
          <v-select v-model="selectedMilestone.id"
                          :items="milestones"
                          label="Select a Milestone..."
                          item-text="milestoneType"
                          item-value="id"
                          autocomplete="off">
          </v-select>
          <v-text-field text
                        type="number"
                        label="Milestone Payment %"
                        v-model="selectedMilestone.allocation">
          </v-text-field>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addMilestoneToOverride()"
                 :disabled="!selectedMilestone.id || !selectedMilestone.allocation">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addMilestone"></v-divider>
        <v-data-table
          :headers="milestoneHeaders"
          :items="override.milestones"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available milestones
          </template>

          <template #no-results>
            No available milestones
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.milestoneType}}</td>
              <td class="text-left">{{item.allocation}}</td>
              <td>
                <v-dialog
                  v-if=""
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this milestone: <strong>{{ item.milestoneType }}</strong>?
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
                        @click="deleteMilestone(item.overridePlanAllocationId)">
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
    <v-row v-if="overrideId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Receiving Overrides
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="override.status === 'PENDING'" @click="addReceivingUser = !addReceivingUser">
              <v-icon v-if="addReceivingUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addReceivingUser" class="square-card text-left pa-5">
            <v-autocomplete v-model="newReceivingUser.userId"
                            :items="receivingUsersToAdd"
                            :loading="receivingUsersLoading"
                            prepend-icon="search"
                            :search-input.sync="receivingUserSearch"
                            label="Search for a user..."
                            item-text="name"
                            item-value="userId"
                            autocomplete="off">
            </v-autocomplete>
            <v-text-field text
                          type="number"
                          label="M1 Allocation"
                          v-model="newReceivingUser.m1Allocation">
            </v-text-field>
          <v-text-field text
                        type="number"
                        label="M2 Allocation"
                        v-model="newReceivingUser.m2Allocation">
          </v-text-field>
            <v-btn color="primaryCustom" class="mr-3 white--text" @click="addReceivingUserToOverride()"
                   :disabled="!newReceivingUser.userId">
              Add
            </v-btn>
        </v-card>
        <v-divider v-if="addAssignedUser"></v-divider>
        <v-data-table
            :headers="receivingHeaders"
            :items="override.receivingUsers"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.m1Allocation}}</td>
              <td class="text-left">{{item.m2Allocation}}</td>
              <td>
                <v-dialog
                  v-if=""
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete <strong>{{ item.name }}</strong>?
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
                        @click="deleteReceivingUser(item.userId)">
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
    <v-row v-if="overrideId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Assigned to Override Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="override.status === 'PENDING'" @click="addAssignedUser = !addAssignedUser">
              <v-icon v-if="addAssignedUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addAssignedUser" class="square-card text-left pa-5">
          <div v-if="!override.positionId">
            You must selected a Position Type.
          </div>
          <div v-else>
            <v-autocomplete v-model="newAssignedUser.userId"
                            :items="assignedUsersToAdd"
                            :loading="assignedUsersLoading"
                            prepend-icon="search"
                            :search-input.sync="assignedUserSearch"
                            label="Search for a user..."
                            item-text="name"
                            item-value="userId"
                            autocomplete="off"
            >
              <template slot='item' slot-scope='{ item }'>
                {{ item.name }} - {{ item.position }}
              </template>
            </v-autocomplete>
            <DatetimePickerInput
              v-model="newAssignedUser.startDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="Start Date"
            />
            <DatetimePickerInput
              v-model="newAssignedUser.endDate"
              :timezone="this.timezone"
              :type="'date'"
              :format="'MMMM DD, YYYY'"
              label="End Date"
            />
            <v-btn color="primaryCustom" class="mr-3 white--text" @click="addAssignedUserToOverride()"
                   :disabled="!newAssignedUser.userId || !newAssignedUser.startDate">
              Add
            </v-btn>
          </div>
        </v-card>
        <v-divider v-if="addAssignedUser"></v-divider>
        <v-data-table
            :headers="headers"
            :items="override.assignedUsers"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
              <td>
                <v-dialog
                  v-if=""
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title
                      class="headline grey lighten-2"
                      primary-title
                    >
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete <strong>{{ item.name }}</strong>?
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
                        @click="deleteAssignedUser(item.id)">
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
  import Vue2Filters from 'vue2-filters'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {getRequest, deleteRequest, putRequest, postRequest, getSnackbar} from '@/helpers/helpers'
  import {getRequestWithParams} from "../../helpers/helpers";

  export default {
    name: 'Override',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      if(this.overrideId) {
        this.getOverrideDetails()
      } else {
        this.dataLoading = false
      }
    },
    watch: {
      $route(to, from) {
        // react to route changes...
        // this.$router.push({name: 'commission', params: {id: to.params.id}})
        // this.planId = to.params.id
        this.overrideId = to.params.id
        this.getOverrideDetails()
      },
      assignedUserSearch (val) {
        if(!val) {
          return
        }
        this.assignedUsersToAdd = []
        this.getAssignedUsersDebounced(val)
      },
      receivingUserSearch (val) {
        if(!val) {
          return
        }
        this.receivingUsersToAdd = []
        this.getReceivingUsersDebounced(val)
      }
    },
    data() {
      return {
        snackbar: {},
        dataLoading: true,
        cloneDialog: false,
        moment,
        cloneStartDate: null,
        timezone: this.$store.state.user.details.timezone.value,
        inactivateConfirm: false,
        deleteConfirm: false,
        overrideId: this.$route.params.id,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: '', value: 'icons', show: true},
        ],
        receivingHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'M1 Allocation', value: 'm1Allocation', show: true},
          {text: 'M2 Allocation', value: 'm2Allocation', show: true},
          {text: '', value: 'icons', show: true},
        ],
        milestoneHeaders: [
          {text: 'Milestone', value: 'milestoneType', show: true},
          {text: 'Milestone Payment %', value: 'allocation', show: true},
          {text: '', value: 'icons', show: true},
        ],
        override: {
          approvedBy: {},
          createdBy: {},
          assignedUsers: []
        },
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ],
        addAssignedUser: false,
        assignedUsersLoading: false,
        newAssignedUser: {},
        assignedUsersToAdd: [],
        assignedUserSearch: null,
        addMilestone: false,
        selectedMilestone: {},
        milestones: [],
        addReceivingUser: false,
        receivingUsersLoading: false,
        newReceivingUser: {
          m1Allocation: 0,
          m2Allocation: 0,
        },
        receivingUsersToAdd: [],
        receivingUserSearch: null,
      }
    },
    methods: {
      async getOverrideDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.override = data
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      goToDetails (item) {
        console.log('handle going to item', item)
      },
      async deleteOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Deleted')
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async cloneOverride (users) {
        console.log('CLONE', this.override)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            receivingUsers: users ? users.filter(u => u.selected).map(u => u.userId) : [],
            assignedUsers: [],
            backdateApprovalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/clone`, params, 'blueraven')
          console.log('randaLogger cloned Plan', data)
          this.$router.push({name: 'override', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Cloning Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async saveOverride () {
        console.log('SAVE', this.override)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            name: this.override.name,
            description: this.override.description,
            positionId: this.override.positionId,
            total: this.override.total
          }
          const {data} = await postRequest(`/commissionManagement/overrides`, params, 'blueraven')
          console.log('randaLogger added Plan', data)
          this.$router.push({name: 'override', params: {id: data.id}})
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivateOverride () {
        console.log('INACTIVATE', this.override)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/commissionManagement/overrides/${this.override}/inactivate`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Inactivated')
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Inactivating Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getAssignedUsersDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getAssignedUsers(val)
        }, 500) /* 500ms throttle */
      },
      async getAssignedUsers(query) {
        console.log('ADD A USER', this.newAssignedUser)
        if(this.addAssignedUser) {
          this.assignedUsersLoading = true
          try {
            let params = {
              positionId: this.override.positionId,
              query
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            this.assignedUsersToAdd = data
            this.assignedUsersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Override Plan Users')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addAssignedUserToOverride() {
        if(this.addAssignedUser) {
          try {
            let params = {
              userId: this.newAssignedUser.userId,
              startDate: this.newAssignedUser.startDate,
              endDate: this.newAssignedUser.endDate
            }
            const {data} = await postRequest(`/commissionManagement/overrides/${this.override.id}/assignedUsers`, params, 'blueraven')
            this.override.assignedUsers.push(data)
            this.newAssignedUser = {}
            this.assignedUserSearch = null
            this.addAssignedUser = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Assigning User')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async deleteAssignedUser (assignedUserId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}/assignedUsers/${assignedUserId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Assigned User Deleted')
          this.override.assignedUsers = this.override.assignedUsers.filter(au => {
            return au.id !== assignedUserId
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Assigned User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getReceivingUsersDebounced(val) {
        clearTimeout(this._searchReceivingTimerId)
        this._searchReceivingTimerId = setTimeout(() => {
          this.getReceivingUsers(val)
        }, 500) /* 500ms throttle */
      },
      async getReceivingUsers(query) {
        console.log('ADD A USER', this.newReceivingUser)
        if(this.addReceivingUser) {
          this.receivingUsersLoading = true
          try {
            let params = {
              query
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            this.receivingUsersToAdd = data
            this.receivingUsersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Receiving Override Users')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addReceivingUserToOverride() {
        if(this.addReceivingUser) {
          try {
            let params = {
              userId: this.newReceivingUser.userId,
              m1Allocation: this.newReceivingUser.m1Allocation,
              m2Allocation: this.newReceivingUser.m2Allocation
            }
            const {data} = await postRequest(`/commissionManagement/overrides/${this.override.id}/receivingUsers`, params, 'blueraven')
            this.override.receivingUsers.push(data)
            this.newReceivingUser = {
              m1Allocation: 0,
              m2Allocation: 0
            }
            this.receivingUserSearch = null
            this.addReceivingUser = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Adding Receiving User')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async deleteReceivingUser (receivingUserId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}/receivingUsers/${receivingUserId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Receiving User Deleted')
          this.override.receivingUsers = this.override.receivingUsers.filter(au => {
            return au.userId !== receivingUserId
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Receiving User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getMilestones() {
        if(this.addMilestone) {
          try {
            const {data} = await getRequest(`/commissionManagement/milestones`, 'blueraven')
            this.milestones = data
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Milestones')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addMilestoneToOverride() {
          try {
            let params = {
              milestoneTypeId: this.selectedMilestone.id,
              allocation: this.selectedMilestone.allocation
            }
            const {data} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/milestone`, params, 'blueraven')
            console.log('randaLogger', data)
            this.selectedMilestone = {}
            this.addMilestone = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Adding Milestone')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
      },
      async deleteMilestone (overridePlanAllocationId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}/milestone/${overridePlanAllocationId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Milestone Deleted')
          this.override.milestones = this.override.milestones.filter(m => {
            return m.overridePlanAllocationId !== overridePlanAllocationId
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Milestone')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

