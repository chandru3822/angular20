<template>
  <v-container class="pa-0" id="residualPlan-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="planId">{{residualPlan.name}}</span>
        <span v-else>New Residual Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <v-btn color="primary" class="white--text mr-2"
                 :disabled="!residualPlan.name"
                 @click="savePlan()">
            Save
          </v-btn>
          <v-btn color="green" class="white--text mr-2"
                 v-if="$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN') && planId && residualPlan.statusType === 'PENDING'"
                 :disabled="errorMessages.length > 0"
                 @click="approvePlan()">
            Approve
          </v-btn>
          <v-dialog v-if="planId && !residualPlan.approved"
                    v-model="deleteConfirm"
                    width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Delete
              </v-btn>
            </template>
            <v-card>
              <v-card-title
                class="text-h5 grey lighten-2"
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
                  @click="[deleteConfirm = true, deletePlan()]">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>

          <v-dialog v-else-if="planId"
              v-model="inactivateConfirm"
              width="500">
            <template #activator="{ on }">
              <v-btn color="red" dark class="mr-2" v-on="on">
                Inactivate
              </v-btn>
            </template>
            <v-card v-if="planHasActiveUsers()">
              <v-card-title
                class="text-h5 grey lighten-2"
                primary-title>
                Error
              </v-card-title>

              <v-card-text class="pt-4">
                You cannot set this plan to inactive with active users.
                <table class="table mt-2">
                  <tr v-for="(u, idx) in activeUsers()" :key="idx">
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
            <v-card v-else>
              <v-card-title
                class="text-h5 grey lighten-2"
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
                  @click="[inactivateConfirm = true, inactivatePlan()]">
                  Yes
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>


          <v-dialog v-if="planId && residualPlan && residualPlan.users && residualPlan.users.filter(u => {return u.endDate == null}).length > 0"
            v-model="cloneDialog"
            width="600"
          >
            <template v-slot:activator="{ on }">
              <v-btn color="primary" dark v-on="on" class="mr-2">
                Clone
              </v-btn>
            </template>

            <v-card>
              <v-card-title
                class="text-h5 grey lighten-2"
                primary-title
              >
                Clone {{residualPlan.name}}
              </v-card-title>

              <v-card-text class="pt-4">
                <div class="mb-2">
                  This option allows you to copy an entire plan over. <br/>
                  By default, no users are copied over.
                </div>
                Users to Copy:
                <div v-for="u in filterBy(residualPlan.users, (u) => { return u.endDate == null })">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}: {{u.startDate | formatDate('date')}}
                </div>
                <div class="mt-3" v-if="residualPlan.users && residualPlan.users.filter(u => u.selected).length > 0">
                  <DatetimePickerInput
                    v-model="cloneStartDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="Start Date"
                  />
                  <div v-if="cloneStartDate">
                    * This will update the end date for all selected users to {{moment(cloneStartDate, 'YYYY-MM-DD').subtract(1, 'd') | formatDate('date') }} on their current plan.
                  </div>
                  <div v-if="cloneDateError" class="error--text">
                    You cannot select a start date that is before or equal to any other user's plan start date.
                  </div>
                </div>
              </v-card-text>

              <v-divider></v-divider>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn
                  text
                  @click="[cloneDialog = false, cloneStartDate = null]"
                >
                  Cancel
                </v-btn>
                <v-btn
                  color="primary"
                  :disabled="(residualPlan.users.filter(u => u.selected).length > 0 && !cloneStartDate) ||
                            (residualPlan.users.filter(u => u.selected).length === 0 && cloneStartDate != null)"
                  class="white--text"
                  @click="validateStartDates()">
                  Clone
                </v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-toolbar-items>
    </v-toolbar>
    <v-divider v-if="errorMessages.length > 0"></v-divider>
    <v-row v-if="errorMessages.length > 0">
      <v-col cols="12">
        <v-list v-for="(em, index) in errorMessages" :key="index" class="pa-0" color="transparent">
          <v-list-item>
            <v-list-item-content class="text-left error--text">
              {{em}}
            </v-list-item-content>
          </v-list-item>
        </v-list>
      </v-col>
    </v-row>
    <v-divider></v-divider>
    <v-form ref="residualPlanForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            v-model="residualPlan.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            v-model="residualPlan.description"></v-text-field>
              <v-select attach v-model="residualPlan.positionId"
                        :items="positions"
                        :disabled="true"
                        no-data-text="No Users Available"
                        label="Position"
                        item-text="label"
                        item-value="id"
              ></v-select>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="planId">
              <v-text-field text
                            label="Status"
                            disabled
                            v-model="residualPlan.statusType"></v-text-field>
              <v-text-field text
                            disabled
                            label="Created By"
                            v-model="residualPlan.createdName"></v-text-field>
              <v-text-field text
                            disabled
                            label="Approved"
                            v-if="residualPlan.approvedDate"
                            v-model="residualPlan.approvedDate"></v-text-field>
              <v-text-field text
                            disabled
                            v-if="residualPlan.approvedName"
                            label="Approved By"
                            v-model="residualPlan.approvedName"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Levels
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="residualPlan.statusType === 'PENDING'" @click="[selectedLevel = {}, addLevel = !addLevel]">
              <v-icon v-if="addLevel">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addLevel" class="square-card text-left pa-5">
          <v-text-field text
                        type="text"
                        label="Name"
                        v-model="selectedLevel.name">
          </v-text-field>
          <v-text-field text
                        type="number"
                        label="Level"
                        v-model="selectedLevel.level">
          </v-text-field>
          <v-text-field text
                        type="number"
                        label="# FDC Lower"
                        v-model="selectedLevel.nbrFdcLower">
          </v-text-field>
          <v-text-field text
                        type="number"
                        label="# FDC Upper"
                        v-model="selectedLevel.nbrFdcUpper">
          </v-text-field>
          <v-text-field text
                        type="number"
                        label="Total"
                        v-model="selectedLevel.total">
          </v-text-field>
          <v-btn color="primary" class="mr-3 white--text" @click="addLevelToPlan()"
                 :disabled="!selectedLevel.name || !selectedLevel.level || !selectedLevel.nbrFdcLower || !selectedLevel.nbrFdcUpper || !selectedLevel.total">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addLevel"></v-divider>
        <v-data-table
          :headers="levelHeaders"
          :items="residualPlan.residualPlanAllocations"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          single-expand
          :expanded.sync="levelExpanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available levels
          </template>

          <template #no-results>
            No available levels
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-text-field text
                            type="text"
                            label="Name"
                            v-model="item.name">
              </v-text-field>
              <v-text-field text
                            type="number"
                            label="Level"
                            v-model="item.level">
              </v-text-field>
              <v-text-field text
                            type="number"
                            label="# FDC Lower"
                            v-model="item.nbrFdcLower">
              </v-text-field>
              <v-text-field text
                            type="number"
                            label="# FDC Upper"
                            v-model="item.nbrFdcUpper">
              </v-text-field>
              <v-text-field text
                            type="number"
                            label="Total"
                            v-model="item.total">
              </v-text-field>
              <v-btn :disabled="!item.name || !item.level || !item.nbrFdcLower || !item.nbrFdcUpper || !item.total"
                     @click="[levelExpanded = [], updateLevel(item)]">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.level}}</td>
              <td class="text-left">{{item.nbrFdcLower}}</td>
              <td class="text-left">{{item.nbrFdcUpper}}</td>
              <td class="text-left">{{item.total || 0 | currency('$', 2)}}</td>
              <td>
                <v-btn small text @click="levelExpanded = [item]"
                       v-if="residualPlan.statusType === 'PENDING' && !levelExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="levelExpanded = []"
                       v-if="levelExpanded.includes(item)">cancel
                </v-btn>
                <v-dialog
                  v-if="residualPlan.statusType === 'PENDING'"
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card>
                    <v-card-title class="text-h5 grey lighten-2" primary-title>
                      Confirm
                    </v-card-title>

                    <v-card-text>
                      Are you sure you want to delete this level: <strong>{{ item.name }}</strong>?
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
                        @click="deleteLevel(item.id)">
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
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Users Assigned to Plan
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text @click="[addUser = !addUser, newUser = {}, userHistory = []]">
              <v-icon v-if="addUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addUser" class="square-card text-left px-5 pb-5">
          <v-row>
            <v-col cols="12" md="6">
              <v-autocomplete v-model="newUser.userId"
                              :items="usersToAdd"
                              :loading="usersLoading"
                              prepend-icon="search"
                              cache-items
                              :search-input.sync="userSearch"
                              label="Search for a user..."
                              item-text="name"
                              item-value="userId"
                              autocomplete="off"
                              @input="getUserHistory(newUser.userId)"
                              attach
              >
                <template slot='item' slot-scope='{ item }'>
                  {{ item.name }} - {{ item.position }}
                </template>
              </v-autocomplete>
              <DatetimePickerInput
                v-model="newUser.startDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="Start Date"
                :readonly="!newUser.userId || errorLoadingUserHistory"
                @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
              />
              <DatetimePickerInput
                v-model="newUser.endDate"
                :timezone="timezone"
                :type="'date'"
                :format="'MMMM DD, YYYY'"
                label="End Date"
                :readonly="!newUser.userId || errorLoadingUserHistory"
                @input="checkDates(newUser.startDate, newUser.endDate, userHistory, newUser)"
              />
            </v-col>
            <v-col cols="12" md="6">
              <v-data-table
                :headers="historyHeaders"
                :items="userHistory"
                :fixed-header="true"
                :items-per-page="-1"
                disable-sort
                hide-default-footer
                class="elevation-1"
                v-if="userHistory.length > 0"
              >
              </v-data-table>
              <div v-if="errorLoadingUserHistory" class="error--text">
                We had a problem loading this user's plan history. Cannot add this user until their history can be checked.
              </div>
            </v-col>
          </v-row>

          <div v-if="newUser.dateError" class="error--text mb-2">
            * Error: {{newUser.dateErrorMsg}}
          </div>
          <div class="mb-2" v-else-if="newUser.showNote">
            {{newUser.noteMsg}}
          </div>
          <v-btn color="primary" class="mr-3 white--text" @click="addUserToPlan()"
                 :disabled="newUser.dateError || !newUser.userId || !newUser.startDate || errorLoadingUserHistory">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterResidualPlanUsers()"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="assignedUserExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available users
          </template>

          <template #no-results>
            No available users
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-row>
                <v-col cols="12" md="6">
                  <DatetimePickerInput
                    v-model="item.endDate"
                    :timezone="timezone"
                    :type="'date'"
                    :format="'MMMM DD, YYYY'"
                    label="End Date"
                    :readonly="errorLoadingUserHistory"
                    @input="checkDates(item.startDate, item.endDate, userHistory, item, residualPlan.id)"
                  />
                </v-col>
                <v-col cols="12" md="6">
                  <v-data-table
                    :headers="historyHeaders"
                    :items="userHistory"
                    :fixed-header="true"
                    :items-per-page="-1"
                    hide-default-footer
                    class="elevation-1"
                    v-if="userHistory.length > 0"
                  >
                  </v-data-table>
                  <div v-if="errorLoadingUserHistory" class="error--text">
                    We had a problem loading this user's plan history. Cannot add this user until their history can be checked.
                  </div>
                </v-col>
              </v-row>
              <div v-if="item.dateError" class="error--text mb-2">
                * Error: {{item.dateErrorMsg}}
              </div>
              <div class="mb-2" v-else-if="item.showNote">
                {{item.noteMsg}}
              </div>
              <v-btn color="primary" class="mr-3 white--text" @click="updateAssignedUser(item)"
                     :disabled="item.dateError || !item.userId || !item.startDate || errorLoadingUserHistory">
                Save
              </v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.position}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
              <td>

                <v-btn small text @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                       v-if="residualPlan.statusType === 'PENDING' && !assignedUserExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="assignedUserExpanded = []"
                       v-if="assignedUserExpanded.includes(item)">cancel
                </v-btn>
                <v-dialog
                  v-if="residualPlan.statusType === 'PENDING'"
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
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
                        @click="deleteUserFromPlan(item)">
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
  import Vue2Filters from 'vue2-filters'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import {handleHidingGlobalLoader, getRequest, deleteRequest, putRequest, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'

  export default {
    name: 'ResidualPlan',
    mixins: [Vue2Filters.mixin],
    components: {

      DatetimePickerInput
    },
    created() {
      if(this.planId) {
        this.getResidualPlanDetails()
      } else {
        this.dataLoading = false
      }
    },
    watch: {
      $route(to) {
        // react to route changes...
        this.planId = to.params.id
        this.getResidualPlanDetails()
      },
      userSearch (val) {
        if(!val) {
          this.newUser.userId = null
          this.usersToAdd = []
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
        userHistory: [],
        usersLoading: false,
        levelExpanded: [],
        levelHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Level', value: 'level', show: true},
          {text: '# FDC Lower', value: 'nbrFdcLower', show: true},
          {text: '# FDC Upper', value: 'nbrFdcUpper', show: true},
          {text: 'Total', value: 'total', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addLevel: false,
        selectedLevel: {},
        moment,
        cloneStartDate: null,
        timezone: this.$store.state.user.details.timezone.value,
        dataLoading: true,
        inactivateConfirm: false,
        deleteConfirm: false,
        planId: this.$route.params.id,
        errorLoadingUserHistory: false,
        assignedUserExpanded: [],
        headers: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Position', value: 'Position', show: true},
          {text: 'Employee ID', value: 'employeeId', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
          {text: '', value: 'icons', show: true},
        ],
        historyHeaders: [
          {text: 'Name', value: 'name', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        positions: [
          {id: 1, label: 'Closer'},
          {id: 4, label: 'Setter'}
        ],
        errorMessages: [],
        cloneDateError: false,
        residualPlan: {
          users: [],
          positionId: 1
        }
      }
    },


    methods: {
      async getResidualPlanDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/residuals/plan/${this.planId}`, 'blueraven')
          this.residualPlan = data
          if([2,3].includes(this.residualPlan.statusId)) {
            this.residualPlan.approved = true
          }
          // temporarily only allowing closers
          this.residualPlan.positionType = 'closers'
          this.checkErrorMessages()
          this.dataLoading = false
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Residual Plan Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      validateStartDates() {
        //this is used when cloning users
        this.cloneDateError = false
        this.residualPlan?.users?.forEach(u => {
          if(u.selected && u.startDate >= this.cloneStartDate) {
            this.cloneDateError = true
          }
        })

        if(!this.cloneDateError) {
          this.clonePlan(this.residualPlan.users, this.cloneStartDate)
          this.cloneDialog = false;
        }
      },
      checkDates(startDate, endDate, plans, item, existingId) {
        //item = where to track the error
        item.dateError = false

        if(startDate > endDate) {
          item.dateError = true
          item.dateErrorMsg = 'End Date cannot be before Start Date'
        } else {
          let overlap = []
          let hasActivePlan = false
          plans.forEach(p => {
            if(this.dateRangeOverlap(startDate, endDate, p, existingId)) {
              overlap.push(p)
            }
            // if any plan doesn't have an end date, then there is an active plan
            if(!p.endDate) {
              hasActivePlan = true
            }
          })
          if(overlap.length > 0) {
            item.dateError = true
            item.dateErrorMsg = 'Plans Cannot Overlap'
          } else if(!existingId && startDate && hasActivePlan) {
            item.showNote = true
            item.noteMsg = `The Current plan's end date will be set to ${moment(startDate).subtract(1, 'd').format('MM/DD/YYYY')}.`
          }
        }
      },
      dateRangeOverlap(start, end, plan, existingId) {
        //this will not allow them to go back in time to add plans before existing plans which seems to be ok
        if(plan.id === existingId) {
          // ignore overlap check for self on existing record
          return false
        } else {
          //this is used when adding a new plan
          return start <= plan.startDate || start <= plan.endDate
        }
      },
      checkErrorMessages () {
        this.errorMessages = []
      },
      planHasActiveUsers () {
        let hasActive = false
        this.residualPlan?.users?.forEach(u => {
          if(u.endDate === null || u.endDate > new Date()){
            hasActive = true
          }
        })
        return hasActive
      },
      activeUsers () {
        return this.residualPlan?.users?.filter(u => {
          return u.endDate === null || u.endDate > new Date()
        })
      },
      async savePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            id: this.residualPlan.id,
            name: this.residualPlan.name,
            description: this.residualPlan.description,
            positionId: this.residualPlan.positionId
          }
          const {data, status} = await postRequest(`/commissionManagement/residuals/plan`, params, 'blueraven')
          if(!this.planId) {
            //need to reload some stuff if this was a new plan
            this.$router.push({name: 'residualPlan', params: {id: data.id}})
          }
          this.checkErrorMessages()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Residual Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async approvePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/commissionManagement/residuals/plan/${this.planId}/approve`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Residual Plan Approved')
          this.residualPlan = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Approving Residual Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivatePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/commissionManagement/residuals/${this.planId}/inactivate`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Residual Plan Inactivated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'residualPlans'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Inactivating Residual Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deletePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/residuals/plan/${this.planId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Residual Plan Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'residualPlans'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Residual Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
          const {data} = await postRequest(`/commissionManagement/residuals/plan/${this.planId}/clone`, params, 'blueraven')
          this.$router.push({name: 'residualPlan', params: {id: data.id}})
          // temporarily only allowing closers
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Cloning ResidualPlan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateAssignedUser(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/commissionManagement/residuals/${this.planId}/updateUser`, item, 'blueraven')
          this.assignedUserExpanded = []
          this.userHistory = []
          this.snackbar = getSnackbar('SUCCESS', 'Assigned User Updated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Assigned User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        if(this.addUser) {
          this.usersLoading = true
          try {
            let params = {
              positions: 'closers',
              query,
              planId: this.planId
            }
            const {data} = await getRequestWithParams(`/commissionManagement/_search`, {params}, 'blueraven')
            this.usersToAdd = data
            this.usersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Residual Plan Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async addUserToPlan() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            userId: this.newUser.userId,
            startDate: this.newUser.startDate,
            endDate: this.newUser.endDate,
            approvalCreds: null
          }
          const {data, status} = await postRequest(`/commissionManagement/residuals/${this.planId}/users`, params, 'blueraven')
          this.residualPlan.users = data
          this.snackbar = getSnackbar('SUCCESS', 'Residual Plan User Added')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.addUser = false
          this.newUser = {}
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Residual Plan User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteUserFromPlan(residualPlanUser) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/commissionManagement/residuals/${this.planId}/residualPlanUser/${residualPlanUser.id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Residual Plan User Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          residualPlanUser.archived = true
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Residual Plan User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterResidualPlanUsers () {
        return this.residualPlan.users.filter(cu => { return !cu.archived})
      },
      async getUserHistory(userId) {
        //reset the rest of the new user fields if they change users
        delete this.newUser.startDate
        delete this.newUser.endDate
        this.newUser.dateError = false
        this.newUser.dateErrorMsg = ''
        this.newUser.showNote = false
        this.newUser.noteMsg = ''
        this.errorLoadingUserHistory = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/residuals/residualPlanUser/${userId}/history`, 'blueraven')
          this.userHistory = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          this.errorLoadingUserHistory = true
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User History')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addLevelToPlan() {
        try {
          let params = {
            ...this.selectedLevel
          }
          const {data} = await postRequest(`/commissionManagement/residuals/plan/${this.planId}/allocation`, params, 'blueraven')
          this.residualPlan.residualPlanAllocations.push(data)
          this.selectedLevel = {}
          this.addLevel = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteLevel (residualPlanAllocationId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/commissionManagement/residuals/plan/${this.planId}/allocation/${residualPlanAllocationId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Level Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.residualPlan.residualPlanAllocations = this.residualPlan.residualPlanAllocations.filter(rpa => {
            return rpa.id !== residualPlanAllocationId
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateLevel(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await putRequest(`/commissionManagement/residuals/plan/${this.planId}/allocation`, item, 'blueraven')
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Level')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
    }
  }
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

