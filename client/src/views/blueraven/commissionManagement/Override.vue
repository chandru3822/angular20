<template>
  <v-container class="pa-0" id="override-container">
    <v-dialog :width="600" v-model="showProjectAssignmentModal">
      <ProjectAssignmentModal @cancel="showProjectAssignmentModal = false"
                              :plan-id="parseInt(overrideId)"
                              :override="true"
                              :plan-name="override.name"></ProjectAssignmentModal>
    </v-dialog>
    <v-toolbar flat color="transparent">
      <v-toolbar-title>
        <span v-if="overrideId">{{override.name}}</span>
        <span v-else>New Override Plan</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-toolbar-items>
        <div class="commission-button-container">
          <v-btn color="primary" class="white--text mr-2"
                 v-if="userIsAdmin && overrideId"
                 @click="showProjectAssignmentModal = true">
            Admin
          </v-btn>
          <v-btn color="primary" class="white--text mr-2"
                 :disabled="!override.name || !override.positionId || !override.total"
                 v-if="userCanEdit"
                 @click="saveOverride()">
            Save
          </v-btn>
          <v-btn color="success" class="white--text mr-2"
                 v-if="$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN') && overrideId && override.status === 'PENDING'"
                 :disabled="errorMessages.length > 0"
                 @click="approveOverride()">
            Approve
          </v-btn><v-btn color="error" class="white--text mr-2"
                 v-if="overrideId && override.status !== 'ACTIVE' && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')"
                 :disabled="errorMessages.length > 0"
                 @click="openDeleteDialog(override, deleteTypes.OVERRIDE)">
            Delete
          </v-btn>
          <v-btn color="error" class="mr-2" v-else-if="overrideId && $store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'DELETE')" @click="inactivateConfirm=true">
            Inactivate
          </v-btn>
          <MultiOptionDialog
              :open-dialog="inactivateConfirm"
              :options="inactivateOptions"
              @cancel="inactivateConfirm=false"
              @option-0="[inactivateConfirm = true, inactivateOverride()]"
          >
            <template v-slot:title>
              <span v-if="planHasActiveUsers()">Error</span>
              <span v-else>Confirm</span>
            </template>
            <div v-if="planHasActiveUsers()">
              You cannot set this plan to inactive with active users.
              <table class="table mt-2">
                <tr v-for="(u, idx) in activeUsers()" :key="idx">
                  <td class="pr-3">{{u.name}}</td>
                  <td>{{u.position}}</td>
                </tr>
              </table>
            </div>
            <div v-else>
              Are you sure you want to inactivate this plan?
            </div>
          </MultiOptionDialog>
          <v-btn color="primary" v-if="overrideId && override && userCanAdd" @click="showCloneDialog=true">Clone</v-btn>
          <ConfirmationDialog
              :open-dialog="showCloneDialog"
              @confirm="validateStartDates"
              @@close-dialog="[showCloneDialog=false, cloneStartDate=null]"
              :disable-confirm="(override.assignedUsers.filter(u => u.selected).length > 0 && !cloneStartDate) ||
                             (override.assignedUsers.filter(u => u.selected).length === 0 && cloneStartDate != null)"
          >
            <template v-slot:title>{{cloneDialogTitle}}</template>
            <div class="mb-2">
                This option allows you to copy an entire plan over. <br/>
                By default, no users are copied over.
              </div>
              Receiving Users to Copy:
              <div v-for="u in override.receivingUsers">
                <input type="checkbox" class="mr-2" v-model="u.selected">
                {{ u.name }}
              </div>
              <div class="mt-3">
                Assigned Users to Copy:
                <div v-for="u in override.assignedUsers">
                  <input type="checkbox" class="mr-2" v-model="u.selected">
                  {{ u.name }}: {{u.startDate | formatDate('date')}}
                </div>
                <div class="mt-3" v-if="override.assignedUsers && override.assignedUsers.filter(u => u.selected).length > 0">
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
              </div>
            <template v-slot:no>cancel</template>
            <template v-slot:yes>clone</template>
          </ConfirmationDialog>
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
    <v-form ref="overrideForm">
      <v-container>
        <v-row>
          <v-col cols="12" sm="6">
            <v-card flat class="pa-3" color="transparent">
              <v-text-field text
                            label="Name"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="override.name"></v-text-field>
              <v-text-field text
                            label="Description"
                            :readonly="!userCanEdit"
                            :disabled="!userCanEdit"
                            v-model="override.description"></v-text-field>
              <v-select attach v-model="override.positionId"
                        :items="positions"
                        :readonly="!userCanEdit"
                        :disabled="override.id != null || !userCanEdit"
                        no-data-text="No Users Available"
                        label="Position Type"
                        item-text="label"
                        item-value="id"
              ></v-select>
              <v-text-field text
                            :readonly="!userCanEdit"
                            :disabled="(override.id && override.status !== 'PENDING') || !userCanEdit"
                            :label="payRateText"
                            v-model="override.total"></v-text-field>

              <div v-if="customFieldGroups.length > 0">
                <CustomValueInput
                  v-for="item in customFieldGroups[0].customFieldValues"
                  :callback="(item) => updateDirtyValue(item)"
                  :readonly="!userCanEdit"
                  :showFieldName="false"
                  :field="item"
                />
              </div>
            </v-card>
          </v-col>
          <v-col cols="12" sm="6">
            <v-card class="pa-3" v-if="overrideId">
              <v-text-field text
                            label="Status"
                            disabled
                            v-model="override.status"></v-text-field>
              <v-text-field text
                            v-if="override.createdBy"
                            disabled
                            label="Created By"
                            v-model="override.createdBy.name"></v-text-field>
              <v-text-field text
                            disabled
                            v-if="override.approved"
                            label="Approved"
                            v-model="override.approved"></v-text-field>
              <v-text-field text
                            disabled
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
            Receiving Overrides
          </v-toolbar-title>
          <v-spacer></v-spacer>
          <v-toolbar-items>
            <v-btn text color="primary" v-if="override.status === 'PENDING'" @click="addReceivingUser = !addReceivingUser">
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
                            autocomplete="off"
                            attach>
            </v-autocomplete>
            <v-text-field text
                          type="number"
                          label="M1 Allocation"
                          v-model="newReceivingUser.m1Allocation">
            </v-text-field>
          <v-text-field text
                        v-if="positionId === 1"
                        type="number"
                        label="M2 Allocation"
                        v-model="newReceivingUser.m2Allocation">
          </v-text-field>
            <v-btn color="primary" class="mr-3 white--text" @click="addReceivingUserToOverride()"
                   :disabled="!newReceivingUser.userId">
              Add
            </v-btn>
        </v-card>
        <v-divider v-if="addAssignedUser"></v-divider>
        <v-data-table
            :headers="visibleReceivingHeaders"
            :items="override.receivingUsers"
            :fixed-header="true"
            :items-per-page="-1"
            disable-sort
            :loading="dataLoading"
            single-expand
            item-key="userId"
            :expanded.sync="expanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
          </template>

          <template #expanded-item="{ headers, item }">
            <td :colspan="headers.length" class="pa-4 text-left">
              <v-text-field text
                            type="number"
                            label="M1 Allocation"
                            v-model.number="item.m1Allocation">
              </v-text-field>
              <v-text-field text
                            v-if="positionId === 1"
                            type="number"
                            label="M2 Allocation"
                            v-model.number="item.m2Allocation">
              </v-text-field>
              <v-btn color="primary" :disabled="!item.m1Allocation || (positionId === 1 && !item.m2Allocation)"
                     @click="[expanded = [], updateReceivingUser(item)]">Save</v-btn>
            </td>
          </template>

          <template #item="{ item, index }">
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.m1Allocation}}</td>
              <td class="text-left" v-if="positionId !== 4">{{item.m2Allocation}}</td>
              <td>
                <v-btn small text color="primary" @click="expanded = [item]"
                       v-if="override.status === 'PENDING' && !expanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text color="primary" @click="expanded = []"
                       v-if="expanded.includes(item)">
                  cancel
                </v-btn>
                <v-btn color="primary" text @click="openDeleteDialog(item, deleteTypes.RECEIVING)">
                  <v-icon>delete</v-icon>
                </v-btn>
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
            <v-btn text color="primary" v-if="userCanAdd"
                   @click="[addAssignedUser = !addAssignedUser, newAssignedUser = {}, userHistory = []]">
              <v-icon v-if="addAssignedUser">remove</v-icon>
              <v-icon v-else>add</v-icon>
            </v-btn>
          </v-toolbar-items>
        </v-toolbar>
        <v-divider></v-divider>
        <v-card v-if="addAssignedUser" class="square-card text-left px-5 pb-5">
          <div v-if="!override.positionId">
            You must selected a Position Type.
          </div>
          <div v-else>
            <v-row>
              <v-col cols="12" md="6">
                <v-autocomplete v-model="newAssignedUser.userId"
                                :items="assignedUsersToAdd"
                                :loading="assignedUsersLoading"
                                prepend-icon="search"
                                :search-input.sync="assignedUserSearch"
                                label="Search for a user..."
                                item-text="name"
                                item-value="userId"
                                autocomplete="off"
                                @input="getUserHistory(newAssignedUser.userId)"
                                attach
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
                  :readonly="!newAssignedUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newAssignedUser.startDate, newAssignedUser.endDate, userHistory, newAssignedUser)"
                />
                <DatetimePickerInput
                  v-model="newAssignedUser.endDate"
                  :timezone="this.timezone"
                  :type="'date'"
                  :format="'MMMM DD, YYYY'"
                  label="End Date"
                  :readonly="!newAssignedUser.userId || errorLoadingUserHistory"
                  @input="checkDates(newAssignedUser.startDate, newAssignedUser.endDate, userHistory, newAssignedUser)"
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
            <div v-if="newAssignedUser.dateError" class="error--text mb-2">
              * Error: {{newAssignedUser.dateErrorMsg}}
            </div>
            <div class="mb-2" v-else-if="newAssignedUser.showNote">
              {{newAssignedUser.noteMsg}}
            </div>
            <v-btn color="primary" class="mr-3 white--text" @click="addAssignedUserToOverride()"
                   :disabled="newAssignedUser.dateError || !newAssignedUser.userId || !newAssignedUser.startDate || errorLoadingUserHistory">
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
            single-expand
            :expanded.sync="assignedUserExpanded"
            hide-default-footer
            class="elevation-1"
        >
          <template #no-data>
            <span class="default-text-color">No available users</span>
          </template>

          <template #no-results>
            <span class="default-text-color">No available users</span>
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
                    @input="checkDates(item.startDate, item.endDate, userHistory, item, override.id)"
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
            <tr class="clickable" :class="{'shaded-row': index % 2}">
              <td class="text-left">{{item.name}}</td>
              <td class="text-left">{{item.employeeId}}</td>
              <td class="text-left">{{item.startDate}}</td>
              <td class="text-left">{{item.endDate}}</td>
              <td>
                <v-btn small text color="primary" @click="[assignedUserExpanded = [item], getUserHistory(item.userId)]"
                       v-if="override.status === 'PENDING' && !assignedUserExpanded.includes(item)">
                  <v-icon>edit</v-icon>
                </v-btn>
                <v-btn small text @click="assignedUserExpanded = []"
                       v-if="assignedUserExpanded.includes(item)">cancel
                </v-btn>
                <v-btn
                  v-if="override.status === 'PENDING'"
                  small text color="primary" @click="openDeleteDialog(item, deleteTypes.ASSIGNED)">
                  <v-icon>delete</v-icon>
                </v-btn>
              </td>
            </tr>
          </template>
        </v-data-table>
      </v-col>
    </v-row>
    <ConfirmationDialog :open-dialog="showDeleteDialog" @confirm="deleteConfirmed" @close-dialog="closeDeleteDialog">
      <div v-if="deleteType==deleteTypes.OVERRIDE">Are you sure you want to delete this plan?</div>
      <div v-else>Are you sure you want to delete <strong>{{itemToDeleteName}}</strong>?</div>

    </ConfirmationDialog>
  </v-container>
