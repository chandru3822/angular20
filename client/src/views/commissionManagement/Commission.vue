<template>
  <v-container class="pa-0" id="commission-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        {{commission.name}}
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="button-container">
          <v-dialog v-if="!commission.approved"
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
                  @click="deleteConfirm = true; deletePlan()">
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
            <v-card v-if="!commission.users || commission.users.length === 0">
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
                    @click="inactivateConfirm = true; inactivatePlan()">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
            <v-card v-else>
              <v-card-title
                  class="headline grey lighten-2"
                  primary-title>
                Error
              </v-card-title>

              <v-card-text class="pt-4">
                You cannot set this plan to inactive with active users.
                <table class="table mt-2">
                  <tr v-for="(u, idx) in commission.users" :key="idx">
                    <td class="pr-3">{{u.name}}</td>
                    <td>{{u.position}}</td>
                  </tr>
                </table>
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                    @click="inactivateConfirm = false">
                  Cancel
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>


          <v-dialog v-if="commission && commission.users && commission.users.filter(u => {return u.endDate == null}).length > 0"
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
                Clone {{commission.name}}
              </v-card-title>

              <v-card-text class="pt-4">
                <div class="mb-2">
                  This option allows you to copy an entire plan over. <br/>
                  By default, no users are copied over.
                </div>
                Users to Copy:
                <div v-for="u in filterBy(commission.users, (u) => { return u.endDate == null })">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}
                </div>
                <div class="mt-3" v-if="commission.users && commission.users.filter(u => u.selected).length > 0">
                  {{cloneStartDate}}
                  <DatetimePickerInput
                    v-model="cloneStartDate"
                    :timezone="this.timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="Start Date"
                  />
                  <div v-if="cloneStartDate">
                    * This will update the end date for all selected users to {{moment(cloneStartDate, 'YYYY-MM-DD').subtract(1, 'd') | formatDate('date') }} on the existing plan.
                  </div>
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
                  :disabled="(commission.users.filter(u => u.selected).length > 0 && !cloneStartDate) ||
                            (commission.users.filter(u => u.selected).length === 0 && cloneStartDate != null)"
                  class="white--text"
                  @click="cloneDialog = false; clonePlan(commission.users, cloneStartDate)"
                >
                  Clone
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
          <v-btn color="primaryCustom" dark v-else @click="clonePlan()">
            Clone
          </v-btn>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider></v-divider>
    <v-form ref="commissionForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="commission.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="commission.description"></v-text-field>
              <v-text-field text
                            label="Position"
                            v-model="commission.positionType"></v-text-field>
              <v-text-field text
                            label="Rate per kW ($)"
                            v-model="commission.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3">
              <v-text-field text
                            label="Status"
                            v-model="commission.statusType"></v-text-field>
              <v-text-field text
                            label="Created By"
                            v-model="commission.createdName"></v-text-field>
              <v-text-field text
                            label="Approved"
                            v-model="commission.approvedDate"></v-text-field>
              <v-text-field text
                            label="Approved By"
                            v-model="commission.approvedName"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row>
      <v-col>
        <v-card class="square-card">
          <v-card-title>
            Source Deductions
          </v-card-title>
        </v-card>
        <v-divider></v-divider>
        <v-data-table
            :headers="sourceHeaders"
            :items="commission.source"
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
              <td class="text-left">{{item.sourceName}}</td>
              <td class="text-left">{{item.feeAmount}}</td>
              <td class="text-left">{{item.feeType}}</td>
              <td class="text-left">{{item.milestoneType}}</td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <v-row>
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Users Assigned to Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="addUser = !addUser">
              <v-icon>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left pa-5">
          <v-autocomplete v-model="newUser.userId"
                          :items="usersToAdd"
                          :loading="usersLoading"
                          prepend-icon="search"
                          :search-input.sync="userSearch"
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
            v-model="newUser.startDate"
            :timezone="this.timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="Start Date"
          />
          <DatetimePickerInput
            v-model="newUser.endDate"
            :timezone="this.timezone"
            :type="'date'"
            :format="'MMMM DD, YYYY'"
            label="End Date"
          />
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToPlan()"
                 :disabled="!newUser.userId || !newUser.startDate">
            Add
          </v-btn>
        </v-card>
        <v-data-table
            :headers="headers"
            :items="commission.users"
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
              <td class="text-left">{{item.position}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
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
    name: 'Commission',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      this.getCommissionDetails()
    },
    watch: {
      $route(to, from) {
        // react to route changes...
        console.log('randaLogger', to)
        console.log('randaLogger', from)
        // this.$router.push({name: 'commission', params: {id: to.params.id}})
        // this.planId = to.params.id
        this.planId = to.params.id
        this.getCommissionDetails()
      },
      userSearch (val) {
        if(!val) {
          return
        }
        this.usersToAdd = []
        this.getUsersToAddDebounced(val)
      }
    },
    data() {
      return {
        snackbar: {},
        cloneDialog: false,
        addUser: false,
        newUser: {},
        usersToAdd: [],
        userSearch: null,
        usersLoading: false,
        moment,
        cloneStartDate: null,
        timezone: this.$store.state.user.details.timezone.value,
        dataLoading: true,
        inactivateConfirm: false,
        deleteConfirm: false,
        planId: this.$route.params.id,
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Position', value: 'Position', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        sourceHeaders: [
          {text: 'Source', value: 'source', show: true},
          {text: 'Fee Amount', value: 'feeAmount', show: true},
          {text: 'Fee Type', value: 'feeType', show: true},
          {text: 'Deduct at Milestone', value: 'deductAtMilestone', show: true},
        ],
        commission: {
          users: []
        }
      }
    },

    methods: {
      async getCommissionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/plan/${this.planId}`, 'blueraven')
          this.commission = data ? data[0] : []
          if([2,3].includes(this.commission.statusId)) {
            this.commission.approved = true
          }
          // temporarily only allowing closers
          this.commission.positionType = 'closers'
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commission Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivatePlan () {
        console.log('INACTIVATE', this.commission)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/commissionManagement/${this.planId}/inactivate`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Commission Plan Inactivated')
          this.$router.push({name: 'commissions'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Inactivating Commission Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/${this.planId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Commission Plan Deleted')
          this.$router.push({name: 'commissions'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Commission Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async clonePlan (users, startDate) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            users: users ? users.filter(u => u.selected).map(u => u.userId) : [],
            startDate: startDate ?? null,
            backdateApprovalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/${this.planId}/clone`, params, 'blueraven')
          console.log('randaLogger cloned Plan', data)
          if(data && data[0] !== null ) {
            this.$router.push({name: 'commission', params: {id: data[0].id}})
          }
          // temporarily only allowing closers
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Cloning Commission')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      getUsersToAddDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getUsersToAdd(val)
        }, 500) /* 500ms throttle */
      },
      async getUsersToAdd(query) {
        console.log('ADD A USER', this.newUser)
        if(this.addUser) {
          this.usersLoading = true
          try {
            let params = {
              positions: 'closers',
              query
            }
            const {data} = await getRequestWithParams(`/commissionManagement/_search`, {params}, 'blueraven')
            this.usersToAdd = data
            this.usersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Commission Plan Users')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addUserToPlan() {
        console.log('ADD A USER', this.newUser)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: this.newUser.userId,
            startDate: this.newUser.startDate,
            endDate: this.newUser.endDate,
            approvalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/${this.planId}/users`, params, 'blueraven')
          this.commission.users = data
          this.snackbar = getSnackbar('SUCCESS', 'Commission Plan User Added')
          this.addUser = false
          this.newUser = {}
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Commission Plan User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      }
    }
  }
</script>

<style lang="scss">
</style>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
.button-container {
  display: flex;
  align-items: center;
}
</style>

