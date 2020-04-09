<template>
  <v-container class="pa-0" id="commission-container">
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="planId">{{commission.name}}</span>
        <span v-else>New Commission Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <v-btn color="primaryCustom" class="white--text mr-2"
                 :disabled="!commission.name"
                 @click="savePlan()">
            Save
          </v-btn>
          <v-btn color="green" class="white--text mr-2"
                 v-if="planId && commission.statusType === 'PENDING'"
                 :disabled="errorMessages.length > 0"
                 @click="approvePlan()">
            Approve
          </v-btn>
          <v-dialog v-if="planId && !commission.approved"
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
                class="headline grey lighten-2"
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
          </v-dialog>


          <v-dialog v-if="planId && commission && commission.users && commission.users.filter(u => {return u.endDate == null}).length > 0"
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
                    :timezone="timezone"
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
              <v-select v-model="commission.positionId"
                        :items="positions"
                        :disabled="true"
                        no-data-text="No Users Available"
                        label="Position"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            label="Rate per kW ($)"
                            type="number"
                            :disabled="commission.statusType !== 'PENDING'"
                            v-model.number="commission.total"></v-text-field>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="planId">
              <v-text-field text
                            label="Status"
                            disabled
                            v-model="commission.statusType"></v-text-field>
              <v-text-field text
                            disabled
                            label="Created By"
                            v-model="commission.createdName"></v-text-field>
              <v-text-field text
                            disabled
                            label="Approved"
                            v-if="commission.approvedDate"
                            v-model="commission.approvedDate"></v-text-field>
              <v-text-field text
                            disabled
                            v-if="commission.approvedName"
                            label="Approved By"
                            v-model="commission.approvedName"></v-text-field>
            </v-card>
          </v-col>
        </v-row>
      </v-container>
    </v-form>
    <v-row v-if="planId">
      <v-col>
        <v-toolbar flat>
          <v-toolbar-title>
            Milestones
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="commission.statusType === 'PENDING'" @click="selectedMilestone = {}; addMilestone = !addMilestone; getMilestones()">
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
                        label="Milestone Payment $"
                        v-model="selectedMilestone.allocation">
          </v-text-field>
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addMilestoneToPlan()"
                 :disabled="!selectedMilestone.id || !selectedMilestone.allocation">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addMilestone"></v-divider>
        <v-data-table
          :headers="milestoneHeaders"
          :items="commission.milestones"
          :fixed-header="true"
          :items-per-page="-1"
          disable-sort
          :loading="dataLoading"
          single-expand
          :expanded.sync="milestoneExpanded"
          hide-default-footer
          class="elevation-1"
        >
          <template #no-data>
            No available milestones
          </template>

          <template #no-results>
            No available milestones
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-text-field text
                            type="number"
                            label="Milestone Payment $"
                            v-model="item.allocation">
              </v-text-field>
              <v-btn :disabled="!item.allocation"
                     @click="milestoneExpanded = []; updateMilestone(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.milestoneType}}</td>
              <td class="text-left">{{item.allocation}}</td>
              <td>
                <v-btn small text @click="milestoneExpanded = [item]"
                       v-if="commission.statusType === 'PENDING' && !milestoneExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="milestoneExpanded = []"
                       v-if="milestoneExpanded.includes(item)">cancel
                </v-btn>
                <v-dialog
                  v-if="commission.statusType === 'PENDING'"
                  v-model="item.deleteConfirm"
                  width="500">
                  <template v-slot:activator="{ on }">
                    <v-btn text v-on="on">
                      <v-icon>delete</v-icon>
                    </v-btn>
                  </template>
                  <v-card v-if="checkIfMilestoneUsed(item.milestoneId)">
                    <v-card-title class="headline grey lighten-2" primary-title>
                      Error
                    </v-card-title>
                    <v-card-text>
                      Cannot delete milestones that are in use by sources.
                    </v-card-text>
                    <v-divider></v-divider>
                    <v-card-actions>
                      <v-spacer></v-spacer>
                      <v-btn @click="item.deleteConfirm = false">
                        Ok
                      </v-btn>
                    </v-card-actions>
                  </v-card>
                  <v-card v-else>
                    <v-card-title class="headline grey lighten-2" primary-title>
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
                        @click="deleteMilestone(item.commissionPlanAllocationId)">
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
            Source Deductions
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text v-if="commission.statusType === 'PENDING'" @click="selectedSource = {}; addSource = !addSource; getSources()">
              <v-icon v-if="addSource">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addSource" class="square-card text-left pa-5">
          <div v-if="!commission.milestones || commission.milestones.length === 0">
            You must add milestones to this plan first.
          </div>
          <div v-else>
            <v-select v-model="selectedSource.id"
                      :items="sources"
                      label="Select a Source..."
                      item-text="sourceName"
                      item-value="id"
                      autocomplete="off">
            </v-select>
            <v-text-field text
                          label="Fee Amount"
                          v-model="selectedSource.feeAmount"></v-text-field>
            <v-select v-model="selectedSource.feeTypeId"
                      :items="feeTypes"
                      label="Fee Type"
                      item-text="label"
                      item-value="id"
            ></v-select>
            <v-select v-model="selectedSource.milestoneId"
                      :items="commission.milestones"
                      label="Deduct at Milestone"
                      item-text="milestoneType"
                      item-value="milestoneId"
            ></v-select>
            <v-btn color="primaryCustom" class="mr-3 white--text" @click="addSourceToPlan()"
                   :disabled="!selectedSource.id || !selectedSource.feeTypeId || !selectedSource.feeAmount">
              Add
            </v-btn>
          </div>
        </v-card>
        <v-divider v-if="addSource"></v-divider>
        <v-data-table
            :headers="sourceHeaders"
            :items="commission.sources"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            :expanded.sync="sourceExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            No available sources
          </template>

          <template #no-results>
            No available sources
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-text-field text
                            label="Fee Amount"
                            v-model="item.feeAmount"></v-text-field>
              <v-select v-model="item.feeTypeId"
                        :items="feeTypes"
                        label="Fee Type"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-select v-model="item.milestoneId"
                        :items="commission.milestones"
                        label="Deduct at Milestone"
                        item-text="milestoneType"
                        item-value="milestoneId"
              ></v-select>
              <v-btn :disabled="!item.feeAmount || !item.feeTypeId || !item.milestoneId"
                     @click="sourceExpanded = []; updateSource(item)">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.sourceName}}</td>
              <td class="text-left">{{item.feeAmount}}</td>
              <td class="text-left">{{item.feeType}}</td>
              <td class="text-left">{{item.milestoneType}}</td>
              <td>
                <v-btn small text @click="sourceExpanded = [item]"
                       v-if="commission.statusType === 'PENDING' && !sourceExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="sourceExpanded = []"
                       v-if="sourceExpanded.includes(item)">cancel
                </v-btn>
                <v-dialog
                  v-if="commission.statusType === 'PENDING'"
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
                      Are you sure you want to delete this source: <strong>{{ item.sourceName }}</strong>?
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
                        @click="deleteSource(item.id)">
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
            <v-btn text @click="addUser = !addUser; newUser = {}; userHistory = []">
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
          <v-btn color="primaryCustom" class="mr-3 white--text" @click="addUserToPlan()"
                 :disabled="newUser.dateError || !newUser.userId || !newUser.startDate || errorLoadingUserHistory">
            Add
          </v-btn>
        </v-card>
        <v-divider v-if="addUser"></v-divider>
        <v-data-table
            :headers="headers"
            :items="filterCommissionUsers()"
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
                    @input="checkDates(item.startDate, item.endDate, userHistory, item, commission.id)"
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
              <v-btn color="primaryCustom" class="mr-3 white--text" @click="updateAssignedUser(item)"
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

                <v-btn small text @click="assignedUserExpanded = [item]; getUserHistory(item.userId)"
                       v-if="commission.statusType === 'PENDING' && !assignedUserExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="assignedUserExpanded = []"
                       v-if="assignedUserExpanded.includes(item)">cancel
                </v-btn>
                <v-dialog
                  v-if="commission.statusType === 'PENDING'"
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
  import orderBy from "lodash.orderby";

  export default {
    name: 'Commission',
    mixins: [Vue2Filters.mixin],
    components: {
      Snackbar,
      DatetimePickerInput
    },
    created() {
      if(this.planId) {
        this.getCommissionDetails()
      } else {
        this.dataLoading = false
      }
    },
    watch: {
      $route(to, from) {
        // react to route changes...
        this.planId = to.params.id
        this.getCommissionDetails()
      },
      userSearch (val, test, third) {
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
        userHistory: [],
        usersLoading: false,
        moment,
        cloneStartDate: null,
        timezone: this.$store.state.user.details.timezone.value,
        dataLoading: true,
        inactivateConfirm: false,
        deleteConfirm: false,
        planId: this.$route.params.id,
        milestoneExpanded: [],
        sourceExpanded: [],
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
        feeTypes: [
          {id: 1, label: 'Per kW'},
          {id: 2, label: 'Flat'}
        ],
        sourceHeaders: [
          {text: 'Source', value: 'source', show: true},
          {text: 'Fee Amount', value: 'feeAmount', show: true},
          {text: 'Fee Type', value: 'feeType', show: true},
          {text: 'Deduct at Milestone', value: 'deductAtMilestone', show: true},
          {text: '', value: 'icons', show: true},
        ],
        milestoneHeaders: [
          {text: 'Milestone', value: 'milestoneType', show: true},
          {text: 'Milestone Payment ($)', value: 'allocation', show: true},
          {text: '', value: 'icons', show: true},
        ],
        addMilestone: false,
        selectedMilestone: {},
        milestones: [],
        addSource: false,
        selectedSource: {},
        sources: [],
        errorMessages: [],
        commission: {
          users: [],
          positionId: 1
        }
      }
    },


    methods: {
      async getCommissionDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/plan/${this.planId}`, 'blueraven')
          this.commission = data
          if([2,3].includes(this.commission.statusId)) {
            this.commission.approved = true
          }
          // temporarily only allowing closers
          this.commission.positionType = 'closers'
          this.checkErrorMessages()
          this.dataLoading = false
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Commission Details')
          this.$store.commit(AppMutations.SET_LOADING, false)
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
        if(this.commission.total === 0) {
          this.errorMessages.push('The Rate per kW cannot be zero.')
        }
        //sum of m1 and m2 payment = rate per kw
        let sum = this.commission.milestones.reduce((a, b) => a + b.allocation, 0)
        if(sum !== this.commission.total) {
          this.errorMessages.push('The sum of all milestone payment amounts must equal the Rate per kW. ')
        }
      },
      planHasActiveUsers () {
        let hasActive = false
        this.commission?.users?.forEach(u => {
          if(u.endDate === null || u.endDate > new Date()){
            hasActive = true
          }
        })
        return hasActive
      },
      activeUsers () {
        return this.commission?.users?.filter(u => {
          return u.endDate === null || u.endDate > new Date()
        })
      },
      async savePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            id: this.commission.id,
            name: this.commission.name,
            description: this.commission.description,
            positionId: this.commission.positionId,
            total: this.commission.total
          }
          const {data} = await postRequest(`/commissionManagement`, params, 'blueraven')
          if(!this.planId) {
            //need to reload some stuff if this was a new plan
            this.$router.push({name: 'commission', params: {id: data.id}})
          }
          this.checkErrorMessages()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Commission Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async approvePlan () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/commissionManagement/${this.planId}/approve`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Commission Plan Approved')
          this.commission = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Approving Commission Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivatePlan () {
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
      async updateAssignedUser(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await postRequest(`/commissionManagement/${this.planId}/updateUser`, item, 'blueraven')
          this.assignedUserExpanded = []
          this.userHistory = []
          this.snackbar = getSnackbar('SUCCESS', 'Assigned User Updated')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Updating Assigned User')
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
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Commission Plan Users')
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
      },
      async deleteUserFromPlan(commissionPlanUser) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/${this.planId}/commissionUser/${commissionPlanUser.id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Commission Plan User Deleted')
          commissionPlanUser.archived = true
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Commission Plan User')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      filterCommissionUsers () {
        return this.commission.users.filter(cu => { return !cu.archived})
      },
      async getMilestones() {
        if(this.addMilestone) {
          try {
            const {data} = await getRequest(`/commissionManagement/${this.planId}/availableMilestones`, 'blueraven')
            this.milestones = data
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Milestones')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async updateMilestone(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/commissionManagement/${this.planId}/milestone`, item, 'blueraven')
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Milestone')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addMilestoneToPlan() {
        try {
          let params = {
            milestoneTypeId: this.selectedMilestone.id,
            allocation: this.selectedMilestone.allocation
          }
          const {data} = await postRequest(`/commissionManagement/${this.planId}/milestone`, params, 'blueraven')
          this.commission.milestones.push(data)
          this.checkErrorMessages()
          this.selectedMilestone = {}
          this.addMilestone = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Milestone')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteMilestone (commissionPlanAllocationId) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/${this.planId}/milestone/${commissionPlanAllocationId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Milestone Deleted')
          this.commission.milestones = this.commission.milestones.filter(m => {
            return m.commissionPlanAllocationId !== commissionPlanAllocationId
          })
          this.checkErrorMessages()
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Milestone')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      checkIfMilestoneUsed(milestoneId) {
        let used = false
        this.commission.sources.forEach(s => {
          if(s.milestoneId === milestoneId) {
            used = true
          }
        })

        return used

      },
      async getSources() {
        if(this.addSource) {
          try {
            const {data} = await getRequest(`/commissionManagement/${this.planId}/availableSources`, 'blueraven')
            this.sources = data
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Sources')
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async updateSource(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await putRequest(`/commissionManagement/${this.planId}/source`, item, 'blueraven')
          item.milestoneType = data.milestoneType
          item.feeType = data.feeType
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Milestone')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
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
        console.log('randaLogger', userId)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data} = await getRequest(`/commissionManagement/commissionUser/${userId}/history`, 'blueraven')
          this.userHistory = data
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          this.errorLoadingUserHistory = true
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Retrieving User History')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async addSourceToPlan() {
        try {
          let params = {
            sourceId: this.selectedSource.id,
            milestoneId: this.selectedSource.milestoneId,
            feeAmount: this.selectedSource.feeAmount,
            feeTypeId: this.selectedSource.feeTypeId,
          }
          const {data} = await postRequest(`/commissionManagement/${this.planId}/source`, params, 'blueraven')
          this.commission.sources.push(data)
          this.selectedSource = {}
          this.addSource = false
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Adding Source')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async deleteSource (id) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/${this.planId}/source/${id}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Source Deleted')
          this.commission.sources = this.commission.sources.filter(s => {
            return s.id !== id
          })
          this.$store.commit(AppMutations.SET_LOADING, false)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Source')
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