</template>

<script>
  import {AppMutations} from '@/stores/AppStore'
  import CustomValueInput from '@/views/flow/components/CustomValueInput.vue'
  import Vue2Filters from 'vue2-filters'
  import moment from 'moment'
  import DatetimePickerInput from '@/components/DatetimePickerInput.vue'
  import ProjectAssignmentModal from "@/views/blueraven/commissionManagement/ProjectAssignmentModal";
  import {handleHidingGlobalLoader, getRequest, deleteRequest, postRequestWithRequestParams, postRequest, getSnackbar, getRequestWithParams} from '@/helpers/helpers'
  import ConfirmationDialog from "@/components/ConfirmationDialog";
  import MultiOptionDialog from "@/components/MultiOptionDialog";

  const deleteTypes={
    OVERRIDE:0,
    RECEIVING:1,
    ASSIGNED:2
  }

  export default {
    name: 'Override',
    mixins: [Vue2Filters.mixin],
    components: {
      MultiOptionDialog,
      ConfirmationDialog,
      CustomValueInput,
      DatetimePickerInput,
      ProjectAssignmentModal
    },
    created() {
      if(this.overrideId) {
        this.getOverrideDetails()
      } else {
        this.dataLoading = false
      }
    },
    computed: {
      visibleReceivingHeaders() {
        return this.receivingHeaders.filter(header => header.show === true)
      },
      itemToDeleteName() {
        return this.itemToDelete ? this.itemToDelete.name : ''
      },
      cloneDialogTitle(){
        return this.override ? `Clone ${this.override.name}` : "Clone"
      },
      inactivateOptions(){
        return this.planHasActiveUsers() ? [] : ['inactivate']
      }
    },
    watch: {
      '$store.state.brs.commissionPositionId': function () {
        //they can't switch between Setter/Closer while on an actual override plan
        this.$router.push(`/commissionManagement/overrides`)
      },
      $route(to) {
        // react to route changes...
        // this.$router.push({name: 'commission', params: {id: to.params.id}})
        // this.planId = to.params.id
        this.overrideId = to.params.id
        this.getOverrideDetails()
      },
      assignedUserSearch (val) {
        if(!val) {
          this.newAssignedUser.userId = null
          this.assignedUsersToAdd = []
          return
        }
        this.assignedUsersToAdd = []
        this.getAssignedUsersDebounced(val)
      },
      receivingUserSearch (val) {
        if(!val) {
          this.receivingUsersToAdd = []
          this.newReceivingUser.userId = null
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
        showProjectAssignmentModal: false,
        moment,
        positionId: this.$store.state.brs.commissionPositionId,
        payRateText: this.$store.state.brs.commissionPositionId === 4 ? 'Base Pay' : 'Rate per kW ($)',
        cloneStartDate: null,
        userCanAdd: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADD'),
        userCanEdit: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'EDIT'),
        userIsAdmin: this.$store.getters.userHasFeatureAccessLevel('COMMISSIONS', 'ADMIN'),
        cloneDateError: false,
        timezone: this.$store.state.user.details.timezone.value,
        inactivateConfirm: false,
        deleteConfirm: false,
        overrideId: this.$route.params.id,
        expanded: [],
        assignedUserExpanded: [],
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
          {text: 'M2 Allocation', value: 'm2Allocation', show: this.$store.state.brs.commissionPositionId !== 4},
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
        addReceivingUser: false,
        receivingUsersLoading: false,
        newReceivingUser: {
          m1Allocation: 0,
          m2Allocation: 0,
        },
        errorLoadingUserHistory: false,
        historyHeaders: [
          {text: 'Name', value: 'planName', show: true},
          {text: 'Start Date', value: 'startDate', show: true},
          {text: 'End Date', value: 'endDate', show: true},
        ],
        receivingUsersToAdd: [],
        receivingUserSearch: null,
        errorMessages: [],
        userHistory: [],
        customFieldGroups: [],
        showDeleteDialog: false,
        itemToDelete: null,
        deleteType: null,
        deleteTypes,
        showCloneDialog: false
      }
    },
    methods: {
      updateDirtyValue(item) {
        item.valueWasChanged = true
        this.dataWasChanged = true
      },
      async getCustomFieldGroups() {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const params = {sourceId: this.overrideId, objectTypeId: 9}
          const {data, status} = await getRequestWithParams(`/customFieldGroup/getCustomFieldGroupAssignmentsByObjectType`, {params}, 'blueraven')
          this.customFieldGroups = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error retrieving custom fields')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getOverrideDetails () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.override = data
          this.getCustomFieldGroups()
          this.dataLoading = false
          this.checkErrorMessages()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Loading Override Details')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      checkErrorMessages () {
        this.errorMessages = []
        //sum of all m1 and m2's should equal rate per kw$ (or base pay for setter)
        let sum = 0
        this.override?.receivingUsers?.forEach(ru => {
          sum += ru.m1Allocation + ru.m2Allocation
        })
        if(sum !== this.override.total) {
          this.errorMessages.push(`The sum of all milestone allocations must equal the ${this.payRateText}. `)
        }
      },
      planHasActiveUsers () {
        let hasActive = false
        this.override?.assignedUsers?.forEach(u => {
          if(u.endDate === null || u.endDate > new Date()){
            hasActive = true
          }
        })
        return hasActive
      },
      activeUsers () {
        return this.override?.assignedUsers?.filter(u => {
          return u.endDate === null || u.endDate > new Date()
        })
      },
      // goToDetails (item) {
      // },
      async deleteOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await deleteRequest(`/commissionManagement/overrides/${this.overrideId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Override Plan')
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async cloneOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            receivingUsers: this.override?.receivingUsers?.filter(u => u.selected).map(u => u.userId),
            assignedUsers: this.override?.assignedUsers?.filter(u => u.selected).map(u => u.userId),
            startDate: this.cloneStartDate,
            backdateApprovalCreds: null
          }
          const {data} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/clone`, params, 'blueraven')
          this.$router.push({name: 'override', params: {id: data.id}})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Cloning Override Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async getUserHistory(userId) {
        //reset the rest of the new user fields if they change users
        delete this.newAssignedUser.startDate
        delete this.newAssignedUser.endDate
        this.newAssignedUser.dateError = false
        this.newAssignedUser.dateErrorMsg = ''
        this.newAssignedUser.showNote = false
        this.newAssignedUser.noteMsg = ''
        this.errorLoadingUserHistory = false
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await getRequest(`/commissionManagement/overrides/assignedUsers/${userId}/history`, 'blueraven')
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
      validateStartDates() {
        //this is used when cloning users
        this.cloneDateError = false
        this.override?.assignedUsers?.forEach(u => {
          if(u.selected && u.startDate >= this.cloneStartDate) {
            this.cloneDateError = true
          }
        })

        if(!this.cloneDateError) {
          this.cloneOverride()
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
        let valueToCheck = plan.planId ?? plan.id
        //this will not allow them to go back in time to add plans before existing plans which seems to be ok
        if(valueToCheck === existingId) {
          // ignore overlap check for self on existing record
          return false
        } else {
          //this is used when adding a new plan
          return start <= plan.startDate || start <= plan.endDate
        }
      },
      async saveOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          let params = {
            name: this.override.name,
            description: this.override.description,
            positionId: this.override.positionId,
            total: this.override.total,
            id: this.override.id,
            customFieldGroups: this.customFieldGroups
          }
          const {data, status} = await postRequest(`/commissionManagement/overrides`, params, 'blueraven')
          if(!this.overrideId) {
            //need to reload some stuff if this was a new plan
            this.$router.push({name: 'override', params: {id: data.id}})
          }
          this.checkErrorMessages()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Override Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async approveOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {data, status} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/approve`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Approved')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.override = data
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Approving Override Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async inactivateOverride () {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          await postRequest(`/commissionManagement/overrides/${this.overrideId}/inactivate`, {}, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Override Plan Inactivated')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$router.push({name: 'overrides'})
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Inactivating Override Plan')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
      },
      async updateAssignedUser(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/commissionManagement/overrides/${this.overrideId}/updateUser`, item, 'blueraven')
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
      getAssignedUsersDebounced(val) {
        clearTimeout(this._searchTimerId)
        this._searchTimerId = setTimeout(() => {
          this.getAssignedUsers(val)
        }, 500) /* 500ms throttle */
      },
      async getAssignedUsers(query) {
        if(this.addAssignedUser) {
          this.assignedUsersLoading = true
          try {
            let params = {
              positionId: this.override.positionId,
              query,
              planId: this.override.id,
              isReceiving: false
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            this.assignedUsersToAdd = data
            this.assignedUsersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Override Plan Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
            const {data} = await postRequestWithRequestParams(`/commissionManagement/overrides/${this.override.id}/assignedUsers/${this.override.positionId}`, params, { addUserToPlan: true }, 'blueraven')
            this.override.assignedUsers = data
            this.newAssignedUser = {}
            this.assignedUserSearch = null
            this.addAssignedUser = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Assigning User')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async deleteAssignedUser () {
        const assignedUserId = this.itemToDelete.id
        console.log(assignedUserId)
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/commissionManagement/overrides/${this.overrideId}/assignedUsers/${assignedUserId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Assigned User Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.override.assignedUsers = this.override.assignedUsers.filter(au => {
            return au.id !== assignedUserId
          })
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Assigned User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
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
        if(this.addReceivingUser) {
          this.receivingUsersLoading = true
          try {
            let params = {
              query,
              planId: this.override.id,
              isReceiving: true,
              positionId: this.override.positionId
            }
            const {data} = await getRequestWithParams(`/commissionManagement/overrides/_search`, {params}, 'blueraven')
            this.receivingUsersToAdd = data
            this.receivingUsersLoading = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Retrieving Receiving Override Users')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async updateReceivingUser(item) {
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await postRequest(`/commissionManagement/overrides/${this.override.id}/receivingUser`, item, 'blueraven')
          this.checkErrorMessages()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Saving Receiving User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
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
            this.checkErrorMessages()
            this.newReceivingUser = {
              m1Allocation: 0,
              m2Allocation: 0
            }
            this.receivingUserSearch = null
            this.addReceivingUser = false
          } catch (e) {
            console.error('*** ERROR ***', e)
            this.snackbar = getSnackbar('ERROR', 'Error Adding Receiving User')
            this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
            this.$store.commit(AppMutations.SET_LOADING, false)
          }
        }
      },
      async deleteReceivingUser () {
        const receivingUserId = this.itemToDelete.userId
        this.$store.commit(AppMutations.SET_LOADING, true)
        try {
          const {status} = await deleteRequest(`/commissionManagement/overrides/${this.overrideId}/receivingUsers/${receivingUserId}`, 'blueraven')
          this.snackbar = getSnackbar('SUCCESS', 'Receiving User Deleted')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.override.receivingUsers = this.override.receivingUsers.filter(au => {
            return au.userId !== receivingUserId
          })
          this.checkErrorMessages()
          handleHidingGlobalLoader(this, status)
        } catch (e) {
          console.error('*** ERROR ***', e)
          this.snackbar = getSnackbar('ERROR', 'Error Deleting Receiving User')
          this.$store.commit(AppMutations.SHOW_SNACK, this.snackbar)
          this.$store.commit(AppMutations.SET_LOADING, false)
        }
        this.closeDeleteDialog()
      },
      deleteConfirmed(){
        console.log("deleteConfirmed")
        switch (this.deleteType){
          case deleteTypes.OVERRIDE:
            this.deleteOverride()
            break
          case deleteTypes.RECEIVING:
            this.deleteReceivingUser()
            break
          case deleteTypes.ASSIGNED:
            this.deleteAssignedUser()
            break
          default:
        }
        this.closeDeleteDialog()
      },
      openDeleteDialog(item, type) {
        this.itemToDelete = item
        this.deleteType=type
        this.showDeleteDialog = true
      },
      closeDeleteDialog(){
        this.showDeleteDialog = false
        this.itemToDelete = null
        this.deleteType=null
      }
    }
  }
</script>

<style lang="scss" scoped>
.v-data-table {
  border-radius: 0;
}
</style>

